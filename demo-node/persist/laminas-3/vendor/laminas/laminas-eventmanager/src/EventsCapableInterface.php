<?php

namespace Laminas\EventManager;

/**
 * Interface indicating that an object composes an EventManagerInterface instance.
 */
interface EventsCapableInterface
{
    /**
     * Retrieve the event manager
     *
     * Lazy-loads an EventManager instance if none registered.
     *
     * @return EventManagerInterface
     */
    public function getEventManager();
}
