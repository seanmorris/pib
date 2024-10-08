<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\PackageProvider;

use Composer\Composer;
use Composer\Installer\PackageEvent;
use Composer\IO\IOInterface;
use Composer\IO\NullIO;
use Composer\Repository\CompositeRepository;
use Composer\Repository\InstalledArrayRepository;
use Composer\Repository\InstalledRepository;
use Composer\Repository\PlatformRepository;
use Composer\Repository\RepositoryFactory;
use Composer\Repository\RepositoryInterface;
use Composer\Repository\RootPackageRepository;

use function method_exists;

/**
 * @internal
 */
final class PackageProviderDetectionFactory implements PackageProviderDetectionFactoryInterface
{
    private Composer $composer;

    public function __construct(Composer $composer)
    {
        $this->composer = $composer;
    }

    public function detect(PackageEvent $event, string $packageName): PackageProviderDetectionInterface
    {
        $installedRepo = new InstalledRepository($this->prepareRepositoriesForInstalledRepository());
        $defaultRepos  = new CompositeRepository($this->createDefaultRepos(new NullIO()));

        if (
            ($match = $defaultRepos->findPackage($packageName, '*'))
            && false === $installedRepo->hasPackage($match)
        ) {
            $installedRepo->addRepository(new InstalledArrayRepository([clone $match]));
        }

        return new InstalledRepositoryPackageProvider($installedRepo);
    }

    /**
     * @return list<RepositoryInterface>
     */
    private function prepareRepositoriesForInstalledRepository(): array
    {
        /** @var array<string,string|false> $platformOverrides */
        $platformOverrides = $this->composer->getConfig()->get('platform') ?? [];

        $rootPackage           = $this->composer->getPackage();
        $rootPackageRepository = $rootPackage->getRepository() ?? new RootPackageRepository(clone $rootPackage);

        return [
            $rootPackageRepository,
            $this->composer->getRepositoryManager()->getLocalRepository(),
            new PlatformRepository([], $platformOverrides),
        ];
    }

    /**
     * @return RepositoryInterface[]
     */
    private function createDefaultRepos(IOInterface $io): array
    {
        if (method_exists(RepositoryFactory::class, 'defaultReposWithDefaultManager')) {
            return RepositoryFactory::defaultReposWithDefaultManager($io);
        }

        return RepositoryFactory::defaultRepos($io);
    }
}
