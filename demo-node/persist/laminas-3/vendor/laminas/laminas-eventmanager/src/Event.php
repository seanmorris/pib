<?php

namespace Laminas\EventManager;

use ArrayAccess;

use function gettype;
use function is_array;
use function is_object;
use function sprintf;

/**
 * Representation of an event
 *
 * Encapsulates the target context and parameters passed, and provides some
 * behavior for interacting with the event manager.
 *
 * @template-covariant TTarget of object|string|null
 * @template-covariant TParams of array|ArrayAccess|object
 * @implements EventInterface<TTarget, TParams>
 */
class Event implements EventInterface
{
    /** @var string|null Event name */
    protected $name;

    /**
     * @var object|string|null The event target
     * @psalm-var TTarget
     */
    protected $target;

    /**
     * @var array|ArrayAccess|object The event parameters
     * @psalm-var TParams
     * @psalm-suppress InvalidPropertyAssignmentValue Empty array _can_ be assigned, but there is no "template type
     * default" functionality in Psalm (https://github.com/vimeo/psalm/issues/3048).
     */
    protected $params = [];

    /** @var bool Whether or not to stop propagation */
    protected $stopPropagation = false;

    /**
     * Constructor
     *
     * Accept a target and its parameters.
     *
     * @param string|null $name Event name
     * @param string|object|null $target
     * @psalm-param TTarget $target
     * @param array|ArrayAccess|object|null $params
     * @psalm-param TParams|array<empty,empty>|null $params
     */
    public function __construct($name = null, $target = null, $params = [])
    {
        if (null !== $name) {
            $this->setName($name);
        }

        if (null !== $target) {
            $this->setTarget($target);
        }

        if ($params !== null && $params !== []) {
            $this->setParams($params);
        }
    }

    /**
     * {@inheritDoc}
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * {@inheritDoc}
     */
    public function getTarget()
    {
        return $this->target;
    }

    /**
     * {@inheritDoc}
     *
     * @template NewTParams of array|ArrayAccess|object
     * @psalm-param NewTParams $params
     * @psalm-this-out static&self<TTarget, NewTParams>
     * @throws Exception\InvalidArgumentException
     */
    public function setParams($params)
    {
        /** @psalm-suppress DocblockTypeContradiction, RedundantCondition Sanity check to actually enforce docblock. */
        if (! is_array($params) && ! is_object($params)) {
            throw new Exception\InvalidArgumentException(
                sprintf('Event parameters must be an array or object; received "%s"', gettype($params))
            );
        }

        /** @psalm-suppress InvalidPropertyAssignmentValue Pretty sure this is correct after this-out. */
        $this->params = $params;
    }

    /**
     * {@inheritDoc}
     */
    public function getParams()
    {
        return $this->params;
    }

    /**
     * {@inheritDoc}
     */
    public function getParam($name, $default = null)
    {
        // Check in params that are arrays or implement array access
        if (is_array($this->params) || $this->params instanceof ArrayAccess) {
            if (! isset($this->params[$name])) {
                return $default;
            }

            /** @psalm-suppress MixedArrayAccess We've just verified `$this->params` is array-like... */
            return $this->params[$name];
        }

        // Check in normal objects
        if (! isset($this->params->{$name})) {
            return $default;
        }
        /** @psalm-suppress MixedPropertyFetch Only object is left over from union. */
        return $this->params->{$name};
    }

    /**
     * {@inheritDoc}
     */
    public function setName($name)
    {
        /** @psalm-suppress RedundantCastGivenDocblockType Cast is safety measure in case caller passes junk. */
        $this->name = (string) $name;
    }

    /**
     * {@inheritDoc}
     *
     * @template NewTTarget of object|string|null
     * @psalm-param NewTTarget $target
     * @psalm-this-out static&self<NewTTarget, TParams>
     */
    public function setTarget($target)
    {
        /** @psalm-suppress InvalidPropertyAssignmentValue Pretty sure this is correct after this-out. */
        $this->target = $target;
    }

    /**
     * {@inheritDoc}
     */
    public function setParam($name, $value)
    {
        if (is_array($this->params) || $this->params instanceof ArrayAccess) {
            // Arrays or objects implementing array access
            /** @psalm-suppress MixedArrayAssignment No way to extend existing array template. */
            $this->params[$name] = $value;
            return;
        }

        // Objects
        $this->params->{$name} = $value;
    }

    /**
     * {@inheritDoc}
     */
    public function stopPropagation($flag = true)
    {
        /** @psalm-suppress RedundantCastGivenDocblockType Cast is safety measure in case caller passes junk. */
        $this->stopPropagation = (bool) $flag;
    }

    /**
     * {@inheritDoc}
     */
    public function propagationIsStopped()
    {
        return $this->stopPropagation;
    }
}
