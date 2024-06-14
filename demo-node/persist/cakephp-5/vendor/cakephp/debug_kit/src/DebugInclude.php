<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit;

use Cake\Core\Plugin as CorePlugin;
use Composer\Json\JsonFile;
use InvalidArgumentException;

/**
 * Contains methods for Providing list of files.
 */
class DebugInclude
{
    /**
     * The list of plugins within the application
     *
     * @var array<string>
     */
    protected array $_pluginPaths = [];

    /**
     * The list of Composer packages
     *
     * @var array<string>
     */
    protected array $_composerPaths = [];

    /**
     * File Types
     *
     * @var array
     */
    protected array $_fileTypes = [
        'Auth', 'Cache', 'Collection', 'Config', 'Configure', 'Console', 'Component', 'Controller',
        'Behavior', 'Database', 'Datasource', 'Model', 'Template', 'View', 'Utility',
        'Network', 'Routing', 'I18n', 'Log', 'Error', 'Event', 'Form', 'Filesystem',
        'ORM', 'Filter', 'Validation',
    ];

    /**
     * Get a list of plugins on construct for later use
     */
    public function __construct()
    {
        foreach (CorePlugin::loaded() as $plugin) {
            $this->_pluginPaths[$plugin] = str_replace('/', DIRECTORY_SEPARATOR, CorePlugin::path($plugin));
        }

        $lockFile = new JsonFile(ROOT . DIRECTORY_SEPARATOR . 'composer.lock');
        if ($lockFile->exists()) {
            $lockContent = $lockFile->read();

            $vendorDir = ROOT . DIRECTORY_SEPARATOR . 'vendor' . DIRECTORY_SEPARATOR;
            $packages = array_merge($lockContent['packages'], $lockContent['packages-dev']);

            foreach ($packages as $package) {
                /** @var string $name */
                $name = $package['name'];
                $this->_composerPaths[$name] = $vendorDir
                    . str_replace('/', DIRECTORY_SEPARATOR, $name)
                    . DIRECTORY_SEPARATOR;
            }
        }
    }

    /**
     * Get the possible include paths
     *
     * @return array
     */
    public function includePaths(): array
    {
        /** @psalm-suppress RedundantCast */
        $paths = explode(PATH_SEPARATOR, (string)get_include_path());
        $paths = array_filter($paths, function ($path) {
            if ($path === '.' || strlen($path) === 0) {
                return false;
            }

            return true;
        });

        return array_values($paths);
    }

    /**
     * Check if a path is part of CakePHP
     *
     * @param string $file File to check
     * @return bool
     */
    public function isCakeFile(string $file): bool
    {
        return strpos($file, CAKE) === 0;
    }

    /**
     * Check if a path is from APP but not a plugin
     *
     * @param string $file File to check
     * @return bool
     */
    public function isAppFile(string $file): bool
    {
        return strpos($file, APP) === 0;
    }

    /**
     * Detect plugin the file belongs to
     *
     * @param string $file File to check
     * @return string|bool plugin name, or false if not plugin
     */
    public function getPluginName(string $file): string|bool
    {
        foreach ($this->_pluginPaths as $plugin => $path) {
            if (strpos($file, $path) === 0) {
                return $plugin;
            }
        }

        return false;
    }

    /**
     * Detect Composer package the file belongs to
     *
     * @param string $file File to check
     * @return string|bool package name, or false if not Composer package
     */
    public function getComposerPackageName(string $file): string|bool
    {
        foreach ($this->_composerPaths as $package => $path) {
            if (strpos($file, $path) === 0) {
                return $package;
            }
        }

        return false;
    }

    /**
     * Replace the path with APP, CAKE, ROOT or the plugin name
     *
     * @param string $file File to check
     * @param string $type The file type
     * @param string|null $name plugin name or composer package
     * @return string Path with replaced prefix
     */
    public function niceFileName(string $file, string $type, ?string $name = null): string
    {
        switch ($type) {
            case 'app':
                return str_replace(APP, 'APP' . DIRECTORY_SEPARATOR, $file);

            case 'cake':
                return str_replace(CAKE, 'CAKE' . DIRECTORY_SEPARATOR, $file);

            case 'root':
                return str_replace(ROOT, 'ROOT', $file);

            case 'plugin':
                return str_replace($this->_pluginPaths[$name], $name . DIRECTORY_SEPARATOR, $file);

            case 'vendor':
                return str_replace($this->_composerPaths[$name], '', $file);
        }

        throw new InvalidArgumentException("Type `{$type}` is not supported.");
    }

    /**
     * Get the type of file (model, controller etc)
     *
     * @param string $file File to check.
     * @return string
     */
    public function getFileType(string $file): string
    {
        foreach ($this->_fileTypes as $type) {
            if (stripos($file, DIRECTORY_SEPARATOR . $type . DIRECTORY_SEPARATOR) !== false) {
                return $type;
            }
        }

        return 'other';
    }
}
