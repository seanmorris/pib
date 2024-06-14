<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         0.1.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\Command;

use Bake\Utility\Process;
use Bake\Utility\TemplateRenderer;
use Bake\View\BakeView;
use Cake\Command\PluginLoadCommand;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Core\App;
use Cake\Core\Configure;
use Cake\Core\Plugin;
use Cake\Utility\Filesystem;
use Cake\Utility\Inflector;
use RuntimeException;
use function Cake\Core\env;

/**
 * The Plugin Command handles creating an empty plugin, ready to be used
 */
class PluginCommand extends BakeCommand
{
    /**
     * Plugin path.
     *
     * @var string
     */
    public string $path;

    /**
     * initialize
     *
     * @return void
     */
    public function initialize(): void
    {
        parent::initialize();
        $this->path = current(App::path('plugins'));
    }

    /**
     * Execute the command.
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return int|null The exit code or null for success
     */
    public function execute(Arguments $args, ConsoleIo $io): ?int
    {
        $name = $args->getArgument('name');
        if (empty($name)) {
            $io->err('<error>You must provide a plugin name in CamelCase format.</error>');
            $io->err('To make an "MyExample" plugin, run <info>`cake bake plugin MyExample`</info>.');

            return static::CODE_ERROR;
        }
        $parts = explode('/', $name);
        $plugin = implode('/', array_map([Inflector::class, 'camelize'], $parts));

        $pluginPath = $this->_pluginPath($plugin);
        if (is_dir($pluginPath)) {
            $io->out(sprintf('Plugin: %s already exists, no action taken', $plugin));
            $io->out(sprintf('Path: %s', $pluginPath));

            return static::CODE_ERROR;
        }
        if (!$this->bake($plugin, $args, $io)) {
            $io->error(sprintf('An error occurred trying to bake: %s in %s', $plugin, $this->path . $plugin));
            $this->abort();
        }

        return static::CODE_SUCCESS;
    }

    /**
     * Bake the plugin's contents
     *
     * Also update the autoloader and the root composer.json file if it can be found
     *
     * @param string $plugin Name of the plugin in CamelCased format
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return bool|null
     */
    public function bake(string $plugin, Arguments $args, ConsoleIo $io): ?bool
    {
        $pathOptions = App::path('plugins');
        if (count($pathOptions) > 1) {
            $this->findPath($pathOptions, $io);
        }
        $io->out(sprintf('<info>Plugin Name:</info> %s', $plugin));
        $io->out(sprintf('<info>Plugin Directory:</info> %s', $this->path . $plugin));
        $io->hr();

        $looksGood = $io->askChoice('Look okay?', ['y', 'n', 'q'], 'y');

        if (strtolower($looksGood) !== 'y') {
            return null;
        }

        $this->_generateFiles($plugin, $this->path, $args, $io);
        $this->_modifyApplication($plugin, $io);

        $composer = $this->findComposer($args, $io);

        try {
            $cwd = getcwd();

            // Windows makes running multiple commands at once hard.
            chdir(dirname($this->_rootComposerFilePath()));
            $command = 'php ' . escapeshellarg($composer) . ' dump-autoload';
            $process = new Process($io);
            $io->out($process->call($command));

            chdir($cwd);
        } catch (RuntimeException $e) {
            $error = $e->getMessage();
            $io->error(sprintf('Could not run `composer dump-autoload`: %s', $error));
            $this->abort();
        }

        $io->hr();
        $io->out(sprintf('<success>Created:</success> %s in %s', $plugin, $this->path . $plugin), 2);

        $emptyFile = $this->path . '.gitkeep';
        $this->deleteEmptyFile($emptyFile, $io);

        return true;
    }

    /**
     * Modify the application class
     *
     * @param string $plugin Name of plugin the plugin.
     * @param \Cake\Console\ConsoleIo $io ConsoleIo
     * @return void
     */
    protected function _modifyApplication(string $plugin, ConsoleIo $io): void
    {
        $this->executeCommand(PluginLoadCommand::class, [$plugin], $io);
    }

    /**
     * Generate all files for a plugin
     *
     * Find the first path which contains `src/Template/Bake/Plugin` that contains
     * something, and use that as the template to recursively render a plugin's
     * contents. Allows the creation of a bake them containing a `Plugin` folder
     * to provide customized bake output for plugins.
     *
     * @param string $pluginName the CamelCase name of the plugin
     * @param string $path the path to the plugins dir (the containing folder)
     * @param \Cake\Console\Arguments $args CLI arguments.
     * @param \Cake\Console\ConsoleIo $io The io instance.
     * @return void
     */
    protected function _generateFiles(
        string $pluginName,
        string $path,
        Arguments $args,
        ConsoleIo $io
    ): void {
        $namespace = str_replace('/', '\\', $pluginName);
        $baseNamespace = Configure::read('App.namespace');

        $name = $pluginName;
        $vendor = 'your-name-here';
        if (str_contains($pluginName, '/')) {
            [$vendor, $name] = explode('/', $pluginName);
        }
        $package = Inflector::dasherize($vendor) . '/' . Inflector::dasherize($name);

        $composerConfig = json_decode(
            file_get_contents(ROOT . DS . 'composer.json'),
            true
        );

        $renderer = $this->createTemplateRenderer()
            ->set([
                'name' => $name,
                'package' => $package,
                'namespace' => $namespace,
                'baseNamespace' => $baseNamespace,
                'plugin' => $pluginName,
                'routePath' => Inflector::dasherize($pluginName),
                'path' => $path,
                'root' => ROOT,
                'cakeVersion' => $composerConfig['require']['cakephp/cakephp'],
            ]);

        $root = $path . $pluginName . DS;

        $paths = [];
        if ($args->hasOption('theme')) {
            $paths[] = Plugin::templatePath($args->getOption('theme'));
        }

        $paths = array_merge($paths, Configure::read('App.paths.templates'));
        $paths[] = Plugin::templatePath('Bake');

        $fs = new Filesystem();
        $templates = [];
        do {
            $templatesPath = array_shift($paths) . BakeView::BAKE_TEMPLATE_FOLDER . '/Plugin';
            if (is_dir($templatesPath)) {
                $templates = array_keys(iterator_to_array(
                    $fs->findRecursive($templatesPath, '/\.twig$/')
                ));
            }
        } while (!$templates);

        sort($templates);
        foreach ($templates as $template) {
            $template = substr($template, strrpos($template, 'Plugin' . DIRECTORY_SEPARATOR) + 7, -4);
            $template = rtrim($template, '.');
            $filename = $template;
            if ($filename === 'src/Plugin.php') {
                $filename = 'src/' . $name . 'Plugin.php';
            }
            $this->_generateFile($renderer, $template, $root, $filename, $io);
        }
    }

    /**
     * Generate a file
     *
     * @param \Bake\Utility\TemplateRenderer $renderer The renderer to use.
     * @param string $template The template to render
     * @param string $root The path to the plugin's root
     * @param string $filename Filename to generate.
     * @param \Cake\Console\ConsoleIo $io The io instance.
     * @return void
     */
    protected function _generateFile(
        TemplateRenderer $renderer,
        string $template,
        string $root,
        string $filename,
        ConsoleIo $io
    ): void {
        $io->out(sprintf('Generating %s file...', $template));
        $out = $renderer->generate('Bake.Plugin/' . $template);
        $io->createFile($root . $filename, $out);
    }

    /**
     * The path to the main application's composer file
     *
     * This is a test isolation wrapper
     *
     * @return string the abs file path
     */
    protected function _rootComposerFilePath(): string
    {
        return ROOT . DS . 'composer.json';
    }

    /**
     * find and change $this->path to the user selection
     *
     * @param array<string> $pathOptions The list of paths to look in.
     * @param \Cake\Console\ConsoleIo $io The io object
     * @return void
     */
    public function findPath(array $pathOptions, ConsoleIo $io): void
    {
        $valid = false;
        foreach ($pathOptions as $i => $path) {
            if (!is_dir($path)) {
                unset($pathOptions[$i]);
            }
        }
        $pathOptions = array_values($pathOptions);
        $max = count($pathOptions);

        if ($max === 0) {
            $io->error('No valid plugin paths found! Please configure a plugin path that exists.');
            $this->abort();
        }

        if ($max === 1) {
            $this->path = $pathOptions[0];

            return;
        }

        $choice = 0;
        while (!$valid) {
            foreach ($pathOptions as $i => $option) {
                $io->out($i + 1 . '. ' . $option);
            }
            $prompt = 'Choose a plugin path from the paths above.';
            $choice = (int)$io->ask($prompt);
            if ($choice > 0 && $choice <= $max) {
                $valid = true;
            }
        }
        $this->path = $pathOptions[$choice - 1];
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @param \Cake\Console\ConsoleOptionParser $parser The option parser
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser->setDescription(
            'Create the directory structure, AppController class and testing setup for a new plugin. ' .
            'Can create plugins in any of your bootstrapped plugin paths.'
        )->addArgument('name', [
            'help' => 'CamelCased name of the plugin to create.',
        ])->addOption('composer', [
            'default' => ROOT . DS . 'composer.phar',
            'help' => 'The path to the composer executable.',
        ])->addOption('force', [
            'short' => 'f',
            'boolean' => true,
            'help' => 'Force overwriting existing files without prompting.',
        ])->addOption('theme', [
            'short' => 't',
            'help' => 'The theme to use when baking code.',
            'default' => Configure::read('Bake.theme') ?: null,
            'choices' => $this->_getBakeThemes(),
        ]);

        return $parser;
    }

    /**
     * Uses either the CLI option or looks in $PATH and cwd for composer.
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return string|bool Either the path to composer or false if it cannot be found.
     */
    public function findComposer(Arguments $args, ConsoleIo $io): string|bool
    {
        if ($args->hasOption('composer')) {
            /** @var string $path */
            $path = $args->getOption('composer');
            if (file_exists($path)) {
                return $path;
            }
        }
        $composer = false;
        $path = env('PATH');
        if (!empty($path)) {
            $paths = explode(PATH_SEPARATOR, $path);
            $composer = $this->_searchPath($paths, $io);
        }

        return $composer;
    }

    /**
     * Search the $PATH for composer.
     *
     * @param array<string> $path The paths to search.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return string|bool
     */
    protected function _searchPath(array $path, ConsoleIo $io): string|bool
    {
        $composer = ['composer.phar', 'composer'];
        foreach ($path as $dir) {
            foreach ($composer as $cmd) {
                if (is_file($dir . DS . $cmd)) {
                    $io->verbose('Found composer executable in ' . $dir);

                    return $dir . DS . $cmd;
                }
            }
        }

        return false;
    }
}
