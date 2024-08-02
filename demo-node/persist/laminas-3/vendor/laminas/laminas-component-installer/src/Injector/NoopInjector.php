<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\Injector;

/**
 * @internal
 */
final class NoopInjector implements InjectorInterface
{
    /**
     * {@inheritDoc}
     *
     * @param int $type
     * @return true
     */
    public function registersType(int $type): bool
    {
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public function getTypesAllowed(): array
    {
        return [];
    }

    /**
     * @param non-empty-string $package
     */
    public function isRegistered(string $package): bool
    {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public function inject(string $package, int $type): bool
    {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public function remove(string $package): bool
    {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public function setApplicationModules(array $modules): self
    {
        return $this;
    }

    /**
     * {@inheritDoc}
     */
    public function setModuleDependencies(array $modules): self
    {
        return $this;
    }
}
