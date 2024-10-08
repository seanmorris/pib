<?php

declare(strict_types=1);

namespace Laminas\SkeletonInstaller;

use Composer\Composer;
use Composer\Installer as ComposerInstaller;
use Composer\IO\IOInterface;
use Composer\Package\Link;
use Composer\Package\RootPackageInterface;
use Composer\Package\Version\VersionParser;

use function is_array;
use function sprintf;
use function strtolower;

/**
 * Prompt for and install optional packages.
 */
class OptionalPackagesInstaller
{
    use ComposerJsonRetrievalTrait;

    /** @var Composer */
    private $composer;

    /** @var callable Factory for creating a ComposerInstaller instance. */
    private $installerFactory = [self::class, 'createInstaller'];

    /** @var IOInterface */
    private $io;

    // @codingStandardsIgnoreStart
    /**
     * @var string[]
     */
    private $packageConfigPrompts = [
        'require'     => '<info>    When prompted to install as a module, select application.config.php or modules.config.php</info>',
        'require-dev' => '<info>    When prompted to install as a module, select development.config.php.dist</info>',
    ];
    // @codingStandardsIgnoreEnd

    /** @var VersionParser */
    private $versionParser;

    public function __construct(Composer $composer, IOInterface $io)
    {
        $this->composer      = $composer;
        $this->io            = $io;
        $this->versionParser = new VersionParser();
    }

    /**
     * Prompt for and install optional packages
     */
    public function __invoke()
    {
        // Locate and return valid optional packages
        $optionalPackages = Collection::create($this->getOptionalDependencies())
            ->filter([OptionalPackage::class, 'isValidSpec']);

        // If none are found, do nothing.
        if ($optionalPackages->isEmpty()) {
            return;
        }

        // Prompt for minimal install
        if ($this->requestMinimalInstall()) {
            // If a minimal install is requested, remove optional package information
            $this->removeOptionalPackages();
            return;
        }

        // Prompt for each package, and filter accordingly
        $packagesToInstall = $optionalPackages
            ->map(function (array $spec): OptionalPackage {
                return new OptionalPackage($spec);
            })
            ->filter(function (OptionalPackage $package): bool {
                return $this->promptForPackage($package);
            });

        // If no optional packages were selected, do nothing.
        if ($packagesToInstall->isEmpty()) {
            $this->io->write('<info>    No optional packages selected to install</info>');
            $this->removeOptionalPackages();
            return;
        }

        // Run an installer update
        $package = $this->updateRootPackage($this->composer->getPackage(), $packagesToInstall);
        if (0 !== $this->runInstaller($package, $packagesToInstall)) {
            $this->io->write('<error>Error installing optional packages. Run with verbosity to debug');
            return;
        }

        // Update the composer.json
        $this->updateComposerJson($packagesToInstall);
    }

    /**
     * Retrieve list of optional dependencies.
     *
     * Looks for a extra.laminas-skeleton-installer key with an array value,
     * returning it if found, or an empty array otherwise.
     *
     * @return list<array>
     */
    private function getOptionalDependencies()
    {
        $package = $this->composer->getPackage();
        $extra   = $package->getExtra();

        if (isset($extra['laminas-skeleton-installer']) && is_array($extra['laminas-skeleton-installer'])) {
            return $extra['laminas-skeleton-installer'];
        }

        // supports legacy "extra.zend-skeleton-installer" configuration
        return isset($extra['zend-skeleton-installer']) && is_array($extra['zend-skeleton-installer'])
            ? $extra['zend-skeleton-installer']
            : [];
    }

    /**
     * Prompt the user for a mimimal install.
     *
     * @return bool
     */
    private function requestMinimalInstall()
    {
        $question = <<<'END'

                <question>Do you want a minimal install (no optional packages)?</question> <comment>Y/n</comment>

        END;

        while (true) {
            $answer = $this->io->ask($question, 'y');
            $answer = strtolower($answer);

            if ('n' === $answer) {
                return false;
            }

            if ('y' === $answer) {
                return true;
            }

            $this->io->write('<error>Invalid answer</error>');
        }
    }

    /**
     * Create the callback for emitting and handling a package prompt.
     *
     * @return bool
     */
    private function promptForPackage(OptionalPackage $package)
    {
        $question = sprintf(
            "\n    <question>%s</question> <comment>y/N</comment>\n",
            $package->getPrompt()
        );

        while (true) {
            $answer = $this->io->ask($question, 'n');
            $answer = strtolower($answer);

            if ('n' === $answer) {
                return false;
            }

            if ('y' === $answer) {
                $this->io->write(sprintf(
                    '<info>    Will install %s (%s)</info>',
                    $package->getName(),
                    $package->getConstraint()
                ));
                if ($package->isModule()) {
                    $extra = $package->isDev()
                        ? $this->packageConfigPrompts['require-dev']
                        : $this->packageConfigPrompts['require'];
                    $this->io->write($extra);
                }
                return true;
            }

            $this->io->write('<error>Invalid answer</error>');
        }
    }

    /**
     * Remove optional packages after a minimal install or failure to select packages.
     */
    private function removeOptionalPackages()
    {
        $this->io->write('<info>    Removing optional packages from composer.json</info>');
        $this->updateComposerJson(new Collection([]));
    }

    /**
     * Update the composer.json definition.
     *
     * Adds all packages to the appropriate require or require-dev sections of
     * the composer.json, and removes the extra.laminas-skeleton-installer node.
     *
     * @param Collection<int, OptionalPackage> $packagesToInstall
     */
    private function updateComposerJson(Collection $packagesToInstall): void
    {
        $this->io->write('<info>    Updating composer.json</info>');
        $composerJson = $this->getComposerJson();
        $json         = $packagesToInstall->reduce(function ($composer, $package) {
            return $this->updateComposerRequirement($composer, $package);
        }, $composerJson->read());
        unset($json['extra']['laminas-skeleton-installer'], $json['extra']['zend-skeleton-installer']);
        if (empty($json['extra'])) {
            unset($json['extra']);
        }
        $composerJson->write($json);
    }

    /**
     * Add a package to the composer definition.
     *
     * @param array $composer
     * @return array
     */
    private function updateComposerRequirement(array $composer, OptionalPackage $package)
    {
        $key                                 = $package->isDev() ? 'require-dev' : 'require';
        $composer[$key][$package->getName()] = $package->getConstraint();
        return $composer;
    }

    /**
     * Update the root package definition
     *
     * @param Collection<int, OptionalPackage> $packagesToInstall
     * @return RootPackageInterface
     */
    private function updateRootPackage(RootPackageInterface $package, Collection $packagesToInstall)
    {
        $this->io->write('<info>Updating root package</info>');
        $package->setRequires($packagesToInstall->reduce(function ($requires, $package) {
            return $this->addRootPackageRequirement($requires, $package);
        }, $package->getRequires()));
        return $package;
    }

    /**
     * Add a requirement to the root package.
     *
     * @param array $requires
     * @return array
     */
    private function addRootPackageRequirement(array $requires, OptionalPackage $package)
    {
        $name        = $package->getName();
        $constraint  = $package->getConstraint();
        $description = $package->isDev()
            ? 'requires for development'
            : 'requires';

        $requires[$name] = new Link(
            '__root__',
            $name,
            $this->versionParser->parseConstraints($constraint),
            $description,
            $constraint
        );

        return $requires;
    }

    /**
     * Creates and runs a Composer installer instance, returning the results.
     *
     * The instance has the following modifications:
     *
     * - It uses the updated root package
     * - It uses a new EventDispatcher, to prevent triggering already accumulated plugins
     * - It marks the operation as an update
     * - It specifies an update whitelist of only the new packages to install
     * - It disables plugins
     *
     * @param Collection<int, OptionalPackage> $packagesToInstall
     */
    private function runInstaller(RootPackageInterface $package, Collection $packagesToInstall): int
    {
        $this->io->write('<info>    Running an update to install optional packages</info>');

        /** @var ComposerInstaller $installer */
        $installer = ($this->installerFactory)($this->composer, $this->io, $package);

        $installer->setDevMode(true);
        $installer->setUpdate(true);

        $this->attachPackageWhitelistBasedOnComposerVersion($installer, $packagesToInstall);

        return $installer->run();
    }

    /**
     * Create an Installer instance.
     *
     * Private static factory, to allow slip-streaming in a mock as needed for
     * testing.
     *
     * @return ComposerInstaller
     */
    // phpcs:ignore SlevomatCodingStandard.Classes.UnusedPrivateElements
    private static function createInstaller(Composer $composer, IOInterface $io, RootPackageInterface $package)
    {
        $eventDispatcher = new BroadcastEventDispatcher(
            $composer,
            $io,
            null,
            $composer->getEventDispatcher(),
            ['post-package-install']
        );

        return new ComposerInstaller(
            $io,
            $composer->getConfig(),
            $package,
            $composer->getDownloadManager(),
            $composer->getRepositoryManager(),
            $composer->getLocker(),
            $composer->getInstallationManager(),
            $eventDispatcher,
            $composer->getAutoloadGenerator()
        );
    }

    /** @param Collection<int, OptionalPackage> $packagesToInstall */
    private function attachPackageWhitelistBasedOnComposerVersion(
        ComposerInstaller $installer,
        Collection $packagesToInstall
    ) {
        $installer->setUpdateAllowList(
            $packagesToInstall->map(function ($package): string {
                return $package->getName();
            })
                ->toArray()
        );
    }
}
