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

class ClassBuilder
{
    /**
     * @var \Bake\CodeGen\ParsedClass|null
     */
    protected ?ParsedClass $parsedClass;

    /**
     * @param \Bake\CodeGen\ParsedClass $parsedClass Parsed class it already exists
     */
    public function __construct(?ParsedClass $parsedClass = null)
    {
        $this->parsedClass = $parsedClass;
    }

    /**
     * Returns the list of implements to add to class.
     *
     * @param array<string> $generated Implements that are generated
     * @return array<string>
     */
    public function getImplements(array $generated = []): array
    {
        return array_unique(array_merge($generated, $this->parsedClass->implements ?? []));
    }

    /**
     * Returns the user functions from existing file.
     *
     * @param array<string> $generated Constants that are generated
     * @return array<string, string>
     */
    public function getUserConstants(array $generated = []): array
    {
        if ($this->parsedClass === null) {
            return [];
        }

        return array_diff_key($this->parsedClass->constants, array_flip($generated));
    }

    /**
     * Returns the user functions from existing file.
     *
     * @param array<string> $generated Proeprties that are generated
     * @return array<string, string>
     */
    public function getUserProperties(array $generated = []): array
    {
        if ($this->parsedClass === null) {
            return [];
        }

        return array_diff_key($this->parsedClass->properties, array_flip($generated));
    }

    /**
     * Returns the user functions from existing file.
     *
     * @param array<string> $generated Methods that are generated
     * @return array<string, string>
     */
    public function getUserFunctions(array $generated = []): array
    {
        if ($this->parsedClass === null) {
            return [];
        }

        return array_diff_key($this->parsedClass->methods, array_flip($generated));
    }
}
