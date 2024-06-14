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
namespace Migrations;

use Cake\Core\App;
use Cake\Core\Plugin as CorePlugin;
use Cake\Database\Schema\CollectionInterface;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use ReflectionClass;

trait TableFinderTrait
{
    /**
     * Tables to skip
     *
     * @var string[]
     */
    public array $skipTables = ['phinxlog'];

    /**
     * Regex of Table name to skip
     *
     * @var string
     */
    public string $skipTablesRegex = '_phinxlog';

    /**
     * Gets a list of table to baked based on the Collection instance passed and the options passed to
     * the shell call.
     *
     * @param \Cake\Database\Schema\CollectionInterface $collection Instance of the collection of a specific database
     * connection.
     * @param array $options Array of options passed to a shell call.
     * @return array
     */
    protected function getTablesToBake(CollectionInterface $collection, array $options = []): array
    {
        $options += [
            'require-table' => false,
            'plugin' => null,
        ];
        $tables = $collection->listTables();

        if (empty($tables)) {
            return $tables;
        }

        if ($options['require-table'] === true || $options['plugin']) {
            $tableNamesInModel = $this->getTableNames($options['plugin']);

            if (empty($tableNamesInModel)) {
                return [];
            }

            foreach ($tableNamesInModel as $num => $table) {
                if ($table && str_contains($table, '.')) {
                    $split = array_reverse(explode('.', $table, 2));

                    $config = (array)ConnectionManager::getConfig($this->connection);
                    $key = isset($config['schema']) ? 'schema' : 'database';
                    if ($config[$key] === $split[1]) {
                        $table = $split[0];
                    }
                }

                if (!in_array($table, $tables, true)) {
                    unset($tableNamesInModel[$num]);
                }
            }
            $tables = $tableNamesInModel;
        } else {
            foreach ($tables as $num => $table) {
                if (in_array($table, $this->skipTables, true) || (strpos($table, $this->skipTablesRegex) !== false)) {
                    unset($tables[$num]);
                    continue;
                }
            }
        }

        return $tables;
    }

    /**
     * Gets list Tables Names
     *
     * @param string|null $pluginName Plugin name if exists.
     * @return array<int, string|null>
     */
    protected function getTableNames(?string $pluginName = null): array
    {
        if ($pluginName !== null && !CorePlugin::getCollection()->has($pluginName)) {
            return [];
        }
        $list = [];
        $tables = $this->findTables($pluginName);

        if (empty($tables)) {
            return [];
        }

        foreach ($tables as $table) {
            $list = array_merge($list, $this->fetchTableName($table, $pluginName));
        }

        return array_unique($list);
    }

    /**
     * Find Table Class
     *
     * @param string|null $pluginName Plugin name if exists.
     * @return array
     */
    protected function findTables(?string $pluginName = null): array
    {
        $path = 'Model' . DS . 'Table' . DS;
        if ($pluginName) {
            $path = CorePlugin::path($pluginName) . 'src' . DS . $path;
        } else {
            /** @psalm-suppress UndefinedConstant */
            $path = APP . $path;
        }

        if (!is_dir($path)) {
            return [];
        }

        return array_map('basename', glob($path . '*.php') ?: []);
    }

    /**
     * fetch TableName From Table Object
     *
     * @param string $className Name of Table Class.
     * @param string|null $pluginName Plugin name if exists.
     * @return list<null|string>
     */
    protected function fetchTableName(string $className, ?string $pluginName = null): array
    {
        $tables = [];
        $className = str_replace('Table.php', '', $className);
        if (!$className) {
            return $tables;
        }

        if ($pluginName !== null) {
            $className = $pluginName . '.' . $className;
        }

        $namespacedClassName = App::className($className, 'Model/Table', 'Table');

        if ($namespacedClassName === null) {
            return $tables;
        }

        $reflection = new ReflectionClass($namespacedClassName);
        if (!$reflection->isInstantiable()) {
            return $tables;
        }

        $table = TableRegistry::getTableLocator()->get($className);
        foreach ($table->associations()->keys() as $key) {
            /** @psalm-suppress PossiblyNullReference */
            if ($table->associations()->get($key)->type() === 'belongsToMany') {
                /** @var \Cake\ORM\Association\BelongsToMany $belongsToMany */
                $belongsToMany = $table->associations()->get($key);
                $tables[] = $belongsToMany->junction()->getTable();
            }
        }
        $tableName = $table->getTable();
        $splitted = array_reverse(explode('.', $tableName, 2));
        if (isset($splitted[1])) {
            $config = ConnectionManager::getConfig($this->connection);
            if ($config) {
                $key = isset($config['schema']) ? 'schema' : 'database';
                if ($config[$key] === $splitted[1]) {
                    $tableName = $splitted[0];
                }
            }
        }
        $tables[] = $tableName;

        return $tables;
    }
}
