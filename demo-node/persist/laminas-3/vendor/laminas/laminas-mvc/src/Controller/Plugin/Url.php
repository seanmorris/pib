<?php

namespace Laminas\Mvc\Controller\Plugin;

use Laminas\Mvc\Exception\RuntimeException;
use Laminas\Mvc\Exception\InvalidArgumentException;
use Laminas\Mvc\Exception\DomainException;
use Laminas\EventManager\EventInterface;
use Laminas\Mvc\Exception;
use Laminas\Mvc\InjectApplicationEventInterface;
use Laminas\Mvc\ModuleRouteListener;
use Laminas\Mvc\MvcEvent;
use Laminas\Router\RouteStackInterface;
use Traversable;

class Url extends AbstractPlugin
{
    /**
     * Generates a URL based on a route
     *
     * @param  string             $route              RouteInterface name
     * @param  array|Traversable  $params             Parameters to use in url generation, if any
     * @param  array|bool         $options            RouteInterface-specific options to use in url generation, if any.
     *                                                If boolean, and no fourth argument, used as $reuseMatchedParams.
     * @param  bool               $reuseMatchedParams Whether to reuse matched parameters
     *
     * @throws RuntimeException
     * @throws InvalidArgumentException
     * @throws DomainException
     * @return string
     */
    public function fromRoute($route = null, $params = [], $options = [], $reuseMatchedParams = false)
    {
        $controller = $this->getController();
        if (! $controller instanceof InjectApplicationEventInterface) {
            throw new DomainException(
                'Url plugin requires a controller that implements InjectApplicationEventInterface'
            );
        }

        if (! is_array($params)) {
            if (! $params instanceof Traversable) {
                throw new InvalidArgumentException(
                    'Params is expected to be an array or a Traversable object'
                );
            }
            $params = iterator_to_array($params);
        }

        $event   = $controller->getEvent();
        $router  = null;
        $matches = null;
        if ($event instanceof MvcEvent) {
            $router  = $event->getRouter();
            $matches = $event->getRouteMatch();
        } elseif ($event instanceof EventInterface) {
            $router  = $event->getParam('router', false);
            $matches = $event->getParam('route-match', false);
        }
        if (! $router instanceof RouteStackInterface) {
            throw new DomainException(
                'Url plugin requires that controller event compose a router; none found'
            );
        }

        if (3 == func_num_args() && is_bool($options)) {
            $reuseMatchedParams = $options;
            $options = [];
        }

        if ($route === null) {
            if (! $matches) {
                throw new RuntimeException('No RouteMatch instance present');
            }

            $route = $matches->getMatchedRouteName();

            if ($route === null) {
                throw new RuntimeException('RouteMatch does not contain a matched route name');
            }
        }

        if ($reuseMatchedParams && $matches) {
            $routeMatchParams = $matches->getParams();

            if (isset($routeMatchParams[ModuleRouteListener::ORIGINAL_CONTROLLER])) {
                $routeMatchParams['controller'] = $routeMatchParams[ModuleRouteListener::ORIGINAL_CONTROLLER];
                unset($routeMatchParams[ModuleRouteListener::ORIGINAL_CONTROLLER]);
            }

            if (isset($routeMatchParams[ModuleRouteListener::MODULE_NAMESPACE])) {
                unset($routeMatchParams[ModuleRouteListener::MODULE_NAMESPACE]);
            }

            $params = array_merge($routeMatchParams, $params);
        }

        $options['name'] = $route;
        return $router->assemble($params, $options);
    }
}
