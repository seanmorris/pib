<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\Injector;

use Laminas\ComponentInstaller\Exception;

/**
 * @internal
 *
 * @todo add getConfigFile() method in 2.0
 */
interface InjectorInterface
{
    public const TYPE_CONFIG_PROVIDER    = 0;
    public const TYPE_COMPONENT          = 1;
    public const TYPE_MODULE             = 2;
    public const TYPE_DEPENDENCY         = 3;
    public const TYPE_BEFORE_APPLICATION = 4;

    /**
     * Whether or not the injector can handle the given type.
     *
     * @param InjectorInterface::TYPE_* $type
     */
    public function registersType(int $type): bool;

    /**
     * Return a list of types the injector handles.
     *
     * @return list<InjectorInterface::TYPE_*>
     */
    public function getTypesAllowed(): array;

    /**
     * Is a given package already registered?
     *
     * @param non-empty-string $package
     */
    public function isRegistered(string $package): bool;

    /**
     * Register a package with the configuration.
     *
     * @param non-empty-string $package Package to inject into configuration.
     * @param InjectorInterface::TYPE_* $type
     * @throws Exception\RuntimeException
     */
    public function inject(string $package, int $type): bool;

    /**
     * Remove a package from the configuration.
     *
     * @param non-empty-string $package Package to remove.
     * @throws Exception\RuntimeException
     */
    public function remove(string $package): bool;

    /**
     * Set modules of the application.
     *
     * @param list<non-empty-string> $modules
     */
    public function setApplicationModules(array $modules): self;

    /**
     * Create an injector for  dependencies for the module.
     *
     * @param list<non-empty-string> $modules
     */
    public function setModuleDependencies(array $modules): self;
}
