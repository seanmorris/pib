<?php

declare(strict_types=1);

namespace Laminas\Router;

use Psr\Container\ContainerInterface;

use function class_exists;
use function sprintf;

trait RouterConfigTrait
{
    /**
     * Create and return a router instance, by calling the appropriate factory.
     *
     * @param string $class
     * @param array $config
     * @return RouteInterface
     */
    private function createRouter($class, array $config, ContainerInterface $container)
    {
        // Obtain the configured router class, if any
        if (isset($config['router_class']) && class_exists($config['router_class'])) {
            $class = $config['router_class'];
        }

        // Inject the route plugins
        if (! isset($config['route_plugins'])) {
            $routePluginManager      = $container->get('RoutePluginManager');
            $config['route_plugins'] = $routePluginManager;
        }

        // Obtain an instance
        $factory = sprintf('%s::factory', $class);
        return $factory($config);
    }
}
