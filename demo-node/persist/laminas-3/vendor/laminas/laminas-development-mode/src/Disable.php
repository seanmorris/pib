<?php

declare(strict_types=1);

namespace Laminas\DevelopmentMode;

use RuntimeException;

use function file_exists;
use function fwrite;
use function is_resource;
use function sprintf;
use function unlink;

use const PHP_EOL;
use const STDERR;

class Disable
{
    use ConfigDiscoveryTrait;

    public const DEVEL_CONFIG = 'config/development.config.php';
    public const DEVEL_LOCAL  = 'config/autoload/development.local.php';

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
     * Disable development mode.
     *
     * @return int
     */
    public function __invoke()
    {
        $develConfig = $this->projectDir
            ? sprintf('%s/%s', $this->projectDir, self::DEVEL_CONFIG)
            : self::DEVEL_CONFIG;
        if (! file_exists($develConfig)) {
            // nothing to do
            echo 'Development mode was already disabled.', PHP_EOL;
            return 0;
        }

        try {
            $this->removeConfigCacheFile();
        } catch (RuntimeException $ex) {
            fwrite($this->errorStream, $ex->getMessage());
            return 1;
        }

        $develLocalConfig = $this->projectDir
            ? sprintf('%s/%s', $this->projectDir, self::DEVEL_LOCAL)
            : self::DEVEL_LOCAL;
        if (file_exists($develLocalConfig)) {
            // optional application config override
            unlink($develLocalConfig);
        }

        unlink($develConfig);

        echo 'Development mode is now disabled.', PHP_EOL;
        return 0;
    }
}
