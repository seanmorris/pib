<?php

declare(strict_types=1);

namespace Laminas\SkeletonInstaller;

use ArrayAccess;
use ArrayIterator;
use Countable;
use InvalidArgumentException;
use IteratorAggregate;
use OutOfRangeException;
use ReturnTypeWillChange;
use Traversable;

use function array_key_exists;
use function count;
use function is_array;
use function iterator_to_array;
use function sprintf;

/**
 * @template TKey of array-key
 * @template TValue
 * @template-implements ArrayAccess<TKey, TValue>
 * @template-implements IteratorAggregate<TKey, TValue>
 */
class Collection implements
    ArrayAccess,
    Countable,
    IteratorAggregate
{
    /** @var array<TKey, TValue> */
    protected $items;

    /**
     * @param iterable<TKey, TValue> $items
     * @throws InvalidArgumentException
     */
    public function __construct($items)
    {
        if ($items instanceof Traversable) {
            $items = iterator_to_array($items);
        }

        if (! is_array($items)) {
            throw new InvalidArgumentException('Collections require arrays or Traversable objects');
        }

        $this->items = $items;
    }

    /**
     * @template TInputKey of array-key
     * @template TInputValue
     * @param iterable<TInputKey, TInputValue> $items
     * @return self<TInputKey, TInputValue>
     */
    public static function create($items)
    {
        return new static($items);
    }

    /**
     * Cast collection to an array.
     *
     * @return array<TKey, TValue>
     */
    public function toArray()
    {
        return $this->items;
    }

    /**
     * Apply a callback to each item in the collection.
     *
     * @param callable(TValue): void $callback
     * @return $this
     */
    public function each(callable $callback)
    {
        foreach ($this->items as $item) {
            $callback($item);
        }
        return $this;
    }

    /**
     * Reduce the collection to a single value.
     *
     * @template TAccumulator
     * @param callable(TAccumulator, TValue): TAccumulator $callback
     * @param TAccumulator $initial Initial value.
     * @return TAccumulator
     */
    public function reduce(callable $callback, $initial = null)
    {
        $accumulator = $initial;

        foreach ($this->items as $item) {
            $accumulator = $callback($accumulator, $item);
        }

        return $accumulator;
    }

    /**
     * Filter the collection using a callback.
     *
     * Filter callback should return true for values to keep.
     *
     * @param callable(TValue): bool $callback
     * @return self<int, TValue>
     */
    public function filter(callable $callback)
    {
        /** @var self<int, TValue> $newMap */
        $newMap = new static([]);

        return $this->reduce(
            /**
             * @param self<int, TValue> $filtered
             * @param TValue $item
             * @return self<int, TValue>
             */
            function (self $filtered, $item) use ($callback) {
                if ($callback($item)) {
                    $filtered[] = $item;
                }
                return $filtered;
            },
            $newMap
        );
    }

    /**
     * Filter the collection using a callback; reject any items matching the callback.
     *
     * Filter callback should return true for values to reject.
     *
     * @param callable(TValue): bool $callback
     * @return self<int, TValue>
     */
    public function reject(callable $callback)
    {
        /** @var self<int, TValue> $newMap */
        $newMap = new static([]);

        return $this->reduce(
            /**
             * @param self<int, TValue> $filtered
             * @param TValue $item
             * @return self<int, TValue>
             */
            function (self $filtered, $item) use ($callback) {
                if (! $callback($item)) {
                    $filtered[] = $item;
                }
                return $filtered;
            },
            $newMap
        );
    }

    /**
     * Transform each value in the collection.
     *
     * Callback should return the new value to use.
     *
     * @template TMapResult
     * @param callable(TValue): TMapResult $callback
     * @return self<int, TMapResult>
     */
    public function map(callable $callback)
    {
        /** @var self<int, TMapResult> $newMap */
        $newMap = new static([]);

        return $this->reduce(
            /**
             * @param self<int, TMapResult> $results
             * @param TValue $item
             * @return self<int, TMapResult>
             */
            function (self $results, $item) use ($callback) {
                $results[] = $callback($item);
                return $results;
            },
            $newMap
        );
    }

    /** @inheritDoc */
    #[ReturnTypeWillChange]
    public function offsetExists($offset)
    {
        return array_key_exists($offset, $this->items);
    }

    /** @inheritDoc */
    #[ReturnTypeWillChange]
    public function offsetGet($offset)
    {
        if (! $this->offsetExists($offset)) {
            throw new OutOfRangeException(sprintf(
                'Offset %s does not exist in the collection',
                $offset
            ));
        }

        return $this->items[$offset];
    }

    /**
     * @inheritDoc
     *
     * If $offset is null, pushes the item onto the stack.
     */
    #[ReturnTypeWillChange]
    public function offsetSet($offset, $value)
    {
        if (null === $offset) {
            $this->items[] = $value;
            return;
        }

        $this->items[$offset] = $value;
    }

    /** @inheritDoc */
    #[ReturnTypeWillChange]
    public function offsetUnset($offset)
    {
        if ($this->offsetExists($offset)) {
            unset($this->items[$offset]);
        }
    }

    /**
     * Countable: number of items in the collection.
     *
     * @return int
     */
    #[ReturnTypeWillChange]
    public function count()
    {
        return count($this->items);
    }

    /**
     * Is the collection empty?
     *
     * @return bool
     */
    public function isEmpty()
    {
        return 0 === $this->count();
    }

    /** @inheritDoc */
    #[ReturnTypeWillChange]
    public function getIterator()
    {
        return new ArrayIterator($this->items);
    }
}
