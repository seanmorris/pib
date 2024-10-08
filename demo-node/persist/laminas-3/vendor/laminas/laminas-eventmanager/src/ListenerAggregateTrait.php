<?php

namespace Laminas\EventManager;

/**
 * Provides logic to easily create aggregate listeners, without worrying about
 * manually detaching events
 */
trait ListenerAggregateTrait
{
    /** @var callable[] */
    protected $listeners = [];

    /**
     * {@inheritDoc}
     */
    public function detach(EventManagerInterface $events)
    {
        foreach ($this->listeners as $index => $callback) {
            $events->detach($callback);
            unset($this->listeners[$index]);
        }
    }
}
