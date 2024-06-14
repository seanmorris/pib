<?php
/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Test\Fixture;

use Cake\TestSuite\Fixture\TestFixture;

/**
 * Panels fixture.
 *
 * Used to create schema for tests and at runtime.
 */
class PanelsFixture extends TestFixture
{
    /**
     * table property
     *
     * This is necessary to prevent userland inflections from causing issues.
     *
     * @var string
     */
    public string $table = 'panels';

    /**
     * Records
     *
     * @var array
     */
    public array $records = [];
}
