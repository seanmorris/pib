<?php

declare(strict_types=1);

namespace Laminas\View\Renderer;

interface TreeRendererInterface
{
    /**
     * Indicate whether the renderer is capable of rendering trees of view models
     *
     * @return bool
     */
    public function canRenderTrees();
}
