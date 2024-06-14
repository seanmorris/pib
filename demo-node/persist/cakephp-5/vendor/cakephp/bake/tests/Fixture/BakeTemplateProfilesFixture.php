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
 * @since         1.2.1
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\Test\Fixture;

use Cake\TestSuite\Fixture\TestFixture;

/**
 * Fixture used for test bake template task
 *
 * @package Bake\Test\Fixture
 * @see TemplateTaskTest::testBakeTemplate
 */
class BakeTemplateProfilesFixture extends TestFixture
{
    /**
     * @var string
     */
    public string $table = 'profiles';

    /**
     * records property
     *
     * @var array
     */
    public array $records = [
        ['author_id' => 1, 'nick' => 'The Comedian', 'avatar' => 'smiley.png'],
        ['author_id' => 2, 'nick' => 'Rorschach', 'avatar' => 'stains.png'],
        ['author_id' => 3, 'nick' => 'Ozymandias', 'avatar' => null],
        ['author_id' => 4, 'nick' => 'Dr. Manhattan', 'avatar' => 'blue_lightning.png'],
    ];
}
