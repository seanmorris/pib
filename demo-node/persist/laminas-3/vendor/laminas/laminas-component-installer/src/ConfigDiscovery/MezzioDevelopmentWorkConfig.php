<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\ConfigDiscovery;

/**
 * @internal
 */
final class MezzioDevelopmentWorkConfig implements DiscoveryInterface
{
    private const CONFIG_FILE = 'config/development.config.php';

    private ConfigAggregator $discovery;

    public function __construct(string $projectDirectory = '')
    {
        $this->discovery = new ConfigAggregator($projectDirectory, self::CONFIG_FILE);
    }

    public function locate(): bool
    {
        return $this->discovery->locate();
    }
}
