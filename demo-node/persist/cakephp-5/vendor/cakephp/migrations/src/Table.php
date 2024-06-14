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

use Cake\Collection\Collection;
use Cake\ORM\Locator\LocatorAwareTrait;
use Phinx\Db\Action\AddColumn;
use Phinx\Db\Table as BaseTable;
use Phinx\Db\Table\Column;
use Phinx\Util\Literal;

/**
 * @method \Migrations\CakeAdapter getAdapter()
 */
class Table extends BaseTable
{
    use LocatorAwareTrait;

    /**
     * Primary key for this table.
     * Can either be a string or an array in case of composite
     * primary key.
     *
     * @var string|string[]
     */
    protected string|array $primaryKey;

    /**
     * Add a primary key to a database table.
     *
     * @param string|string[] $columns Table Column(s)
     * @return $this
     */
    public function addPrimaryKey(string|array $columns)
    {
        $this->primaryKey = $columns;

        return $this;
    }

    /**
     * {@inheritDoc}
     *
     * You can pass `autoIncrement` as an option and it will be converted
     * to the correct option for phinx to create the column with an
     * auto increment attribute
     *
     * @param string|\Phinx\Db\Table\Column $columnName Column Name
     * @param string|\Phinx\Util\Literal|null $type Column Type
     * @param array $options Column Options
     * @throws \InvalidArgumentException
     * @return $this
     */
    public function addColumn(Column|string $columnName, string|Literal|null $type = null, $options = [])
    {
        $options = $this->convertedAutoIncrement($options);

        return parent::addColumn($columnName, $type, $options);
    }

    /**
     * {@inheritDoc}
     *
     * You can pass `autoIncrement` as an option and it will be converted
     * to the correct option for phinx to create the column with an
     * auto increment attribute
     *
     * @param string $columnName Column Name
     * @param string|\Phinx\Db\Table\Column|\Phinx\Util\Literal $newColumnType New Column Type
     * @param array $options Options
     * @return $this
     */
    public function changeColumn(string $columnName, string|Column|Literal $newColumnType, array $options = [])
    {
        $options = $this->convertedAutoIncrement($options);

        return parent::changeColumn($columnName, $newColumnType, $options);
    }

    /**
     * Convert the `autoIncrement` option to the correct options for phinx.
     *
     * @param array $options Options
     * @return array Converted options
     */
    protected function convertedAutoIncrement(array $options): array
    {
        if (isset($options['autoIncrement']) && $options['autoIncrement'] === true) {
            $options['identity'] = true;
            unset($options['autoIncrement']);
        }

        return $options;
    }

    /**
     * {@inheritDoc}
     *
     * If using MySQL and no collation information has been given to the table options, a request to the information
     * schema will be made to get the default database collation and apply it to the database. This is to prevent
     * phinx default mechanism to put the collation to a default of "utf8_general_ci".
     *
     * @return void
     */
    public function create(): void
    {
        $options = $this->getTable()->getOptions();
        if ((!isset($options['id']) || $options['id'] === false) && !empty($this->primaryKey)) {
            $options['primary_key'] = $this->primaryKey;
            $this->filterPrimaryKey();
        }

        if ($this->getAdapter()->getAdapterType() === 'mysql' && empty($options['collation'])) {
            $encodingRequest = 'SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
                FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = :dbname';

            $cakeConnection = $this->getAdapter()->getCakeConnection();
            $connectionConfig = $cakeConnection->config();

            $statement = $cakeConnection->execute($encodingRequest, ['dbname' => $connectionConfig['database']]);
            $defaultEncoding = $statement->fetch('assoc');
            if (!empty($defaultEncoding['DEFAULT_COLLATION_NAME'])) {
                $options['collation'] = $defaultEncoding['DEFAULT_COLLATION_NAME'];
            }
        }

        $this->getTable()->setOptions($options);

        parent::create();
    }

    /**
     * {@inheritDoc}
     *
     * After a table update, the TableRegistry should be cleared in order to prevent issues with
     * table schema stored in Table objects having columns that might have been renamed or removed during
     * the update process.
     *
     * @return void
     */
    public function update(): void
    {
        parent::update();
        $this->getTableLocator()->clear();
    }

    /**
     * {@inheritDoc}
     *
     * We disable foreign key deletion for the SQLite adapter as SQLite does not support the feature natively and the
     * process implemented by Phinx has serious side-effects (for instance it rename FK references in existing tables
     * which breaks the database schema cohesion).
     *
     * @param string|array $columns Column(s)
     * @param string|null $constraint Constraint names
     * @return $this
     */
    public function dropForeignKey($columns, $constraint = null)
    {
        if ($this->getAdapter()->getAdapterType() === 'sqlite') {
            return $this;
        }

        return parent::dropForeignKey($columns, $constraint);
    }

    /**
     * This method is called in case a primary key was defined using the addPrimaryKey() method.
     * It currently does something only if using SQLite.
     * If a column is an auto-increment key in SQLite, it has to be a primary key and it has to defined
     * when defining the column. Phinx takes care of that so we have to make sure columns defined as autoincrement were
     * not added with the addPrimaryKey method, otherwise, SQL queries will be wrong.
     *
     * @return void
     */
    protected function filterPrimaryKey(): void
    {
        $options = $this->getTable()->getOptions();
        if ($this->getAdapter()->getAdapterType() !== 'sqlite' || empty($options['primary_key'])) {
            return;
        }

        $primaryKey = $options['primary_key'];
        if (!is_array($primaryKey)) {
            $primaryKey = [$primaryKey];
        }
        $primaryKey = array_flip($primaryKey);

        $columnsCollection = (new Collection($this->actions->getActions()))
            ->filter(function ($action) {
                return $action instanceof AddColumn;
            })
            ->map(function ($action) {
                /** @var \Phinx\Db\Action\ChangeColumn|\Phinx\Db\Action\RenameColumn|\Phinx\Db\Action\RemoveColumn|\Phinx\Db\Action\AddColumn $action */
                return $action->getColumn();
            });
        $primaryKeyColumns = $columnsCollection->filter(function (Column $columnDef, $key) use ($primaryKey) {
            return isset($primaryKey[$columnDef->getName()]);
        })->toArray();

        if (empty($primaryKeyColumns)) {
            return;
        }

        foreach ($primaryKeyColumns as $primaryKeyColumn) {
            if ($primaryKeyColumn->isIdentity()) {
                unset($primaryKey[$primaryKeyColumn->getName()]);
            }
        }

        $primaryKey = array_flip($primaryKey);

        if (!empty($primaryKey)) {
            $options['primary_key'] = $primaryKey;
        } else {
            unset($options['primary_key']);
        }

        $this->getTable()->setOptions($options);
    }

    /**
     * @inheritDoc
     */
    public function addTimestamps($createdAt = '', $updatedAt = '', bool $withTimezone = false)
    {
        $createdAt = $createdAt ?: 'created';
        $updatedAt = $updatedAt ?: 'modified';

        return parent::addTimestamps($createdAt, $updatedAt, $withTimezone);
    }
}
