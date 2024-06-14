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
 * @since         2.8.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\CodeGen;

/**
 * @internal
 */
class ParsedClass
{
    /**
     * @var string
     */
    public string $name;

    /**
     * @var array<string>
     */
    public array $implements;

    /**
     * @var array<string, string>
     */
    public array $constants;

    /**
     * @var array<string, string>
     */
    public array $properties;

    /**
     * @var array<string, string>
     */
    public array $methods;

    /**
     * @param string $name Class name
     * @param array<string> $implements List of implements
     * @param array<string, string> $constants Class constants
     * @param array<string, string> $properties Class properties
     * @param array<string, string> $methods Class methods
     */
    public function __construct(string $name, array $implements, array $constants, array $properties, array $methods)
    {
        $this->name = $name;
        $this->implements = $implements;
        $this->constants = $constants;
        $this->properties = $properties;
        $this->methods = $methods;
    }
}
