<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Renderer\RendererInterface as Renderer;

abstract class AbstractHelper implements HelperInterface
{
    /**
     * View object instance
     *
     * @var Renderer|null
     */
    protected $view;

    /**
     * Set the View object
     *
     * @return self
     */
    public function setView(Renderer $view)
    {
        $this->view = $view;
        return $this;
    }

    /**
     * Get the view object
     *
     * @return null|Renderer
     */
    public function getView()
    {
        return $this->view;
    }
}
