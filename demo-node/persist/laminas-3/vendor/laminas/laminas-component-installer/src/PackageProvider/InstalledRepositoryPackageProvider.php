<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\PackageProvider;

use Composer\Repository\InstalledRepository;

use function array_values;

/**
 * @internal
 */
final class InstalledRepositoryPackageProvider implements PackageProviderDetectionInterface
{
    private InstalledRepository $installedRepository;

    public function __construct(InstalledRepository $installedRepository)
    {
        $this->installedRepository = $installedRepository;
    }

    public function whatProvides(string $packageName): array
    {
        return array_values($this->installedRepository->findPackagesWithReplacersAndProviders($packageName));
    }
}
