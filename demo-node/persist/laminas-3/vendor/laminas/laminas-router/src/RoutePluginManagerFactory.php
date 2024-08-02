<?php

declare(strict_types=1);

namespace Laminas\Router;

use Laminas\ServiceManager\FactoryInterface;
use Laminas\ServiceManager\ServiceLocatorInterface;
use Psr\Container\ContainerInterface;

class RoutePluginManagerFactory implements FactoryInterface
{
    /**
     * Create and return a route plugin manager.
     *
     * @param  string $name
     * @param  null|array $options
     * @return RoutePluginManager
     */
    public function __invoke(ContainerInterface $container, $name, ?array $options = null)
    {
        $options = $options ?? [];
        return new RoutePluginManager($container, $options);
    }

    /**
     * Create and return RoutePluginManager instance.
     *
     * For use with laminas-servicemanager v2; proxies to __invoke().
     *
     * @deprecated Since 3.6.0 - This component is no longer compatible with Service Manager v2
     *
     * @return RoutePluginManager
     */
    public function createService(ServiceLocatorInterface $serviceLocator)
    {
        return $this($serviceLocator, RoutePluginManager::class);
    }
}
