<?php

namespace Jasny\Twig;

use Twig\Error\RuntimeError;
use Twig\Extension\AbstractExtension;
use Twig\TwigFilter;

/**
 * Expose the PCRE functions to Twig.
 *
 * @see http://php.net/manual/en/book.pcre.php
 */
class PcreExtension extends AbstractExtension
{
    /**
     * Class constructor
     */
    public function __construct()
    {
        if (!extension_loaded('pcre')) {
            throw new \Exception("The Twig PCRE extension requires the PCRE extension."); // @codeCoverageIgnore
        }
    }

    /**
     * Return extension name
     *
     * @return string
     */
    public function getName()
    {
        return 'jasny/pcre';
    }

    /**
     * {@inheritdoc}
     */
    public function getFilters()
    {
        return [
            new TwigFilter('preg_quote', [$this, 'quote']),
            new TwigFilter('preg_match', [$this, 'match']),
            new TwigFilter('preg_get', [$this, 'get']),
            new TwigFilter('preg_get_all', [$this, 'getAll']),
            new TwigFilter('preg_grep', [$this, 'grep']),
            new TwigFilter('preg_replace', [$this, 'replace']),
            new TwigFilter('preg_filter', [$this, 'filter']),
            new TwigFilter('preg_split', [$this, 'split']),
        ];
    }


    /**
     * Check that the regex doesn't use the eval modifier
     *
     * @param string $pattern
     * @throws \LogicException
     */
    protected function assertNoEval($pattern)
    {
        $pos = strrpos($pattern, $pattern[0]);
        $modifiers = substr($pattern, $pos + 1);

        if (strpos($modifiers, 'e') !== false) {
            throw new RuntimeError("Using the eval modifier for regular expressions is not allowed");
        }
    }


    /**
     * Quote regular expression characters.
     *
     * @param string $value
     * @param string $delimiter
     * @return string
     */
    public function quote($value, $delimiter = '/')
    {
        if (!isset($value)) {
            return null;
        }

        return preg_quote($value, $delimiter);
    }

    /**
     * Perform a regular expression match.
     *
     * @param string $value
     * @param string $pattern
     * @return boolean
     */
    public function match($value, $pattern)
    {
        if (!isset($value)) {
            return null;
        }

        return preg_match($pattern, $value);
    }

    /**
     * Perform a regular expression match and return a matched group.
     *
     * @param string $value
     * @param string $pattern
     * @return string
     */
    public function get($value, $pattern, $group = 0)
    {
        if (!isset($value)) {
            return null;
        }

        return preg_match($pattern, $value, $matches) && isset($matches[$group]) ? $matches[$group] : null;
    }

    /**
     * Perform a regular expression match and return the group for all matches.
     *
     * @param string $value
     * @param string $pattern
     * @return array
     */
    public function getAll($value, $pattern, $group = 0)
    {
        if (!isset($value)) {
            return null;
        }

        return preg_match_all($pattern, $value, $matches, PREG_PATTERN_ORDER) && isset($matches[$group])
            ? $matches[$group] : [];
    }

    /**
     * Perform a regular expression match and return an array of entries that match the pattern
     *
     * @param array  $values
     * @param string $pattern
     * @param string $flags    Optional 'invert' to return entries that do not match the given pattern.
     * @return array
     */
    public function grep($values, $pattern, $flags = '')
    {
        if (!isset($values)) {
            return null;
        }

        if (is_string($flags)) {
            $flags = $flags === 'invert' ? PREG_GREP_INVERT : 0;
        }

        return preg_grep($pattern, $values, $flags);
    }

    /**
     * Perform a regular expression search and replace.
     *
     * @param string $value
     * @param string $pattern
     * @param string $replacement
     * @param int    $limit
     * @return string
     */
    public function replace($value, $pattern, $replacement = '', $limit = -1)
    {
        $this->assertNoEval($pattern);

        if (!isset($value)) {
            return null;
        }

        return preg_replace($pattern, $replacement, $value, $limit);
    }

    /**
     * Perform a regular expression search and replace, returning only matched subjects.
     *
     * @param string $value
     * @param string $pattern
     * @param string $replacement
     * @param int    $limit
     * @return string
     */
    public function filter($value, $pattern, $replacement = '', $limit = -1)
    {
        $this->assertNoEval($pattern);

        if (!isset($value)) {
            return null;
        }

        return preg_filter($pattern, $replacement, $value, $limit);
    }

    /**
     * Split text into an array using a regular expression.
     *
     * @param string $value
     * @param string $pattern
     * @return array
     */
    public function split($value, $pattern)
    {
        if (!isset($value)) {
            return null;
        }

        return preg_split($pattern, $value);
    }
}
