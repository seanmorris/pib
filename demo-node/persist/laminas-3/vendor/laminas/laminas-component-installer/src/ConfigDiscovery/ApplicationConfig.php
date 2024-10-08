<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\ConfigDiscovery;

/**
 * @internal
 */
final class ApplicationConfig extends AbstractDiscovery
{
    /**
     * Configuration file to look for.
     *
     * @var non-empty-string
     */
    protected string $configFile = 'config/application.config.php';

    /**
     * Expected pattern to match if the configuration file exists.
     *
     * @var non-empty-string
     */
    protected string $expected = '/^(\s+)(\'modules\'\s*\=\>\s*(array\(|\[))\s*$/m';

    /**
     * @param non-empty-string|null $configFile
     */
    public function __construct(string $projectDirectory = '', ?string $configFile = null)
    {
        $this->configFile = $configFile ?? $this->configFile;
        parent::__construct($projectDirectory);
    }
}
