<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller;

use ArrayIterator;
use Countable;
use IteratorAggregate;
use OutOfRangeException;

use function array_filter;
use function array_key_exists;
use function array_merge;
use function array_search;
use function array_unique;
use function array_values;
use function count;
use function gettype;
use function is_scalar;
use function sprintf;

use const ARRAY_FILTER_USE_BOTH;

/**
 * @internal
 *
 * @template TKey of array-key
 * @template TValue
 *
 * @implements IteratorAggregate<TKey, TValue>
 */
final class Collection implements
    Countable,
    IteratorAggregate
{
    /** @var array<TKey,TValue> */
    protected array $items;

    /**
     * @param array<TKey,TValue> $items
     */
    public function __construct(array $items)
    {
        $this->items = $items;
    }

    /**
     * Cast collection to an array.
     *
     * @return array<TKey,TValue>
     */
    public function toArray(): array
    {
        return $this->items;
    }

    /**
     * Apply a callback to each item in the collection.
     *
     * @param callable(TValue,TKey):void $callback
     * @return self<TKey,TValue>
     */
    public function each(callable $callback): self
    {
        foreach ($this->items as $key => $item) {
            $callback($item, $key);
        }
        return $this;
    }

    /**
     * Filter the collection using a callback.
     *
     * Filter callback should return true for values to keep.
     *
     * @param callable(TValue,TKey):bool $callback
     * @return self<TKey,TValue>
     */
    public function filter(callable $callback): self
    {
        $filtered = array_filter($this->items, $callback, ARRAY_FILTER_USE_BOTH);

        return new self($filtered);
    }

    /**
     * Filter the collection using a callback; reject any items matching the callback.
     *
     * Filter callback should return true for values to reject.
     *
     * @param callable(TValue,TKey):bool $callback
     * @return self<TKey,TValue>
     */
    public function reject(callable $callback): self
    {
        /** @psalm-suppress MixedArgument Psalm is not able to infer the type from the static callable (yet). */
        $filtered = array_filter(
            $this->items,
            static fn ($value, $key) => ! $callback($value, $key),
            ARRAY_FILTER_USE_BOTH
        );
        return new self($filtered);
    }

    /**
     * Transform each value in the collection.
     *
     * Callback should return the new value to use.
     *
     * @template     TNewValue
     * @psalm-param  callable(TValue,TKey):TNewValue $callback
     * @psalm-return self<TKey,TNewValue>
     */
    public function map(callable $callback): self
    {
        $mapped = [];
        foreach ($this->items as $key => $value) {
            $mapped[$key] = $callback($value, $key);
        }

        return new self($mapped);
    }

    /**
     * Return a new collection containing only unique items.
     *
     * @return self<TKey,TValue>
     * @psalm-immutable
     */
    public function unique(): self
    {
        return new self(array_unique($this->items));
    }

    /**
     * @param TKey $offset
     */
    public function has($offset): bool
    {
        return array_key_exists($offset, $this->items);
    }

    /**
     * @param TKey $offset
     * @return TValue
     * @throws OutOfRangeException
     */
    public function get($offset)
    {
        if (! $this->has($offset)) {
            throw new OutOfRangeException(sprintf(
                'Offset %s does not exist in the collection',
                $offset
            ));
        }

        return $this->items[$offset];
    }

    /**
     * @param TKey $offset
     * @param TValue $value
     */
    public function set($offset, $value): void
    {
        $this->items[$offset] = $value;
    }

    /**
     * Countable: number of items in the collection.
     */
    public function count(): int
    {
        return count($this->items);
    }

    public function isEmpty(): bool
    {
        return $this->items === [];
    }

    /**
     * Traversable: Iterate the collection.
     *
     * @return ArrayIterator<TKey,TValue>
     */
    public function getIterator(): ArrayIterator
    {
        return new ArrayIterator($this->items);
    }

    /**
     * @param callable(TValue,TKey):bool $callback
     */
    public function anySatisfies(callable $callback): bool
    {
        foreach ($this->items as $index => $item) {
            if ($callback($item, $index)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @return self<int<0, max>, TValue>
     */
    public function toOrderedCollection(): self
    {
        return new self(array_values($this->items));
    }

    /**
     * @param self<TKey,TValue> $collection
     * @return self<TKey,TValue>
     */
    public function merge(Collection $collection): self
    {
        $this->items = array_merge($this->items, $collection->toArray());

        return $this;
    }

    /**
     * @param TValue $value
     * @return TKey
     * @throws OutOfRangeException
     */
    public function getKey($value)
    {
        $key = array_search($value, $this->items, true);
        if ($key === false) {
            throw new OutOfRangeException(sprintf(
                'Value %s does not exist in the collection',
                is_scalar($value) ? (string) $value : gettype($value)
            ));
        }

        return $key;
    }
}
