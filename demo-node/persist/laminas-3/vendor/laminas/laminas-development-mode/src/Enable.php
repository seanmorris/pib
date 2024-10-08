<?php

declare(strict_types=1);

namespace Laminas\DevelopmentMode;

use RuntimeException;

use function basename;
use function copy;
use function file_exists;
use function fwrite;
use function in_array;
use function is_resource;
use function sprintf;
use function symlink;

use const PHP_EOL;
use const PHP_OS;
use const STDERR;

class Enable
{
    use ConfigDiscoveryTrait;

    public const DEVEL_CONFIG      = 'config/development.config.php';
    public const DEVEL_CONFIG_DIST = 'config/development.config.php.dist';
    public const DEVEL_LOCAL       = 'config/autoload/development.local.php';
    public const DEVEL_LOCAL_DIST  = 'config/autoload/development.local.php.dist';

    /** @var resource */
    private $errorStream;

    /**
     * @param string $projectDir Location to resolve project from.
     * @param null|resource $errorStream Stream to which to write errors; defaults to STDERR
     */
    public function __construct(private $projectDir = '', $errorStream = null)
    {
        $this->errorStream = is_resource($errorStream) ? $errorStream : STDERR;
    }

    /**
     * Enable development mode.
     *
     * @return int
     */
    public function __invoke()
    {
        $develConfig = $this->projectDir
            ? sprintf('%s/%s', $this->projectDir, self::DEVEL_CONFIG)
            : self::DEVEL_CONFIG;
        if (file_exists($develConfig)) {
            // nothing to do
            echo 'Already in development mode!', PHP_EOL;
            return 0;
        }

        $develConfigDist = $this->projectDir
            ? sprintf('%s/%s', $this->projectDir, self::DEVEL_CONFIG_DIST)
            : self::DEVEL_CONFIG_DIST;
        if (! file_exists($develConfigDist)) {
            fwrite(
                $this->errorStream,
                'MISSING "config/development.config.php.dist". Could not switch to development mode!' . PHP_EOL
            );
            return 1;
        }

        try {
            $this->removeConfigCacheFile();
        } catch (RuntimeException $ex) {
            fwrite($this->errorStream, $ex->getMessage());
            return 1;
        }

        $this->copy($develConfigDist, $develConfig);

        $develLocalDist = $this->projectDir
            ? sprintf('%s/%s', $this->projectDir, self::DEVEL_LOCAL_DIST)
            : self::DEVEL_LOCAL_DIST;
        if (file_exists($develLocalDist)) {
            // optional application config override
            $develLocal = $this->projectDir
                ? sprintf('%s/%s', $this->projectDir, self::DEVEL_LOCAL)
                : self::DEVEL_LOCAL;
            $this->copy($develLocalDist, $develLocal);
        }

        echo 'You are now in development mode.', PHP_EOL;
        return 0;
    }

    /**
     * Returns whether the OS support symlinks reliably.
     *
     * This approach uses a pre-configured whitelist of PHP_OS values that
     * typically support symlinks reliably. This may omit some systems that
     * also support symlinks properly; if you find this to be the case, please
     * send a pull request with the PHP_OS value for us to match.
     *
     * This method is marked protected so that we can mock it.
     *
     * @return bool
     */
    protected function supportsSymlinks()
    {
        return in_array(PHP_OS, ['Linux', 'Unix', 'Darwin']);
    }

    /**
     * Copy, or symlink, the source to the destination.
     *
     * @param string $source
     * @param string $destination
     * @return void
     */
    private function copy($source, $destination)
    {
        if ($this->supportsSymlinks()) {
            symlink(basename($source), $destination);
            return;
        }

        copy($source, $destination);
    }
}
