<?php

declare(strict_types=1);

namespace Laminas\View;

use ArrayIterator;
use ArrayObject;
use ReturnTypeWillChange; // phpcs:ignore

use function call_user_func;
use function gettype;
use function is_array;
use function is_callable;
use function is_object;
use function method_exists;
use function sprintf;
use function strtolower;
use function trigger_error;

use const E_USER_NOTICE;

/**
 * Class for Laminas\View\Renderer\PhpRenderer to help enforce private constructs.
 *
 * @todo       Allow specifying string names for manager, filter chain, variables
 * @todo       Move escaping into variables object
 * @todo       Move strict variables into variables object
 * @extends ArrayObject<string, mixed>
 */
class Variables extends ArrayObject
{
    /**
     * Strict variables flag; when on, undefined variables accessed in the view
     * scripts will trigger notices
     *
     * @var bool
     */
    protected $strictVars = false;

    /**
     * Constructor
     *
     * @param array<string, mixed> $variables
     * @param array<string, mixed> $options
     */
    public function __construct(array $variables = [], array $options = [])
    {
        parent::__construct(
            $variables,
            ArrayObject::ARRAY_AS_PROPS,
            ArrayIterator::class
        );

        $this->setOptions($options);
    }

    /**
     * Configure object
     *
     * @param  array<string, mixed> $options
     * @return Variables
     */
    public function setOptions(array $options)
    {
        foreach ($options as $key => $value) {
            switch (strtolower($key)) {
                case 'strict_vars':
                    $this->setStrictVars($value);
                    break;
                default:
                    // Unknown options are considered variables
                    $this[$key] = $value;
                    break;
            }
        }
        return $this;
    }

    /**
     * Set status of "strict vars" flag
     *
     * @param  bool $flag
     * @return Variables
     */
    public function setStrictVars($flag)
    {
        $this->strictVars = (bool) $flag;
        return $this;
    }

    /**
     * Are we operating with strict variables?
     *
     * @return bool
     */
    public function isStrict()
    {
        return $this->strictVars;
    }

    /**
     * Assign many values at once
     *
     * @param  array<string, mixed>|object $spec
     * @return Variables
     * @throws Exception\InvalidArgumentException
     */
    public function assign($spec)
    {
        if (is_object($spec)) {
            if (method_exists($spec, 'toArray')) {
                $spec = $spec->toArray();
            } else {
                $spec = (array) $spec;
            }
        }
        if (! is_array($spec)) {
            throw new Exception\InvalidArgumentException(sprintf(
                'assign() expects either an array or an object as an argument; received "%s"',
                gettype($spec)
            ));
        }
        foreach ($spec as $key => $value) {
            $this[$key] = $value;
        }

        return $this;
    }

    /**
     * Get the variable value
     *
     * If the value has not been defined, a null value will be returned; if
     * strict vars on in place, a notice will also be raised.
     *
     * Otherwise, returns _escaped_ version of the value.
     *
     * @param string $offset
     * @return mixed
     */
    #[ReturnTypeWillChange]
    public function offsetGet($offset)
    {
        if (! $this->offsetExists($offset)) {
            if ($this->isStrict()) {
                trigger_error(sprintf(
                    'View variable "%s" does not exist',
                    $offset
                ), E_USER_NOTICE);
            }
            return;
        }

        $return = parent::offsetGet($offset);

        // If we have a closure/functor, invoke it, and return its return value
        if (is_object($return) && is_callable($return)) {
            $return = call_user_func($return);
        }

        return $return;
    }

    /**
     * Clear all variables
     *
     * @return void
     */
    public function clear()
    {
        $this->exchangeArray([]);
    }
}
