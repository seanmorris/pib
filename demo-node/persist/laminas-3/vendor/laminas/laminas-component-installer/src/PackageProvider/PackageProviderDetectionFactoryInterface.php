<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\PackageProvider;

use Composer\Installer\PackageEvent;

/**
 * @internal
 */
interface PackageProviderDetectionFactoryInterface
{
    public function detect(PackageEvent $event, string $packageName): PackageProviderDetectionInterface;
}
