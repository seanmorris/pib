<?php
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
namespace Bake\Test\Fixture;

use Cake\TestSuite\Fixture\TestFixture;

/**
 * Test fixture for various data types.
 */
class DatatypesFixture extends TestFixture
{
    /**
     * Records property
     *
     * @var array
     */
    public array $records = [
        ['decimal_field' => '30.123', 'float_field' => 42.23, 'huge_int' => '1234567891234567891', 'small_int' => '1234', 'tiny_int' => '12', 'bool' => 0, 'timestamp_field' => '2007-03-17 01:16:23'],
    ];
}
