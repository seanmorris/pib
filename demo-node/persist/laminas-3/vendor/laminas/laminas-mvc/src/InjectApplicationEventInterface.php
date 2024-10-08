<?php

namespace Laminas\Mvc;

use Laminas\EventManager\EventInterface as Event;

interface InjectApplicationEventInterface
{
    /**
     * Compose an Event
     *
     * @return void
     */
    public function setEvent(Event $event);

    /**
     * Retrieve the composed event
     *
     * @return Event
     */
    public function getEvent();
}
