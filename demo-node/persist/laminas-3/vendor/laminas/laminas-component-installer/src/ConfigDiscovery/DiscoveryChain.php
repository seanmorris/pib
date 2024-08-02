<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\ConfigDiscovery;

use Laminas\ComponentInstaller\Collection;

/**
 * @internal
 */
final class DiscoveryChain implements DiscoveryChainInterface
{
    /**
     * Discovery Collection
     *
     * @var Collection<string,DiscoveryInterface>
     */
    protected Collection $chain;

    /**
     * Optionally specify project directory; $configFile will be relative to
     * this value.
     *
     * @param array<string,class-string<DiscoveryInterface>> $discovery
     */
    public function __construct(array $discovery, string $projectDirectory = '')
    {
        $this->chain = (new Collection($discovery))
            // Create a discovery class for the discovery type
            ->map(static fn(string $discoveryClass) => new $discoveryClass($projectDirectory))
            // Use only those where we can locate a corresponding config file
            ->filter(static fn(DiscoveryInterface $discovery) => $discovery->locate());
    }

    /**
     * {@inheritDoc}
     */
    public function locate(): bool
    {
        return $this->chain->count() > 0;
    }

    /**
     * {@inheritDoc}
     */
    public function discoveryExists(string $name): bool
    {
        return $this->chain->has($name);
    }
}
