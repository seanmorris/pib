<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\Injector;

/**
 * @internal
 */
final class MezzioDevelopmentWorkConfigInjector implements InjectorInterface
{
    private const CONFIG_FILE = 'config/development.config.php';

    private ConfigAggregatorInjector $injector;

    public function __construct(string $projectRoot)
    {
        $this->injector = new ConfigAggregatorInjector($projectRoot, self::CONFIG_FILE);
    }

    public function registersType(int $type): bool
    {
        return $this->injector->registersType($type);
    }

    public function getTypesAllowed(): array
    {
        return $this->injector->getTypesAllowed();
    }

    public function isRegistered(string $package): bool
    {
        return $this->injector->isRegistered($package);
    }

    public function inject(string $package, int $type): bool
    {
        return $this->injector->inject($package, $type);
    }

    public function remove(string $package): bool
    {
        return $this->injector->remove($package);
    }

    public function setApplicationModules(array $modules): InjectorInterface
    {
        return $this->injector->setApplicationModules($modules);
    }

    public function setModuleDependencies(array $modules): InjectorInterface
    {
        return $this->injector->setModuleDependencies($modules);
    }
}
