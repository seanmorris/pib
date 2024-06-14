<?php

/**
 * This file is part of the m1\env library
 *
 * (c) m1 <hello@milescroxford.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * @package     m1/env
 * @version     2.0.0
 * @author      Miles Croxford <hello@milescroxford.com>
 * @copyright   Copyright (c) Miles Croxford <hello@milescroxford.com>
 * @license     http://github.com/m1/env/blob/master/LICENSE.md
 * @link        http://github.com/m1/env/blob/master/README.md Documentation
 */

namespace M1\Env\Helper;

/**
 * The class for string helping
 *
 * @since 1.1.0
 */
class StringHelper
{
    /**
     * The bool variants available in .env
     *
     * @var array $bool_variants
     */
    private static $bool_variants = array(
        'true', 'false', 'yes', 'no'
    );

    /**
     * Returns if value is a bool
     *
     * @param string $value The value to test
     *
     * @return bool Is a value a bool
     */
    public function isBool($value)
    {
        return in_array(strtolower($value), self::$bool_variants);
    }

    /**
     * Returns if the bool is in a string
     *
     * @param string $value         The value to test
     * @param bool   $quoted_string Is the context a quoted string
     * @param int    $word_count    The amount of words in the sentence
     *
     * @return bool Is a value a bool in a string
     */
    public function isBoolInString($value, $quoted_string, $word_count)
    {
        return (is_bool($value)) && ($quoted_string || $word_count >= 2);
    }

    /**
     * Returns if value is null
     *
     * @param string $value The value to test
     *
     * @return bool Is a value null
     */
    public function isNull($value)
    {
        return $value === 'null';
    }

    /**
     * Returns if value is number
     *
     * @param string $value The value to test
     *
     * @return bool Is a value a number
     */
    public function isNumber($value)
    {
        return is_numeric($value);
    }

    /**
     * Returns if value is a string
     *
     * @param string $value The value to test
     *
     * @return bool Is a value a string
     */
    public function isString($value)
    {
        return $this->startsWith('\'', $value) || $this->startsWith('"', $value);
    }

    /**
     * Returns if variable value is a clone, e.g. BOOL = $(BOOL_1)
     *
     * @param string $value         The value to test
     * @param array  $matches       The matches of the variables
     * @param bool   $quoted_string If the value is in a quoted string
     *
     * @return bool Is a value null
     */
    public function isVariableClone($value, $matches, $quoted_string)
    {
        return (count($matches[0]) === 1) && $value == $matches[0][0] && !$quoted_string;
    }

    /**
     * Returns if value starts with a value
     *
     * @param string $string The value to search for
     * @param string $line   The line to test
     *
     * @return bool Returns if the line starts with value
     */
    public function startsWith($string, $line)
    {
        return $string === "" || strrpos($line, $string, -strlen($line)) !== false;
    }

    /**
     * Returns if value starts with a number
     *
     * @param string $line   The line to test
     *
     * @return bool Returns if the line starts with a number
     */
    public function startsWithNumber($line)
    {
        return is_numeric(substr($line, 0, 1));
    }

    /**
     * Strips comments from a value
     *
     * @param string $value The value to strip comments from
     *
     * @return string value
     */
    public function stripComments($value)
    {
        $value = explode(" #", $value, 2);
        return trim($value[0]);
    }
}
