<?php

declare(strict_types=1);

namespace Laminas\View\Renderer;

use ArrayAccess;
use Laminas\View\Model\ModelInterface;
use Laminas\View\Resolver\ResolverInterface;

/**
 * Interface class for Laminas\View\Renderer\* compatible template engine implementations
 */
interface RendererInterface
{
    /**
     * Return the template engine object, if any
     *
     * If using a third-party template engine, such as Smarty, patTemplate,
     * phplib, etc, return the template engine object. Useful for calling
     * methods on these objects, such as for setting filters, modifiers, etc.
     *
     * @return mixed
     */
    public function getEngine();

    /**
     * Set the resolver used to map a template name to a resource the renderer may consume.
     *
     * @return RendererInterface
     */
    public function setResolver(ResolverInterface $resolver);

    /**
     * Processes a view script and returns the output.
     *
     * @param  string|ModelInterface   $nameOrModel The script/resource process, or a view model
     * @param  null|array|ArrayAccess $values      Values to use during rendering
     * @return string The script output.
     */
    public function render($nameOrModel, $values = null);
}
