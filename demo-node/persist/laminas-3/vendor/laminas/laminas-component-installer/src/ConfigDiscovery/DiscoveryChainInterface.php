<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\ConfigDiscovery;

/**
 * @internal
 */
interface DiscoveryChainInterface extends DiscoveryInterface
{
    public function discoveryExists(string $name): bool;
}
