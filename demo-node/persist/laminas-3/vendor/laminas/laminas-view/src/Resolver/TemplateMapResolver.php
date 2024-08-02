<?php

declare(strict_types=1);

namespace Laminas\View\Resolver;

use ArrayIterator;
use IteratorAggregate;
use Laminas\Stdlib\ArrayUtils;
use Laminas\View\Exception;
use Laminas\View\Renderer\RendererInterface as Renderer;
use ReturnTypeWillChange;
use Traversable;

use function array_key_exists;
use function array_replace_recursive;
use function get_debug_type;
use function is_iterable;
use function is_string;
use function sprintf;
use function trigger_error;

use const E_USER_DEPRECATED;

/**
 * @implements IteratorAggregate<string, string>
 * @final
 */
class TemplateMapResolver implements IteratorAggregate, ResolverInterface
{
    /** @var array<string, string> */
    protected $map = [];

    /**
     * Constructor
     *
     * Instantiate and optionally populate template map.
     *
     * @param iterable<string, string> $map
     */
    public function __construct($map = [])
    {
        $this->setMap($map);
    }

    /**
     * IteratorAggregate: return internal iterator
     *
     * @return Traversable<string, string>
     */
    #[ReturnTypeWillChange]
    public function getIterator()
    {
        return new ArrayIterator($this->map);
    }

    /**
     * Set (overwrite) template map
     *
     * Maps should be arrays or Traversable objects with name => path pairs
     *
     * @param iterable<string, string> $map
     * @throws Exception\InvalidArgumentException
     * @return $this
     */
    public function setMap($map)
    {
        if (! is_iterable($map)) {
            throw new Exception\InvalidArgumentException(sprintf(
                '%s: expects an array or Traversable, received "%s"',
                __METHOD__,
                get_debug_type($map),
            ));
        }

        if ($map instanceof Traversable) {
            $map = ArrayUtils::iteratorToArray($map);
        }

        $this->map = $map;
        return $this;
    }

    /**
     * Add an entry to the map
     *
     * @param string|iterable<string, string> $nameOrMap
     * @param null|string $path
     * @throws Exception\InvalidArgumentException
     * @return $this
     */
    public function add($nameOrMap, $path = null)
    {
        if (is_string($nameOrMap) && ($path === null || $path === '')) {
            trigger_error(
                'Using add() to remove individual templates is deprecated and will be removed in version 3.0',
                E_USER_DEPRECATED,
            );
            unset($this->map[$nameOrMap]);

            return $this;
        }

        $map = is_string($nameOrMap) && is_string($path)
            ? [$nameOrMap => $path]
            : $nameOrMap;

        if (! is_iterable($map)) {
            throw new Exception\InvalidArgumentException(sprintf(
                '%s: expects a string, array, or Traversable for the first argument; received "%s"',
                __METHOD__,
                get_debug_type($map),
            ));
        }

        $this->merge($map);

        return $this;
    }

    /**
     * Merge internal map with provided map
     *
     * @param  iterable<string, string> $map
     * @throws Exception\InvalidArgumentException
     * @return $this
     */
    public function merge($map)
    {
        if (! is_iterable($map)) {
            throw new Exception\InvalidArgumentException(sprintf(
                '%s: expects an array or Traversable, received "%s"',
                __METHOD__,
                get_debug_type($map),
            ));
        }

        if ($map instanceof Traversable) {
            $map = ArrayUtils::iteratorToArray($map);
        }

        $this->map = array_replace_recursive($this->map, $map);
        return $this;
    }

    /**
     * Does the resolver contain an entry for the given name?
     *
     * @param  string $name
     * @return bool
     */
    public function has($name)
    {
        return array_key_exists($name, $this->map);
    }

    /**
     * Retrieve a template path by name
     *
     * @param  string $name
     * @return false|string
     * @throws Exception\DomainException If no entry exists.
     */
    public function get($name)
    {
        if (! $this->has($name)) {
            // @TODO This should be exceptional
            return false;
        }

        return $this->map[$name];
    }

    /**
     * Retrieve the template map
     *
     * @return array<string, string>
     */
    public function getMap()
    {
        return $this->map;
    }

    /**
     * Resolve a template/pattern name to a resource the renderer can consume
     *
     * @param string $name
     * @return false|string
     */
    public function resolve($name, ?Renderer $renderer = null)
    {
        return $this->get($name);
    }
}
