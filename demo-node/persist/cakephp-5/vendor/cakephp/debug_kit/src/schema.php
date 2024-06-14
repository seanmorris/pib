<?php
declare(strict_types=1);

use Cake\Database\Schema\TableSchema;

/**
 * Runtime plugin schema for DebugKit toolbar
 *
 * This schema data is used to generate the tables
 * that DebugKit store persistent data in. We're using
 * the Cake\Database abstract types so that we can
 * generate SQL for any SQL dialect that CakePHP supports.
 */
return [
     [
        'table' => 'requests',
        'columns' => [
            'id' => ['type' => 'uuid', 'null' => false],
            'url' => ['type' => 'text', 'null' => false],
            'content_type' => ['type' => 'string'],
            'status_code' => ['type' => 'integer'],
            'method' => ['type' => 'string'],
            'requested_at' => ['type' => 'datetime', 'null' => false],
        ],
        'constraints' => [
            'primary' => ['type' => 'primary', 'columns' => ['id']],
        ],
     ],
     [
        'table' => 'panels',
        'columns' => [
            'id' => ['type' => 'uuid'],
            'request_id' => ['type' => 'uuid', 'null' => false],
            'panel' => ['type' => 'string'],
            'title' => ['type' => 'string'],
            'element' => ['type' => 'string'],
            'summary' => ['type' => 'string'],
            'content' => ['type' => 'binary', 'length' => TableSchema::LENGTH_LONG],
        ],
        'constraints' => [
            'primary' => ['type' => 'primary', 'columns' => ['id']],
            'unique_panel' => ['type' => 'unique', 'columns' => ['request_id', 'panel']],
            'request_id_fk' => [
                'type' => 'foreign',
                'columns' => ['request_id'],
                'references' => ['requests', 'id'],
            ],
        ],
     ],
];
