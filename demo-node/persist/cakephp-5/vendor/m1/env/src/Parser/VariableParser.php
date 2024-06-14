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
 * @since 1.1.0
 */
class VariableParser extends AbstractParser
{
    /**
     * The regex to get variables '$(VARIABLE)' in .env
     * Unescaped: ${(.*?)}
     *
     * @var string REGEX_ENV_VARIABLE
     */
    const REGEX_ENV_VARIABLE = '\\${(.*?)}';

    /**
     * The symbol for the assign default value parameter expansion
     *
     * @var string SYMBOL_ASSIGN_DEFAULT_VALUE
     */
    const SYMBOL_ASSIGN_DEFAULT_VALUE = '=';

    /**
     * The symbol for the default value parameter expansion
     *
     * @var string SYMBOL_DEFAULT_VALUE
     */
    const SYMBOL_DEFAULT_VALUE = '-';

    /**
     * Variables context
     *
     * @var array
     */
    private $context;

    /**
     * {@inheritdoc}
     *
     * @param \M1\Env\Parser $parser The parent parser
     * @param array $context Variables context
     */
    public function __construct($parser, array $context = array())
    {
        parent::__construct($parser);

        $this->context = $context;
    }

    /**
     * Parses a .env variable
     *
     * @param string $value         The value to parse
     * @param bool   $quoted_string Is the value in a quoted string
     *
     * @return string The parsed value
     */
    public function parse($value, $quoted_string = false)
    {
        $matches = $this->fetchVariableMatches($value);

        if (is_array($matches)) {
            if ($this->parser->string_helper->isVariableClone($value, $matches, $quoted_string)) {
                return $this->fetchVariable($value, $matches[1][0], $matches, $quoted_string);
            }

            $value = $this->doReplacements($value, $matches, $quoted_string);
        }

        return $value;
    }

    /**
     * Get variable matches inside a string
     *
     * @param string $value The value to parse
     *
     * @return array The variable matches
     */
    private function fetchVariableMatches($value)
    {
        preg_match_all('/' . self::REGEX_ENV_VARIABLE . '/', $value, $matches);

        if (!is_array($matches) || !isset($matches[0]) || empty($matches[0])) {
            return false;
        }

        return $matches;
    }

    /**
     * Parses a .env variable
     *
     * @param string $value The value to parse
     * @param string $variable_name The variable name to get
     * @param array $matches The matches of the variables
     * @param bool $quoted_string Is the value in a quoted string
     *
     * @return string The parsed value
     * @throws \M1\Env\Exception\ParseException If the variable can not be found
     */
    private function fetchVariable($value, $variable_name, $matches, $quoted_string)
    {
        if ($this->hasParameterExpansion($variable_name)) {
            $replacement = $this->fetchParameterExpansion($variable_name);
        } elseif ($this->hasVariable($variable_name)) {
            $replacement = $this->getVariable($variable_name);
        } else {
            throw new ParseException(
                sprintf('Variable has not been defined: %s', $variable_name),
                $value,
                $this->parser->line_num
            );
        }

        if ($this->parser->string_helper->isBoolInString($replacement, $quoted_string, count($matches[0]))) {
            $replacement = ($replacement) ? 'true' : 'false';
        }

        return $replacement;
    }

    /**
     * Checks to see if the variable has a parameter expansion
     *
     * @param string $variable The variable to check
     *
     * @return bool Does the variable have a parameter expansion
     */
    private function hasParameterExpansion($variable)
    {
        if ((strpos($variable, self::SYMBOL_DEFAULT_VALUE) !== false) ||
            (strpos($variable, self::SYMBOL_ASSIGN_DEFAULT_VALUE) !== false)
        ) {
            return true;
        }

        return false;
    }

    /**
     * Fetches and sets the parameter expansion
     *
     * @param string $variable_name The parameter expansion inside this to fetch
     *
     * @return string The parsed value
     */
    private function fetchParameterExpansion($variable_name)
    {
        $parameter_type = $this->fetchParameterExpansionType($variable_name);

        list($parameter_symbol, $empty_flag) = $this->fetchParameterExpansionSymbol($variable_name, $parameter_type);
        list($variable, $default) = $this->splitVariableDefault($variable_name, $parameter_symbol);

        $value = $this->getVariable($variable);

        return $this->parseVariableParameter(
            $variable,
            $default,
            $this->hasVariable($variable),
            $empty_flag && empty($value),
            $parameter_type
        );
    }

    /**
     * Fetches the parameter expansion type
     *
     * @param string $variable_name The parameter expansion type to get from this
     *
     * @return string The parameter expansion type
     */
    private function fetchParameterExpansionType($variable_name)
    {
        if (strpos($variable_name, self::SYMBOL_ASSIGN_DEFAULT_VALUE) !== false) {
            return 'assign_default_value';
        }

        return 'default_value'; // self::DEFAULT_VALUE_SYMBOL
    }

    /**
     * Fetches the parameter type symbol
     *
     * @param string $variable_name The variable
     * @param string $type          The type of parameter expansion
     *
     * @return array The symbol and if there is a empty check
     */
    private function fetchParameterExpansionSymbol($variable_name, $type)
    {
        $class = new \ReflectionClass($this);
        $symbol = $class->getConstant('SYMBOL_'.strtoupper($type));
        $pos = strpos($variable_name, $symbol);

        $check_empty = substr($variable_name, ($pos - 1), 1) === ":";

        if ($check_empty) {
            $symbol = sprintf(":%s", $symbol);
        }

        return array($symbol, $check_empty);
    }

    /**
     * Splits the parameter expansion into variable and default
     *
     * @param string $variable_name    The variable name to split
     * @param string $parameter_symbol The parameter expansion symbol
     *
     * @throws \M1\Env\Exception\ParseException If the parameter expansion if not valid syntax
     *
     * @return array The split variable and default value
     */
    private function splitVariableDefault($variable_name, $parameter_symbol)
    {
        $variable_default = explode($parameter_symbol, $variable_name, 2);

        if (count($variable_default) !== 2 || empty($variable_default[1])) {
            throw new ParseException(
                'You must have valid parameter expansion syntax, eg. ${parameter:=word}',
                $variable_name,
                $this->parser->line_num
            );
        }

        return array(trim($variable_default[0]), trim($variable_default[1]));
    }


    /**
     * Parses and sets the variable and default if needed
     *
     * @param string $variable The variable to parse
     * @param string $default  The default value
     * @param bool   $exists   Does the variable exist
     * @param bool   $empty    Is there the variable empty if exists and the empty flag is set
     * @param string $type     The type of parameter expansion
     *
     * @return string The parsed value
     */
    private function parseVariableParameter($variable, $default, $exists, $empty, $type)
    {
        if ($exists && !$empty) {
            return $this->getVariable($variable);
        }

        return $this->assignVariableParameterDefault($variable, $default, $empty, $type);
    }

    /**
     * Parses and sets the variable parameter to default
     *
     * @param string $variable The variable to parse
     * @param string $default  The default value
     * @param bool   $empty    Is there the variable empty if exists and the empty flag is set
     * @param string $type     The type of parameter expansion
     *
     * @return string The parsed default value
     */
    private function assignVariableParameterDefault($variable, $default, $empty, $type)
    {
        $default = $this->parser->value_parser->parse($default);

        if ($type === "assign_default_value" && $empty) {
            $this->parser->lines[$variable] = $default;
        }

        return $default;
    }

    /**
     * Checks to see if a variable exists
     *
     * @param string $variable The variable name to get
     *
     * @return bool
     */
    private function hasVariable($variable)
    {
        if (array_key_exists($variable, $this->parser->lines)) {
            return true;
        }

        if (array_key_exists($variable, $this->context)) {
            return true;
        }

        return false;
    }

    /**
     * Get variable value
     *
     * @param string $variable
     *
     * @return mixed
     */
    private function getVariable($variable)
    {
        if (array_key_exists($variable, $this->parser->lines)) {
            return $this->parser->lines[$variable];
        }

        if (array_key_exists($variable, $this->context)) {
            return $this->context[$variable];
        }

        return null;
    }

    /**
     * Do the variable replacements
     *
     * @param string $value         The value to throw an error with if doesn't exist
     * @param array  $matches       The matches of the variables
     * @param bool   $quoted_string Is the value in a quoted string
     *
     * @return string The parsed value
     */
    public function doReplacements($value, $matches, $quoted_string)
    {
        $replacements = array();

        for ($i = 0; $i <= (count($matches[0]) - 1); $i++) {
            $replacement = $this->fetchVariable($value, $matches[1][$i], $matches, $quoted_string);
            $replacements[$matches[0][$i]] = $replacement;
        }

        if (!empty($replacements)) {
            $value = strtr($value, $replacements);
        }

        return $value;
    }
}
