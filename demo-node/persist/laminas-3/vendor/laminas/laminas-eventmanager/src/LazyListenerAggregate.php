<?php

namespace Laminas\EventManager;

use Psr\Container\ContainerInterface;

use function get_debug_type;
use function is_array;
use function sprintf;

/**
 * Aggregate listener for attaching lazy listeners.
 *
 * Lazy listeners are listeners where creation is deferred until they are
 * triggered; this removes the most costly mechanism of pulling a listener
 * from a container unless the listener is actually invoked.
 *
 * Usage is:
 *
 * <code>
 * $aggregate = new LazyListenerAggregate(
 *     $lazyEventListenersOrDefinitions,
 *     $container
 * );
 * $aggregate->attach($events);
 * </code>
 */
class LazyListenerAggregate implements ListenerAggregateInterface
{
    use ListenerAggregateTrait;

    // phpcs:disable SlevomatCodingStandard.Classes.UnusedPrivateElements.WriteOnlyProperty

    /** @var ContainerInterface Container from which to pull lazy listeners. */
    private $container;

    /** @var array Additional environment/option variables to use when creating listener. */
    private $env;

    // phpcs:enable

    /**
     * Generated LazyEventListener instances.
     *
     * @var LazyEventListener[]
     */
    private $lazyListeners = [];

    /**
     * Constructor
     *
     * Accepts the composed $listeners, as well as the $container and $env in
     * order to create a listener aggregate that defers listener creation until
     * the listener is triggered.
     *
     * Listeners may be either LazyEventListener instances, or lazy event
     * listener definitions that can be provided to a LazyEventListener
     * constructor in order to create a new instance; in the latter case, the
     * $container and $env will be passed at instantiation as well.
     *
     * @param array $listeners LazyEventListener instances or array definitions
     *     to pass to the LazyEventListener constructor.
     * @param array $env
     * @throws Exception\InvalidArgumentException For invalid listener items.
     */
    public function __construct(array $listeners, ContainerInterface $container, array $env = [])
    {
        $this->container = $container;
        $this->env       = $env;

        // This would raise an exception for invalid structs
        foreach ($listeners as $listener) {
            if (is_array($listener)) {
                $listener = new LazyEventListener($listener, $container, $env);
            }

            if (! $listener instanceof LazyEventListener) {
                throw new Exception\InvalidArgumentException(sprintf(
                    'All listeners must be LazyEventListener instances or definitions; received %s',
                    get_debug_type($listener),
                ));
            }

            $this->lazyListeners[] = $listener;
        }
    }

    /**
     * Attach the aggregate to the event manager.
     *
     * Loops through all composed lazy listeners, and attaches them to the
     * event manager.
     *
     * @param int $priority
     * @return void
     */
    public function attach(EventManagerInterface $events, $priority = 1)
    {
        foreach ($this->lazyListeners as $lazyListener) {
            $this->listeners[] = $events->attach(
                $lazyListener->getEvent(),
                $lazyListener,
                $lazyListener->getPriority($priority)
            );
        }
    }
}
