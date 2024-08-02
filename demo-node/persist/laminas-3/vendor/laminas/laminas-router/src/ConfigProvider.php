<?php

declare(strict_types=1);

namespace Laminas\Router;

use Laminas\ServiceManager\ConfigInterface;

/**
 * Provide base configuration for using the component.
 *
 * Provides base configuration expected in order to:
 *
 * - seed and configure the default routers and route plugin manager.
 * - provide routes to the given routers.
 *
 * @see ConfigInterface
 *
 * @psalm-import-type ServiceManagerConfigurationType from ConfigInterface
 */
class ConfigProvider
{
    /**
     * Provide default configuration.
     *
     * @return array<string, array>
     */
    public function __invoke()
    {
        return [
            'dependencies'  => $this->getDependencyConfig(),
            'route_manager' => $this->getRouteManagerConfig(),
        ];
    }

    /**
     * Provide default container dependency configuration.
     *
     * @return ServiceManagerConfigurationType
     */
    public function getDependencyConfig()
    {
        return [
            'aliases'   => [
                'HttpRouter'         => Http\TreeRouteStack::class,
                'router'             => RouteStackInterface::class,
                'Router'             => RouteStackInterface::class,
                'RoutePluginManager' => RoutePluginManager::class,

                // Legacy Zend Framework aliases
                'Zend\Router\Http\TreeRouteStack' => Http\TreeRouteStack::class,
                'Zend\Router\RoutePluginManager'  => RoutePluginManager::class,
                'Zend\Router\RouteStackInterface' => RouteStackInterface::class,
            ],
            'factories' => [
                Http\TreeRouteStack::class => Http\HttpRouterFactory::class,
                RoutePluginManager::class  => RoutePluginManagerFactory::class,
                RouteStackInterface::class => RouterFactory::class,
            ],
        ];
    }

    /**
     * Provide default route plugin manager configuration.
     *
     * @return array
     */
    public function getRouteManagerConfig()
    {
        return [];
    }
}
