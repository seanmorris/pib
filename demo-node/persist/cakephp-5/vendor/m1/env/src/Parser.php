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

namespace M1\Env;

use M1\Env\Exception\ParseException;
use M1\Env\Helper\StringHelper;
use M1\Env\Parser\ValueParser;
use M1\Env\Parser\KeyParser;

/**
 * The .env parser
 *
 * @since 0.1.0
 */
class Parser
{
    /**
     * The Env key parser
     *
     * @var \M1\Env\Parser\KeyParser $key_parser
     */
    private $key_parser;

    /**
     * The line num of the current value
     *
     * @var int $line_num
     */
    public $line_num;

    /**
     * The current parsed values/lines
     *
     * @var array $lines
     */
    public $lines = array();

    /**
     * The String helper class
     *
     * @var \M1\Env\Helper\StringHelper $string_helper
     */
    public $string_helper;


    /**
     * The Env value parser
     *
     * @var \M1\Env\Parser\ValueParser $value_parser
     */
    public $value_parser;

    /**
     * The parser constructor
     *
     * @param string $content The content to parse
     * @param array $context Variables context
     */
    public function __construct($content, array $context = array())
    {
        $this->key_parser = new KeyParser($this);
        $this->value_parser = new ValueParser($this, $context);
        $this->string_helper = new StringHelper();

        $this->doParse($content);
    }

    /**
     * Parses the .env and returns the contents statically
     *
     * @param string $content The content to parse
     * @param array $context Variables context
     *
     * @return array The .env contents
     */
    public static function parse($content, array $context = array())
    {
        $parser = new Parser($content, $context);

        return $parser->getContent();
    }

    /**
     * Opens the .env, parses it then returns the contents
     *
     * @param string $content The content to parse
     *
     * @return array The .env contents
     */
    protected function doParse($content)
    {
        $raw_lines = array_filter($this->makeLines($content), 'strlen');

        if (empty($raw_lines)) {
            return;
        }

        return $this->parseContent($raw_lines);
    }

    /**
     * Splits the string into an array
     *
     * @param string $content The string content to split
     *
     * @return array The array of lines to parse
     */
    private function makeLines($content)
    {
        return explode("\n", str_replace(array("\r\n", "\n\r", "\r"), "\n", $content));
    }

    /**
     * Parses the .env line by line
     *
     * @param array $raw_lines The raw content of the file
     *
     * @throws \M1\Env\Exception\ParseException If the file does not have a key=value structure
     *
     * @return array The .env contents
     */
    private function parseContent(array $raw_lines)
    {
        $this->lines = array();
        $this->line_num = 0;

        foreach ($raw_lines as $raw_line) {
            $this->line_num++;

            $line = trim($raw_line);

            if ($this->string_helper->startsWith('#', $line) || !$line) {
                continue;
            }

            $this->parseLine($raw_line);
        }

        return $this->lines;
    }

    /**
     * Parses a line of the .env
     *
     * @param string $raw_line The raw content of the line
     *
     * @return array The parsed lines
     */
    private function parseLine($raw_line)
    {
        $raw_line = $this->parseExport($raw_line);

        list($key, $value) = $this->parseKeyValue($raw_line);

        $key = $this->key_parser->parse($key);

        if (!is_string($key)) {
            return;
        }

        $this->lines[$key] = $this->value_parser->parse($value);
    }

    /**
     * Parses a export line of the .env
     *
     * @param string $raw_line The raw content of the line
     *
     * @throws \M1\Env\Exception\ParseException If the file does not have a key=value structure
     *
     * @return string The parsed line
     */
    private function parseExport($raw_line)
    {
        $line = trim($raw_line);

        if ($this->string_helper->startsWith("export", $line)) {
            $export_line = explode("export", $raw_line, 2);

            if (count($export_line) !== 2 || empty($export_line[1])) {
                throw new ParseException(
                    'You must have a export key = value',
                    $raw_line,
                    $this->line_num
                );
            }

            $line = trim($export_line[1]);
        }

        return $line;
    }

    /**
     * Gets the key = value items from the line
     *
     * @param string $raw_line The raw content of the line
     *
     * @throws \M1\Env\Exception\ParseException If the line does not have a key=value structure
     *
     * @return array The parsed lines
     */
    private function parseKeyValue($raw_line)
    {
        $key_value = explode("=", $raw_line, 2);

        if (count($key_value) !== 2) {
            throw new ParseException(
                'You must have a key = value',
                $raw_line,
                $this->line_num
            );
        }

        return $key_value;
    }

    /**
     * Returns the contents of the .env
     *
     * @return array The .env contents
     */
    public function getContent($keyName = null)
    {
		if (!is_null($keyName)) {
			return (array_key_exists($keyName, $this->lines)) ? $this->lines[$keyName] : null;
		}
        return $this->lines;
    }
}
