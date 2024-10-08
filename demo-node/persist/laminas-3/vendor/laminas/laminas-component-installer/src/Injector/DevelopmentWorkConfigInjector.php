<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\Injector;

/**
 * @internal
 */
final class DevelopmentWorkConfigInjector implements InjectorInterface
{
    private const CONFIG_FILE = 'config/development.config.php';

    protected InjectorInterface $applicationInjector;

    public function __construct(string $projectRoot = '')
    {
        $this->applicationInjector = new ApplicationConfigInjector($projectRoot, self::CONFIG_FILE);
    }

    public function registersType(int $type): bool
    {
        return $this->applicationInjector->registersType($type);
    }

    public function getTypesAllowed(): array
    {
        return $this->applicationInjector->getTypesAllowed();
    }

    public function isRegistered(string $package): bool
    {
        return $this->applicationInjector->isRegistered($package);
    }

    public function inject(string $package, int $type): bool
    {
        return $this->applicationInjector->inject($package, $type);
    }

    public function remove(string $package): bool
    {
        return $this->applicationInjector->remove($package);
    }

    public function setApplicationModules(array $modules): InjectorInterface
    {
        return $this->applicationInjector->setApplicationModules($modules);
    }

    public function setModuleDependencies(array $modules): InjectorInterface
    {
        return $this->applicationInjector->setModuleDependencies($modules);
    }
}
