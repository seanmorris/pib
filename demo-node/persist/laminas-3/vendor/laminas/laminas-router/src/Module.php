<?php

declare(strict_types=1);

namespace Laminas\Router;

/**
 * Register with a laminas-mvc application.
 */
class Module
{
    /**
     * Provide default router configuration.
     *
     * @return array
     */
    public function getConfig()
    {
        $provider = new ConfigProvider();
        return [
            'service_manager' => $provider->getDependencyConfig(),
            'route_manager'   => $provider->getRouteManagerConfig(),
            'router'          => ['routes' => []],
        ];
    }
}
