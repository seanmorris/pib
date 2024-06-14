<?php
declare(strict_types=1);

namespace Migrations\Util;

use Cake\Collection\Collection;
use Cake\Utility\Hash;
use Phinx\Db\Adapter\AdapterInterface;
use ReflectionClass;

/**
 * Utility class used to parse arguments passed to a ``bake migration`` class
 */
class ColumnParser
{
    /**
     * Regex used to parse the column definition passed through the shell
     *
     * @var string
     */
    protected string $regexpParseColumn = '/
        ^
        (\w+)
        (?::(\w+\??
            (?:\[
                (?:[0-9]|[1-9][0-9]+)
                (?:,(?:[0-9]|[1-9][0-9]+))?
            \])?
        ))?
        (?::(\w+))?
        (?::(\w+))?
        $
        /x';

    /**
     * Regex used to parse the field type and length
     *
     * @var string
     */
    protected string $regexpParseField = '/(\w+\??)\[([0-9,]+)\]/';

    /**
     * Parses a list of arguments into an array of fields
     *
     * @param array<string> $arguments A list of arguments being parsed
     * @return array<string, array>
     */
    public function parseFields(array $arguments): array
    {
        $fields = [];
        $arguments = $this->validArguments($arguments);
        foreach ($arguments as $field) {
            preg_match($this->regexpParseColumn, $field, $matches);
            $field = $matches[1];
            $type = Hash::get($matches, 2, '');
            $indexType = Hash::get($matches, 3);

            $typeIsPk = in_array($type, ['primary', 'primary_key'], true);
            $isPrimaryKey = false;
            if ($typeIsPk || in_array($indexType, ['primary', 'primary_key'], true)) {
                $isPrimaryKey = true;

                if ($typeIsPk) {
                    $type = 'primary';
                }
            }
            $nullable = (bool)strpos($type, '?');
            $type = $nullable ? str_replace('?', '', $type) : $type;

            [$type, $length] = $this->getTypeAndLength($field, $type);
            $fields[$field] = [
                'columnType' => $type,
                'options' => [
                    'null' => $nullable,
                    'default' => null,
                ],
            ];

            if ($length !== null) {
                if (is_array($length)) {
                    [$fields[$field]['options']['precision'], $fields[$field]['options']['scale']] = $length;
                } else {
                    $fields[$field]['options']['limit'] = $length;
                }
            }

            if ($isPrimaryKey === true && $type === 'integer') {
                $fields[$field]['options']['autoIncrement'] = true;
            }
        }

        return $fields;
    }

    /**
     * Parses a list of arguments into an array of indexes
     *
     * @param array<string> $arguments A list of arguments being parsed
     * @return array<string, array>
     */
    public function parseIndexes(array $arguments): array
    {
        $indexes = [];
        $arguments = $this->validArguments($arguments);
        foreach ($arguments as $field) {
            preg_match($this->regexpParseColumn, $field, $matches);
            $field = $matches[1];
            $type = Hash::get($matches, 2);
            $indexType = Hash::get($matches, 3);
            $indexName = Hash::get($matches, 4);

            if (
                in_array($type, ['primary', 'primary_key'], true) ||
                in_array($indexType, ['primary', 'primary_key'], true) ||
                $indexType === null
            ) {
                continue;
            }

            $indexUnique = false;
            if ($indexType === 'unique') {
                $indexUnique = true;
            }

            $indexName = $this->getIndexName($field, $indexType, $indexName, $indexUnique);

            if (empty($indexes[$indexName])) {
                $indexes[$indexName] = [
                    'columns' => [],
                    'options' => [
                        'unique' => $indexUnique,
                        'name' => $indexName,
                    ],
                ];
            }

            $indexes[$indexName]['columns'][] = $field;
        }

        return $indexes;
    }

    /**
     * Parses a list of arguments into an array of fields composing the primary key
     * of the table
     *
     * @param array<string> $arguments A list of arguments being parsed
     * @return array<string>
     */
    public function parsePrimaryKey(array $arguments): array
    {
        $primaryKey = [];
        $arguments = $this->validArguments($arguments);
        foreach ($arguments as $field) {
            preg_match($this->regexpParseColumn, $field, $matches);
            $field = $matches[1];
            $type = Hash::get($matches, 2);
            $indexType = Hash::get($matches, 3);

            if (
                in_array($type, ['primary', 'primary_key'], true)
                || in_array($indexType, ['primary', 'primary_key'], true)
            ) {
                $primaryKey[] = $field;
            }
        }

        return $primaryKey;
    }

    /**
     * Returns a list of only valid arguments
     *
     * @param array<string> $arguments A list of arguments
     * @return array<string>
     */
    public function validArguments(array $arguments): array
    {
        $collection = new Collection($arguments);

        return $collection->filter(function ($value, $field) {
            return preg_match($this->regexpParseColumn, (string)$field);
        })->toArray();
    }

    /**
     * Get the type and length of a field based on the field and the type passed
     *
     * @param string $field Name of field
     * @param string|null $type User-specified type
     * @return array<string|int|array|null> First value is the field type, second value is the field length. If no length
     * can be extracted, null is returned for the second value
     */
    public function getTypeAndLength(string $field, ?string $type): array
    {
        if ($type && preg_match($this->regexpParseField, $type, $matches)) {
            if (str_contains($matches[2], ',')) {
                $matches[2] = explode(',', $matches[2]);
            }

            return [$matches[1], $matches[2]];
        }

        /** @var string $fieldType */
        $fieldType = $this->getType($field, $type);
        $length = $this->getLength($fieldType);

        return [$fieldType, $length];
    }

    /**
     * Retrieves a type that should be used for a specific field
     *
     * @param string $field Name of field
     * @param string|null $type User-specified type
     * @return string|null
     */
    public function getType(string $field, ?string $type): ?string
    {
        $reflector = new ReflectionClass(AdapterInterface::class);
        $collection = new Collection($reflector->getConstants());

        $validTypes = $collection->filter(function ($value, $constant) {
            return substr($constant, 0, strlen('PHINX_TYPE_')) === 'PHINX_TYPE_';
        })->toArray();
        $fieldType = $type;
        if ($type === null || !in_array($type, $validTypes, true)) {
            if ($type === 'primary') {
                $fieldType = 'integer';
            } elseif ($field === 'id') {
                $fieldType = 'integer';
            } elseif (in_array($field, ['created', 'modified', 'updated'], true) || substr($field, -3) === '_at') {
                $fieldType = 'datetime';
            } elseif (in_array($field, ['latitude', 'longitude', 'lat', 'lng'], true)) {
                $fieldType = 'decimal';
            } else {
                $fieldType = 'string';
            }
        }

        return $fieldType;
    }

    /**
     * Returns the default length to be used for a given type.
     *
     * @param string $type User-specified type
     * @return int|int[]|null
     */
    public function getLength(string $type): int|array|null
    {
        $length = null;
        if ($type === 'string') {
            $length = 255;
        } elseif ($type === 'tinyinteger') {
            $length = 4;
        } elseif ($type === 'smallinteger') {
            $length = 6;
        } elseif ($type === 'integer') {
            $length = 11;
        } elseif ($type === 'biginteger') {
            $length = 20;
        } elseif ($type === 'decimal') {
            $length = [10, 6];
        }

        return $length;
    }

    /**
     * Returns the default length to be used for a given fie
     *
     * @param string $field Name of field
     * @param string|null $indexType Type of index
     * @param string|null $indexName Name of index
     * @param bool $indexUnique Whether this is a unique index or not
     * @return string
     */
    public function getIndexName(string $field, ?string $indexType, ?string $indexName, bool $indexUnique): string
    {
        if (empty($indexName)) {
            $indexName = strtoupper('BY_' . $field);
            if ($indexType === 'primary') {
                $indexName = 'PRIMARY';
            } elseif ($indexUnique) {
                $indexName = strtoupper('UNIQUE_' . $field);
            }
        }

        return $indexName;
    }
}
