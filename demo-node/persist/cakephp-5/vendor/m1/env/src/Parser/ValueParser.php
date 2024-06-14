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

namespace M1\Env\Parser;

use M1\Env\Exception\ParseException;

/**
 * The value parser for Env
 *
 * @since 0.2.0
 */
class ValueParser extends AbstractParser
{
    /**
     * The regex to get the content between double quote (") strings, ignoring escaped quotes.
     * Unescaped: "(?:[^"\\]*(?:\\.)?)*"
     *
     * @var string REGEX_QUOTE_DOUBLE_STRING
     */
    const REGEX_QUOTE_DOUBLE_STRING = '"(?:[^\"\\\\]*(?:\\\\.)?)*\"';

    /**
     * The regex to get the content between single quote (') strings, ignoring escaped quotes
     * Unescaped: '(?:[^'\\]*(?:\\.)?)*'
     *
     * @var string REGEX_QUOTE_SINGLE_STRING
     */
    const REGEX_QUOTE_SINGLE_STRING = "'(?:[^'\\\\]*(?:\\\\.)?)*'";

    /**
     * The value types that Env supports
     *
     * @var array $value_types
     */
    private static $value_types = array(
        'string',
        'bool',
        'number',
        'null',
    );

    /**
     * The map to convert escaped characters into real characters
     *
     * @var array $character_map
     */
    private static $character_map = array(
        "\\n" => "\n",
        "\\\"" => "\"",
        '\\\'' => "'",
        '\\t' => "\t"
    );

    /**
     * The parser for variables
     *
     * @var \M1\Env\Parser\VariableParser $variable_parser
     */
    private $variable_parser;

    /**
     * {@inheritdoc}
     *
     * @param \M1\Env\Parser $parser The parent parser
     * @param array $context Variables context
     */
    public function __construct($parser, array $context = array())
    {
        parent::__construct($parser);

        $this->variable_parser = new VariableParser($parser, $context);
    }

    /**
     * Parses a .env value
     *
     * @param string $value    The value to parse
     *
     * @return string|null The parsed key, or null if the key is a comment
     */
    public function parse($value)
    {
        $value = trim($value);

        if ($this->parser->string_helper->startsWith('#', $value)) {
            return null;
        }

        return $this->parseValue($value);
    }

    /**
     * Parses a .env value
     *
     * @param string $value The value to parse
     *
     * @return string|null The parsed value, or null if the value is null
     *
     * @uses parseString
     * @uses parseNull
     * @uses parseBool
     * @uses parseNumber
     */
    private function parseValue($value)
    {
        foreach (self::$value_types as $type) {
            $parsed_value = $value;

            if ($type !== 'string') {
                $parsed_value = $this->parser->string_helper->stripComments($value);
            }

            list($is_function, $parse_function) = $this->fetchFunctionNames($type);

            if ($this->parser->string_helper->$is_function($parsed_value)) {
                return $this->$parse_function($parsed_value);
            }
        }

        return (isset($parsed_value)) ? $this->parseUnquotedString($parsed_value) : $value;
    }

    /**
     * Gets the functions for the value type
     *
     * @param string $type The value type
     *
     * @return string[] The is and parse function names
     */
    private function fetchFunctionNames($type)
    {
        $type = ucfirst($type);

        return array(
            'is'.$type,
            'parse'.$type
        );
    }

    /**
     * Parses a .env string
     *
     * @param string $value    The value to parse
     *
     * @return string The parsed string
     */
    private function parseString($value)
    {
        $single = false;
        $regex = self::REGEX_QUOTE_DOUBLE_STRING;
        $symbol = '"';

        if ($this->parser->string_helper->startsWith('\'', $value)) {
            $single = true;
            $regex =  self::REGEX_QUOTE_SINGLE_STRING;
            $symbol = "'";
        }

        $matches = $this->fetchStringMatches($value, $regex, $symbol);

        $value = $matches[0];
        if ($value !== '') {
            $value = substr($value, 1, strlen($value) - 2);
        }
        $value = strtr($value, self::$character_map);

        return ($single) ? $value : $this->variable_parser->parse($value, true);
    }

    /**
     * Gets the regex matches in the string
     *
     * @param string $regex    The regex to use
     * @param string $value    The value to parse
     * @param string $symbol   The symbol we're parsing for
     *
     * @throws \M1\Env\Exception\ParseException If the string has a missing end quote
     *
     * @return string[] The matches based on the regex and the value
     */
    private function fetchStringMatches($value, $regex, $symbol)
    {
        if (!preg_match('/'.$regex.'/', $value, $matches)) {
            throw new ParseException(
                sprintf('Missing end %s quote', $symbol),
                $value,
                $this->parser->line_num
            );
        }

        return $matches;
    }

    /**
     * Parses a .env null value
     *
     * @param string $value The value to parse
     *
     * @return null Null value
     */
    private function parseNull($value)
    {
        return (is_null($value) || $value === "null") ? null : false;
    }

    /**
     * Parses a .env unquoted string
     *
     * @param string $value The value to parse
     *
     * @return string The parsed string
     */
    private function parseUnquotedString($value)
    {
        if ($value === "") {
            return null;
        }

        return $this->variable_parser->parse($value);
    }

    /**
     * Parses a .env bool
     *
     * @param string $value The value to parse
     *
     * @return bool The parsed bool
     */
    private function parseBool($value)
    {
        $value = strtolower($value);

        return $value === "true" || $value === "yes";
    }

    /**
     * Parses a .env number
     *
     * @param string $value The value to parse
     *
     * @return int|float The parsed bool
     */
    private function parseNumber($value)
    {
        if (strpos($value, '.') !== false) {
            return (float) $value;
        }

        return (int) $value;
    }
}
