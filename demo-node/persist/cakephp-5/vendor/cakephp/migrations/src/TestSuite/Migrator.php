<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Migrations\TestSuite;

use Cake\Database\Connection;
use Cake\Datasource\ConnectionManager;
use Cake\Log\Log;
use Cake\TestSuite\ConnectionHelper;
use Exception;
use Migrations\Migrations;
use RuntimeException;

class Migrator
{
    /**
     * @var \Cake\TestSuite\ConnectionHelper
     */
    protected ConnectionHelper $helper;

    /**
     * Constructor.
     */
    public function __construct()
    {
        /** @psalm-suppress InternalClass */
        $this->helper = new ConnectionHelper();
    }

    /**
     * Runs one set of migrations.
     * This is useful if all your migrations are located in config/Migrations,
     * or in a single directory, or in a single plugin.
     *
     * ## Options
     *
     * - `skip` A list of `fnmatch` compatible table names that should be ignored.
     *
     * For additional options {@see \Migrations\Migrations::migrate()}.
     *
     * @param array<string, mixed> $options Migrate options. Connection defaults to `test`.
     * @param bool $truncateTables Truncate all tables after running migrations. Defaults to true.
     * @return void
     */
    public function run(
        array $options = [],
        bool $truncateTables = true
    ): void {
        $this->runMany([$options], $truncateTables);
    }

    /**
     * Runs multiple sets of migrations.
     * This is useful if your migrations are located in multiple sources, plugins or connections.
     *
     * For options, {@see \Migrations\Migrator::run()}.
     *
     * Example:
     *
     * $this->runMany([
     *  ['connection' => 'some-connection', 'source' => 'some/directory'],
     *  ['plugin' => 'PluginA']
     * ]);
     *
     * @param array<array<string, mixed>> $options Array of option arrays.
     * @param bool $truncateTables Truncate all tables after running migrations. Defaults to true.
     * @return void
     */
    public function runMany(
        array $options = [],
        bool $truncateTables = true
    ): void {
        // Don't recreate schema if we are in a phpunit separate process test.
        if (isset($GLOBALS['__PHPUNIT_BOOTSTRAP'])) {
            return;
        }

        // Detect all connections involved, and mark those with changed status.
        $connectionsToDrop = [];
        $connectionsList = [];
        foreach ($options as $i => $migrationSet) {
            $migrationSet += ['connection' => 'test'];
            $skip = $migrationSet['skip'] ?? [];
            unset($migrationSet['skip']);

            $options[$i] = $migrationSet;
            $connectionName = $migrationSet['connection'];
            if (!isset($connectionsList[$connectionName])) {
                $connectionsList[$connectionName] = ['name' => $connectionName, 'skip' => $skip];
            }

            $migrations = new Migrations();
            if (!isset($connectionsToDrop[$connectionName]) && $this->shouldDropTables($migrations, $migrationSet)) {
                $connectionsToDrop[$connectionName] = ['name' => $connectionName, 'skip' => $skip];
            }
        }

        foreach ($connectionsToDrop as $item) {
            $this->dropTables($item['name'], $item['skip']);
        }

        // Run all sets of migrations
        foreach ($options as $migrationSet) {
            $migrations = new Migrations();

            try {
                if (!$migrations->migrate($migrationSet)) {
                    throw new RuntimeException(
                        "Unable to migrate fixtures for `{$migrationSet['connection']}`."
                    );
                }
            } catch (Exception $e) {
                throw new RuntimeException(
                    'Could not apply migrations for ' . json_encode($migrationSet) . "\n\n" .
                    "Migrations failed to apply with message:\n\n" .
                    $e->getMessage() . "\n\n" .
                    'If you are using the `skip` option and running multiple sets of migrations ' .
                    'on the same connection try calling `truncate()` before `runMany()` to avoid this.',
                    0,
                    $e
                );
            }
        }

        // Truncate all connections if required in parameters
        if ($truncateTables) {
            foreach ($connectionsList as $item) {
                $this->truncate($item['name'], $item['skip']);
            }
        }
    }

    /**
     * Truncate tables after calling run([], false)
     *
     * For options, {@see \Migrations\Migrations::migrate()}.
     *
     * @param string $connection Connection name to truncate all non-phinx tables
     * @param string[] $skip A fnmatch compatible list of table names to skip.
     * @return void
     */
    public function truncate(string $connection, array $skip = []): void
    {
        // Don't recreate schema if we are in a phpunit separate process test.
        if (isset($GLOBALS['__PHPUNIT_BOOTSTRAP'])) {
            return;
        }

        $tables = $this->getNonPhinxTables($connection, $skip);
        if ($tables) {
            /** @psalm-suppress InternalMethod */
            $this->helper->truncateTables($connection, $tables);
        }
    }

    /**
     * Detect if migrations have changed and the database needs to be wiped.
     *
     * @param \Migrations\Migrations $migrations The migrations service.
     * @param array $options The connection options.
     * @return bool
     */
    protected function shouldDropTables(Migrations $migrations, array $options): bool
    {
        Log::write('debug', "Reading migrations status for {$options['connection']}...");

        $messages = [
            'down' => [],
            'missing' => [],
        ];
        foreach ($migrations->status($options) as $migration) {
            if ($migration['status'] === 'up' && ($migration['missing'] ?? false)) {
                $messages['missing'][] = 'Applied but, missing Migration ' .
                    "source={$migration['name']} id={$migration['id']}";
            }
            if ($migration['status'] === 'down') {
                $messages['down'][] = "Migration to reverse. source={$migration['name']} id={$migration['id']}";
            }
        }
        $output = [];
        $hasProblems = false;
        $itemize = function ($item) {
            return '- ' . $item;
        };
        if (!empty($messages['down'])) {
            $hasProblems = true;
            $output[] = 'Migrations needing to be reversed:';
            $output = array_merge($output, array_map($itemize, $messages['down']));
            $output[] = '';
        }
        if (!empty($messages['missing'])) {
            $hasProblems = true;
            $output[] = 'Applied but missing migrations:';
            $output = array_merge($output, array_map($itemize, $messages['down']));
            $output[] = '';
        }
        if ($output) {
            $output = array_merge(
                ['Your migration status some differences with the expected state.', ''],
                $output,
                ['Going to drop all tables in this source, and re-apply migrations.']
            );
            Log::write('debug', implode("\n", $output));
        }

        return $hasProblems;
    }

    /**
     * Drops the regular tables of the provided connection
     * and truncates the phinx tables.
     *
     * @param string $connection Connection on which tables are dropped.
     * @param string[] $skip A fnmatch compatible list of tables to skip.
     * @return void
     */
    protected function dropTables(string $connection, array $skip = []): void
    {
        $dropTables = $this->getNonPhinxTables($connection, $skip);
        if (count($dropTables)) {
            /** @psalm-suppress InternalMethod */
            $this->helper->dropTables($connection, $dropTables);
        }
        $phinxTables = $this->getPhinxTables($connection);
        if (count($phinxTables)) {
            /** @psalm-suppress InternalMethod */
            $this->helper->truncateTables($connection, $phinxTables);
        }
    }

    /**
     * Get the list of tables that are phinxlog
     *
     * @param string $connection The connection name to operate on.
     * @return string[] The list of tables that are not related to phinx in the provided connection.
     */
    protected function getPhinxTables(string $connection): array
    {
        $connection = ConnectionManager::get($connection);
        assert($connection instanceof Connection);
        $tables = $connection->getSchemaCollection()->listTables();

        return array_filter($tables, function ($table) {
            return strpos($table, 'phinxlog') !== false;
        });
    }

    /**
     * Get the list of tables that are not phinxlog related.
     *
     * @param string $connection The connection name to operate on.
     * @param string[] $skip A fnmatch compatible list of tables to skip.
     * @return string[] The list of tables that are not related to phinx in the provided connection.
     */
    protected function getNonPhinxTables(string $connection, array $skip): array
    {
        $connection = ConnectionManager::get($connection);
        assert($connection instanceof Connection);
        $tables = $connection->getSchemaCollection()->listTables();
        $skip[] = '*phinxlog*';

        return array_filter($tables, function ($table) use ($skip) {
            foreach ($skip as $pattern) {
                if (fnmatch($pattern, $table) === true) {
                    return false;
                }
            }

            return true;
        });
    }
}
