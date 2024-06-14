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
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Migrations\Command;

use Bake\Command\SimpleBakeCommand;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Core\Configure;
use Cake\Datasource\ConnectionManager;
use Cake\Utility\Inflector;

/**
 * Task class for generating seed files.
 *
 * @property \Bake\Command\TestCommand $Test
 */
class BakeSeedCommand extends SimpleBakeCommand
{
    /**
     * path to Migration directory
     *
     * @var string
     */
    public string $pathFragment = 'config/Seeds/';

    /**
     * @var string
     */
    protected string $_name;

    /**
     * @inheritDoc
     */
    public static function defaultName(): string
    {
        return 'bake seed';
    }

    /**
     * @inheritDoc
     */
    public function name(): string
    {
        return 'seed';
    }

    /**
     * @inheritDoc
     */
    public function fileName($name): string
    {
        return Inflector::camelize($name) . 'Seed.php';
    }

    /**
     * @inheritDoc
     */
    public function getPath(Arguments $args): string
    {
        $path = ROOT . DS . $this->pathFragment;
        if ($this->plugin) {
            $path = $this->_pluginPath($this->plugin) . $this->pathFragment;
        }

        return str_replace('/', DS, $path);
    }

    /**
     * @inheritDoc
     */
    public function template(): string
    {
        return 'Migrations.Seed/seed';
    }

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

        $table = Inflector::underscore((string)$arguments->getArgumentAt(0));
        if ($arguments->hasOption('table')) {
            /** @var string $table */
            $table = $arguments->getOption('table');
        }

        $records = false;
        if ($arguments->getOption('data')) {
            $limit = (int)$arguments->getOption('limit');

            /** @var string $fields */
            $fields = $arguments->getOption('fields') ?: '*';
            if ($fields !== '*') {
                $fields = explode(',', $fields);
            }
            $model = $this->getTableLocator()->get('BakeSeed', [
                'table' => $table,
                'connection' => ConnectionManager::get($this->connection),
            ]);

            $query = $model->find('all')
                ->enableHydration(false);

            if ($limit) {
                $query->limit($limit);
            }
            if ($fields !== '*') {
                $query->select($fields);
            }

            /** @var array $records */
            $records = $query->disableResultsCasting()->toArray();

            $records = $this->prettifyArray($records);
        }

        return [
            'className' => $this->_name,
            'namespace' => $namespace,
            'records' => $records,
            'table' => $table,
        ];
    }

    /**
     * @inheritDoc
     */
    public function bake(string $name, Arguments $args, ConsoleIo $io): void
    {
        $newArgs = new Arguments(
            $args->getArguments(),
            ['no-test' => true] + $args->getOptions(),
            ['name']
        );
        $this->_name = $name;
        parent::bake($name, $newArgs, $io);
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @param \Cake\Console\ConsoleOptionParser $parser Option parser to update.
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser = parent::buildOptionParser($parser);

        $parser->setDescription(
            'Bake seed class.'
        )->addOption('table', [
            'help' => 'The database table to use.',
        ])->addOption('data', [
            'boolean' => true,
            'help' => 'Include data from the table to the seed',
        ])->addOption('fields', [
            'default' => '*',
            'help' => 'If including data, comma separated list of fields to select (all fields by default)',
        ])->addOption('limit', [
            'short' => 'l',
            'help' => 'If including data, max number of rows to select',
        ]);

        return $parser;
    }

    /**
     * Prettify var_export of an array output
     *
     * @param array $array              Array to prettify
     * @param int $tabCount             Initial tab count
     * @param string $indentCharacter   Desired indent for the code.
     * @return string
     */
    protected function prettifyArray(array $array, int $tabCount = 3, string $indentCharacter = '    '): string
    {
        $content = var_export($array, true);

        $lines = explode("\n", $content);

        $inString = false;

        foreach ($lines as $k => &$line) {
            if ($k === 0) {
                // First row
                $line = '[';
                continue;
            }

            if ($k === count($lines) - 1) {
                // Last row
                $line = str_repeat($indentCharacter, --$tabCount) . ']';
                continue;
            }

            $line = ltrim($line);

            if (!$inString) {
                if ($line === '),') {
                    // Check for closing bracket
                    $line = '],';
                    $tabCount--;
                } elseif (preg_match("/^\d+\s\=\>\s$/", $line)) {
                    // Mark '0 =>' kind of lines to remove
                    $line = false;
                    continue;
                }

                //Insert tab count
                $line = str_repeat($indentCharacter, $tabCount) . $line;
            }

            $length = strlen($line);
            for ($j = 0; $j < $length; $j++) {
                if ($line[$j] === '\\') {
                    // skip character right after an escape \
                    $j++;
                } elseif ($line[$j] === '\'') {
                    // check string open/end
                    $inString = !$inString;
                }
            }

            // check for opening bracket
            if (!$inString && trim($line) === 'array (') {
                $line = str_replace('array (', '[', $line);
                $tabCount++;
            }
        }
        unset($line);

        // Remove marked lines
        $lines = array_filter($lines, function ($line) {
            return $line !== false;
        });

        return implode("\n", $lines);
    }
}
