<?php

namespace Laminas\Mvc\Service;

use Interop\Container\ContainerInterface;
use Laminas\Mvc\SendResponseListener;

class SendResponseListenerFactory
{
    /**
     * @return SendResponseListener
     */
    public function __invoke(ContainerInterface $container)
    {
        $listener = new SendResponseListener();
        $listener->setEventManager($container->get('EventManager'));
        return $listener;
    }
}
