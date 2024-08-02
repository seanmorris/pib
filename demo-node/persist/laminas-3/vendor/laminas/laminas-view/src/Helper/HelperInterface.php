<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Renderer\RendererInterface as Renderer;

interface HelperInterface
{
    /**
     * Set the View object
     *
     * @return HelperInterface
     */
    public function setView(Renderer $view);

    /**
     * Get the View object
     *
     * @return Renderer|null
     */
    public function getView();
}
