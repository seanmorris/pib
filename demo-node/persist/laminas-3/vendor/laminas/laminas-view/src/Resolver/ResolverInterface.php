<?php

declare(strict_types=1);

namespace Laminas\View\Resolver;

use Laminas\View\Renderer\RendererInterface as Renderer;

interface ResolverInterface
{
    /**
     * Resolve a template/pattern name to a resource the renderer can consume
     *
     * In version 3.0 of this component, this method will guarantee a string return type or an exception will be thrown.
     *
     * @param  string $name
     * @return string|false
     */
    public function resolve($name, ?Renderer $renderer = null);
}
