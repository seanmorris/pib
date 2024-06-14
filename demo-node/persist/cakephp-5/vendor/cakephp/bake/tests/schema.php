<?php
declare(strict_types=1);

/**
 * Abstract schema for Bake tests.
 *
 * This format resembles the existing fixture schema
 * and is converted to SQL via the Schema generation
 * features of the Database package.
 */
return [
    [
        'table' => 'authors',
        'columns' => [
            'id' => [
                'type' => 'integer',
            ],
            'name' => [
                'type' => 'string',
                'default' => null,
            ],
        ],
        'constraints' => [
            'primary' => [
                'type' => 'primary',
                'columns' => [
                    'id',
                ],
            ],
        ],
    ],
    [
        'table' => 'tags',
        'columns' => [
            'id' => [
                'type' => 'integer',
                'null' => false,
            ],
            'name' => [
                'type' => 'string',
                'null' => false,
            ],
            'description' => [
                'type' => 'text',
                'length' => 16777215,
            ],
            'created' => [
                'type' => 'datetime',
                'null' => true,
                'default' => null,
            ],
        ],
        'constraints' => [
            'primary' => [
                'type' => 'primary',
                'columns' => [
                    'id',
                ],
            ],
        ],
    ],
    [
        'table' => 'articles',
        'columns' => [
            'id' => [
                'type' => 'integer',
            ],
            'author_id' => [
                'type' => 'integer',
                'null' => true,
            ],
            'title' => [
                'type' => 'string',
                'null' => true,
            ],
            'body' => 'text',
            'published' => [
                'type' => 'string',
                'length' => 1,
                'default' => 'N',
            ],
        ],
        'constraints' => [
            'primary' => [
                'type' => 'primary',
                'columns' => [
                    'id',
                ],
            ],
        ],
    ],
    [
        'table' => 'articles_tags',
        'columns' => [
            'article_id' => [
                'type' => 'integer',
                'null' => false,
            ],
            'tag_id' => [
                'type' => 'integer',
                'null' => false,
            ],
        ],
        'constraints' => [
            'unique_tag' => [
                'type' => 'primary',
                'columns' => [
                    'article_id',
                    'tag_id',
                ],
            ],
            'tag_id_fk' => [
                'type' => 'foreign',
                'columns' => [
                    'tag_id',
                ],
                'references' => [
                    'tags',
                    'id',
                ],
                'update' => 'cascade',
                'delete' => 'cascade',
            ],
        ],
    ],
    [
        'table' => 'posts',
        'columns' => [
            'id' => [
                'type' => 'integer',
            ],
            'author_id' => [
                'type' => 'integer',
                'null' => false,
            ],
            'title' => [
                'type' => 'string',
                'null' => false,
            ],
            'body' => 'text',
            'published' => [
                'type' => 'string',
                'length' => 1,
                'default' => 'N',
            ],
        ],
        'constraints' => [
            'primary' => [
                'type' => 'primary',
                'columns' => [
                    'id',
                ],
            ],
        ],
    ],
    [
        'table' => 'comments',
        'columns' => [
            'id' => [
                'type' => 'integer',
            ],
            'article_id' => [
                'type' => 'integer',
                'null' => false,
            ],
            'user_id' => [
                'type' => 'integer',
                'null' => false,
            ],
            'comment' => [
                'type' => 'text',
            ],
            'published' => [
                'type' => 'string',
                'length' => 1,
                'default' => 'N',
            ],
            'created' => [
                'type' => 'datetime',
            ],
            'updated' => [
                'type' => 'datetime',
            ],
        ],
        'constraints' => [
            'primary' => [
                'type' => 'primary',
                'columns' => [
                    'id',
                ],
            ],
        ],
    ],
    [
        'table' => 'bake_articles_bake_tags',
        'columns' => [
            'bake_article_id' => ['type' => 'integer', 'null' => false],
            'bake_tag_id' => ['type' => 'integer', 'null' => false],
        ],
        'constraints' => ['UNIQUE_TAG' => ['type' => 'unique', 'columns' => ['bake_article_id', 'bake_tag_id']]],
    ],
    [
        'table' => 'bake_articles',
        'columns' => [
            'id' => ['type' => 'integer'],
            'bake_user_id' => ['type' => 'integer', 'null' => false],
            'title' => ['type' => 'string', 'length' => 50, 'null' => false],
            'body' => 'text',
            'rating' => ['type' => 'float', 'unsigned' => true, 'default' => 0.0, 'null' => false],
            'score' => ['type' => 'decimal', 'unsigned' => true, 'default' => 0.0, 'null' => false],
            'published' => ['type' => 'boolean', 'length' => 1, 'default' => false],
            'created' => 'datetime',
            'updated' => 'datetime',
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'car',
        'columns' => [
            'id' => ['type' => 'integer'],
            'bake_user_id' => ['type' => 'integer', 'null' => false],
            'title' => ['type' => 'string', 'null' => false],
            'body' => 'text',
            'published' => ['type' => 'boolean', 'length' => 1, 'default' => false],
            'created' => 'datetime',
            'updated' => 'datetime',
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'cars',
        'columns' => [
            'id' => ['type' => 'integer'],
            'bake_user_id' => ['type' => 'integer', 'null' => false],
            'title' => ['type' => 'string', 'null' => false],
            'body' => 'text',
            'published' => ['type' => 'boolean', 'length' => 1, 'default' => false],
            'created' => 'datetime',
            'updated' => 'datetime',
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'bake_comments',
        'columns' => [
            'otherid' => ['type' => 'integer'],
            'bake_article_id' => ['type' => 'integer', 'null' => false],
            'bake_user_id' => ['type' => 'integer', 'null' => false],
            'comment' => 'text',
            'published' => ['type' => 'string', 'length' => 1, 'default' => 'N'],
            'created' => ['type' => 'datetime', 'length' => null, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null],
            'updated' => ['type' => 'datetime', 'length' => null, 'null' => true, 'default' => null, 'comment' => '', 'precision' => null],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['otherid']]],
    ],
    [
        'table' => 'bake_tags',
        'columns' => [
            'id' => ['type' => 'integer'],
            'tag' => ['type' => 'string', 'null' => false],
            'created' => 'datetime',
            'updated' => 'datetime',
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'bake_authors',
        'columns' => [
            'id' => ['type' => 'integer'],
            'role_id' => ['type' => 'integer', 'null' => false],
            'name' => ['type' => 'string', 'default' => null],
            'description' => ['type' => 'text', 'default' => null],
            'member' => ['type' => 'boolean'],
            'member_number' => ['type' => 'integer', 'null' => true],
            'account_balance' => ['type' => 'decimal', 'null' => true, 'precision' => 2, 'length' => 12],
            'created' => 'datetime',
            'modified' => 'datetime',
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'profiles',
        'columns' => [
            'id' => ['type' => 'integer'],
            'author_id' => ['type' => 'integer', 'null' => false],
            'nick' => ['type' => 'string', 'null' => false],
            'avatar' => ['type' => 'string', 'default' => null],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'roles',
        'columns' => [
            'id' => ['type' => 'integer'],
            'name' => ['type' => 'string', 'null' => false],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'binary_tests',
        'columns' => [
            'id' => ['type' => 'integer'],
            'byte' => ['type' => 'binary', 'length' => 1],
            'data' => ['type' => 'binary', 'length' => 300],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'categories',
        'columns' => [
            'id' => ['type' => 'integer', 'length' => 11, 'unsigned' => true, 'null' => false, 'default' => null, 'comment' => '', 'autoIncrement' => true, 'precision' => null],
            'created' => ['type' => 'datetime', 'length' => null, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null],
            'modified' => ['type' => 'datetime', 'length' => null, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null],
            'name' => ['type' => 'string', 'length' => 100, 'null' => false, 'default' => '', 'comment' => '', 'precision' => null, 'fixed' => null],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'categories_products',
        'columns' => [
            'category_id' => ['type' => 'integer', 'length' => 11, 'unsigned' => true, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null, 'autoIncrement' => null],
            'product_id' => ['type' => 'integer', 'length' => 11, 'unsigned' => true, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null, 'autoIncrement' => null],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['category_id', 'product_id'], 'length' => []]],
    ],
    [
        'table' => 'category_threads',
        'columns' => [
            'id' => ['type' => 'integer'],
            'parent_id' => ['type' => 'integer'],
            'name' => ['type' => 'string', 'null' => false],
            'lft' => ['type' => 'integer', 'unsigned' => true],
            'rght' => ['type' => 'integer', 'unsigned' => true],
            'created' => 'datetime',
            'updated' => 'datetime',
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'datatypes',
        'columns' => [
            'id' => ['type' => 'integer', 'null' => false],
            'decimal_field' => ['type' => 'decimal', 'length' => '6', 'precision' => 3, 'default' => '0.000'],
            'float_field' => ['type' => 'float', 'length' => '5,2', 'null' => false, 'default' => null],
            'huge_int' => ['type' => 'biginteger'],
            'small_int' => ['type' => 'smallinteger'],
            'tiny_int' => ['type' => 'tinyinteger'],
            'bool' => ['type' => 'boolean', 'null' => false, 'default' => false],
            'uuid' => ['type' => 'uuid'],
            'timestamp_field' => ['type' => 'timestamp'],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'hidden_fields',
        'columns' => [
            'id' => ['type' => 'integer'],
            'password' => ['type' => 'string', 'null' => true, 'length' => 255],
            'auth_token' => ['type' => 'string', 'null' => true, 'length' => 255],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'users',
        'columns' => [
            'id' => ['type' => 'integer'],
            'username' => ['type' => 'string', 'null' => true, 'length' => 255],
            'password' => ['type' => 'string', 'null' => true, 'length' => 255],
            'created' => ['type' => 'timestamp', 'null' => true],
            'updated' => ['type' => 'timestamp', 'null' => true],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'bake_users',
        'columns' => [
            'id' => ['type' => 'integer'],
            'username' => ['type' => 'string', 'null' => true, 'length' => 255],
            'password' => ['type' => 'string', 'null' => true, 'length' => 255],
            'status' => ['type' => 'tinyinteger', 'length' => 2, 'default' => null, 'null' => true],
            'created' => ['type' => 'timestamp', 'null' => true],
            'updated' => ['type' => 'timestamp', 'null' => true],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'invitations',
        'columns' => [
            'id' => ['type' => 'integer'],
            'sender_id' => ['type' => 'integer', 'null' => false],
            'receiver_id' => ['type' => 'integer', 'null' => false],
            'body' => 'text',
            'created' => 'datetime',
            'updated' => 'datetime',
        ],
        'constraints' => [
            'primary' => ['type' => 'primary', 'columns' => ['id']],
            'sender_idx' => [
                'type' => 'foreign',
                'columns' => ['sender_id'],
                'references' => ['users', 'id'],
                'update' => 'noAction',
                'delete' => 'noAction',
            ],
            'receiver_idx' => [
                'type' => 'foreign',
                'columns' => ['receiver_id'],
                'references' => ['users', 'id'],
                'update' => 'noAction',
                'delete' => 'noAction',
            ],
        ],
    ],
    [
        'table' => 'number_trees',
        'columns' => [
            'id' => ['type' => 'integer'],
            'name' => ['type' => 'string', 'length' => 50, 'null' => false],
            'parent_id' => 'integer',
            'lft' => ['type' => 'integer', 'unsigned' => true],
            'rght' => ['type' => 'integer', 'unsigned' => true],
            'depth' => ['type' => 'integer', 'unsigned' => true],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'old_products',
        'columns' => [
            'id' => ['type' => 'integer', 'length' => 11, 'unsigned' => true, 'null' => false, 'default' => null, 'comment' => '', 'autoIncrement' => true, 'precision' => null],
            'created' => ['type' => 'datetime', 'length' => null, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null],
            'modified' => ['type' => 'datetime', 'length' => null, 'null' => true, 'default' => null, 'comment' => '', 'precision' => null],
            'name' => ['type' => 'string', 'length' => 100, 'null' => false, 'default' => '', 'comment' => '', 'precision' => null, 'fixed' => null],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id'], 'length' => []]],
    ],
    [
        'table' => 'products',
        'columns' => [
            'id' => ['type' => 'integer', 'length' => 11, 'unsigned' => true, 'null' => false, 'default' => null, 'comment' => '', 'autoIncrement' => true, 'precision' => null],
            'created' => ['type' => 'datetime', 'length' => null, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null],
            'modified' => ['type' => 'datetime', 'length' => null, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null],
            'name' => ['type' => 'string', 'length' => 100, 'null' => false, 'default' => '', 'comment' => '', 'precision' => null, 'fixed' => null],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id'], 'length' => []]],
    ],
    [
        'table' => 'product_versions',
        'columns' => [
            'id' => ['type' => 'integer', 'length' => 11, 'unsigned' => true, 'null' => false, 'default' => null, 'comment' => '', 'autoIncrement' => true, 'precision' => null],
            'product_id' => ['type' => 'integer', 'length' => 11, 'unsigned' => true, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null, 'autoIncrement' => null],
            'version' => ['type' => 'datetime', 'length' => null, 'null' => false, 'default' => null, 'comment' => '', 'precision' => null],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id'], 'length' => []]],
    ],
    [
        'table' => 'todo_items',
        'columns' => [
            'id' => ['type' => 'integer', 'null' => false],
            'user_id' => ['type' => 'integer', 'null' => false],
            'title' => ['type' => 'string', 'length' => 50, 'null' => false],
            'body' => ['type' => 'text'],
            'effort' => ['type' => 'decimal', 'default' => 0, 'null' => false],
            'completed' => ['type' => 'boolean', 'default' => false, 'null' => false],
            'todo_task_count' => ['type' => 'integer', 'default' => 0, 'null' => false],
            'created' => ['type' => 'datetime'],
            'updated' => ['type' => 'datetime'],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'todo_reminders',
        'columns' => [
            'id' => ['type' => 'integer', 'null' => false],
            'todo_item_id' => ['type' => 'integer', 'null' => false],
            'triggered_at' => ['type' => 'datetime'],
        ],
        'constraints' => [
            'primary' => ['type' => 'primary', 'columns' => ['id']],
            'unique_todo_item' => ['type' => 'unique', 'columns' => ['todo_item_id']],
        ],
    ],
    [
        'table' => 'todo_labels',
        'columns' => [
            'id' => ['type' => 'integer'],
            'label' => ['type' => 'string', 'null' => false],
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['id']]],
    ],
    [
        'table' => 'todo_items_todo_labels',
        'columns' => [
            'todo_item_id' => ['type' => 'integer', 'null' => false],
            'todo_label_id' => ['type' => 'integer', 'null' => false],
        ],
        'constraints' => [
            'primary' => ['type' => 'primary', 'columns' => ['todo_item_id', 'todo_label_id']],
            'item_fk' => [
                'type' => 'foreign',
                'columns' => ['todo_item_id'],
                'references' => ['todo_items', 'id'],
                'update' => 'cascade',
                'delete' => 'cascade',
            ],
            'label_fk' => [
                'type' => 'foreign',
                'columns' => ['todo_label_id'],
                'references' => ['todo_labels', 'id'],
                'update' => 'cascade',
                'delete' => 'cascade',
            ],
        ],
    ],
    [
        'table' => 'todo_tasks',
        'columns' => [
            'uid' => ['type' => 'integer'],
            'todo_item_id' => ['type' => 'integer', 'null' => false],
            'title' => ['type' => 'string', 'length' => 50, 'null' => false],
            'body' => 'text',
            'completed' => ['type' => 'boolean', 'default' => false, 'null' => false],
            'effort' => ['type' => 'decimal', 'default' => 0.0, 'null' => false, 'unsigned' => true],
            'created' => 'datetime',
            'updated' => 'datetime',
        ],
        'constraints' => ['primary' => ['type' => 'primary', 'columns' => ['uid']]],
    ],
    [
        'table' => 'unique_fields',
        'columns' => [
            'id' => ['type' => 'integer'],
            'username' => ['type' => 'string', 'null' => true, 'length' => 255],
            'email' => ['type' => 'string', 'null' => true, 'length' => 255],
            'field_1' => ['type' => 'string', 'null' => true, 'length' => 255],
            'field_2' => ['type' => 'string', 'null' => true,'length' => 255],
        ],
        'constraints' => [
            'primary' => [
                'type' => 'primary',
                'columns' => ['id'],
            ],
            'multiple_fields_unique' => [
                'type' => 'unique',
                'columns' => [
                    'field_1',
                    'field_2',
                ],
            ],
        ],
    ],
    [
        'table' => 'self_referencing_unique_keys',
        'columns' => [
            'id' => ['type' => 'integer'],
            'parent_id' => ['type' => 'integer'],
        ],
        'constraints' => [
            'primary' => ['type' => 'primary', 'columns' => ['id']],
            'unique_self_referencing_parent' => ['type' => 'unique', 'columns' => ['parent_id']],
        ],
    ],
];
