<?php
declare(strict_types=1);

/**
 * CakePHP : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP Project
 * @since         2.0.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\Utility;

use Cake\Database\Schema\CollectionInterface;
use Cake\Database\Schema\TableSchemaInterface;

/**
 * Proxy for a SchemaCollection that subsets listTables()
 *
 * Useful to create determinsitic subsets of fixtures when
 * testing.
 */
class SubsetSchemaCollection implements CollectionInterface
{
    /**
     * @var \Cake\Database\Schema\CollectionInterface
     */
    protected CollectionInterface $collection;

    /**
     * @var list<string>
     */
    protected array $tables = [];

    /**
     * @param \Cake\Database\Schema\CollectionInterface $collection The wrapped collection
     * @param list<string> $tables The subset of tables.
     */
    public function __construct(CollectionInterface $collection, array $tables)
    {
        $this->collection = $collection;
        $this->tables = $tables;
    }

    /**
     * Get the wrapped collection
     *
     * @return \Cake\Database\Schema\CollectionInterface
     */
    public function getInnerCollection(): CollectionInterface
    {
        return $this->collection;
    }

    /**
     * Get the list of tables in this schema collection.
     *
     * @return list<string>
     */
    public function listTables(): array
    {
        return $this->tables;
    }

    /**
     * @inheritDoc
     */
    public function describe(string $name, array $options = []): TableSchemaInterface
    {
        return $this->collection->describe($name, $options);
    }
}
