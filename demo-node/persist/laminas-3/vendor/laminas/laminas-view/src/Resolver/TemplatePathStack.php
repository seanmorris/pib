<?php

declare(strict_types=1);

namespace Laminas\View\Resolver;

use Laminas\Stdlib\ArrayUtils;
use Laminas\Stdlib\SplStack;
use Laminas\View\Exception;
use Laminas\View\Renderer\RendererInterface as Renderer;
use Laminas\View\Stream;
use SplFileInfo;
use Traversable;

use function array_change_key_case;
use function count;
use function file_exists;
use function get_debug_type;
use function gettype;
use function in_array;
use function ini_get;
use function is_array;
use function is_string;
use function ltrim;
use function pathinfo;
use function preg_match;
use function rtrim;
use function sprintf;
use function stream_get_wrappers;
use function stream_wrapper_register;
use function strpos;

use const DIRECTORY_SEPARATOR;
use const PATHINFO_EXTENSION;

/**
 * Resolves view scripts based on a stack of paths
 *
 * @psalm-type PathStack = SplStack<string>
 * @psalm-type Options = array{
 *     lfi_protection?: bool,
 *     script_paths?: list<string>,
 *     default_suffix?: string,
 *     use_stream_wrapper?: bool,
 * }
 * @final
 */
class TemplatePathStack implements ResolverInterface
{
    /** @deprecated */
    public const FAILURE_NO_PATHS = 'TemplatePathStack_Failure_No_Paths';
    /** @deprecated */
    public const FAILURE_NOT_FOUND = 'TemplatePathStack_Failure_Not_Found';

    /**
     * Default suffix to use
     *
     * Appends this suffix if the template requested does not use it.
     *
     * @var string
     */
    protected $defaultSuffix = 'phtml';

    /** @var PathStack */
    protected $paths;

    /**
     * Reason for last lookup failure
     *
     * @deprecated This property will be removed in v3.0 of this component.
     *
     * @var false|string
     */
    protected $lastLookupFailure = false;

    /**
     * Flag indicating whether or not LFI protection for rendering view scripts is enabled
     *
     * @var bool
     */
    protected $lfiProtectionOn = true;

    /**@+
     * Flags used to determine if a stream wrapper should be used for enabling short tags
     */

    /**
     * @deprecated Stream wrapper functionality will be removed in version 3.0 of this component
     *
     * @var bool
     */
    protected $useViewStream = false;
    /**
     * @deprecated Stream wrapper functionality will be removed in version 3.0 of this component
     *
     * @var bool
     */
    protected $useStreamWrapper = false;

    /**@-*/

    /** @param  null|Options|Traversable<string, mixed> $options */
    public function __construct($options = null)
    {
        $this->useViewStream = (bool) ini_get('short_open_tag');
        if ($this->useViewStream) {
            if (! in_array('laminas.view', stream_get_wrappers())) {
                /** @psalm-suppress DeprecatedClass */
                stream_wrapper_register('laminas.view', Stream::class);
            }
        }

        /** @psalm-var PathStack $paths */
        $paths       = new SplStack();
        $this->paths = $paths;
        if (null !== $options) {
            $this->setOptions($options);
        }
    }

    /**
     * Configure object
     *
     * @param  Options|Traversable<string, mixed> $options
     * @return void
     * @throws Exception\InvalidArgumentException
     */
    public function setOptions($options)
    {
        /** @psalm-suppress DocblockTypeContradiction */
        if (! is_array($options) && ! $options instanceof Traversable) {
            throw new Exception\InvalidArgumentException(sprintf(
                'Expected array or Traversable object; received "%s"',
                get_debug_type($options),
            ));
        }

        $options = $options instanceof Traversable ? ArrayUtils::iteratorToArray($options) : $options;
        $options = array_change_key_case($options);

        if (isset($options['lfi_protection'])) {
            $this->setLfiProtection($options['lfi_protection']);
        }

        if (isset($options['script_paths'])) {
            $this->addPaths($options['script_paths']);
        }

        if (isset($options['use_stream_wrapper'])) {
            $this->setUseStreamWrapper($options['use_stream_wrapper']);
        }

        if (isset($options['default_suffix'])) {
            $this->setDefaultSuffix($options['default_suffix']);
        }
    }

    /**
     * Set default file suffix
     *
     * @param  string $defaultSuffix
     * @return $this
     */
    public function setDefaultSuffix($defaultSuffix)
    {
        $this->defaultSuffix = (string) $defaultSuffix;
        $this->defaultSuffix = ltrim($this->defaultSuffix, '.');
        return $this;
    }

    /**
     * Get default file suffix
     *
     * @return string
     */
    public function getDefaultSuffix()
    {
        return $this->defaultSuffix;
    }

    /**
     * Add many paths to the stack at once
     *
     * @param  list<string> $paths
     * @return $this
     */
    public function addPaths(array $paths)
    {
        foreach ($paths as $path) {
            $this->addPath($path);
        }
        return $this;
    }

    /**
     * Reset the path stack to the paths provided
     *
     * @param  PathStack|list<string> $paths
     * @return TemplatePathStack
     * @throws Exception\InvalidArgumentException
     */
    public function setPaths($paths)
    {
        if ($paths instanceof SplStack) {
            $this->paths = $paths;

            return $this;
        }

        /** @psalm-suppress RedundantConditionGivenDocblockType */
        if (is_array($paths)) {
            $this->clearPaths();
            $this->addPaths($paths);

            return $this;
        }

        throw new Exception\InvalidArgumentException(
            "Invalid argument provided for \$paths, expecting either an array or SplStack object"
        );
    }

    /**
     * Normalize a path for insertion in the stack
     *
     * @param  string $path
     * @return string
     */
    public static function normalizePath($path)
    {
        $path  = rtrim($path, '/');
        $path  = rtrim($path, '\\');
        $path .= DIRECTORY_SEPARATOR;
        return $path;
    }

    /**
     * Add a single path to the stack
     *
     * @param  string $path
     * @return $this
     * @throws Exception\InvalidArgumentException
     */
    public function addPath($path)
    {
        if (! is_string($path)) {
            throw new Exception\InvalidArgumentException(sprintf(
                'Invalid path provided; must be a string, received %s',
                gettype($path)
            ));
        }
        $this->paths->push(static::normalizePath($path));
        return $this;
    }

    /**
     * Clear all paths
     *
     * @return void
     */
    public function clearPaths()
    {
        /** @psalm-var PathStack $paths */
        $paths       = new SplStack();
        $this->paths = $paths;
    }

    /**
     * Returns stack of paths
     *
     * @return PathStack
     */
    public function getPaths()
    {
        return $this->paths;
    }

    /**
     * Set LFI protection flag
     *
     * @param  bool $flag
     * @return TemplatePathStack
     */
    public function setLfiProtection($flag)
    {
        $this->lfiProtectionOn = (bool) $flag;
        return $this;
    }

    /**
     * Return status of LFI protection flag
     *
     * @return bool
     */
    public function isLfiProtectionOn()
    {
        return $this->lfiProtectionOn;
    }

    /**
     * Set flag indicating if stream wrapper should be used if short_open_tag is off
     *
     * @deprecated will be removed in version 3
     *
     * @param  bool $flag
     * @return TemplatePathStack
     */
    public function setUseStreamWrapper($flag)
    {
        $this->useStreamWrapper = (bool) $flag;
        return $this;
    }

    /**
     * Should the stream wrapper be used if short_open_tag is off?
     *
     * Returns true if the use_stream_wrapper flag is set, and if short_open_tag
     * is disabled.
     *
     * @deprecated will be removed in version 3
     *
     * @return bool
     */
    public function useStreamWrapper()
    {
        return $this->useViewStream && $this->useStreamWrapper;
    }

    /**
     * Retrieve the filesystem path to a view script
     *
     * @param  string $name
     * @return string
     * @throws Exception\DomainException
     */
    public function resolve($name, ?Renderer $renderer = null)
    {
        $this->lastLookupFailure = false;

        if ($this->isLfiProtectionOn() && preg_match('#\.\.[\\\/]#', $name)) {
            throw new Exception\DomainException(
                'Requested scripts may not include parent directory traversal ("../", "..\\" notation)'
            );
        }

        if (! count($this->paths)) {
            $this->lastLookupFailure = static::FAILURE_NO_PATHS;
            // @TODO In version 3, this should become an exception
            return false;
        }

        // Ensure we have the expected file extension
        $defaultSuffix = $this->getDefaultSuffix();
        if (pathinfo($name, PATHINFO_EXTENSION) === '') {
            $name .= '.' . $defaultSuffix;
        }

        foreach ($this->paths as $path) {
            $file = new SplFileInfo($path . $name);
            if ($file->isReadable()) {
                // Found! Return it.
                if (($filePath = $file->getRealPath()) === false && 0 === strpos($path, 'phar://')) {
                    // Do not try to expand phar paths (realpath + phars == fail)
                    $filePath = $path . $name;
                    if (! file_exists($filePath)) {
                        break;
                    }
                }
                /** @psalm-suppress DeprecatedMethod */
                if ($this->useStreamWrapper()) {
                    // If using a stream wrapper, prepend the spec to the path
                    $filePath = 'laminas.view://' . $filePath;
                }
                return $filePath;
            }
        }

        $this->lastLookupFailure = static::FAILURE_NOT_FOUND;
        // @TODO This should become an exception in v3.0
        return false;
    }

    /**
     * Get the last lookup failure message, if any
     *
     * @deprecated In version 3.0, this resolver will throw exceptions instead of
     *             incorrectly returning false from resolve()
     *
     * @return false|string
     */
    public function getLastLookupFailure()
    {
        return $this->lastLookupFailure;
    }
}
