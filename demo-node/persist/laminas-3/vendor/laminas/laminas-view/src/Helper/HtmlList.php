<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\Escaper\Escaper;
use Laminas\View\Exception;
use Laminas\View\HtmlAttributesSet;

use function is_array;
use function sprintf;
use function strlen;
use function substr;

use const PHP_EOL;

/**
 * Helper for ordered and unordered lists
 *
 * @psalm-import-type AttributeSet from HtmlAttributesSet
 * @final
 */
class HtmlList extends AbstractHtmlElement
{
    use DeprecatedAbstractHelperHierarchyTrait;

    private Escaper $escaper;

    /**
     * @deprecated since 2.20.x - There is no reason for this helper to extend AbstractHtmlElement.
     *             The inheritance tree will be removed in version 3.0 of this component
     *
     * @var string
     */
    protected $closingBracket = '';

    public function __construct(?Escaper $escaper = null)
    {
        $this->escaper = $escaper ?: new Escaper();
    }

    /**
     * Generates a 'List' element.
     *
     * @param  array<array-key, scalar|array> $items Array with the elements of the list
     * @param  bool                           $ordered Specifies ordered/unordered list; default unordered
     * @param  AttributeSet|null              $attribs Attributes for the ol/ul tag.
     * @param  bool                           $escape Whether to Escape the items.
     * @throws Exception\InvalidArgumentException If $items is empty.
     * @return string The list XHTML.
     */
    public function __invoke(array $items, $ordered = false, $attribs = null, $escape = true)
    {
        if (empty($items)) {
            throw new Exception\InvalidArgumentException(sprintf(
                '$items array can not be empty in %s',
                __METHOD__
            ));
        }

        $list = '';

        foreach ($items as $item) {
            if (! is_array($item)) {
                $markup = $escape
                    ? $this->escaper->escapeHtml((string) $item)
                    : (string) $item;
                $list  .= '<li>' . $markup . '</li>' . PHP_EOL;
            } else {
                /** @psalm-var list<scalar|list<scalar>> $item */
                $itemLength = strlen('</li>' . PHP_EOL);
                if ($itemLength < strlen($list)) {
                    $list = substr($list, 0, strlen($list) - $itemLength)
                     . $this->__invoke($item, $ordered, $attribs, $escape) . '</li>' . PHP_EOL;
                } else {
                    $list .= '<li>' . $this->__invoke($item, $ordered, $attribs, $escape) . '</li>' . PHP_EOL;
                }
            }
        }

        $attributes = is_array($attribs)
            ? (string) new HtmlAttributesSet($this->escaper, $attribs)
            : '';

        $tag = $ordered ? 'ol' : 'ul';

        return '<' . $tag . $attributes . '>' . PHP_EOL . $list . '</' . $tag . '>' . PHP_EOL;
    }
}
