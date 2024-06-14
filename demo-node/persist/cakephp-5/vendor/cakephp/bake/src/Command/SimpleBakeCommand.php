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

use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Core\Configure;
use Cake\Utility\Inflector;

/**
 * Base class for simple bake tasks code generator.
 */
abstract class SimpleBakeCommand extends BakeCommand
{
    /**
     * Get the generated object's name.
     *
     * @return string
     */
    abstract public function name(): string;

    /**
     * Get the generated object's filename without the leading path.
     *
     * @param string $name The name of the object being generated
     * @return string
     */
    abstract public function fileName(string $name): string;

    /**
     * Get the template name.
     *
     * @return string
     */
    abstract public function template(): string;

    /**
     * Get template data.
     *
     * @param \Cake\Console\Arguments $arguments The arguments for the command
     * @return array
     * @phpstan-return array<string, mixed>
     */
    public function templateData(Arguments $arguments): array
    {
        $namespace = Configure::read('App.namespace');
        if ($this->plugin) {
            $namespace = $this->_pluginNamespace($this->plugin);
        }

        return ['namespace' => $namespace];
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
        $this->extractCommonProperties($args);
        $name = $args->getArgumentAt(0);
        if (empty($name)) {
            $io->err('You must provide a name to bake a ' . $this->name());
            $this->abort();
        }
        $name = $this->_getName($name);
        $name = Inflector::camelize($name);
        $this->bake($name, $args, $io);
        $this->bakeTest($name, $args, $io);

        return static::CODE_SUCCESS;
    }

    /**
     * Generate a class stub
     *
     * @param string $name The class name
     * @param \Cake\Console\Arguments $args The console arguments
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return void
     */
    protected function bake(string $name, Arguments $args, ConsoleIo $io): void
    {
        $contents = $this->createTemplateRenderer()
            ->set('name', $name)
            ->set($this->templateData($args))
            ->generate($this->template());

        $filename = $this->getPath($args) . $this->fileName($name);
        $io->createFile($filename, $contents, $this->force);

        $emptyFile = $this->getPath($args) . '.gitkeep';
        $this->deleteEmptyFile($emptyFile, $io);
    }

    /**
     * Generate a test case.
     *
     * @param string $className The class to bake a test for.
     * @param \Cake\Console\Arguments $args The console arguments
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return void
     */
    public function bakeTest(string $className, Arguments $args, ConsoleIo $io): void
    {
        if ($args->getOption('no-test')) {
            return;
        }
        $test = new TestCommand();
        $test->plugin = $this->plugin;
        $test->bake($this->name(), $className, $args, $io);
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @param \Cake\Console\ConsoleOptionParser $parser Option parser to update.
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser = $this->_setCommonOptions($parser);
        $name = $this->name();
        $parser->setDescription(
            sprintf('Bake a %s class file.', $name)
        )->addArgument('name', [
            'help' => sprintf(
                'Name of the %s to bake. Can use Plugin.name to bake %s files into plugins.',
                $name,
                $name
            ),
        ])->addOption('no-test', [
            'boolean' => true,
            'help' => 'Do not generate a test skeleton.',
        ]);

        return $parser;
    }
}
