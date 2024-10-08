<?php

declare(strict_types=1);

namespace Laminas\Router;

/**
 * @template TRoute of RouteInterface
 */
interface RouteStackInterface extends RouteInterface
{
    /**
     * Add a route to the stack.
     *
     * @param string          $name
     * @param iterable|TRoute $route
     * @param int             $priority
     * @return static
     */
    public function addRoute($name, $route, $priority = null);

    /**
     * Add multiple routes to the stack.
     *
     * @param iterable $routes
     * @return static
     */
    public function addRoutes($routes);

    /**
     * Remove a route from the stack.
     *
     * @param  string $name
     * @return static
     */
    public function removeRoute($name);

    /**
     * Remove all routes from the stack and set new ones.
     *
     * @param iterable $routes
     * @return static
     */
    public function setRoutes($routes);
}
