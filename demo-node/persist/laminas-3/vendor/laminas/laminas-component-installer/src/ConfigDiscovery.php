<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller;

use Laminas\ComponentInstaller\ConfigDiscovery\DiscoveryChainInterface;
use Laminas\ComponentInstaller\Injector\InjectorInterface;

use function is_array;

/**
 * @internal
 */
final class ConfigDiscovery
{
    /**
     * Map of known configuration files and their locators.
     */
    private const DISCOVERY = [
        'config/application.config.php'      => ConfigDiscovery\ApplicationConfig::class,
        'config/modules.config.php'          => ConfigDiscovery\ModulesConfig::class,
        'config/development.config.php.dist' => [
            'dist'        => ConfigDiscovery\DevelopmentConfig::class,
            'work'        => ConfigDiscovery\DevelopmentWorkConfig::class,
            'mezzio-dist' => ConfigDiscovery\MezzioDevelopmentConfig::class,
            'mezzio-work' => ConfigDiscovery\MezzioDevelopmentWorkConfig::class,
        ],
        'config/config.php'                  => [
            'aggregator' => ConfigDiscovery\ConfigAggregator::class,
            'manager'    => ConfigDiscovery\MezzioConfig::class,
        ],
    ];

    /**
     * Map of config files to injectors
     */
    private const INJECTORS = [
        'config/application.config.php'      => Injector\ApplicationConfigInjector::class,
        'config/modules.config.php'          => Injector\ModulesConfigInjector::class,
        'config/development.config.php.dist' => [
            'dist'        => Injector\DevelopmentConfigInjector::class,
            'work'        => Injector\DevelopmentWorkConfigInjector::class,
            'mezzio-dist' => Injector\MezzioDevelopmentConfigInjector::class,
            'mezzio-work' => Injector\MezzioDevelopmentWorkConfigInjector::class,
        ],
        'config/config.php'                  => [
            'aggregator' => Injector\ConfigAggregatorInjector::class,
            'manager'    => Injector\MezzioConfigInjector::class,
        ],
    ];

    /**
     * Return a list of available configuration options.
     *
     * @template TKey of array-key
     * @param Collection<TKey,InjectorInterface::TYPE_*> $availableTypes Collection of injector type
     *     constants indicating valid package types that could be injected.
     * @param string $projectRoot Path to the project root; assumes PWD by default.
     * @return Collection<int,ConfigOption> Collection of ConfigOption instances.
     */
    public function getAvailableConfigOptions(Collection $availableTypes, string $projectRoot = ''): Collection
    {
        $options = (new Collection(self::DISCOVERY))
            // Create a discovery class for the discovery type
            ->map(
                static function ($discoveryClass) use ($projectRoot): DiscoveryChainInterface {
                    if (! is_array($discoveryClass)) {
                        $discoveryClass = ['generic' => $discoveryClass];
                    }

                    return new ConfigDiscovery\DiscoveryChain($discoveryClass, $projectRoot);
                }
            )
            // Use only those where we can locate a corresponding config file
            ->filter(static fn(DiscoveryChainInterface $discovery) => $discovery->locate())
            // Create an injector for the config file
            ->map(function (DiscoveryChainInterface $discovery, string $file) use ($projectRoot, $availableTypes) {
                // Look up the injector based on the file type
                $injectorClass = self::INJECTORS[$file];
                if (is_array($injectorClass)) {
                    return new Injector\ConfigInjectorChain(
                        $injectorClass,
                        $discovery,
                        $availableTypes,
                        $projectRoot
                    );
                }
                return new $injectorClass($projectRoot);
            })
            // Keep only those injectors that match types available for the package
            ->filter(static fn($injector) => $availableTypes->anySatisfies(
                static fn($type) => $injector->registersType($type)
            ))
            // Create a config option using the file and injector
            ->map(static fn ($injector, $file) => new ConfigOption($file, $injector))
            ->toOrderedCollection();

        if ($options->isEmpty()) {
            return new Collection([]);
        }

        return new Collection([
            new ConfigOption('Do not inject', new Injector\NoopInjector()),
            ...$options->toArray(),
        ]);
    }
}
