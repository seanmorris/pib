<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use function assert;
use function str_replace;
use function strlen;
use function strpos;
use function substr;
use function trim;

use const PHP_EOL;

abstract class AbstractHtmlElement extends AbstractHelper
{
    /**
     * EOL character
     *
     * @deprecated just use PHP_EOL
     */
    public const EOL = PHP_EOL;

    /**
     * The tag closing bracket
     *
     * @var string
     */
    protected $closingBracket;

    /**
     * Get the tag closing bracket
     *
     * @return string
     */
    public function getClosingBracket()
    {
        if (! $this->closingBracket) {
            if ($this->isXhtml()) {
                $this->closingBracket = ' />';
            } else {
                $this->closingBracket = '>';
            }
        }

        return $this->closingBracket;
    }

    /**
     * Is doctype XHTML?
     *
     * @return bool
     */
    protected function isXhtml()
    {
        $plugin = $this->getView()->plugin('doctype');
        assert($plugin instanceof Doctype);

        return $plugin->isXhtml();
    }

    /**
     * Converts an associative array to a string of tag attributes.
     *
     * @access public
     * @param array $attribs From this array, each key-value pair is
     * converted to an attribute name and value.
     * @return string The XHTML for the attributes.
     */
    protected function htmlAttribs($attribs)
    {
        foreach ((array) $attribs as $key => $val) {
            if ('id' === $key) {
                $attribs[$key] = $this->normalizeId($val);
            }
        }

        $helper = $this->getView()->plugin(HtmlAttributes::class);
        assert($helper instanceof HtmlAttributes);

        return (string) $helper($attribs);
    }

    /**
     * Normalize an ID
     *
     * @param  string $value
     * @return string
     */
    protected function normalizeId($value)
    {
        if (false !== strpos($value, '[')) {
            if ('[]' === substr($value, -2)) {
                $value = substr($value, 0, strlen($value) - 2);
            }
            $value = trim($value, ']');
            $value = str_replace('][', '-', $value);
            $value = str_replace('[', '-', $value);
        }

        return $value;
    }
}
