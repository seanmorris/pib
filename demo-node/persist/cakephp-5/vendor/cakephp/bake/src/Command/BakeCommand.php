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
 * @since         2.0.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\Command;

use Bake\CodeGen\CodeParser;
use Bake\CodeGen\ParsedFile;
use Bake\Utility\CommonOptionsTrait;
use Bake\Utility\TemplateRenderer;
use Cake\Command\Command;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Core\Configure;
use Cake\Core\ConventionsTrait;
use Cake\Event\Event;
use Cake\Event\EventManager;
use InvalidArgumentException;
use function Cake\Core\pluginSplit;

/**
 * Base class for commands that bake can use.
 *
 * Classes that extend this class will be auto-discovered by bake
 * and attached as subcommands.
 */
abstract class BakeCommand extends Command
{
    use CommonOptionsTrait;
    use ConventionsTrait;

    /**
     * The pathFragment appended to the plugin/app path.
     *
     * @var string
     */
    protected string $pathFragment;

    /**
     * Get the command name.
     *
     * Returns the command name based on class name.
     * For e.g. for a command with class name `UpdateTableCommand` or `BakeUpdateTableCommand`
     * the default name returned would be `'bake update_table'`.
     *
     * @return string
     */
    public static function defaultName(): string
    {
        $name = parent::defaultName();
        if (strpos($name, 'bake_') === 0) {
            $name = substr($name, 5);
        }

        return 'bake ' . $name;
    }

    /**
     * Handles splitting up the plugin prefix and classname.
     *
     * Sets the plugin parameter and plugin property.
     *
     * @param string $name The name to possibly split.
     * @return string The name without the plugin prefix.
     */
    protected function _getName(string $name): string
    {
        if (strpos($name, '.')) {
            [$plugin, $name] = pluginSplit($name);
            $this->plugin = $plugin;
        }

        return $name;
    }

    /**
     * Get the prefix name.
     *
     * Handles camelcasing each namespace in the prefix path.
     *
     * @param \Cake\Console\Arguments $args Arguments instance to read the prefix option from.
     * @return string The inflected prefix path.
     */
    protected function getPrefix(Arguments $args): string
    {
        $prefix = $args->getOption('prefix');
        if (!$prefix) {
            return '';
        }
        $parts = explode('/', $prefix);

        return implode('/', array_map([$this, '_camelize'], $parts));
    }

    /**
     * Gets the path for output. Checks the plugin property
     * and returns the correct path.
     *
     * @param \Cake\Console\Arguments $args Arguments instance to read the prefix option from.
     * @return string Path to output.
     */
    public function getPath(Arguments $args): string
    {
        $path = APP . $this->pathFragment;
        if ($this->plugin) {
            $path = $this->_pluginPath($this->plugin) . 'src/' . $this->pathFragment;
        }
        $prefix = $this->getPrefix($args);
        if ($prefix) {
            $path .= $prefix . DIRECTORY_SEPARATOR;
        }

        return str_replace('/', DIRECTORY_SEPARATOR, $path);
    }

    /**
     * Gets the path to the template path for the application or plugin.
     *
     * @param \Cake\Console\Arguments $args Arguments instance to read the prefix option from.
     * @param string|null $container The container directory in the templates directory.
     * @return string Path to output.
     */
    public function getTemplatePath(Arguments $args, ?string $container = null): string
    {
        $paths = (array)Configure::read('App.paths.templates');
        if (empty($paths)) {
            throw new InvalidArgumentException(
                'Could not read template paths. ' .
                'Ensure `App.paths.templates` is defined in your application configuration.'
            );
        }
        $path = $paths[0];
        if ($this->plugin) {
            $path = $this->_pluginPath($this->plugin) . 'templates' . DIRECTORY_SEPARATOR;
        }
        if ($container) {
            $path .= $container . DIRECTORY_SEPARATOR;
        }
        $prefix = $this->getPrefix($args);
        if ($prefix) {
            $path .= $prefix . DIRECTORY_SEPARATOR;
        }

        return str_replace('/', DIRECTORY_SEPARATOR, $path);
    }

    /**
     * Creates a new instance of TemplateRenderer with theme set.
     *
     * @return \Bake\Utility\TemplateRenderer
     */
    public function createTemplateRenderer(): TemplateRenderer
    {
        $renderer = new TemplateRenderer($this->theme);
        EventManager::instance()->dispatch(new Event('Bake.renderer', $renderer));

        return $renderer;
    }

    /**
     * Delete empty file in a given path
     *
     * @param string $path Path to folder which contains 'empty' file.
     * @param \Cake\Console\ConsoleIo $io ConsoleIo to delete file with.
     * @return void
     */
    protected function deleteEmptyFile(string $path, ConsoleIo $io): void
    {
        if (file_exists($path)) {
            unlink($path);
            $io->out(sprintf('<success>Deleted</success> `%s`', $path), 1, ConsoleIo::NORMAL);
        }
    }

    /**
     * Check if a column name is valid.
     *
     * The Regex used here basically states that:
     * - the column name has to start with an ASCII character (lower or upper case) or an underscore and
     * - further characters are allowed to be either lower or upper case ASCII characters, numbers or underscores.
     *
     * @param string $name The name of the column.
     * @return bool
     */
    protected function isValidColumnName(string $name): bool
    {
        return (bool)preg_match('/^[a-zA-Z_][a-zA-Z0-9_]*$/', $name);
    }

    /**
     * Parses a file if it exists.
     *
     * @param string $path File path
     * @return \Bake\CodeGen\ParsedFile|null
     */
    protected function parseFile(string $path): ?ParsedFile
    {
        if (file_exists($path)) {
            return (new CodeParser())->parseFile(file_get_contents($path));
        }

        return null;
    }

    /**
     * Write file contents out to path and prompt user with options with file exists.
     *
     * @param \Cake\Console\ConsoleIo $io Console io
     * @param string $path The path to create the file at
     * @param string $contents The contents to put into the file
     * @param bool $forceOverwrite Whether the file should be overwritten without prompting the user
     * @param bool $skipIfUnchanged Skip writing output if the contents match existing file
     * @return bool True if successful, false otherwise
     * @throws \Cake\Console\Exception\StopException When `q` is given as an answer
     *   to whether a file should be overwritten.
     */
    protected function writeFile(
        ConsoleIo $io,
        string $path,
        string $contents,
        bool $forceOverwrite = false,
        bool $skipIfUnchanged = true
    ): bool {
        if ($skipIfUnchanged && file_exists($path) && file_get_contents($path) === $contents) {
            $io->info("Skipping update to `{$path}`. It already exists and would not change.");

            return true;
        }

        return $io->createFile($path, $contents, $forceOverwrite);
    }
}
