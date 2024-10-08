<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\ConfigDiscovery;

use function file_get_contents;
use function is_dir;
use function is_file;
use function preg_match;
use function sprintf;

/**
 * @internal
 */
abstract class AbstractDiscovery implements DiscoveryInterface
{
    /**
     * Configuration file to look for.
     *
     * Implementations MUST overwrite this.
     *
     * @var non-empty-string
     */
    protected string $configFile = 'to-be-overridden';

    /**
     * Expected pattern to match if the configuration file exists.
     *
     * Implementations MUST overwrite this.
     *
     * @var non-empty-string
     */
    protected string $expected = 'to-be-overridden';

    /**
     * Optionally specify project directory; $configFile will be relative to
     * this value.
     */
    public function __construct(string $projectDirectory = '')
    {
        if ('' !== $projectDirectory && is_dir($projectDirectory)) {
            $this->configFile = sprintf(
                '%s/%s',
                $projectDirectory,
                $this->configFile
            );
        }
    }

    /**
     * Determine if the configuration file exists and contains modules.
     */
    public function locate(): bool
    {
        if (! is_file($this->configFile)) {
            return false;
        }

        $config = file_get_contents($this->configFile);
        return 1 === preg_match($this->expected, $config);
    }
}
