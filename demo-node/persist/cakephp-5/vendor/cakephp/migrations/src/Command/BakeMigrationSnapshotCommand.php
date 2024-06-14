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

use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Core\Configure;
use Cake\Database\Connection;
use Cake\Database\Schema\CollectionInterface;
use Cake\Datasource\ConnectionManager;
use Cake\Event\Event;
use Cake\Event\EventManager;
use Migrations\TableFinderTrait;
use Migrations\Util\UtilTrait;

/**
 * Task class for generating migration snapshot files.
 */
class BakeMigrationSnapshotCommand extends BakeSimpleMigrationCommand
{
    use SnapshotTrait;
    use TableFinderTrait;
    use UtilTrait;

    /**
     * @var string
     */
    protected string $_name;

    /**
     * @inheritDoc
     */
    public static function defaultName(): string
    {
        return 'bake migration_snapshot';
    }

    /**
     * @inheritDoc
     */
    public function bake(string $name, Arguments $args, ConsoleIo $io): void
    {
        $collection = $this->getCollection($this->connection);

        $connection = ConnectionManager::get($this->connection);
        assert($connection instanceof Connection);

        EventManager::instance()->on('Bake.initialize', function (Event $event) use ($collection, $connection): void {
            $event->getSubject()->loadHelper('Migrations.Migration', [
                'collection' => $collection,
                'connection' => $connection,
            ]);
        });
        $this->_name = $name;

        parent::bake($name, $args, $io);
    }

    /**
     * @inheritDoc
     */
    public function template(): string
    {
        return 'Migrations.config/snapshot';
    }

    /**
     * @inheritDoc
     */
    public function templateData(Arguments $arguments): array
    {
        $namespace = Configure::read('App.namespace');
        $pluginPath = '';
        if ($this->plugin) {
            $namespace = $this->_pluginNamespace($this->plugin);
            $pluginPath = $this->plugin . '.';
        }

        $collection = $this->getCollection($this->connection);
        $options = [
            'require-table' => $arguments->getOption('require-table'),
            'plugin' => $this->plugin,
        ];
        $tables = $this->getTablesToBake($collection, $options);

        sort($tables, SORT_NATURAL);

        $tables = array_combine($tables, $tables);

        $autoId = true;
        if ($arguments->hasOption('disable-autoid')) {
            $autoId = !$arguments->getOption('disable-autoid');
        }

        return [
            'plugin' => $this->plugin,
            'pluginPath' => $pluginPath,
            'namespace' => $namespace,
            'collection' => $collection,
            'tables' => $tables,
            'action' => 'create_table',
            'name' => $this->_name,
            'autoId' => $autoId,
        ];
    }

    /**
     * Get a collection from a database
     *
     * @param string $connection Database connection name.
     * @return \Cake\Database\Schema\CollectionInterface
     */
    public function getCollection(string $connection): CollectionInterface
    {
        $connection = ConnectionManager::get($connection);
        assert($connection instanceof Connection);

        return $connection->getSchemaCollection();
    }

    /**
     * To check if a Table Model is to be added in the migration file
     *
     * @param string $tableName Table name in underscore case.
     * @param string|null $pluginName Plugin name if exists.
     * @deprecated Will be removed in the next version
     * @return bool True if the model is to be added.
     */
    public function tableToAdd(string $tableName, ?string $pluginName = null): bool
    {
        return true;
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function getOptionParser(): ConsoleOptionParser
    {
        $parser = parent::getOptionParser();

        $parser->setDescription(
            "Bake migration snapshot class\n" .
            "\n" .
            'Migration snapshots capture the current schema of an application into a ' .
            'migration that will reproduce the current state as accurately as possible.'
        )->addArgument('name', [
            'help' => 'Name of the migration to bake. Can use Plugin.name to bake migration files into plugins.',
            'required' => true,
        ])
        ->addOption('require-table', [
            'boolean' => true,
            'default' => false,
            'help' => 'If require-table is set to true, check also that the table class exists.',
        ])->addOption('disable-autoid', [
            'boolean' => true,
            'default' => false,
            'help' => 'Disable phinx behavior of automatically adding an id field.',
        ])
        ->addOption('no-lock', [
            'help' => 'If present, no lock file will be generated after baking',
            'boolean' => true,
        ]);

        return $parser;
    }
}
