<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\Injector;

use Laminas\ComponentInstaller\ConfigDiscovery\DiscoveryInterface;

use function str_replace;

/**
 * @internal
 *
 * @psalm-require-extends AbstractInjector
 */
trait ConditionalDiscoveryTrait
{
    public function inject(string $package, int $type): bool
    {
        if (! $this->validConfigAggregatorConfig()) {
            return false;
        }

        /** @psalm-suppress ArgumentTypeCoercion Psalm has issues with trait inheritance and type parsing. */
        return parent::inject('\\' . $package, $type);
    }

    public function remove(string $package): bool
    {
        if (! $this->validConfigAggregatorConfig()) {
            return false;
        }

        return parent::remove('\\' . $package);
    }

    /**
     * Does the config file hold valid ConfigAggregator configuration?
     */
    private function validConfigAggregatorConfig(): bool
    {
        $discoveryClass = $this->getDiscoveryClass();
        $discovery      = new $discoveryClass($this->getProjectRoot(), $this->configFile);
        return $discovery->locate();
    }

    /**
     * Calculate the project root from the config file
     */
    private function getProjectRoot(): string
    {
        $configFile = $this->getConfigFile();
        if ($this->getDefaultConfigFile() === $configFile) {
            return '';
        }

        return str_replace('/' . $this->getDefaultConfigFile(), '', $configFile);
    }

    abstract protected function getDefaultConfigFile(): string;

    /**
     * @return class-string<DiscoveryInterface>
     */
    abstract protected function getDiscoveryClass(): string;
}
