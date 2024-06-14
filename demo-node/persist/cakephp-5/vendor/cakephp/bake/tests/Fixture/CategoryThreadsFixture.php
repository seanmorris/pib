<?php
/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         0.1.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\Test\Fixture;

use Cake\TestSuite\Fixture\TestFixture;

/**
 * Fixture for testing threaded models.
 */
class CategoryThreadsFixture extends TestFixture
{
    /**
     * records property
     *
     * @var array
     */
    public array $records = [
        ['parent_id' => 0, 'name' => 'Category 1', 'lft' => 1, 'rght' => 14, 'created' => '2007-03-18 15:30:23', 'updated' => '2007-03-18 15:32:31'],
        ['parent_id' => 1, 'name' => 'Category 1.1', 'lft' => 2, 'rght' => 9, 'created' => '2007-03-18 15:30:23', 'updated' => '2007-03-18 15:32:31'],
        ['parent_id' => 2, 'name' => 'Category 1.1.1', 'lft' => 3, 'rght' => 8, 'created' => '2007-03-18 15:30:23', 'updated' => '2007-03-18 15:32:31'],
        ['parent_id' => 3, 'name' => 'Category 1.1.2', 'lft' => 4, 'rght' => 7, 'created' => '2007-03-18 15:30:23', 'updated' => '2007-03-18 15:32:31'],
        ['parent_id' => 4, 'name' => 'Category 1.1.1.1', 'lft' => 5, 'rght' => 6, 'created' => '2007-03-18 15:30:23', 'updated' => '2007-03-18 15:32:31'],
        ['parent_id' => 5, 'name' => 'Category 2', 'lft' => 10, 'rght' => 13, 'created' => '2007-03-18 15:30:23', 'updated' => '2007-03-18 15:32:31'],
        ['parent_id' => 6, 'name' => 'Category 2.1', 'lft' => 11, 'rght' => 12, 'created' => '2007-03-18 15:30:23', 'updated' => '2007-03-18 15:32:31'],
    ];
}
