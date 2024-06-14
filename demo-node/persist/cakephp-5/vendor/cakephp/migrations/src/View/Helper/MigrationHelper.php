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
namespace Migrations\View\Helper;

use ArrayAccess;
use Cake\Core\Configure;
use Cake\Database\Connection;
use Cake\Database\Driver\Mysql;
use Cake\Database\Schema\CollectionInterface;
use Cake\Database\Schema\TableSchemaInterface;
use Cake\Utility\Hash;
use Cake\Utility\Inflector;
use Cake\View\Helper;
use Cake\View\View;
use Phinx\Config\FeatureFlags;

/**
 * Migration Helper class for output of field data in migration files.
 *
 * MigrationHelper encloses all methods needed while working with HTML pages.
 */
class MigrationHelper extends Helper
{
    /**
     * Schemas list for tables analyzed during migration baking
     *
     * @var array<string, \Cake\Database\Schema\TableSchemaInterface>
     */
    protected array $schemas = [];

    /**
     * Stores the status of the ``$this->table()`` statements issued while baking.
     * It helps prevent duplicate calls in case of complex conditions
     *
     * @var array<bool>
     */
    protected array $tableStatementStatus = [];

    /**
     * @var array<string, array<string, array<string>>>
     */
    protected array $returnedData = [];

    /**
     * Store a table's column listing.
     *
     * @param string $table The table name
     * @param string $columnsList The column list to store.
     * @return void
     */
    public function storeReturnedData(string $table, string $columnsList): void
    {
        $this->returnedData['dropForeignKeys'][$table][] = $columnsList;
    }

    /**
     * Get all stored data.
     *
     * @return array An array of stored data.
     */
    public function getReturnedData(): array
    {
        return $this->returnedData;
    }

    /**
     * Constructor
     *
     * ### Settings
     *
     * - `collection` \Cake\Database\Schema\Collection
     * - `connection` \Cake\Database\Connection
     *
     * @param \Cake\View\View $View The View this helper is being attached to.
     * @param array $config Configuration settings for the helper.
     */
    public function __construct(View $View, array $config = [])
    {
        parent::__construct($View, $config);
    }

    /**
     * Returns the method to be used for the Table::save()
     *
     * @param string|null $action Name of action to take against the table
     * @return string
     */
    public function tableMethod(?string $action = null): string
    {
        if ($action === 'drop_table') {
            return 'drop';
        }

        if ($action === 'create_table') {
            return 'create';
        }

        return 'update';
    }

    /**
     * Returns the method to be used for the index manipulation
     *
     * @param string|null $action Name of action to take against the table
     * @return string
     */
    public function indexMethod(?string $action = null): string
    {
        if ($action === 'drop_field') {
            return 'removeIndex';
        }

        return 'addIndex';
    }

    /**
     * Returns the method to be used for the column manipulation
     *
     * @param string|null $action Name of action to take against the table
     * @return string
     */
    public function columnMethod(?string $action = null): string
    {
        if ($action === 'drop_field') {
            return 'removeColumn';
        }

        if ($action === 'alter_field') {
            return 'changeColumn';
        }

        return 'addColumn';
    }

    /**
     * Returns the Cake\Database\Schema\TableSchemaInterface for $table
     *
     * @param string $table Name of the table to retrieve constraints for.
     * @return \Cake\Database\Schema\TableSchemaInterface
     */
    protected function schema(string $table): TableSchemaInterface
    {
        if (isset($this->schemas[$table])) {
            return $this->schemas[$table];
        }

        $collection = $this->getConfig('collection');
        assert($collection instanceof CollectionInterface);
        $schema = $collection->describe($table);
        $this->schemas[$table] = $schema;

        return $schema;
    }

    /**
     * Returns an array of column data for a given table
     *
     * @param \Cake\Database\Schema\TableSchemaInterface|string $table Name of the table to retrieve constraints for
     *  or a table schema object.
     * @return array<string, array>
     */
    public function columns(TableSchemaInterface|string $table): array
    {
        $tableSchema = $table;
        if (!($tableSchema instanceof TableSchemaInterface)) {
            $tableSchema = $this->schema($tableSchema);
        }
        $columns = [];
        $tablePrimaryKeys = $tableSchema->getPrimaryKey();
        foreach ($tableSchema->columns() as $column) {
            if (in_array($column, $tablePrimaryKeys, true)) {
                continue;
            }
            $columns[$column] = $this->column($tableSchema, $column);
        }

        return $columns;
    }

    /**
     * Returns an array of indexes for a given table
     *
     * @param \Cake\Database\Schema\TableSchemaInterface|string $table Name of the table to retrieve constraints for
     *  or a table schema object.
     * @return array<string, array<string, mixed>|null>
     */
    public function indexes(TableSchemaInterface|string $table): array
    {
        $tableSchema = $table;
        if (!($tableSchema instanceof TableSchemaInterface)) {
            $tableSchema = $this->schema($tableSchema);
        }

        $tableIndexes = $tableSchema->indexes();
        $indexes = [];
        if (!empty($tableIndexes)) {
            foreach ($tableIndexes as $name) {
                $indexes[$name] = $tableSchema->getIndex($name);
            }
        }

        return $indexes;
    }

    /**
     * Returns an array of constraints for a given table
     *
     * @param \Cake\Database\Schema\TableSchemaInterface|string $table Name of the table to retrieve constraints for
     *  or a table schema object.
     * @return array<string, array<string, mixed>|null>
     */
    public function constraints(TableSchemaInterface|string $table): array
    {
        $tableSchema = $table;
        if (!($tableSchema instanceof TableSchemaInterface)) {
            $tableSchema = $this->schema($tableSchema);
        }

        $constraints = [];
        $tableConstraints = $tableSchema->constraints();
        if (empty($tableConstraints)) {
            return $constraints;
        }

        if ($tableConstraints[0] === 'primary') {
            unset($tableConstraints[0]);
        }
        if (!empty($tableConstraints)) {
            foreach ($tableConstraints as $name) {
                $constraint = $tableSchema->getConstraint($name);
                if ($constraint && isset($constraint['update'])) {
                    $constraint['update'] = $this->formatConstraintAction($constraint['update']);
                }
                if ($constraint && isset($constraint['delete'])) {
                    $constraint['delete'] = $this->formatConstraintAction($constraint['delete']);
                }
                $constraints[$name] = $constraint;
            }
        }

        return $constraints;
    }

    /**
     * Format a constraint action if it is not already in the format expected by Phinx
     *
     * @param string $constraint Constraint action name
     * @return string Constraint action name altered if needed.
     */
    public function formatConstraintAction(string $constraint): string
    {
        if (defined('\Phinx\Db\Table\ForeignKey::' . $constraint)) {
            return $constraint;
        }

        return strtoupper(Inflector::underscore($constraint));
    }

    /**
     * Returns the primary key data for a given table
     *
     * @param \Cake\Database\Schema\TableSchemaInterface|string $table Name of the table ot retrieve primary key for
     * @return array<array>
     */
    public function primaryKeys(TableSchemaInterface|string $table): array
    {
        $tableSchema = $table;
        if (!($tableSchema instanceof TableSchemaInterface)) {
            $tableSchema = $this->schema($tableSchema);
        }
        $primaryKeys = [];
        $tablePrimaryKeys = $tableSchema->getPrimaryKey();
        foreach ($tableSchema->columns() as $column) {
            if (in_array($column, $tablePrimaryKeys, true)) {
                $primaryKeys[] = ['name' => $column, 'info' => $this->column($tableSchema, $column)];
            }
        }

        return $primaryKeys;
    }

    /**
     * Returns whether any of the given tables/schemas contains a primary key
     * that is incompatible with automatically generated primary keys for the
     * current driver.
     *
     * @param array<\Cake\Database\Schema\TableSchemaInterface|string> $tables List of schemas/tables to check
     * @return bool
     */
    public function hasAutoIdIncompatiblePrimaryKey(array $tables): bool
    {
        $connection = $this->getConfig('connection');
        assert($connection instanceof Connection);

        // currently only MySQL supports unsigned primary keys
        if (!($connection->getDriver() instanceof Mysql)) {
            return false;
        }

        $useUnsignedPrimaryKes = Configure::read(
            'Migrations.unsigned_primary_keys',
            FeatureFlags::$unsignedPrimaryKeys
        );

        foreach ($tables as $table) {
            $schema = $table;
            if (!($schema instanceof TableSchemaInterface)) {
                $schema = $this->schema($schema);
            }

            foreach ($schema->getPrimaryKey() as $column) {
                $data = $schema->getColumn($column);
                if (isset($data['unsigned']) && $data['unsigned'] === !$useUnsignedPrimaryKes) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Returns the primary key columns name for a given table
     *
     * @param \Cake\Database\Schema\TableSchemaInterface|string $table Name of the table ot retrieve primary key for
     * @return array<string>
     */
    public function primaryKeysColumnsList(TableSchemaInterface|string $table): array
    {
        $primaryKeys = $this->primaryKeys($table);
        /** @var array $primaryKeysColumns */
        $primaryKeysColumns = Hash::extract($primaryKeys, '{n}.name');
        sort($primaryKeysColumns);

        return $primaryKeysColumns;
    }

    /**
     * Returns an array of column data for a single column
     *
     * @param \Cake\Database\Schema\TableSchemaInterface $tableSchema Name of the table to retrieve columns for
     * @param string $column A column to retrieve data for
     * @return array<string, string|array<string, mixed>|null>
     */
    public function column(TableSchemaInterface $tableSchema, string $column): array
    {
        $columnType = $tableSchema->getColumnType($column);
        // Phinx doesn't understand timestampfractional.
        if ($columnType === 'timestampfractional') {
            $columnType = 'timestamp';
        }

        return [
            'columnType' => $columnType,
            'options' => $this->attributes($tableSchema, $column),
        ];
    }

    /**
     * Compute the final array of options to display in a `addColumn` or `changeColumn` instruction.
     * The method also takes care of translating properties names between CakePHP database layer and phinx database
     * layer.
     *
     * @param array<string, mixed> $options Array of options to compute the final list from.
     * @return array<string, mixed>
     */
    public function getColumnOption(array $options): array
    {
        $connection = $this->getConfig('connection');
        assert($connection instanceof Connection);

        $wantedOptions = array_flip([
            'length',
            'limit',
            'default',
            'signed',
            'null',
            'comment',
            'autoIncrement',
            'precision',
            'after',
            'collate',
        ]);
        $columnOptions = array_intersect_key($options, $wantedOptions);
        if (empty($columnOptions['comment'])) {
            unset($columnOptions['comment']);
        }
        if (empty($columnOptions['autoIncrement'])) {
            unset($columnOptions['autoIncrement']);
        }

        // currently only MySQL supports the signed option
        $isMysql = $connection->getDriver() instanceof Mysql;
        if (!$isMysql) {
            unset($columnOptions['signed']);
        }

        if ($isMysql && !empty($columnOptions['collate'])) {
            // due to Phinx using different naming for the collation
            $columnOptions['collation'] = $columnOptions['collate'];
            unset($columnOptions['collate']);
        }

        if ($columnOptions['precision'] === null) {
            unset($columnOptions['precision']);
        } else {
            // due to Phinx using different naming for the precision and scale to CakePHP
            $columnOptions['scale'] = $columnOptions['precision'];

            if (isset($columnOptions['limit'])) {
                $columnOptions['precision'] = $columnOptions['limit'];
                unset($columnOptions['limit']);
            }
            if (isset($columnOptions['length'])) {
                $columnOptions['precision'] = $columnOptions['length'];
                unset($columnOptions['length']);
            }
        }

        return $columnOptions;
    }

    /**
     * Returns a string-like representation of a value
     *
     * @param string|float|int|bool|null $value A value to represent as a string
     * @param bool $numbersAsString Set tu true to return as string.
     * @return string|float
     */
    public function value(string|float|int|bool|null $value, bool $numbersAsString = false): string|float
    {
        if ($value === null || $value === 'null' || $value === 'NULL') {
            return 'null';
        }

        if ($value === 'true' || $value === 'false') {
            return $value;
        }

        if (is_bool($value)) {
            return $value ? 'true' : 'false';
        }

        if (!$numbersAsString && (is_numeric($value) || ctype_digit($value))) {
            return (float)$value;
        }

        return sprintf("'%s'", addslashes((string)$value));
    }

    /**
     * Returns an array of attributes for a given table column
     *
     * @param \Cake\Database\Schema\TableSchemaInterface|string $table Name of the table to retrieve columns for
     * @param string $column A column to retrieve attributes for
     * @return array<string, mixed>
     */
    public function attributes(TableSchemaInterface|string $table, string $column): array
    {
        $connection = $this->getConfig('connection');
        assert($connection instanceof Connection);

        $tableSchema = $table;
        if (!($tableSchema instanceof TableSchemaInterface)) {
            $tableSchema = $this->schema($tableSchema);
        }
        $validOptions = [
            'length', 'limit',
            'default', 'null',
            'precision', 'scale',
            'after', 'update',
            'comment', 'unsigned',
            'signed', 'properties',
            'autoIncrement', 'unique',
            'collate',
        ];

        $attributes = [];
        $options = $tableSchema->getColumn($column);
        if ($options === null) {
            return [];
        }

        foreach ($options as $_option => $value) {
            $option = $_option;
            switch ($_option) {
                case 'length':
                    $option = 'limit';
                    break;
                case 'unsigned':
                    $option = 'signed';
                    $value = !$value;
                    break;
                case 'unique':
                    $value = (bool)$value;
                    break;
            }

            if (!in_array($option, $validOptions, true)) {
                continue;
            }

            if ($option === 'default' && is_string($value)) {
                $value = trim($value, "'");
            }

            $attributes[$option] = $value;
        }

        // currently only MySQL supports the signed option
        $isMysql = $connection->getDriver() instanceof Mysql;
        if (!$isMysql) {
            unset($attributes['signed']);
        }

        $defaultCollation = $tableSchema->getOptions()['collation'];
        if (empty($attributes['collate']) || $attributes['collate'] == $defaultCollation) {
            unset($attributes['collate']);
        }

        ksort($attributes);

        return $attributes;
    }

    /**
     * Returns an array converted into a formatted multiline string
     *
     * @param array $list array of items to be stringified
     * @param array<string, mixed> $options options to use
     * @param array<string, mixed> $wantedOptions The options you want to include in the output. If undefined all keys are included.
     * @return string
     */
    public function stringifyList(array $list, array $options = [], array $wantedOptions = []): string
    {
        if (!empty($wantedOptions)) {
            $list = array_intersect_key($list, $wantedOptions);
            if (empty($list['comment'])) {
                unset($list['comment']);
            }
        }

        $options += [
            'indent' => 2,
        ];

        if (!empty($options['remove'])) {
            foreach ($options['remove'] as $option) {
                unset($list[$option]);
            }
            unset($options['remove']);
        }

        if (!$list) {
            return '';
        }

        ksort($list);
        foreach ($list as $k => &$v) {
            if (is_array($v)) {
                $v = $this->stringifyList($v, [
                    'indent' => $options['indent'] + 1,
                ]);
                $v = sprintf('[%s]', $v);
            } else {
                $v = $this->value($v, $k === 'default');
            }
            if (!is_numeric($k)) {
                $v = "'$k' => $v";
            }
        }

        $start = $end = '';
        $join = ', ';
        if ($options['indent']) {
            $join = ',';
            $start = "\n" . str_repeat('    ', $options['indent']);
            $join .= $start;
            $end = "\n" . str_repeat('    ', $options['indent'] - 1);
        }

        return $start . implode($join, $list) . ',' . $end;
    }

    /**
     * Returns a $this->table() statement only if it was not issued already
     *
     * @param string $table Table for which the statement is needed
     * @param bool $reset Reset previously set statement.
     * @return string
     */
    public function tableStatement(string $table, bool $reset = false): string
    {
        if ($reset === true) {
            unset($this->tableStatementStatus[$table]);
        }

        if (!isset($this->tableStatementStatus[$table])) {
            $this->tableStatementStatus[$table] = true;

            return '$this->table(\'' . $table . '\')';
        }

        return '';
    }

    /**
     * Checks whether a table statement was generated for the given table name.
     *
     * @param string $table The table's name for which to check the status for.
     * @return bool
     * @see tableStatement()
     */
    public function wasTableStatementGeneratedFor(string $table): bool
    {
        return isset($this->tableStatementStatus[$table]);
    }

    /**
     * Resets the table statement generation status for the given table name.
     *
     * @param string $table The table's name for which to reset the status.
     * @return void
     * @see tableStatement()
     */
    public function resetTableStatementGenerationFor(string $table): void
    {
        unset($this->tableStatementStatus[$table]);
    }

    /**
     * Render an element.
     *
     * @param string $name The name of the element to render.
     * @param array $data Additional data for the element.
     * @return ?string
     */
    public function element(string $name, array $data): ?string
    {
        return $this->getView()->element($name, $data);
    }

    /**
     * Wrapper around Hash::extract()
     *
     * @param \ArrayAccess|array $list The data to extract from.
     * @param string $path The path to extract.
     * @return \ArrayAccess|array
     */
    public function extract(ArrayAccess|array $list, string $path = '{n}.name'): ArrayAccess|array
    {
        return Hash::extract($list, $path);
    }

    /**
     * Get data to use in create tables element
     *
     * @param \Cake\Database\Schema\TableSchemaInterface|string $table Name of the table to retrieve constraints for
     *  or a table schema object.
     * @return array<string, mixed>
     */
    public function getCreateTableData(TableSchemaInterface|string $table): array
    {
        $constraints = $this->constraints($table);
        $indexes = $this->indexes($table);
        $foreignKeys = [];
        foreach ($constraints as $constraint) {
            /** @psalm-suppress PossiblyNullArrayAccess */
            if ($constraint['type'] === 'foreign') {
                $foreignKeys[] = $constraint['columns'];
            }
        }

        return compact('constraints', 'indexes', 'foreignKeys');
    }

    /**
     * Get data to use inside the create-tables element
     *
     * @param array<\Cake\Database\Schema\TableSchemaInterface|string> $tables The tables to create element data for.
     * @return array<string, mixed>
     */
    public function getCreateTablesElementData(array $tables): array
    {
        $result = [
            'constraints' => [],
            'tables' => [],
        ];
        foreach ($tables as $table) {
            $tableName = $table;
            if ($table instanceof TableSchemaInterface) {
                $tableName = $table->name();
            }
            $data = $this->getCreateTableData($table);
            $tableConstraintsNoUnique = array_filter(
                $data['constraints'],
                function ($constraint) {
                    return $constraint['type'] !== 'unique';
                }
            );
            if ($tableConstraintsNoUnique) {
                $result['constraints'][$tableName] = $data['constraints'];
            }
            $result['tables'][$tableName] = $data;
        }

        return $result;
    }
}
