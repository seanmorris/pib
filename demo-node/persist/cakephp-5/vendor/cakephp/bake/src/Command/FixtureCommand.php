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

use Bake\Utility\TableScanner;
use Brick\VarExporter\VarExporter;
use Cake\Chronos\Chronos;
use Cake\Chronos\ChronosDate;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Core\Configure;
use Cake\Core\Exception\CakeException;
use Cake\Database\Schema\TableSchemaInterface;
use Cake\Database\Type\EnumType;
use Cake\Database\TypeFactory;
use Cake\Datasource\ConnectionManager;
use Cake\Utility\Inflector;
use Cake\Utility\Text;
use DateTimeInterface;
use ReflectionEnum;

/**
 * Task class for creating and updating fixtures files.
 */
class FixtureCommand extends BakeCommand
{
    /**
     * Get the file path.
     *
     * @param \Cake\Console\Arguments $args Arguments instance to read the prefix option from.
     * @return string Path to output.
     */
    public function getPath(Arguments $args): string
    {
        $dir = 'Fixture/';
        $path = defined('TESTS') ? TESTS . $dir : ROOT . DS . 'tests' . DS . $dir;
        if ($this->plugin) {
            $path = $this->_pluginPath($this->plugin) . 'tests/' . $dir;
        }

        return str_replace('/', DS, $path);
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

        $parser = $parser->setDescription(
            'Generate fixtures for use with the test suite. You can use `bake fixture all` to bake all fixtures.'
        )->addArgument('name', [
            'help' => 'Name of the fixture to bake (without the `Fixture` suffix). ' .
                'You can use Plugin.name to bake plugin fixtures.',
        ])->addOption('table', [
            'help' => 'The table name if it does not follow conventions.',
        ])->addOption('count', [
            'help' => 'When using generated data, the number of records to include in the fixture(s).',
            'short' => 'n',
            'default' => '1',
        ])->addOption('fields', [
            'help' => 'Create a fixture that includes the deprecated $fields property.',
            'short' => 'f',
            'boolean' => true,
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
     * @return int|null The exit code or null for success
     */
    public function execute(Arguments $args, ConsoleIo $io): ?int
    {
        $this->extractCommonProperties($args);
        $name = $args->getArgument('name') ?? '';
        $name = $this->_getName($name);

        /** @var \Cake\Database\Connection $connection */
        $connection = ConnectionManager::get($this->connection);
        $scanner = new TableScanner($connection);
        if (empty($name)) {
            $io->out('Choose a fixture to bake from the following:');
            foreach ($scanner->listUnskipped() as $table) {
                $io->out('- ' . $this->_camelize($table));
            }

            return static::CODE_SUCCESS;
        }

        $table = $args->getOption('table') ?? '';
        $model = $this->_camelize($name);
        $this->bake($model, $table, $args, $io);

        return static::CODE_SUCCESS;
    }

    /**
     * Assembles and writes a Fixture file
     *
     * @param string $model Name of model to bake.
     * @param string $useTable Name of table to use.
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return void
     * @throws \RuntimeException
     */
    protected function bake(string $model, string $useTable, Arguments $args, ConsoleIo $io): void
    {
        $table = $schema = $records = $import = $modelImport = null;

        if (!$useTable) {
            $useTable = Inflector::tableize($model);
        } elseif ($useTable !== Inflector::tableize($model)) {
            $table = $useTable;
        }

        $importBits = [];
        if ($args->getOption('schema')) {
            $modelImport = true;
            $importBits[] = "'table' => '{$useTable}'";
        }
        if (!empty($importBits) && $this->connection !== 'default') {
            $importBits[] = "'connection' => '{$this->connection}'";
        }
        if (!empty($importBits)) {
            $import = sprintf('[%s]', implode(', ', $importBits));
        }

        try {
            $data = $this->readSchema($model, $useTable);
        } catch (CakeException $e) {
            $this->getTableLocator()->remove($model);
            $useTable = Inflector::underscore($model);
            $table = $useTable;
            $data = $this->readSchema($model, $useTable);
        }

        $this->validateNames($data, $io);

        if ($modelImport === null) {
            $schema = $this->_generateSchema($data);
        }

        if ($args->getOption('records')) {
            $records = $this->_makeRecordString($this->_getRecordsFromTable($args, $model, $useTable));
        } else {
            $recordCount = 1;
            if ($args->hasOption('count')) {
                $recordCount = (int)$args->getOption('count');
            }
            $records = $this->_makeRecordString($this->_generateRecords($data, $recordCount));
        }

        $this->generateFixtureFile($args, $io, $model, compact('records', 'table', 'schema', 'import'));
    }

    /**
     * Get schema metadata for the current table mapping.
     *
     * @param string $name The model alias to use
     * @param string $table The table name to get schema metadata for.
     * @return \Cake\Database\Schema\TableSchemaInterface
     */
    public function readSchema(string $name, string $table): TableSchemaInterface
    {
        $connection = ConnectionManager::get($this->connection);

        if ($this->getTableLocator()->exists($name)) {
            $model = $this->getTableLocator()->get($name);
        } else {
            $model = $this->getTableLocator()->get($name, [
                'table' => $table,
                'connection' => $connection,
            ]);
        }

        return $model->getSchema();
    }

    /**
     * Validates table and column names are supported.
     *
     * @param \Cake\Database\Schema\TableSchemaInterface $schema Table schema
     * @param \Cake\Console\ConsoleIo $io Console io
     * @return void
     * @throws \Cake\Console\Exception\StopException When table or column names are not supported
     */
    public function validateNames(TableSchemaInterface $schema, ConsoleIo $io): void
    {
        foreach ($schema->columns() as $column) {
            if (!$this->isValidColumnName($column)) {
                $io->abort(sprintf(
                    'Unable to bake model. Table column name must start with a letter or underscore and
                    cannot contain special characters. Found `%s`.',
                    $column
                ));
            }
        }
    }

    /**
     * Generate the fixture file, and write to disk
     *
     * @param \Cake\Console\Arguments $args The CLI arguments.
     * @param \Cake\Console\ConsoleIo $io The console io instance.
     * @param string $model name of the model being generated
     * @param array<string, mixed> $otherVars Contents of the fixture file.
     * @return void
     */
    public function generateFixtureFile(Arguments $args, ConsoleIo $io, string $model, array $otherVars): void
    {
        $defaults = [
            'name' => $model,
            'table' => null,
            'schema' => null,
            'records' => null,
            'import' => null,
            'fields' => null,
            'namespace' => Configure::read('App.namespace'),
        ];
        if ($this->plugin) {
            $defaults['namespace'] = $this->_pluginNamespace($this->plugin);
        }
        $vars = $otherVars + $defaults;
        if (!$args->getOption('fields')) {
            $vars['schema'] = null;
        }

        $path = $this->getPath($args);
        $filename = $vars['name'] . 'Fixture.php';

        $contents = $this->createTemplateRenderer()
            ->set('model', $model)
            ->set($vars)
            ->generate('Bake.tests/fixture');

        $io->out("\n" . sprintf('Baking test fixture for %s...', $model), 1, ConsoleIo::NORMAL);
        $io->createFile($path . $filename, $contents, $this->force);
        $emptyFile = $path . '.gitkeep';
        $this->deleteEmptyFile($emptyFile, $io);
    }

    /**
     * Generates a string representation of a schema.
     *
     * @param \Cake\Database\Schema\TableSchemaInterface $table Table schema
     * @return string fields definitions
     */
    protected function _generateSchema(TableSchemaInterface $table): string
    {
        $cols = $indexes = $constraints = [];
        foreach ($table->columns() as $field) {
            $fieldData = $table->getColumn($field);
            $properties = implode(', ', $this->_values($fieldData));
            $cols[] = "        '$field' => [$properties],";
        }
        foreach ($table->indexes() as $index) {
            $fieldData = $table->getIndex($index);
            $properties = implode(', ', $this->_values($fieldData));
            $indexes[] = "            '$index' => [$properties],";
        }
        foreach ($table->constraints() as $index) {
            $fieldData = $table->getConstraint($index);
            $properties = implode(', ', $this->_values($fieldData));
            $constraints[] = "            '$index' => [$properties],";
        }
        $options = $this->_values($table->getOptions());

        $content = implode("\n", $cols) . "\n";
        if (!empty($indexes)) {
            $content .= "        '_indexes' => [\n" . implode("\n", $indexes) . "\n        ],\n";
        }
        if (!empty($constraints)) {
            $content .= "        '_constraints' => [\n" . implode("\n", $constraints) . "\n        ],\n";
        }
        if (!empty($options)) {
            foreach ($options as &$option) {
                $option = '            ' . $option;
            }
            $content .= "        '_options' => [\n" . implode(",\n", $options) . "\n        ],\n";
        }

        return "[\n$content    ]";
    }

    /**
     * Formats Schema columns from Model Object
     *
     * @param array $values options keys(type, null, default, key, length, extra)
     * @return array<string> Formatted values
     */
    protected function _values(array $values): array
    {
        $vals = [];

        foreach ($values as $key => $val) {
            if (is_array($val)) {
                $vals[] = "'{$key}' => [" . implode(', ', $this->_values($val)) . ']';
            } else {
                $val = var_export($val, true);
                if ($val === 'NULL') {
                    $val = 'null';
                }
                if (!is_numeric($key)) {
                    $vals[] = "'{$key}' => {$val}";
                } else {
                    $vals[] = "{$val}";
                }
            }
        }

        return $vals;
    }

    /**
     * Generate String representation of Records
     *
     * @param \Cake\Database\Schema\TableSchemaInterface $table Table schema array
     * @param int $recordCount The number of records to generate.
     * @return array Array of records to use in the fixture.
     */
    protected function _generateRecords(TableSchemaInterface $table, int $recordCount = 1): array
    {
        $records = [];
        for ($i = 0; $i < $recordCount; $i++) {
            $record = [];
            foreach ($table->columns() as $field) {
                $fieldInfo = $table->getColumn($field);
                $insert = '';
                switch ($fieldInfo['type']) {
                    case 'decimal':
                        $insert = $i + 1.5;
                        break;
                    case 'biginteger':
                    case 'integer':
                    case 'float':
                    case 'smallinteger':
                    case 'tinyinteger':
                        $insert = $i + 1;
                        break;
                    case 'string':
                    case 'binary':
                        $isPrimary = in_array($field, $table->getPrimaryKey());
                        if ($isPrimary) {
                            $insert = Text::uuid();
                        } else {
                            $insert = 'Lorem ipsum dolor sit amet';
                            if (!empty($fieldInfo['length'])) {
                                $insert = substr(
                                    $insert,
                                    0,
                                    (int)$fieldInfo['length'] > 2
                                        ? (int)$fieldInfo['length'] - 2
                                        : (int)$fieldInfo['length']
                                );
                            }
                        }
                        break;
                    case 'timestamp':
                    case 'timestamptimezone':
                    case 'timestampfractional':
                        $insert = time();
                        break;
                    case 'datetime':
                        $insert = date('Y-m-d H:i:s');
                        break;
                    case 'date':
                        $insert = date('Y-m-d');
                        break;
                    case 'time':
                        $insert = date('H:i:s');
                        break;
                    case 'boolean':
                        $insert = 1;
                        break;
                    case 'text':
                        $insert = 'Lorem ipsum dolor sit amet, aliquet feugiat.';
                        $insert .= ' Convallis morbi fringilla gravida,';
                        $insert .= ' phasellus feugiat dapibus velit nunc, pulvinar eget sollicitudin';
                        $insert .= ' venenatis cum nullam, vivamus ut a sed, mollitia lectus. Nulla';
                        $insert .= ' vestibulum massa neque ut et, id hendrerit sit,';
                        $insert .= ' feugiat in taciti enim proin nibh, tempor dignissim, rhoncus';
                        $insert .= ' duis vestibulum nunc mattis convallis.';
                        break;
                    case 'uuid':
                        $insert = Text::uuid();
                        break;
                }
                if (str_starts_with($fieldInfo['type'], 'enum-')) {
                    $insert = null;
                    if ($fieldInfo['default'] || $fieldInfo['null'] === false) {
                        $dbType = TypeFactory::build($fieldInfo['type']);
                        if ($dbType instanceof EnumType) {
                            $class = $dbType->getEnumClassName();
                            $reflectionEnum = new ReflectionEnum($class);
                            $backingType = (string)$reflectionEnum->getBackingType();

                            if ($fieldInfo['default'] !== null) {
                                $insert = $fieldInfo['default'];
                                if ($backingType === 'int') {
                                    $insert = (int)$insert;
                                }
                            } else {
                                $cases = $reflectionEnum->getCases();
                                if ($cases) {
                                    $firstCase = array_shift($cases);
                                    /** @var \BackedEnum $firstValue */
                                    $firstValue = $firstCase->getValue();
                                    $insert = $firstValue->value;
                                }
                            }
                        }
                    }
                }

                $record[$field] = $insert;
            }
            $records[] = $record;
        }

        return $records;
    }

    /**
     * Convert a $records array into a string.
     *
     * @param array $records Array of records to be converted to string
     * @return string A string value of the $records array.
     * @throws \Brick\VarExporter\ExportException
     */
    protected function _makeRecordString(array $records): string
    {
        foreach ($records as &$record) {
            array_walk($record, function (&$value): void {
                if ($value instanceof DateTimeInterface || $value instanceof Chronos) {
                    $value = $value->format('Y-m-d H:i:s');
                } elseif ($value instanceof ChronosDate) {
                    $value = $value->format('Y-m-d');
                }
            });
        }

        return VarExporter::export($records, VarExporter::TRAILING_COMMA_IN_ARRAY, 2);
    }

    /**
     * Interact with the user to get a custom SQL condition and use that to extract data
     * to build a fixture.
     *
     * @param \Cake\Console\Arguments $args CLI arguments
     * @param string $modelName name of the model to take records from.
     * @param string|null $useTable Name of table to use.
     * @return array Array of records.
     */
    protected function _getRecordsFromTable(Arguments $args, string $modelName, ?string $useTable = null): array
    {
        $recordCount = ($args->getOption('count') ?? 10);
        /** @var string $conditions */
        $conditions = ($args->getOption('conditions') ?? '1=1');
        if ($this->getTableLocator()->exists($modelName)) {
            $model = $this->getTableLocator()->get($modelName);
        } else {
            $model = $this->getTableLocator()->get($modelName, [
                'table' => $useTable,
                'connection' => ConnectionManager::get($this->connection),
            ]);
        }
        $records = $model->find('all')
            ->where($conditions)
            ->limit((int)$recordCount)
            ->enableHydration(false);

        return $records->toArray();
    }
}
