<?php
declare(strict_types=1);

namespace Cake\Composer;

use Composer\Composer;
use Composer\EventDispatcher\EventSubscriberInterface;
use Composer\IO\IOInterface;
use Composer\Package\PackageInterface;
use Composer\Plugin\PluginInterface;
use Composer\Script\Event;
use DirectoryIterator;
use RuntimeException;

class Plugin implements PluginInterface, EventSubscriberInterface
{
    /**
     * @inheritDoc
     */
    public function activate(Composer $composer, IOInterface $io)
    {
    }

    /**
     * @inheritDoc
     */
    public function deactivate(Composer $composer, IOInterface $io)
    {
    }

    /**
     * @inheritDoc
     */
    public function uninstall(Composer $composer, IOInterface $io)
    {
    }

    /**
     * @inheritDoc
     */
    public static function getSubscribedEvents()
    {
        return [
            'post-autoload-dump' => 'postAutoloadDump',
            'pre-autoload-dump' => 'preAutoloadDump',
        ];
    }

    /**
     * Add PSR-4 autoload paths for app plugins.
     *
     * @param \Composer\Script\Event $event
     * @return void
     */
    public function preAutoloadDump(Event $event): void
    {
        $package = $event->getComposer()->getPackage();
        $autoload = $package->getAutoload();
        $devAutoload = $package->getDevAutoload();

        $extra = $package->getExtra();
        if (empty($extra['plugin-paths'])) {
            $extra['plugin-paths'] = ['plugins'];
        }

        $root = dirname(realpath($event->getComposer()->getConfig()->get('vendor-dir'))) . '/';
        foreach ($extra['plugin-paths'] as $pluginsPath) {
            if (!is_dir($root . $pluginsPath)) {
                continue;
            }
            foreach (new DirectoryIterator($root . $pluginsPath) as $fileInfo) {
                if (!$fileInfo->isDir() || $fileInfo->isDot()) {
                    continue;
                }

                $folderName = $fileInfo->getFilename();
                if ($folderName[0] === '.') {
                    continue;
                }

                $pluginNamespace = $folderName . '\\';
                $pluginTestNamespace = $folderName . '\\Test\\';
                $path = $pluginsPath . '/' . $folderName . '/';
                if (!isset($autoload['psr-4'][$pluginNamespace]) && is_dir($root . $path . '/src')) {
                    $autoload['psr-4'][$pluginNamespace] = $path . 'src';
                }
                if (!isset($devAutoload['psr-4'][$pluginTestNamespace]) && is_dir($root . $path . '/tests')) {
                    $devAutoload['psr-4'][$pluginTestNamespace] = $path . 'tests';
                }
            }
        }

        $package->setAutoload($autoload);
        $package->setDevAutoload($devAutoload);
    }

    /**
     * Called whenever composer (re)generates the autoloader.
     *
     * Recreates CakePHP's plugin path map, based on composer information
     * and available app plugins.
     *
     * @param \Composer\Script\Event $event Composer's event object.
     * @return void
     */
    public function postAutoloadDump(Event $event): void
    {
        $composer = $event->getComposer();
        $config = $composer->getConfig();

        $vendorDir = realpath($config->get('vendor-dir'));

        $packages = $composer->getRepositoryManager()->getLocalRepository()->getPackages();
        $extra = $event->getComposer()->getPackage()->getExtra();
        if (empty($extra['plugin-paths'])) {
            $pluginDirs = [dirname($vendorDir) . DIRECTORY_SEPARATOR . 'plugins'];
        } else {
            $pluginDirs = $extra['plugin-paths'];
        }

        $plugins = $this->findPlugins($packages, $pluginDirs, $vendorDir);

        $configFile = $this->getConfigFilePath($vendorDir);
        $this->writeConfigFile($configFile, $plugins);
    }

    /**
     * Find all available plugins.
     *
     * Add all composer packages of type `cakephp-plugin`, and all plugins located
     * in the plugins directory to a plugin-name indexed array of paths.
     *
     * @param array<\Composer\Package\PackageInterface> $packages Array of \Composer\Package\PackageInterface objects.
     * @param array<string> $pluginDirs The path to the plugins dir.
     * @param string $vendorDir The path to the vendor dir.
     * @return array<string, string> Plugin name indexed paths to plugins.
     */
    public function findPlugins(
        array $packages,
        array $pluginDirs = ['plugins'],
        string $vendorDir = 'vendor'
    ): array {
        $plugins = [];

        foreach ($packages as $package) {
            if ($package->getType() !== 'cakephp-plugin') {
                continue;
            }

            $ns = $this->getPrimaryNamespace($package);
            $path = $vendorDir . DIRECTORY_SEPARATOR . $package->getPrettyName();
            $plugins[$ns] = $path;
        }

        foreach ($pluginDirs as $path) {
            $path = $this->getFullPath($path, $vendorDir);
            if (is_dir($path)) {
                $dir = new DirectoryIterator($path);
                foreach ($dir as $info) {
                    if (!$info->isDir() || $info->isDot()) {
                        continue;
                    }

                    $name = $info->getFilename();
                    if ($name[0] === '.') {
                        continue;
                    }

                    $plugins[$name] = $path . DIRECTORY_SEPARATOR . $name;
                }
            }
        }

        ksort($plugins);

        return $plugins;
    }

    /**
     * Turns relative paths in full paths.
     *
     * @param string $path Path.
     * @param string $vendorDir The path to the vendor dir.
     * @return string
     */
    public function getFullPath(string $path, string $vendorDir): string
    {
        if (preg_match('{^(?:/|[a-z]:|[a-z0-9.]+://)}i', $path)) {
            return rtrim($path, '/');
        }

        if (substr($path, 0, 2) === './') {
            $path = substr($path, 2);
        }

        return rtrim(dirname($vendorDir) . DIRECTORY_SEPARATOR . $path);
    }

    /**
     * Rewrite the config file with a complete list of plugins.
     *
     * @param string $configFile The path to the config file.
     * @param array<string, string> $plugins Array of plugins.
     * @param string|null $root The root directory. Defaults to a value generated from `$configFile`.
     * @return void
     */
    public function writeConfigFile(string $configFile, array $plugins, ?string $root = null): void
    {
        $root = $root ?: dirname(dirname($configFile));

        $data = '';
        foreach ($plugins as $name => $pluginPath) {
            // Normalize to *nix paths.
            $pluginPath = str_replace('\\', '/', $pluginPath);
            $pluginPath .= '/';

            $pluginPath = str_replace(
                DIRECTORY_SEPARATOR . DIRECTORY_SEPARATOR,
                DIRECTORY_SEPARATOR,
                $pluginPath
            );

            // Namespaced plugins should use /
            $name = str_replace('\\', '/', $name);

            $data .= sprintf("        '%s' => '%s',\n", $name, $pluginPath);
        }

        $contents = <<<'PHP'
<?php
$baseDir = dirname(dirname(__file__));

return [
    'plugins' => [
%s    ],
];

PHP;
        $contents = sprintf($contents, $data);

        // Gross hacks to work around composer smashing `__FILE__` in this
        // PHP file when it runs the code through eval()
        $uppercase = function ($matches) {
            return strtoupper($matches[0]);
        };
        $contents = preg_replace_callback('/__file__/', $uppercase, $contents);

        $root = str_replace(
            DIRECTORY_SEPARATOR . DIRECTORY_SEPARATOR,
            DIRECTORY_SEPARATOR,
            $root
        );

        // Normalize to *nix paths.
        $root = str_replace('\\', '/', $root);
        $contents = str_replace('\'' . $root, '$baseDir . \'', $contents);

        file_put_contents($configFile, $contents);
    }

    /**
     * Path to the plugin config file.
     *
     * @param string $vendorDir Path to composer-vendor dir.
     * @return string Absolute file path.
     */
    public function getConfigFilePath(string $vendorDir): string
    {
        return $vendorDir . DIRECTORY_SEPARATOR . 'cakephp-plugins.php';
    }

    /**
     * Get the primary namespace for a plugin package.
     *
     * @param \Composer\Package\PackageInterface $package Composer's package object.
     * @return string The package's primary namespace.
     * @throws \RuntimeException When the package's primary namespace cannot be determined.
     */
    public function getPrimaryNamespace(PackageInterface $package): string
    {
        $primaryNs = null;
        $autoLoad = $package->getAutoload();
        /** @var array<string, string> $pathMap */
        foreach ($autoLoad as $type => $pathMap) {
            if ($type !== 'psr-4') {
                continue;
            }
            $count = count($pathMap);

            if ($count === 1) {
                $primaryNs = key($pathMap);
                break;
            }

            $matches = preg_grep('#^(\./)?src/?$#', $pathMap);
            if ($matches) {
                $primaryNs = key($matches);
                break;
            }

            foreach (['', '.'] as $path) {
                $key = array_search($path, $pathMap, true);
                if ($key !== false) {
                    $primaryNs = $key;
                }
            }
            break;
        }

        if (!$primaryNs) {
            throw new RuntimeException(
                sprintf(
                    'Unable to get primary namespace for package %s.' .
                    "\nEnsure you have added proper 'autoload' section to your plugin's config" .
                    ' as stated in README on https://github.com/cakephp/plugin-installer',
                    $package->getName()
                )
            );
        }

        return trim($primaryNs, '\\');
    }
}
