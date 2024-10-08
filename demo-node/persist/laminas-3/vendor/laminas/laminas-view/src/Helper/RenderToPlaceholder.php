<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Model\ModelInterface;

/**
 * Renders a template and stores the rendered output as a placeholder
 * variable for later use.
 */
class RenderToPlaceholder extends AbstractHelper
{
    /**
     * Renders a template and stores the rendered output as a placeholder
     * variable for later use.
     *
     * @param string|ModelInterface $script      The template script to render
     * @param string                $placeholder The placeholder variable name in which to store the rendered output
     * @return void
     */
    public function __invoke($script, $placeholder)
    {
        $placeholderHelper = $this->view->plugin('placeholder');
        $placeholderHelper($placeholder)->captureStart();
        echo $this->view->render($script);
        $placeholderHelper($placeholder)->captureEnd();
    }
}
