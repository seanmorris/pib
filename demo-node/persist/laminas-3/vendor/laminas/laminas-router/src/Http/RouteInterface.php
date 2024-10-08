<?php

declare(strict_types=1);

namespace Laminas\Router\Http;

use Laminas\Router\RouteInterface as BaseRoute;
use Laminas\Stdlib\RequestInterface as Request;

/**
 * Tree specific route interface.
 *
 * Note: the additional {@see self::match()} annotation is only here for documentation purposes, because we cannot
 *       change the signature of {@see self::match()} in the interface definition without breaking BC.
 *
 * @method RouteMatch|null match(Request $request, int|null $pathOffset = null, array $options = [])
 */
interface RouteInterface extends BaseRoute
{
    /**
     * Get a list of parameters used while assembling.
     *
     * @return array
     */
    public function getAssembledParams();
}
