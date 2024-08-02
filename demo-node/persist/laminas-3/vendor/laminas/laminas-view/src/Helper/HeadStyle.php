<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View;
use Laminas\View\Exception;
use Laminas\View\Helper\Placeholder\Container\AbstractContainer;
use Laminas\View\Helper\Placeholder\Container\AbstractStandalone;
use stdClass;

use function array_filter;
use function array_shift;
use function count;
use function implode;
use function in_array;
use function is_array;
use function is_string;
use function method_exists;
use function ob_get_clean;
use function ob_start;
use function preg_match;
use function preg_replace;
use function sprintf;
use function str_replace;
use function strtoupper;

use const ARRAY_FILTER_USE_KEY;
use const PHP_EOL;

/**
 * Helper for adding inline CSS to the head in style tags
 *
 * @psalm-type ObjectShape = object{
 *     attributes: array<string, mixed>,
 *     content: string,
 * }
 * @extends AbstractStandalone<int, ObjectShape>
 *
 * Allows the following method calls:
 * @method HeadStyle appendStyle(string $content, array $attributes = [])
 * @method HeadStyle offsetSetStyle(int $index, string $content, array $attributes = [])
 * @method HeadStyle prependStyle(string $content, array $attributes = [])
 * @method HeadStyle setStyle(string $content, array $attributes = [])
 * @method HeadStyle setIndent(int|string $indent)
 * @final
 */
class HeadStyle extends AbstractStandalone
{
    /**
     * Allowed optional attributes
     *
     * @var list<string>
     */
    protected $optionalAttributes = ['lang', 'title', 'media', 'dir', 'nonce'];

    /**
     * Allowed media types
     *
     * @deprecated This property is no longer used and will be removed in version 3.0
     *             Because the media attribute can contain any type of media query, artificially limiting its values
     *             is counter-productive.
     *
     * @var list<string>
     */
    protected $mediaTypes = [
        'all',
        'aural',
        'braille',
        'handheld',
        'print',
        'projection',
        'screen',
        'tty',
        'tv',
    ];

    /**
     * Capture type and/or attributes (used for hinting during capture)
     *
     * @var array<string, mixed>|null
     */
    protected $captureAttrs;

    /**
     * Capture lock
     *
     * @var bool
     */
    protected $captureLock = false;

    /**
     * Capture type (append, prepend, set)
     *
     * @var string|null
     */
    protected $captureType;

    public function __construct()
    {
        parent::__construct();

        $this->getContainer()->setSeparator(PHP_EOL);
    }

    /**
     * Return headStyle object
     *
     * Returns headStyle helper object; optionally, allows specifying
     *
     * @param  string       $content    Stylesheet contents
     * @param  string       $placement  Append, prepend, or set
     * @param  string|array $attributes Optional attributes to utilize
     * @return HeadStyle
     */
    public function __invoke($content = null, $placement = AbstractContainer::APPEND, $attributes = [])
    {
        if ((null !== $content) && is_string($content)) {
            switch (strtoupper($placement)) {
                case AbstractContainer::SET:
                    $action = 'setStyle';
                    break;
                case AbstractContainer::PREPEND:
                    $action = 'prependStyle';
                    break;
                case AbstractContainer::APPEND:
                default:
                    $action = 'appendStyle';
                    break;
            }
            $this->$action($content, $attributes);
        }

        return $this;
    }

    /**
     * Overload method calls
     *
     * @param  string $method
     * @param  array  $args
     * @throws Exception\BadMethodCallException When no $content provided or invalid method.
     * @return mixed
     */
    public function __call($method, $args)
    {
        if (preg_match('/^(?P<action>set|(ap|pre)pend|offsetSet)(Style)$/', $method, $matches)) {
            $index  = null;
            $argc   = count($args);
            $action = $matches['action'];

            if ('offsetSet' === $action) {
                if (0 < $argc) {
                    $index = array_shift($args);
                    --$argc;
                }
            }

            if (1 > $argc) {
                throw new Exception\BadMethodCallException(sprintf(
                    'Method "%s" requires minimally content for the stylesheet',
                    $method,
                ));
            }

            $content = $args[0];
            $attrs   = [];
            if (isset($args[1])) {
                $attrs = (array) $args[1];
            }

            $item = $this->createData($content, $attrs);

            if ('offsetSet' === $action) {
                $this->offsetSet($index, $item);
            } else {
                $this->$action($item);
            }

            return $this;
        }

        return parent::__call($method, $args);
    }

    /**
     * Create string representation of placeholder
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
            if (! $this->isValid($item)) {
                continue;
            }
            $items[] = $this->itemToString($item, $indent);
        }

        $return = implode($container->getSeparator(), $items);

        return $indent . preg_replace("/(\r\n?|\n)/", '$1' . $indent, $return);
    }

    /**
     * Start capture action
     *
     * @param  string $type
     * @param  array<string, mixed>|null $attrs optional style tag attributes
     * @throws Exception\RuntimeException
     * @return void
     */
    public function captureStart($type = AbstractContainer::APPEND, $attrs = null)
    {
        if ($this->captureLock) {
            throw new Exception\RuntimeException('Cannot nest headStyle captures');
        }

        $this->captureLock  = true;
        $this->captureAttrs = $attrs;
        $this->captureType  = $type;
        ob_start();
    }

    /**
     * End capture action and store
     *
     * @return void
     */
    public function captureEnd()
    {
        $content            = ob_get_clean();
        $attrs              = $this->captureAttrs ?? [];
        $this->captureAttrs = null;
        $this->captureLock  = false;

        switch ($this->captureType) {
            case AbstractContainer::SET:
                $this->setStyle($content, $attrs);
                break;
            case AbstractContainer::PREPEND:
                $this->prependStyle($content, $attrs);
                break;
            case AbstractContainer::APPEND:
            default:
                $this->appendStyle($content, $attrs);
                break;
        }
    }

    /**
     * Create data item for use in stack
     *
     * @internal This method is internal and will be made private in version 3.0
     *
     * @param  string $content
     * @param  array<string, mixed> $attributes
     * @return ObjectShape
     */
    public function createData($content, array $attributes)
    {
        if (! isset($attributes['media'])) {
            $attributes['media'] = 'screen';
        }

        return (object) [
            'content'    => $content,
            'attributes' => $attributes,
        ];
    }

    /**
     * Determine if a value is a valid style tag
     *
     * @internal This method is internal and will be made private in version 3.0
     *
     * @return bool
     */
    protected function isValid(mixed $value)
    {
        if (! $value instanceof stdClass || ! isset($value->content) || ! isset($value->attributes)) {
            return false;
        }

        return true;
    }

    private function viewEncoding(): string
    {
        $encoding = null;
        if ($this->view !== null && method_exists($this->view, 'getEncoding')) {
            /** @var mixed $encoding */
            $encoding = $this->view->getEncoding();
        }

        return is_string($encoding) ? $encoding : 'UTF-8';
    }

    /**
     * @param array<array-key, mixed> $value
     * @psalm-assert array<array-key, string> $value
     */
    private static function assertAllString(array $value, string $message): void
    {
        /** @var mixed $item */
        foreach ($value as $item) {
            if (is_string($item)) {
                continue;
            }

            throw new Exception\InvalidArgumentException($message);
        }
    }

    /**
     * @param array<array-key, mixed> $attributes
     * @psalm-return array{media: non-empty-string, ...}|array<array-key, mixed>
     */
    private function normalizeMediaAttribute(array $attributes): array
    {
        if (! isset($attributes['media']) || $attributes['media'] === '' || $attributes['media'] === []) {
            unset($attributes['media']);

            return $attributes;
        }

        if (is_array($attributes['media'])) {
            self::assertAllString(
                $attributes['media'],
                'When the media attribute is an array, the array can only contain string values',
            );

            $attributes['media'] = implode(', ', $attributes['media']);

            return $attributes;
        }

        return $attributes;
    }

    private function styleTagAttributesString(object $item): string
    {
        $escaper    = $this->getEscaper($this->viewEncoding());
        $attributes = isset($item->attributes) && is_array($item->attributes) ? $item->attributes : [];
        $attributes = $this->normalizeMediaAttribute($attributes);
        $attributes = array_filter(
            $attributes,
            fn (int|string $key) => in_array($key, $this->optionalAttributes, true),
            ARRAY_FILTER_USE_KEY,
        );

        return (new View\HtmlAttributesSet($escaper, $attributes))->__toString();
    }

    /**
     * Convert content and attributes into valid style tag
     *
     * @internal This method is internal and will be made private in version 3.0
     *
     * @param ObjectShape $item Item to render
     * @param string $indent Indentation to use
     * @return string
     */
    public function itemToString(stdClass $item, $indent)
    {
        if (! isset($item->content) || ! is_string($item->content) || $item->content === '') {
            return '';
        }

        $attrString = $this->styleTagAttributesString($item);

        $html = '<style type="text/css"' . $attrString . '>'
            . PHP_EOL
            . $item->content
            . PHP_EOL
            . '</style>';

        if (
            isset($item->attributes['conditional'])
            && ! empty($item->attributes['conditional'])
            && is_string($item->attributes['conditional'])
        ) {
            // inner wrap with comment end and start if !IE
            if (str_replace(' ', '', $item->attributes['conditional']) === '!IE') {
                $html = '<!-->' . $html . '<!--';
            }
            $html = '<!--[if ' . $item->attributes['conditional'] . ']>' . $html . '<![endif]-->';
        }

        return $html;
    }

    /**
     * Override append to enforce style creation
     *
     * @param ObjectShape $value
     * @throws Exception\InvalidArgumentException
     * @return AbstractContainer
     */
    public function append($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'Invalid value passed to append; please use appendStyle()',
            );
        }

        return $this->getContainer()->append($value);
    }

    /**
     * Override offsetSet to enforce style creation
     *
     * @param int $offset
     * @param ObjectShape $value
     * @return void
     * @throws Exception\InvalidArgumentException
     */
    public function offsetSet($offset, $value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'Invalid value passed to offsetSet; please use offsetSetStyle()',
            );
        }

        $this->getContainer()->offsetSet($offset, $value);
    }

    /**
     * Override prepend to enforce style creation
     *
     * @param ObjectShape $value
     * @throws Exception\InvalidArgumentException
     * @return AbstractContainer
     */
    public function prepend($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'Invalid value passed to prepend; please use prependStyle()',
            );
        }

        return $this->getContainer()->prepend($value);
    }

    /**
     * Override set to enforce style creation
     *
     * @param ObjectShape $value
     * @throws Exception\InvalidArgumentException
     * @return void
     */
    public function set($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException('Invalid value passed to set; please use setStyle()');
        }

        $this->getContainer()->set($value);
    }
}
