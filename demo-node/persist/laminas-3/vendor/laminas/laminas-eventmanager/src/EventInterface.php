<?php

namespace Laminas\EventManager;

use ArrayAccess;

/**
 * Representation of an event
 *
 * @template-covariant TTarget of object|string|null
 * @template-covariant TParams of array|ArrayAccess|object
 */
interface EventInterface
{
    /**
     * Get event name
     *
     * @return string|null
     */
    public function getName();

    /**
     * Get target/context from which event was triggered
     *
     * @return object|string|null
     * @psalm-return TTarget
     */
    public function getTarget();

    /**
     * Get parameters passed to the event
     *
     * @return array|ArrayAccess|object
     * @psalm-return TParams
     */
    public function getParams();

    /**
     * Get a single parameter by name
     *
     * @param  string|int $name
     * @param  mixed $default Default value to return if parameter does not exist
     * @return mixed
     */
    public function getParam($name, $default = null);

    /**
     * Set the event name
     *
     * @param  string $name
     * @return void
     */
    public function setName($name);

    /**
     * Set the event target/context
     *
     * @param object|string|null $target
     * @template NewTTarget of object|string|null
     * @psalm-param NewTTarget $target
     * @psalm-this-out static&self<NewTTarget, TParams>
     * @return void
     */
    public function setTarget($target);

    /**
     * Set event parameters. Overwrites parameters.
     *
     * @param array|ArrayAccess|object $params
     * @template NewTParams of array|ArrayAccess|object
     * @psalm-param NewTParams $params
     * @psalm-this-out static&self<TTarget, NewTParams>
     * @return void
     */
    public function setParams($params);

    /**
     * Set a single parameter by key
     *
     * @param  string|int $name
     * @param  mixed $value
     * @return void
     */
    public function setParam($name, $value);

    /**
     * Indicate whether or not the parent EventManagerInterface should stop propagating events
     *
     * @param  bool $flag
     * @return void
     */
    public function stopPropagation($flag = true);

    /**
     * Has this event indicated event propagation should stop?
     *
     * @return bool
     */
    public function propagationIsStopped();
}
