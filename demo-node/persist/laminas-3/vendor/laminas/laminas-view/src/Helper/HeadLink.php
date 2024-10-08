<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Exception;
use Laminas\View\Helper\Placeholder\Container\AbstractContainer;
use Laminas\View\Helper\Placeholder\Container\AbstractStandalone;
use stdClass;

use function array_intersect;
use function array_keys;
use function array_shift;
use function count;
use function get_object_vars;
use function implode;
use function is_array;
use function is_object;
use function is_string;
use function method_exists;
use function preg_match;
use function sprintf;
use function str_replace;

use const PHP_EOL;

/**
 * @extends AbstractStandalone<int, object>
 *
 * Creates the following virtual methods:
 * @method HeadLink appendStylesheet($href, $media = 'screen', $conditionalStylesheet = '', $extras = [])
 * @method HeadLink offsetSetStylesheet($index, $href, $media = 'screen', $conditionalStylesheet = '', $extras = [])
 * @method HeadLink prependStylesheet($href, $media = 'screen', $conditionalStylesheet = '', $extras = [])
 * @method HeadLink setStylesheet($href, $media = 'screen', $conditionalStylesheet = '', $extras = [])
 * @method HeadLink appendAlternate($href, $type, $title, $extras = [])
 * @method HeadLink offsetSetAlternate($index, $href, $type, $title, $extras = [])
 * @method HeadLink prependAlternate($href, $type, $title, $extras = [])
 * @method HeadLink setAlternate($href, $type, $title, $extras = [])
 * @final
 */
class HeadLink extends AbstractStandalone
{
    /**
     * Allowed attributes
     *
     * @var string[]
     */
    protected $itemKeys = [
        'charset',
        'href',
        'hreflang',
        'id',
        'media',
        'rel',
        'rev',
        'sizes',
        'type',
        'title',
        'extras',
        'itemprop',
        'crossorigin',
        'integrity',
        'as',
    ];

    /**
     * Constructor
     *
     * Use PHP_EOL as separator
     */
    public function __construct()
    {
        parent::__construct();

        $this->setSeparator(PHP_EOL);
    }

    /**
     * Proxy to __invoke()
     *
     * Allows calling $helper->headLink(), but, more importantly, chaining calls
     * like ->appendStylesheet()->headLink().
     *
     * @param  array<string, mixed>|null $attributes
     * @param  string     $placement
     * @return HeadLink
     */
    public function headLink(?array $attributes = null, $placement = AbstractContainer::APPEND)
    {
        return $this->__invoke($attributes, $placement);
    }

    /**
     * headLink() - View Helper Method
     *
     * Returns current object instance. Optionally, allows passing array of
     * values to build link.
     *
     * @param array<string, mixed>|null $attributes
     * @param string $placement
     * @return $this
     */
    public function __invoke(?array $attributes = null, $placement = AbstractContainer::APPEND)
    {
        if (null !== $attributes) {
            $item = $this->createData($attributes);
            switch ($placement) {
                case AbstractContainer::SET:
                    $this->set($item);
                    break;
                case AbstractContainer::PREPEND:
                    $this->prepend($item);
                    break;
                case AbstractContainer::APPEND:
                default:
                    $this->append($item);
                    break;
            }
        }

        return $this;
    }

    /**
     * Overload method access
     *
     * Items that may be added in the future:
     * - Navigation?  need to find docs on this
     *   - public function appendStart()
     *   - public function appendContents()
     *   - public function appendPrev()
     *   - public function appendNext()
     *   - public function appendIndex()
     *   - public function appendEnd()
     *   - public function appendGlossary()
     *   - public function appendAppendix()
     *   - public function appendHelp()
     *   - public function appendBookmark()
     * - Other?
     *   - public function appendCopyright()
     *   - public function appendChapter()
     *   - public function appendSection()
     *   - public function appendSubsection()
     *
     * @param  string $method
     * @param  mixed $args
     * @throws Exception\BadMethodCallException
     * @return $this|mixed
     */
    public function __call($method, $args)
    {
        if (
            preg_match(
                '/^(?P<action>set|(ap|pre)pend|offsetSet)(?P<type>Stylesheet|Alternate|Prev|Next)$/',
                $method,
                $matches
            )
        ) {
            $argc   = count($args);
            $action = $matches['action'];
            $type   = $matches['type'];
            $index  = null;

            if ('offsetSet' === $action) {
                if (0 < $argc) {
                    $index = array_shift($args);
                    --$argc;
                }
            }

            if (1 > $argc) {
                throw new Exception\BadMethodCallException(
                    sprintf('%s requires at least one argument', $method)
                );
            }

            if (is_array($args[0])) {
                $item = $this->createData($args[0]);
            } else {
                $dataMethod = 'createData' . $type;
                $item       = $this->$dataMethod($args);
            }

            if (is_object($item)) {
                if ('offsetSet' === $action) {
                    $this->offsetSet($index, $item);
                } else {
                    $this->$action($item);
                }
            }

            return $this;
        }

        return parent::__call($method, $args);
    }

    /**
     * Check if value is valid
     *
     * @internal This method will become private in version 3.0
     *
     * @param mixed $value
     * @return bool
     */
    protected function isValid($value)
    {
        if (! is_object($value)) {
            return false;
        }

        $vars         = get_object_vars($value);
        $keys         = array_keys($vars);
        $intersection = array_intersect($this->itemKeys, $keys);
        if (empty($intersection)) {
            return false;
        }

        return true;
    }

    /**
     * append()
     *
     * @param object $value
     * @throws Exception\InvalidArgumentException
     * @return AbstractContainer
     */
    public function append($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'append() expects a data token; please use one of the custom append*() methods'
            );
        }

        return $this->getContainer()->append($value);
    }

    /**
     * offsetSet()
     *
     * @param int $offset
     * @param object $value
     * @return void
     * @throws Exception\InvalidArgumentException
     */
    public function offsetSet($offset, $value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'offsetSet() expects a data token; please use one of the custom offsetSet*() methods'
            );
        }

        $this->getContainer()->offsetSet($offset, $value);
    }

    /**
     * prepend()
     *
     * @param object $value
     * @throws Exception\InvalidArgumentException
     * @return AbstractContainer
     */
    public function prepend($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'prepend() expects a data token; please use one of the custom prepend*() methods'
            );
        }

        return $this->getContainer()->prepend($value);
    }

    /**
     * set()
     *
     * @param object $value
     * @throws Exception\InvalidArgumentException
     * @return $this
     */
    public function set($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'set() expects a data token; please use one of the custom set*() methods'
            );
        }

        $this->getContainer()->set($value);

        return $this;
    }

    /**
     * Create HTML link element from data item
     *
     * @internal This method will become private in version 3.0
     *
     * @return string
     */
    public function itemToString(stdClass $item)
    {
        $attributes = (array) $item;
        $link       = '<link';

        foreach ($this->itemKeys as $itemKey) {
            if (isset($attributes[$itemKey])) {
                if (is_array($attributes[$itemKey])) {
                    foreach ($attributes[$itemKey] as $key => $value) {
                        $link .= sprintf(
                            ' %s="%s"',
                            $key,
                            $this->autoEscape ? $this->escapeAttribute($value) : $value
                        );
                    }
                } else {
                    $link .= sprintf(
                        ' %s="%s"',
                        $itemKey,
                        $this->autoEscape ? $this->escapeAttribute($attributes[$itemKey]) : $attributes[$itemKey]
                    );
                }
            }
        }

        if (method_exists($this->view, 'plugin')) {
            $link .= $this->view->plugin('doctype')->isXhtml() ? ' />' : '>';
        } else {
            $link .= ' />';
        }

        if (($link === '<link />') || ($link === '<link>')) {
            return '';
        }

        if (
            isset($attributes['conditionalStylesheet'])
            && ! empty($attributes['conditionalStylesheet'])
            && is_string($attributes['conditionalStylesheet'])
        ) {
            // inner wrap with comment end and start if !IE
            if (str_replace(' ', '', $attributes['conditionalStylesheet']) === '!IE') {
                $link = '<!-->' . $link . '<!--';
            }
            $link = '<!--[if ' . $attributes['conditionalStylesheet'] . ']>' . $link . '<![endif]-->';
        }

        return $link;
    }

    /**
     * Render link elements as string
     *
     * @param  string|int $indent
     * @return string
     */
    public function toString($indent = null)
    {
        $container = $this->getContainer();
        $indent    = null !== $indent
                ? $container->getWhitespace($indent)
                : $container->getIndent();

        $items = [];
        $container->ksort();
        foreach ($container as $item) {
            $items[] = $this->itemToString($item);
        }

        return $indent . implode($this->escape($container->getSeparator()) . $indent, $items);
    }

    /**
     * Create data item for stack
     *
     * @internal This method will become private in version 3.0
     *
     * @param array<string, mixed> $attributes
     * @return object
     */
    public function createData(array $attributes)
    {
        return (object) $attributes;
    }

    /**
     * Create item for stylesheet link item
     *
     * @deprecated This method is unused and will be removed in version 3.0 of this component
     *
     * @param  array $args
     * @return object|false Returns false if stylesheet is a duplicate
     */
    public function createDataStylesheet(array $args)
    {
        $rel                   = 'stylesheet';
        $type                  = 'text/css';
        $media                 = 'screen';
        $conditionalStylesheet = false;
        $href                  = array_shift($args);

        if ($this->isDuplicateStylesheet($href)) {
            return false;
        }

        if ($args) {
            $media = array_shift($args);
            if (is_array($media)) {
                $media = implode(',', $media);
            } else {
                $media = (string) $media;
            }
        }
        if ($args) {
            $conditionalStylesheet = array_shift($args);
            if (! empty($conditionalStylesheet) && is_string($conditionalStylesheet)) {
                $conditionalStylesheet = (string) $conditionalStylesheet;
            } else {
                $conditionalStylesheet = null;
            }
        }

        if ($args && is_array($args[0])) {
            $extras = array_shift($args);
            $extras = (array) $extras;
        } else {
            $extras = [];
        }

        return $this->createData([
            'rel'                   => $rel,
            'type'                  => $type,
            'href'                  => $href,
            'media'                 => $media,
            'conditionalStylesheet' => $conditionalStylesheet,
            'extras'                => $extras,
        ]);
    }

    /**
     * Is the linked stylesheet a duplicate?
     *
     * @internal This method will become private in version 3.0
     *
     * @param  string $uri
     * @return bool
     */
    protected function isDuplicateStylesheet($uri)
    {
        foreach ($this->getContainer() as $item) {
            if (($item->rel === 'stylesheet') && ($item->href === $uri)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Create item for alternate link item
     *
     * @deprecated This method is unused and will be removed in version 3.0 of this component
     *
     * @param  array $args
     * @throws Exception\InvalidArgumentException
     * @return object
     */
    public function createDataAlternate(array $args)
    {
        if (3 > count($args)) {
            throw new Exception\InvalidArgumentException(sprintf(
                'Alternate tags require 3 arguments; %s provided',
                count($args)
            ));
        }

        $rel   = 'alternate';
        $href  = array_shift($args);
        $type  = array_shift($args);
        $title = array_shift($args);

        if ($args && is_array($args[0])) {
            $extras = array_shift($args);
            $extras = (array) $extras;

            if (isset($extras['media']) && is_array($extras['media'])) {
                $extras['media'] = implode(',', $extras['media']);
            }
        } else {
            $extras = [];
        }

        return $this->createData([
            'rel'    => $rel,
            'href'   => (string) $href,
            'type'   => (string) $type,
            'title'  => (string) $title,
            'extras' => $extras,
        ]);
    }

    /**
     * Create item for a prev relationship (mainly used for pagination)
     *
     * @deprecated This method is unused and will be removed in version 3.0 of this component
     *
     * @param  array $args
     * @return object
     */
    public function createDataPrev(array $args)
    {
        return $this->createData([
            'rel'  => 'prev',
            'href' => (string) array_shift($args),
        ]);
    }

    /**
     * Create item for a prev relationship (mainly used for pagination)
     *
     * @deprecated This method is unused and will be removed in version 3.0 of this component
     *
     * @param  array $args
     * @return object
     */
    public function createDataNext(array $args)
    {
        return $this->createData([
            'rel'  => 'next',
            'href' => (string) array_shift($args),
        ]);
    }
}
