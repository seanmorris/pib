<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\ConfigDiscovery;

/**
 * @internal
 */
interface DiscoveryInterface
{
    /**
     * Attempt to discover if a given configuration file exists.
     *
     * Implementations should check if the file exists, and can potentially
     * look for known expected artifacts within the file to determine if
     * the configuration is one to which the installer can or should write to.
     */
    public function locate(): bool;
}
