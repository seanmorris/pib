<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Exception;
use Laminas\View\Helper\Placeholder\Container\AbstractContainer;
use Laminas\View\Helper\Placeholder\Container\AbstractStandalone;
use Laminas\View\Renderer\PhpRenderer;

use function array_key_exists;
use function array_shift;
use function assert;
use function count;
use function filter_var;
use function implode;
use function in_array;
use function is_object;
use function is_string;
use function ob_get_clean;
use function ob_start;
use function preg_match;
use function sprintf;
use function str_replace;
use function strtolower;
use function ucfirst;

use const FILTER_VALIDATE_BOOLEAN;
use const PHP_EOL;

/**
 * Helper for setting and retrieving script elements for HTML head section
 *
 * Allows the following method calls:
 *
 * @method HeadScript appendFile($src, $type = 'text/javascript', $attrs = [])
 * @method HeadScript offsetSetFile($index, $src, $type = 'text/javascript', $attrs = [])
 * @method HeadScript prependFile($src, $type = 'text/javascript', $attrs = [])
 * @method HeadScript setFile($src, $type = 'text/javascript', $attrs = [])
 * @method HeadScript appendScript($script, $type = 'text/javascript', $attrs = [])
 * @method HeadScript offsetSetScript($index, $src, $type = 'text/javascript', $attrs = [])
 * @method HeadScript prependScript($script, $type = 'text/javascript', $attrs = [])
 * @method HeadScript setScript($script, $type = 'text/javascript', $attrs = [])
 * @psalm-type ObjectShape = object{
 *     type: string,
 *     attributes: array<string, mixed>,
 *     source: string|null,
 * }
 * @extends AbstractStandalone<int, ObjectShape>
 */
class HeadScript extends AbstractStandalone
{
    /**
     * Script type constants
     *
     * @const string
     */
    public const FILE   = 'FILE';
    public const SCRIPT = 'SCRIPT';

    /**
     * @internal
     */
    public const DEFAULT_SCRIPT_TYPE = 'text/javascript';

    /**
     * Are arbitrary attributes allowed?
     *
     * @var bool
     */
    protected $arbitraryAttributes = false;

    /**
     * Is capture lock?
     *
     * @var bool
     */
    protected $captureLock = false;

    /**
     * Capture type
     *
     * @var string|null
     */
    protected $captureScriptType;

    /**
     * Capture attributes
     *
     * @var null|array<string, mixed>
     */
    protected $captureScriptAttrs;

    /**
     * Capture type (append, prepend, set)
     *
     * @var string|null
     */
    protected $captureType;

    /**
     * Optional allowed attributes for script tag
     *
     * @var list<string>
     */
    protected $optionalAttributes = [
        'charset',
        'integrity',
        'crossorigin',
        'defer',
        'async',
        'language',
        'src',
        'id',
        'nonce',
        'nomodule',
        'referrerpolicy',
    ];

    /**
     * Script attributes that behave as booleans
     *
     * @var list<string>
     */
    private array $booleanAttributes = [
        'nomodule',
        'defer',
        'async',
    ];

    /**
     * Required attributes for script tag
     *
     * @deprecated This property is unused and will be removed in version 3.0 of this component
     *
     * @var list<string>
     */
    protected $requiredAttributes = ['type'];

    /**
     * Whether or not to format scripts using CDATA; used only if doctype
     * helper is not accessible
     *
     * @var bool
     */
    public $useCdata = false;

    public function __construct()
    {
        parent::__construct();

        $this->getContainer()->setSeparator(PHP_EOL);
    }

    /**
     * Return headScript object
     *
     * Returns headScript helper object; optionally, allows specifying a script
     * or script file to include.
     *
     * @param  string $mode      Script or file
     * @param  string $spec      Script/url
     * @param  string $placement Append, prepend, or set
     * @param  array<string, mixed> $attrs Array of script attributes
     * @param  string $type      Script type and/or array of script attributes
     * @return $this
     */
    public function __invoke(
        $mode = self::FILE,
        $spec = null,
        $placement = 'APPEND',
        array $attrs = [],
        $type = self::DEFAULT_SCRIPT_TYPE
    ) {
        if ((null !== $spec) && is_string($spec)) {
            $action    = ucfirst(strtolower($mode));
            $placement = strtolower($placement);
            switch ($placement) {
                case 'set':
                case 'prepend':
                case 'append':
                    $action = $placement . $action;
                    break;
                default:
                    $action = 'append' . $action;
                    break;
            }
            $this->$action($spec, $type, $attrs);
        }

        return $this;
    }

    /**
     * Overload method access
     *
     * @param  string $method Method to call
     * @param  array  $args   Arguments of method
     * @throws Exception\BadMethodCallException If too few arguments or invalid method.
     * @return $this
     */
    public function __call($method, $args)
    {
        if (preg_match('/^(?P<action>set|(ap|pre)pend|offsetSet)(?P<mode>File|Script)$/', $method, $matches)) {
            if (1 > count($args)) {
                throw new Exception\BadMethodCallException(sprintf(
                    'Method "%s" requires at least one argument',
                    $method
                ));
            }

            $action = $matches['action'];
            $mode   = strtolower($matches['mode']);
            $type   = self::DEFAULT_SCRIPT_TYPE;
            $index  = 0;
            $attrs  = [];

            if ('offsetSet' === $action) {
                $index = array_shift($args);
                if (1 > count($args)) {
                    throw new Exception\BadMethodCallException(sprintf(
                        'Method "%s" requires at least two arguments, an index and source',
                        $method
                    ));
                }
            }

            $content = $args[0];

            if (isset($args[1])) {
                $type = (string) $args[1];
            }
            if (isset($args[2])) {
                $attrs = (array) $args[2];
            }

            switch ($mode) {
                case 'script':
                    $item = $this->createData($type, $attrs, $content);
                    if ('offsetSet' === $action) {
                        $this->offsetSet($index, $item);
                    } else {
                        $this->$action($item);
                    }
                    break;
                case 'file':
                default:
                    if (! $this->isDuplicate($content)) {
                        $attrs['src'] = $content;
                        $item         = $this->createData($type, $attrs);
                        if ('offsetSet' === $action) {
                            $this->offsetSet($index, $item);
                        } else {
                            $this->$action($item);
                        }
                    }
                    break;
            }

            return $this;
        }

        return parent::__call($method, $args);
    }

    /**
     * Retrieve string representation
     *
     * @param  string|int $indent Amount of whitespaces or string to use for indention
     * @return string
     */
    public function toString($indent = null)
    {
        $container = $this->getContainer();
        $indent    = null !== $indent
            ? $container->getWhitespace($indent)
            : $container->getIndent();

        if ($this->view instanceof PhpRenderer) {
            $doctype = $this->view->plugin('doctype');
            assert($doctype instanceof Doctype);

            $useCdata = $doctype->isXhtml();
        } else {
            $useCdata = $this->useCdata;
        }

        $escapeStart = $useCdata ? '//<![CDATA[' : '//<!--';
        $escapeEnd   = $useCdata ? '//]]>' : '//-->';

        $items = [];
        $container->ksort();
        foreach ($container as $item) {
            if (! $this->isValid($item)) {
                continue;
            }

            $items[] = $this->itemToString($item, $indent, $escapeStart, $escapeEnd);
        }

        return implode($container->getSeparator(), $items);
    }

    /**
     * Start capture action
     *
     * @param string $captureType Type of capture
     * @param string $type        Type of script
     * @param array<string, mixed> $attrs Attributes of capture
     * @throws Exception\RuntimeException
     * @return void
     */
    public function captureStart(
        $captureType = AbstractContainer::APPEND,
        $type = self::DEFAULT_SCRIPT_TYPE,
        $attrs = []
    ) {
        if ($this->captureLock) {
            throw new Exception\RuntimeException('Cannot nest headScript captures');
        }

        $this->captureLock        = true;
        $this->captureType        = $captureType;
        $this->captureScriptType  = $type;
        $this->captureScriptAttrs = $attrs;
        ob_start();
    }

    /**
     * End capture action and store
     *
     * @return void
     */
    public function captureEnd()
    {
        $content                  = ob_get_clean();
        $type                     = $this->captureScriptType;
        $attrs                    = $this->captureScriptAttrs;
        $this->captureScriptType  = null;
        $this->captureScriptAttrs = null;
        $this->captureLock        = false;

        switch ($this->captureType) {
            case AbstractContainer::SET:
            case AbstractContainer::PREPEND:
            case AbstractContainer::APPEND:
                $action = strtolower($this->captureType) . 'Script';
                break;
            default:
                $action = 'appendScript';
                break;
        }

        $this->$action($content, $type, $attrs);
    }

    /**
     * Create data item containing all necessary components of script
     *
     * @internal This method will become private in version 3.0
     *
     * @param  string $type       Type of data
     * @param  array<string, mixed> $attributes Attributes of data
     * @param  string $content    Content of data
     * @return ObjectShape
     */
    public function createData($type, array $attributes, $content = null)
    {
        return (object) [
            'type'       => $type,
            'attributes' => $attributes,
            'source'     => $content,
        ];
    }

    /**
     * Is the file specified a duplicate?
     *
     * @param  string $file Name of file to check
     * @return bool
     */
    protected function isDuplicate($file)
    {
        foreach ($this->getContainer() as $item) {
            if (
                ($item->source === null)
                && array_key_exists('src', $item->attributes)
                && ($file === $item->attributes['src'])
            ) {
                return true;
            }
        }

        return false;
    }

    /**
     * Is the script provided valid?
     *
     * @internal This method will become private in version 3.0
     *
     * @param mixed $value Is the given script valid?
     * @return bool
     */
    protected function isValid($value)
    {
        if (
            ! is_object($value)
            || ! isset($value->type)
            || (! isset($value->source)
                && ! isset($value->attributes))
        ) {
            return false;
        }

        return true;
    }

    /**
     * Create script HTML
     *
     * @internal This method will become private in version 3.0
     *
     * @param ObjectShape $item Item to convert
     * @param string $indent String to add before the item
     * @param string $escapeStart Starting sequence
     * @param string $escapeEnd Ending sequence
     * @return string
     */
    public function itemToString($item, $indent, $escapeStart, $escapeEnd)
    {
        $attrString = '';
        if (! empty($item->attributes)) {
            foreach ($item->attributes as $key => $value) {
                if (
                    (! $this->arbitraryAttributesAllowed() && ! in_array($key, $this->optionalAttributes))
                    || in_array($key, ['conditional', 'noescape'])
                ) {
                    continue;
                }
                if (in_array(strtolower($key), $this->booleanAttributes, true)) {
                    $value = strtolower($key);
                }
                $attrString .= sprintf(
                    ' %s="%s"',
                    $key,
                    $this->autoEscape ? $this->escapeAttribute($value) : $value
                );
            }
        }

        $addScriptEscape = ! (isset($item->attributes['noescape'])
            && filter_var($item->attributes['noescape'], FILTER_VALIDATE_BOOLEAN));

        if (
            (empty($item->type) || strtolower($item->type) === self::DEFAULT_SCRIPT_TYPE)
            && $this->view
            && $this->view->plugin('doctype')->isHtml5()
        ) {
            $html = '<script ' . $attrString . '>';
        } else {
            $type = $this->autoEscape ? $this->escapeAttribute($item->type) : $item->type;
            $html = '<script type="' . $type . '"' . $attrString . '>';
        }
        if (is_string($item->source) && $item->source !== '') {
            $html .= PHP_EOL;

            if ($addScriptEscape) {
                $html .= $indent . '    ' . $escapeStart . PHP_EOL;
            }

            $html .= $indent . '    ' . $item->source;

            if ($addScriptEscape) {
                $html .= PHP_EOL . $indent . '    ' . $escapeEnd;
            }

            $html .= PHP_EOL . $indent;
        }
        $html .= '</script>';

        if (
            isset($item->attributes['conditional'])
            && ! empty($item->attributes['conditional'])
            && is_string($item->attributes['conditional'])
        ) {
            // inner wrap with comment end and start if !IE
            if (str_replace(' ', '', $item->attributes['conditional']) === '!IE') {
                $html = '<!-->' . $html . '<!--';
            }
            $html = $indent . '<!--[if ' . $item->attributes['conditional'] . ']>' . $html . '<![endif]-->';
        } else {
            $html = $indent . $html;
        }

        return $html;
    }

    /**
     * Override append
     *
     * @param ObjectShape $value Append script or file
     * @throws Exception\InvalidArgumentException
     * @return AbstractContainer
     */
    public function append($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'Invalid argument passed to append(); '
                . 'please use one of the helper methods, appendScript() or appendFile()'
            );
        }

        return $this->getContainer()->append($value);
    }

    /**
     * Override prepend
     *
     * @param ObjectShape $value Prepend script or file
     * @throws Exception\InvalidArgumentException
     * @return AbstractContainer
     */
    public function prepend($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'Invalid argument passed to prepend(); '
                . 'please use one of the helper methods, prependScript() or prependFile()'
            );
        }

        return $this->getContainer()->prepend($value);
    }

    /**
     * Override set
     *
     * @param ObjectShape $value Set script or file
     * @throws Exception\InvalidArgumentException
     * @return void
     */
    public function set($value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'Invalid argument passed to set(); please use one of the helper methods, setScript() or setFile()'
            );
        }

        $this->getContainer()->set($value);
    }

    /**
     * Override offsetSet
     *
     * @param int $offset Set script of file offset
     * @param ObjectShape $value
     * @return void
     * @throws Exception\InvalidArgumentException
     */
    public function offsetSet($offset, $value)
    {
        if (! $this->isValid($value)) {
            throw new Exception\InvalidArgumentException(
                'Invalid argument passed to offsetSet(); '
                . 'please use one of the helper methods, offsetSetScript() or offsetSetFile()'
            );
        }

        $this->getContainer()->offsetSet($offset, $value);
    }

    /**
     * Set flag indicating if arbitrary attributes are allowed
     *
     * @param  bool $flag Set flag
     * @return $this
     */
    public function setAllowArbitraryAttributes($flag)
    {
        $this->arbitraryAttributes = (bool) $flag;
        return $this;
    }

    /**
     * Are arbitrary attributes allowed?
     *
     * @return bool
     */
    public function arbitraryAttributesAllowed()
    {
        return $this->arbitraryAttributes;
    }
}
