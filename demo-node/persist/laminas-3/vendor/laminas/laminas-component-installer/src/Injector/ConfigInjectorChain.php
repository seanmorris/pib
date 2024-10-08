<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\Injector;

use Laminas\ComponentInstaller\Collection;
use Laminas\ComponentInstaller\ConfigDiscovery\DiscoveryChainInterface;

use function array_merge;
use function array_unique;
use function array_values;
use function assert;
use function in_array;
use function is_bool;

/**
 * @internal
 */
final class ConfigInjectorChain implements InjectorInterface
{
    /**
     * ConfigInjectors Collection
     *
     * @var Collection<string,InjectorInterface>
     */
    private Collection $chain;

    /**
     * Types this injector is allowed to register.
     *
     * Implementations MAY overwrite this value.
     *
     * @var list<InjectorInterface::TYPE_*>
     */
    private array $allowedTypes = [];

    /**
     * Optionally accept the project root directory; if non-empty, it is used
     * to prefix the $configFile.
     *
     * @param array<string,class-string<InjectorInterface>> $injectors
     * @param Collection<array-key,InjectorInterface::TYPE_*> $availableTypes
     */
    public function __construct(
        array $injectors,
        DiscoveryChainInterface $discoveryChain,
        Collection $availableTypes,
        string $projectRoot = ''
    ) {
        $this->chain = (new Collection($injectors))
            // Keep only those injectors that discovery exists in discoveryChain
            ->filter(
                static fn(string $injector, string $file) => $discoveryChain->discoveryExists($file)
            )
            // Create an injector for the config file
            ->map(
                fn(string $injector): InjectorInterface => new $injector($projectRoot)
            )
            // Keep only those injectors that match types available for the package
            ->filter(fn(InjectorInterface $injector) => $availableTypes->anySatisfies(
                fn(int $type) => $injector->registersType($type)
            ));
    }

    /**
     * {@inheritDoc}
     */
    public function registersType(int $type): bool
    {
        return in_array($type, $this->getTypesAllowed(), true);
    }

    /**
     * {@inheritDoc}
     */
    public function getTypesAllowed(): array
    {
        if ($this->allowedTypes) {
            return $this->allowedTypes;
        }

        $allowedTypes = [];
        foreach ($this->chain->getIterator() as $injector) {
            $allowedTypes[] = $injector->getTypesAllowed();
        }

        $this->allowedTypes = array_values(array_unique(array_merge([], ...$allowedTypes)));
        return $this->allowedTypes;
    }

    /**
     * {@inheritDoc}
     */
    public function isRegistered(string $package): bool
    {
        $isRegisteredCount = $this->chain
            ->filter(fn(InjectorInterface $injector): bool => $injector->isRegistered($package))
            ->count();
        return $this->chain->count() === $isRegisteredCount;
    }

    /**
     * {@inheritDoc}
     */
    public function inject(string $package, int $type): bool
    {
        $injected = false;

        $this->chain
            ->each(function ($injector) use ($package, $type, &$injected) {
                $injected = $injector->inject($package, $type) || $injected;
            });

        assert(is_bool($injected));

        return $injected;
    }

    /**
     * {@inheritDoc}
     */
    public function remove(string $package): bool
    {
        $removed = false;

        $this->chain
            ->each(function ($injector) use ($package, &$removed) {
                $removed = $injector->remove($package) || $removed;
            });

        assert(is_bool($removed));
        return $removed;
    }

    /**
     * @return Collection<string,InjectorInterface>
     */
    public function getCollection(): Collection
    {
        return $this->chain;
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
