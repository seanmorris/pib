<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller;

use ArrayObject;
use Composer\Composer;
use Composer\DependencyResolver\Operation\InstallOperation;
use Composer\DependencyResolver\Operation\UninstallOperation;
use Composer\DependencyResolver\Operation\UpdateOperation;
use Composer\EventDispatcher\EventSubscriberInterface;
use Composer\Installer\PackageEvent;
use Composer\Installer\PackageEvents;
use Composer\IO\IOInterface;
use Composer\Package\PackageInterface;
use Composer\Plugin\PluginInterface;
use DirectoryIterator;
use Laminas\ComponentInstaller\Injector\AbstractInjector;
use Laminas\ComponentInstaller\Injector\ConfigInjectorChain;
use Laminas\ComponentInstaller\Injector\InjectorInterface;
use Laminas\ComponentInstaller\PackageProvider\PackageProviderDetectionFactory;
use Laminas\ComponentInstaller\PackageProvider\PackageProviderDetectionFactoryInterface;
use Laminas\ComponentInstaller\PackageProvider\PackageProviderDetectionInterface;
use RuntimeException;

use function array_filter;
use function array_flip;
use function array_key_exists;
use function array_keys;
use function array_map;
use function array_merge;
use function array_unshift;
use function array_values;
use function assert;
use function explode;
use function file_exists;
use function file_get_contents;
use function gettype;
use function implode;
use function in_array;
use function is_array;
use function is_dir;
use function is_numeric;
use function is_string;
use function preg_match;
use function preg_replace;
use function rtrim;
use function sprintf;
use function str_replace;
use function stripslashes;
use function strtolower;
use function substr;

/**
 * If a package represents a component module, update the application configuration.
 *
 * Packages opt-in to this workflow by defining one or more of the keys:
 *
 * - extra.laminas.component
 * - extra.laminas.module
 * - extra.laminas.config-provider
 *
 * with the value being the string namespace the component and/or module
 * defines, or, in the case of config-provider, the fully qualified class name
 * of the provider:
 *
 * <code class="lang-javascript">
 * {
 *   "extra": {
 *     "laminas": {
 *       "component": "Laminas\\Form",
 *       "module": "Laminas\\ApiTools\\ContentNegotiation",
 *       "config-provider": "Mezzio\\PlatesRenderer\\ConfigProvider"
 *     }
 *   }
 * }
 * </code>
 *
 * With regards to components and modules, for this to work correctly, the
 * package MUST define a `Module` in the namespace listed in either the
 * extra.laminas.component or extra.laminas.module definition.
 *
 * Components are added to the TOP of the modules list, to ensure that userland
 * code and/or modules can override the settings. Modules are added to the
 * BOTTOM of the modules list. Config providers are added to the TOP of
 * configuration providers.
 *
 * In either case, you can edit the appropriate configuration file when
 * complete to create a specific order.
 *
 * @internal
 *
 * @psalm-type ComposerExtraComponentInstallerProjectArrayType = array{
 *     component-auto-installs?: non-empty-list<non-empty-string>,
 *     component-ignore-list?: non-empty-list<non-empty-string>
 * }
 * @psalm-type ComposerExtraComponentInstallerArrayType = array{
 *     component?:non-empty-array<non-empty-string>,
 *     module?:non-empty-array<non-empty-string>,
 *     config-provider?:non-empty-array<non-empty-string>
 * }
 * @psalm-import-type AutoloadRules from PackageInterface
 */
class ComponentInstaller implements
    EventSubscriberInterface,
    PluginInterface
{
    /**
     * Cached injectors to re-use for packages installed later in the current process.
     *
     * @var array<InjectorInterface::TYPE_*,InjectorInterface>
     */
    private array $cachedInjectors = [];

    /** @psalm-suppress PropertyNotSetInConstructor Composer plugins have to be activated via the `activate` method. */
    private Composer $composer;

    /** @psalm-suppress PropertyNotSetInConstructor Composer plugins have to be activated via the `activate` method. */
    private IOInterface $io;

    /**
     * Map of known package types to composer config keys.
     */
    private const PACKAGE_TYPES = [
        InjectorInterface::TYPE_CONFIG_PROVIDER => 'config-provider',
        InjectorInterface::TYPE_COMPONENT       => 'component',
        InjectorInterface::TYPE_MODULE          => 'module',
    ];

    /**
     * Project root in which to install.
     */
    private string $projectRoot = '';

    /** @psalm-suppress PropertyNotSetInConstructor Composer plugins have to be activated via the `activate` method. */
    private PackageProviderDetectionFactoryInterface $packageProviderFactory;

    /** @var Collection<int,ConfigOption>|null */
    private ?Collection $discovered = null;

    public function __construct(string $projectRoot = '')
    {
        if ($projectRoot !== '' && is_dir($projectRoot)) {
            $this->projectRoot = $projectRoot;
        }
    }

    /**
     * Activate plugin.
     *
     * Sets internal pointers to Composer and IOInterface instances, and resets
     * cached injector map.
     *
     * @return void
     */
    public function activate(Composer $composer, IOInterface $io)
    {
        $this->composer               = $composer;
        $this->io                     = $io;
        $this->cachedInjectors        = [];
        $this->packageProviderFactory = new PackageProviderDetectionFactory($composer);
    }

    /**
     * Return list of event handlers in this class.
     *
     * @return array<non-empty-string, non-empty-string>
     */
    public static function getSubscribedEvents()
    {
        return [
            PackageEvents::POST_PACKAGE_INSTALL   => 'onPostPackageInstall',
            PackageEvents::POST_PACKAGE_UPDATE    => 'onPostPackageUpdate',
            PackageEvents::POST_PACKAGE_UNINSTALL => 'onPostPackageUninstall',
        ];
    }

    /**
     * post-package-install event hook.
     *
     * This routine exits early if any of the following conditions apply:
     *
     * - Executed in non-development mode
     * - No config/application.config.php is available
     * - The composer.json does not define one of either extra.laminas.component
     *   or extra.laminas.module
     * - The value used for either extra.laminas.component or extra.laminas.module are
     *   empty or not strings.
     *
     * Otherwise, it will attempt to update the application configuration
     * using the value(s) discovered in extra.laminas.component and/or extra.laminas.module,
     * writing their values into the `modules` list.
     *
     * @return void
     */
    public function onPostPackageInstall(PackageEvent $event)
    {
        if (! $event->isDevMode()) {
            // Do nothing in production mode.
            return;
        }

        $operation = $event->getOperation();
        assert($operation instanceof InstallOperation);
        $package = $operation->getPackage();
        /** @var non-empty-string $name */
        $name = $package->getName();

        $packageExtra = $package->getExtra();
        $extra        = $this->getExtraMetadata($packageExtra);

        if ($extra === []) {
            // Package does not define anything of interest; do nothing.
            return;
        }

        $this->addPackageToConfig($name, $extra, $event, $package);
    }

    public function onPostPackageUpdate(PackageEvent $event): void
    {
        if (! $event->isDevMode()) {
            // Do nothing in production mode.
            return;
        }

        $operation = $event->getOperation();
        assert($operation instanceof UpdateOperation);

        $previousVersion = $operation->getInitialPackage();
        $newVersion      = $operation->getTargetPackage();
        /** @var array<string,mixed> $previousPackageExtra */
        $previousPackageExtra = $previousVersion->getExtra();
        $previousExtra        = $this->getExtraMetadata($previousPackageExtra);
        /** @var array<string,mixed> $newPackageExtra */
        $newPackageExtra = $newVersion->getExtra();
        $newExtra        = $this->getExtraMetadata($newPackageExtra);

        if ($previousExtra === $newExtra) {
            return;
        }

        // Looks like the newer version of the package does not contain component installer informations anymore
        if ($newExtra === []) {
            /** @var non-empty-string $packageName */
            $packageName = $previousVersion->getName();
            $this->removePackageFromConfig($packageName, $previousExtra);
            return;
        }

        /** @var ComposerExtraComponentInstallerArrayType $removed */
        $removed = $this->createRecursiveArrayDiffAssoc($previousExtra, $newExtra);
        /** @var ComposerExtraComponentInstallerArrayType $appended */
        $appended = $this->createRecursiveArrayDiffAssoc($newExtra, $previousExtra);

        /** @var non-empty-string $packageName */
        $packageName = $newVersion->getName();
        if ($appended !== []) {
            // Newer version of the package contains component installer informations
            $this->addPackageToConfig($packageName, $appended, $event, $newVersion);
        }

        if ($removed !== []) {
            $this->removePackageFromConfig($packageName, $removed);
        }
    }

    /**
     * Find all Module classes in the package and their dependencies
     * via method `getModuleDependencies` of Module class.
     *
     * These dependencies are used later
     *
     * @see \Laminas\ComponentInstaller\Injector\AbstractInjector::injectAfterDependencies
     *      to add component in a correct order on the module list - after dependencies.
     *
     * It works with PSR-0, PSR-4, 'classmap' and 'files' composer autoloading.
     *
     * @return array<non-empty-string,list<non-empty-string>>
     */
    private function loadModuleClassesDependencies(PackageInterface $package): array
    {
        /** @psalm-var ArrayObject<non-empty-string,list<non-empty-string>> $dependencies */
        $dependencies = new ArrayObject([]);
        $installer    = $this->composer->getInstallationManager();
        $packagePath  = $installer->getInstallPath($package);

        if ($packagePath === null || $packagePath === '') {
            // Do not try to discover dependencies for metapackage and other
            // potential package types that have no install location.
            return [];
        }
        $this->mapAutoloaders($package->getAutoload(), $dependencies, $packagePath);

        return $dependencies->getArrayCopy();
    }

    /**
     * Find all modules of the application.
     *
     * @return list<non-empty-string>
     */
    private function findApplicationModules(): array
    {
        $modulePath = $this->projectRoot !== ''
            ? sprintf('%s/module', $this->projectRoot)
            : 'module';

        $modules = [];

        if (is_dir($modulePath)) {
            $directoryIterator = new DirectoryIterator($modulePath);
            foreach ($directoryIterator as $file) {
                if ($file->isDot() || ! $file->isDir()) {
                    continue;
                }

                $module = $file->getBaseName();
                if ($module === '') {
                    continue;
                }

                $modules[] = $module;
            }
        }

        return $modules;
    }

    /**
     * post-package-uninstall event hook
     *
     * This routine exits early if any of the following conditions apply:
     *
     * - Executed in non-development mode
     * - No config/application.config.php is available
     * - The composer.json does not define one of either extra.laminas.component
     *   or extra.laminas.module
     * - The value used for either extra.laminas.component or extra.laminas.module are
     *   empty or not strings.
     *
     * Otherwise, it will attempt to update the application configuration
     * using the value(s) discovered in extra.laminas.component and/or extra.laminas.module,
     * removing their values from the `modules` list.
     */
    public function onPostPackageUninstall(PackageEvent $event): void
    {
        if (! $event->isDevMode()) {
            // Do nothing in production mode.
            return;
        }

        $operation = $event->getOperation();
        assert($operation instanceof UninstallOperation);
        $package = $operation->getPackage();

        /** @var non-empty-string $name */
        $name         = $package->getName();
        $packageExtra = $package->getExtra();
        $extra        = $this->getExtraMetadata($packageExtra);

        if ($extra === []) {
            return;
        }

        $this->removePackageFromConfig($name, $extra);
    }

    /**
     * Retrieve the metadata from the "extra" section
     *
     * @return ComposerExtraComponentInstallerArrayType|ComposerExtraComponentInstallerProjectArrayType
     * @psalm-return (
     *  $rootProject is true
     *  ? ComposerExtraComponentInstallerProjectArrayType
     *  : ComposerExtraComponentInstallerArrayType
     * )
     */
    private function getExtraMetadata(array $extra, bool $rootProject = false): array
    {
        if (isset($extra['laminas']) && is_array($extra['laminas'])) {
            return $this->filterComponentInstallerSpecificValuesFromComposerExtra($extra['laminas'], $rootProject);
        }

        /**
         * supports legacy "extra.zf" configuration
         */
        if (isset($extra['zf']) && is_array($extra['zf'])) {
            return $this->filterComponentInstallerSpecificValuesFromComposerExtra($extra['zf'], $rootProject);
        }

        return [];
    }

    /**
     * Discover what package types are relevant based on what the package
     * exposes in the extra configuration.
     *
     * @param ComposerExtraComponentInstallerArrayType $extra
     * @return Collection<non-empty-string,Injector\InjectorInterface::TYPE_*>
     */
    private function discoverPackageTypes(array $extra): Collection
    {
        $packageTypes = array_flip(self::PACKAGE_TYPES);

        /** @var Collection<non-empty-string,Injector\InjectorInterface::TYPE_*> $discoveredTypes */
        $discoveredTypes = new Collection([]);
        (new Collection($extra))
            ->filter(
                static fn(array $components, string $type) => in_array($type, self::PACKAGE_TYPES, true)
            )
            ->each(static function (array $components, string $type) use ($packageTypes, $discoveredTypes): void {
                foreach ($components as $component) {
                    $discoveredTypes->set($component, $packageTypes[$type]);
                }
            });

        return $discoveredTypes;
    }

    /**
     * Marshal a collection of defined package types.
     *
     * @param ComposerExtraComponentInstallerArrayType $extra extra.laminas value
     * @return Collection<InjectorInterface::TYPE_*,non-empty-string>
     */
    private function marshalPackageTypes(array $extra): Collection
    {
        // Create a collection of types registered in the package.
        return (new Collection(self::PACKAGE_TYPES))
            ->filter(fn(string $configKey) => isset($extra[$configKey]));
    }

    /**
     * Marshal a collection of package modules.
     *
     * @param ComposerExtraComponentInstallerArrayType $extra   extra.laminas value
     * @param Collection<InjectorInterface::TYPE_*,non-empty-string> $packageTypes
     * @param Collection<int,ConfigOption> $options ConfigOption instances
     * @return Collection<int,non-empty-string>
     */
    private function marshalPackageComponents(array $extra, Collection $packageTypes, Collection $options): Collection
    {
        // We only want to list modules that the application can configure.
        /** @var Collection<int,InjectorInterface::TYPE_*> $supportedTypes */
        $supportedTypes = new Collection([]);
        $options
            ->map(static fn (ConfigOption $option) => $option->getInjector()->getTypesAllowed())
            ->each(static function (array $allowedTypes) use ($supportedTypes) {
                $supportedTypes->merge(new Collection($allowedTypes));
            });

        $supportedTypes = $supportedTypes
            ->unique();

        $componentsByType = (new Collection($extra))
            ->filter(
            /**
             * @param non-empty-string $typeIdentifier
             */
                static fn (array $components, string $typeIdentifier) => $supportedTypes->anySatisfies(
                    static fn (int $supportedType) => $supportedType === $packageTypes->getKey($typeIdentifier)
                )
            );

        /** @var Collection<int,non-empty-string> $flattenedComponentNames */
        $flattenedComponentNames = new Collection([]);
        $componentsByType
            ->each(static function (array $components) use ($flattenedComponentNames): void {
                foreach ($components as $component) {
                    $flattenedComponentNames->set($flattenedComponentNames->count(), $component);
                }
            });

        return $flattenedComponentNames;
    }

    /**
     * Prepare a list of modules to install/register with configuration.
     *
     * @param ComposerExtraComponentInstallerArrayType   $extra
     * @param Collection<int,ConfigOption> $options
     * @return Collection<int,non-empty-string> List of packages to install
     */
    private function marshalInstallableComponents(array $extra, Collection $options): Collection
    {
        return $this->marshalPackageComponents($extra, $this->marshalPackageTypes($extra), $options)
            // Filter out modules that do not have a registered injector
            ->reject(fn(string $component) => $options->anySatisfies(
                fn(ConfigOption $option) => $option->getInjector()->isRegistered($component)
            ));
    }

    /**
     * Prompt for the user to select a configuration location to update.
     *
     * @param non-empty-string             $name
     * @param Collection<int,ConfigOption> $options
     * @param InjectorInterface::TYPE_* $packageType
     * @param non-empty-string             $packageName
     * @param list<non-empty-string>       $autoInstallations
     * @param list<non-empty-string>       $ignoreList
     */
    private function promptForConfigOption(
        string $name,
        Collection $options,
        int $packageType,
        string $packageName,
        array $autoInstallations,
        array $ignoreList,
        bool $requireDev
    ): InjectorInterface {
        // If package is whitelisted, do not inject
        if (in_array($packageName, $ignoreList, true)) {
            return new Injector\NoopInjector();
        }

        if ($cachedInjector = $this->getCachedInjector($packageType)) {
            return $cachedInjector;
        }

        // If package is allowed to be auto-installed, don't ask...
        if (in_array($packageName, $autoInstallations, true)) {
            $injector = $options->get(1)->getInjector();
            if ($requireDev && $options->has(2)) {
                return $options->get(2)->getInjector();
            }

            return $injector;
        }

        // Default to first discovered option; index 0 is always "Do not inject"
        $default   = $options->count() > 1 ? 1 : 0;
        $questions = $options->map(static fn (ConfigOption $option, int $index) => sprintf(
            "  [<comment>%d</comment>] %s\n",
            $index,
            $option->getPromptText()
        ))->toArray();

        array_unshift($questions, sprintf(
            "\n  <question>Please select which config file you wish to inject '%s' into:</question>\n",
            $name
        ));
        $questions[] = sprintf('  Make your selection (default is <comment>%d</comment>):', $default);

        while (true) {
            /** @psalm-suppress MixedAssignment Well the method returns mixed. We do verifying this in the next lines. */
            $answer = $this->io->ask(implode($questions), $default);

            if (is_numeric($answer) && $options->has((int) $answer)) {
                $injector = $options->get((int) $answer)->getInjector();
                $this->promptToRememberOption($injector, $packageType);

                return $injector;
            }

            $this->io->write('<error>Invalid selection</error>');
        }
    }

    /**
     * Prompt the user to determine if the selection should be remembered for later packages.
     *
     * @param InjectorInterface::TYPE_* $packageType
     */
    private function promptToRememberOption(InjectorInterface $injector, int $packageType): void
    {
        $ask = ["\n  <question>Remember this option for other packages of the same type? (Y/n)</question>"];

        while (true) {
            $answer = $this->io->ask(implode($ask), 'y');
            if (! is_string($answer)) {
                throw new RuntimeException(sprintf(
                    'Expected `%s#ask` to return a string: "%s" returned',
                    IOInterface::class,
                    gettype($answer)
                ));
            }

            switch (strtolower($answer)) {
                case 'y':
                    $this->cacheInjector($injector, $packageType);

                    return;
                case 'n':
                    // intentionally fall-through
                default:
                    return;
            }
        }
    }

    /**
     * Inject a module into available configuration.
     *
     * @param non-empty-string  $package                Package name
     * @param non-empty-string  $component Module to install in configuration
     * @param InjectorInterface $injector               Injector to use.
     * @param InjectorInterface::TYPE_* $packageType
     */
    private function injectModuleOrConfigProviderIntoConfig(
        string $package,
        string $component,
        InjectorInterface $injector,
        int $packageType
    ): void {
        $this->io->write(sprintf('<info>    Installing %s from package %s</info>', $component, $package));

        try {
            if (! $injector->inject($component, $packageType)) {
                $this->io->write('<info>    Package is already registered; skipping</info>');
            }
        } catch (Exception\RuntimeException $ex) {
            $this->io->write(sprintf(
                '<error>    %s</error>',
                $ex->getMessage()
            ));
        }
    }

    /**
     * Remove a package from configuration.
     *
     * @param non-empty-string     $package       Package name
     * @param ComposerExtraComponentInstallerArrayType $metadata      Metadata pulled from extra.laminas
     */
    private function removePackageFromConfig(string $package, array $metadata): void
    {
        $configOptions = $this->detectConfigurationOptions();

        if ($configOptions->isEmpty()) {
            // No configuration options found; do nothing.
            return;
        }

        // Create a collection of types registered in the package.
        $packageTypes = $this->marshalPackageTypes($metadata);

        // Create a collection of configured injectors for the package types
        // registered.
        $injectors = $configOptions
            ->map(fn(ConfigOption $configOption) => $configOption->getInjector())
            ->filter(
                static fn(InjectorInterface $injector) => $packageTypes->anySatisfies(
                    static fn(string $key, int $type) => $injector->registersType($type)
                )
            );

        // Create a collection of unique modules based on the package types present,
        // and remove each from configuration.
        $this->marshalPackageComponents($metadata, $packageTypes, $configOptions)
            ->each(function ($module) use ($package, $injectors) {
                $this->removeModuleFromConfig($module, $package, $injectors);
            });
    }

    /**
     * Remove an individual module defined in a package from configuration.
     *
     * @template TKey of array-key
     * @param non-empty-string $component Module to remove
     * @param non-empty-string $package   Package in which module is defined
     * @param Collection<TKey,InjectorInterface> $injectors Injectors to use for removal
     */
    private function removeModuleFromConfig(string $component, string $package, Collection $injectors): void
    {
        $injectors->each(function (InjectorInterface $injector) use ($component, $package) {
            if (! $injector->isRegistered($component)) {
                return;
            }

            $this->io->write(
                sprintf('<info>    Removing %s from package %s</info>', $component, $package)
            );

            if ($injector->remove($component)) {
                $this->io->write(sprintf(
                    '<info>    Removed package from %s</info>',
                    $this->getInjectorConfigFileName($injector)
                ));
            }
        });
    }

    /**
     * @todo remove after InjectorInterface has getConfigName defined
     */
    private function getInjectorConfigFileName(InjectorInterface $injector): string
    {
        if ($injector instanceof ConfigInjectorChain) {
            return $this->getInjectorChainConfigFileName($injector);
        } elseif ($injector instanceof AbstractInjector) {
            return $this->getAbstractInjectorConfigFileName($injector);
        }

        return '';
    }

    /**
     * @todo remove after InjectorInterface has getConfigName defined
     */
    private function getInjectorChainConfigFileName(ConfigInjectorChain $injector): string
    {
        return implode(
            ', ',
            array_map(
                fn($item) => $this->getInjectorConfigFileName($item),
                $injector->getCollection()->toArray()
            )
        );
    }

    /**
     * @todo remove after InjectorInterface has getConfigName defined
     */
    private function getAbstractInjectorConfigFileName(AbstractInjector $injector): string
    {
        return $injector->getConfigFile();
    }

    /**
     * Attempt to retrieve a cached injector for the current package type.
     *
     * @param InjectorInterface::TYPE_* $packageType
     */
    private function getCachedInjector(int $packageType): ?InjectorInterface
    {
        if (isset($this->cachedInjectors[$packageType])) {
            return $this->cachedInjectors[$packageType];
        }

        return null;
    }

    /**
     * Cache an injector for later use.
     *
     * @param InjectorInterface::TYPE_* $packageType
     */
    private function cacheInjector(InjectorInterface $injector, int $packageType): void
    {
        $this->cachedInjectors[$packageType] = $injector;
    }

    /**
     * Iterate through each autoloader type to find dependencies.
     *
     * @param AutoloadRules       $autoload     List of autoloader types and associated autoloader definitions.
     * @param ArrayObject $dependencies Module dependencies defined by the module.
     * @param non-empty-string $packagePath  Path to the package on the filesystem.
     * @psalm-param ArrayObject<non-empty-string,list<non-empty-string>>                   $dependencies
     */
    private function mapAutoloaders(array $autoload, ArrayObject $dependencies, string $packagePath): void
    {
        foreach ($autoload as $type => $map) {
            $this->mapType($map, $type, $dependencies, $packagePath);
        }
    }

    /**
     * Iterate through a single autolaoder type to find dependencies.
     *
     * @param array       $map          Map of namespace => path(s) pairs.
     * @param string      $type         Type of autoloader being iterated.
     * @param ArrayObject $dependencies Module dependencies defined by the module.
     * @param non-empty-string $packagePath  Path to the package on the filesystem.
     * @psalm-param array<int|string, array<array-key, string>|string>           $map
     * @psalm-param ArrayObject<non-empty-string,list<non-empty-string>>  $dependencies
     */
    private function mapType(array $map, string $type, ArrayObject $dependencies, string $packagePath): void
    {
        foreach ($map as $namespace => $paths) {
            $paths = array_values((array) $paths);
            $this->mapNamespacePaths($paths, $namespace, $type, $dependencies, $packagePath);
        }
    }

    /**
     * Iterate through the paths defined for a given namespace.
     *
     * @param array       $paths        Paths defined for the given namespace.
     * @param string|int  $namespace    PHP namespace to which the paths map or index of file/directory list.
     * @param string      $type         Type of autoloader being iterated.
     * @param ArrayObject $dependencies Module dependencies defined by the module.
     * @param non-empty-string $packagePath  Path to the package on the filesystem.
     * @psalm-param list<string> $paths
     * @psalm-param ArrayObject<non-empty-string,list<non-empty-string>> $dependencies
     */
    private function mapNamespacePaths(
        array $paths,
        $namespace,
        string $type,
        ArrayObject $dependencies,
        string $packagePath
    ): void {
        foreach ($paths as $path) {
            $this->mapPath($path, $namespace, $type, $dependencies, $packagePath);
        }
    }

    /**
     * Find module dependencies for a given namespace for a given path.
     *
     * @param string      $path         Path to inspect.
     * @param string|int  $namespace    PHP namespace to which the paths map.
     * @param string      $type         Type of autoloader being iterated.
     * @param ArrayObject $dependencies Module dependencies defined by the module.
     * @param non-empty-string $packagePath  Path to the package on the filesystem.
     * @psalm-param ArrayObject<non-empty-string,list<non-empty-string>> $dependencies
     */
    private function mapPath(
        string $path,
        $namespace,
        string $type,
        ArrayObject $dependencies,
        string $packagePath
    ): void {
        switch ($type) {
            case 'classmap':
                $fullPath = sprintf('%s/%s', $packagePath, $path);
                if (substr($path, -10) === 'Module.php') {
                    $modulePath = $fullPath;
                    break;
                }

                $modulePath = sprintf('%s/Module.php', rtrim($fullPath, '/'));
                break;
            case 'files':
                if (substr($path, -10) !== 'Module.php') {
                    return;
                }
                $modulePath = sprintf('%s/%s', $packagePath, $path);
                break;
            case 'psr-0':
                assert(is_string($namespace));
                $modulePath = sprintf(
                    '%s/%s%s%s',
                    $packagePath,
                    $path,
                    str_replace('\\', '/', $namespace),
                    'Module.php'
                );
                break;
            case 'psr-4':
                assert(is_string($namespace));
                $modulePath = sprintf(
                    '%s/%s%s',
                    $packagePath,
                    $path,
                    'Module.php'
                );
                break;
            default:
                return;
        }

        if (! file_exists($modulePath)) {
            return;
        }

        $result = $this->getModuleDependencies($modulePath);

        if ($result === []) {
            return;
        }

        // Mimic array + array operation in ArrayObject
        $dependencies->exchangeArray(array_merge($dependencies->getArrayCopy(), $result));
    }

    /**
     * @psalm-return array<string,list<non-empty-string>>
     */
    private function getModuleDependencies(string $file): array
    {
        $content = file_get_contents($file);
        assert(is_string($content));
        if (preg_match('/namespace\s+([^\s]+)\s*;/', $content, $m)) {
            $moduleName = $m[1];

            // @codingStandardsIgnoreStart
            $regExp = '/public\s+function\s+getModuleDependencies\s*\(\s*\)\s*{[^}]*return\s*(?:array\(|\[)([^})\]]*)(\)|\])/';
            // @codingStandardsIgnoreEnd
            if (preg_match($regExp, $content, $m)) {
                $dependencies = array_filter(
                    explode(',', stripslashes(rtrim(preg_replace('/[\s"\']/', '', $m[1]), ',')))
                );

                if ($dependencies) {
                    /** @psalm-var list<non-empty-string> $dependencies */
                    return [$moduleName => $dependencies];
                }
            }
        }

        return [];
    }

    private function isADevDependency(
        PackageProviderDetectionInterface $packageProviderDetection,
        PackageInterface $package
    ): bool {
        $packageName     = $package->getName();
        $devRequirements = $this->composer->getPackage()->getDevRequires();
        if (isset($devRequirements[$packageName])) {
            return true;
        }

        $packages = $packageProviderDetection->whatProvides($packageName);
        if ($packages === []) {
            return false;
        }

        $requirements = $this->composer->getPackage()->getRequires();
        foreach ($packages as $parent) {
            // Package is required by any package which is NOT a dev-requirement
            if (isset($requirements[$parent->getName()])) {
                return false;
            }
        }

        return true;
    }

    public function deactivate(Composer $composer, IOInterface $io): void
    {
    }

    public function uninstall(Composer $composer, IOInterface $io): void
    {
    }

    /**
     * @param non-empty-string $name
     * @param ComposerExtraComponentInstallerArrayType $extra
     */
    private function addPackageToConfig(
        string $name,
        array $extra,
        PackageEvent $event,
        PackageInterface $package
    ): void {
        $packageTypes = $this->discoverPackageTypes($extra);
        $options      = (new ConfigDiscovery())
            ->getAvailableConfigOptions($packageTypes, $this->projectRoot);

        if ($options->isEmpty()) {
            // No configuration options found; do nothing.
            return;
        }

        $packageProviderDetection = $this->packageProviderFactory->detect($event, $name);
        $requireDev               = $this->isADevDependency($packageProviderDetection, $package);
        $dependencies             = $this->loadModuleClassesDependencies($package);
        $applicationModules       = $this->findApplicationModules();

        // Get extra from root package
        /** @var array<string,mixed> $rootPackageExtra */
        $rootPackageExtra  = $this->composer->getPackage()->getExtra();
        $rootExtra         = $this->getExtraMetadata($rootPackageExtra, true);
        $autoInstallations = $rootExtra['component-auto-installs'] ?? [];
        $ignoreList        = $rootExtra['component-ignore-list'] ?? [];

        $this->marshalInstallableComponents($extra, $options)
            // Create injectors
            ->each(function (string $component) use (
                $options,
                $packageTypes,
                $name,
                $requireDev,
                $dependencies,
                $applicationModules,
                $autoInstallations,
                $ignoreList
            ): void {
                $packageType = $packageTypes->get($component);

                $injector = $this->promptForConfigOption(
                    $component,
                    $options,
                    $packageType,
                    $name,
                    $autoInstallations,
                    $ignoreList,
                    $requireDev
                );

                if (isset($dependencies[$component])) {
                    $injector->setModuleDependencies($dependencies[$component]);
                }

                $injector->setApplicationModules($applicationModules);
                $this->injectModuleOrConfigProviderIntoConfig(
                    $name,
                    $component,
                    $injector,
                    $packageType
                );
            });
    }

    /**
     * Use internal property caching as the config options wont change while composer is being executed.
     *
     * @return Collection<int,ConfigOption>
     */
    private function detectConfigurationOptions(): Collection
    {
        if ($this->discovered) {
            return $this->discovered;
        }

        $discovered = (new ConfigDiscovery())
            ->getAvailableConfigOptions(
                new Collection(array_keys(self::PACKAGE_TYPES)),
                $this->projectRoot
            );

        $this->discovered = $discovered;
        return $discovered;
    }

    /**
     * @param array $maybeLaminasSpecificConfiguration
     * @return ComposerExtraComponentInstallerProjectArrayType|ComposerExtraComponentInstallerArrayType
     * @psalm-return (
     *  $rootProject is true
     *  ? ComposerExtraComponentInstallerProjectArrayType
     *  : ComposerExtraComponentInstallerArrayType
     * )
     */
    private function filterComponentInstallerSpecificValuesFromComposerExtra(
        array $maybeLaminasSpecificConfiguration,
        bool $rootProject
    ): array {
        $laminasSpecificConfiguration = [];

        // We do not return component/module/config-provider for root project
        if ($rootProject === false) {
            foreach (self::PACKAGE_TYPES as $packageTypeIdentifier) {
                if (isset($maybeLaminasSpecificConfiguration[$packageTypeIdentifier])) {
                    if ($this->isNonEmptyString($maybeLaminasSpecificConfiguration[$packageTypeIdentifier])) {
                        $laminasSpecificConfiguration[$packageTypeIdentifier] = [
                            $maybeLaminasSpecificConfiguration[$packageTypeIdentifier],
                        ];
                    } elseif (
                        $this->isNonEmptyListContainingNonEmptyStrings(
                            $maybeLaminasSpecificConfiguration[$packageTypeIdentifier]
                        )
                    ) {
                        $laminasSpecificConfiguration[$packageTypeIdentifier] =
                            $maybeLaminasSpecificConfiguration[$packageTypeIdentifier];
                    }
                }
            }

            return $laminasSpecificConfiguration;
        }

        // We do not return component/module/config-provider for components project

        if (
            isset($maybeLaminasSpecificConfiguration['component-auto-installs'])
            && $this->isNonEmptyListContainingNonEmptyStrings(
                $maybeLaminasSpecificConfiguration['component-auto-installs']
            )
        ) {
            $laminasSpecificConfiguration['component-auto-installs']
                = $maybeLaminasSpecificConfiguration['component-auto-installs'];
        }

        if (
            isset($maybeLaminasSpecificConfiguration['component-ignore-list'])
            && $this->isNonEmptyListContainingNonEmptyStrings(
                $maybeLaminasSpecificConfiguration['component-ignore-list']
            )
        ) {
            $laminasSpecificConfiguration['component-ignore-list']
                = $maybeLaminasSpecificConfiguration['component-ignore-list'];
        }

        return $laminasSpecificConfiguration;
    }

    /**
     * @param mixed $value
     * @psalm-assert-if-true non-empty-string $value
     */
    private function isNonEmptyString($value): bool
    {
        return is_string($value) && $value !== '';
    }

    /**
     * @param mixed $value
     * @psalm-assert-if-true non-empty-list<non-empty-string> $value
     */
    private function isNonEmptyListContainingNonEmptyStrings($value): bool
    {
        if (! is_array($value) || $value === []) {
            return false;
        }

        // Quick 'n dirty check if the value is a list
        if (array_values($value) !== $value) {
            return false;
        }

        $values = $value;

        /** @var mixed $value */
        foreach ($values as $value) {
            if (! $this->isNonEmptyString($value)) {
                return false;
            }
        }

        return true;
    }

    private function createRecursiveArrayDiffAssoc(array $metadata1, array $metadata2): array
    {
        $diff = [];

        /** @psalm-suppress MixedAssignment */
        foreach ($metadata1 as $key => $value) {
            if (array_key_exists($key, $metadata2)) {
                if (is_array($value)) {
                    assert(is_array($metadata2[$key]));
                    $recursiveDiff = $this->createRecursiveArrayDiffAssoc($value, $metadata2[$key]);

                    if ($recursiveDiff !== []) {
                        $diff[$key] = $recursiveDiff;
                    }
                } elseif (! in_array($value, $metadata2, true)) {
                    /** @psalm-suppress MixedAssignment */
                    $diff[$key] = $value;
                }
            } elseif (! in_array($value, $metadata2, true)) {
                /** @psalm-suppress MixedAssignment */
                $diff[$key] = $value;
            }
        }

        return $diff;
    }
}
