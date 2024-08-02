<?php

namespace Laminas\Mvc\ResponseSender;

interface ResponseSenderInterface
{
    /**
     * Send the response
     *
     * @param SendResponseEvent $event
     * @return void
     */
    public function __invoke(SendResponseEvent $event);
}
