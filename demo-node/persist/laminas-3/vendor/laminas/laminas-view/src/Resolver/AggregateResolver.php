<?php

declare(strict_types=1);

namespace Laminas\View\Resolver;

use Countable;
use IteratorAggregate;
use Laminas\Stdlib\PriorityQueue;
use Laminas\View\Renderer\RendererInterface as Renderer;
use Laminas\View\Resolver\ResolverInterface as Resolver;
use ReturnTypeWillChange;
use Traversable;

use function count;
use function is_string;

/**
 * @final
 * @implements IteratorAggregate<int, ResolverInterface>
 */
class AggregateResolver implements Countable, IteratorAggregate, Resolver
{
    public const FAILURE_NO_RESOLVERS = 'AggregateResolver_Failure_No_Resolvers';
    public const FAILURE_NOT_FOUND    = 'AggregateResolver_Failure_Not_Found';

    /**
     * Last lookup failure
     *
     * @deprecated This property will be removed in v3.0 of this component.
     *
     * @var false|string
     */
    protected $lastLookupFailure = false;

    /**
     * @deprecated This property will be removed in v3.0 of this component.
     *
     * @var Resolver|null
     */
    protected $lastSuccessfulResolver;

    /** @var PriorityQueue<ResolverInterface, int> */
    protected $queue;

    /**
     * Constructor
     *
     * Instantiate the internal priority queue
     */
    public function __construct()
    {
        /** @var PriorityQueue<ResolverInterface, int> $priorityQueue */
        $priorityQueue = new PriorityQueue();

        $this->queue = $priorityQueue;
    }

    /**
     * Return count of attached resolvers
     *
     * @return int
     */
    #[ReturnTypeWillChange]
    public function count()
    {
        return $this->queue->count();
    }

    /**
     * IteratorAggregate: return internal iterator
     *
     * @return Traversable<int, ResolverInterface>
     */
    #[ReturnTypeWillChange]
    public function getIterator()
    {
        return $this->queue;
    }

    /**
     * Attach a resolver
     *
     * @param  int $priority
     * @return $this
     */
    public function attach(Resolver $resolver, $priority = 1)
    {
        $this->queue->insert($resolver, $priority);
        return $this;
    }

    /**
     * Resolve a template/pattern name to a resource the renderer can consume
     *
     * @param  string $name
     * @return false|string
     */
    public function resolve($name, ?Renderer $renderer = null)
    {
        $this->lastLookupFailure      = false;
        $this->lastSuccessfulResolver = null;

        if (0 === count($this->queue)) {
            $this->lastLookupFailure = static::FAILURE_NO_RESOLVERS;
            return false;
        }

        foreach ($this->queue as $resolver) {
            /**
             * @todo This loop should be modified to try { return resolve } catch { continue } in v3.0
             */
            $resource = $resolver->resolve($name, $renderer);
            if (is_string($resource)) {
                // Resource found; return it
                $this->lastSuccessfulResolver = $resolver;
                return $resource;
            }
        }

        $this->lastLookupFailure = static::FAILURE_NOT_FOUND;
        return false;
    }

    /**
     * Return the last successful resolver, if any
     *
     * @deprecated This method will be removed in v3.0 of this component
     *
     * @return Resolver|null
     */
    public function getLastSuccessfulResolver()
    {
        return $this->lastSuccessfulResolver;
    }

    /**
     * Get last lookup failure
     *
     * @deprecated This method will be removed in v3.0 of this component
     *
     * @return false|string
     */
    public function getLastLookupFailure()
    {
        return $this->lastLookupFailure;
    }
}
