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

use Bake\Utility\CommonOptionsTrait;
use Bake\Utility\TableScanner;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Datasource\ConnectionManager;

/**
 * Task class for creating all fixtures in an application
 */
class FixtureAllCommand extends BakeCommand
{
    use CommonOptionsTrait;

    /**
     * @inheritDoc
     */
    public static function defaultName(): string
    {
        return 'bake fixture all';
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @param \Cake\Console\ConsoleOptionParser $parser The parser to update
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser = $this->_setCommonOptions($parser);

        $parser = $parser->setDescription(
            'Generate all fixtures for use with the test suite.'
        )->addOption('count', [
            'help' => 'When using generated data, the number of records to include in the fixture(s).',
            'short' => 'n',
            'default' => '1',
        ])->addOption('schema', [
            'help' => 'Create a fixture that imports schema, instead of dumping a schema snapshot into the fixture.',
            'short' => 's',
            'boolean' => true,
        ])->addOption('records', [
            'help' => 'Generate a fixture with records from the non-test database.' .
            ' Used with --count and --conditions to limit which records are added to the fixture.',
            'short' => 'r',
            'boolean' => true,
        ])->addOption('conditions', [
            'help' => 'The SQL snippet to use when importing records.',
            'default' => '1=1',
        ]);

        return $parser;
    }

    /**
     * Execute the command.
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return int|null
     */
    public function execute(Arguments $args, ConsoleIo $io): ?int
    {
        $this->extractCommonProperties($args);

        /** @var \Cake\Database\Connection $connection */
        $connection = ConnectionManager::get($args->getOption('connection') ?? 'default');
        $scanner = new TableScanner($connection);
        $fixture = new FixtureCommand();
        foreach ($scanner->listUnskipped() as $table) {
            $fixtureArgs = new Arguments([$table], $args->getOptions(), ['name']);
            $fixture->execute($fixtureArgs, $io);
        }

        return static::CODE_SUCCESS;
    }
}
