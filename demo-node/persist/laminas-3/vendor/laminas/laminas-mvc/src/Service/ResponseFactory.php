<?php

namespace Laminas\Mvc\Service;

use Interop\Container\ContainerInterface;
use Laminas\Http\PhpEnvironment\Response as HttpResponse;
use Laminas\ServiceManager\Factory\FactoryInterface;

class ResponseFactory implements FactoryInterface
{
    /**
     * Create and return a response instance.
     *
     * @param  ContainerInterface $container
     * @param  string $name
     * @param  null|array $options
     * @return HttpResponse
     */
    public function __invoke(ContainerInterface $container, $name, array $options = null)
    {
        return new HttpResponse();
    }
}
