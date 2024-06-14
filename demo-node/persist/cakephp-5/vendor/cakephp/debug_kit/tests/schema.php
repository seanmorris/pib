<?php
declare(strict_types=1);

$tables = require dirname(__DIR__) . '/src/schema.php';

/**
 * Additional tables used for tests.
 */
$testTables = [
    [
        'table' => 'articles',
        'columns' => [
            'id' => ['type' => 'integer'],
            'author_id' => ['type' => 'integer', 'null' => true],
            'title' => ['type' => 'string', 'null' => true],
            'body' => 'text',
            'published' => ['type' => 'string', 'length' => 1, 'default' => 'N'],
        ],
        'constraints' => [
            'primary' => [
                'type' => 'primary',
                'columns' => ['id'],
            ],
        ],
    ],
];

return array_merge($tables, $testTables);
