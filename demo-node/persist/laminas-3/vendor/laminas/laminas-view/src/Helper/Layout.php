<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Exception;
use Laminas\View\Model\ModelInterface as Model;

use function assert;
use function sprintf;

/**
 * View helper for retrieving layout object
 *
 * @psalm-suppress DeprecatedMethod
 * @final
 */
class Layout extends AbstractHelper
{
    use DeprecatedAbstractHelperHierarchyTrait;

    /** @var ViewModel|null */
    protected $viewModelHelper;

    public function __construct(?ViewModel $viewModelHelper = null)
    {
        $this->viewModelHelper = $viewModelHelper;
    }

    /**
     * Set layout template or retrieve "layout" view model
     *
     * If no arguments are given, grabs the "root" or "layout" view model.
     * Otherwise, attempts to set the template for that view model.
     *
     * @param null|string $template
     * @return Model|null|self
     */
    public function __invoke($template = null)
    {
        if (null === $template) {
            return $this->getRoot();
        }

        return $this->setTemplate($template);
    }

    /**
     * Get layout template
     *
     * @return string
     */
    public function getLayout()
    {
        return $this->getRoot()->getTemplate();
    }

    /**
     * Get the root view model
     *
     * @throws Exception\RuntimeException
     * @return Model
     */
    protected function getRoot()
    {
        $root = $this->getViewModelHelper()->getRoot();
        if (! $root instanceof Model) {
            throw new Exception\RuntimeException(sprintf(
                '%s: no view model currently registered as root in renderer',
                __METHOD__
            ));
        }

        return $root;
    }

    /**
     * Set layout template
     *
     * @param  string $template
     * @return Layout
     */
    public function setTemplate($template)
    {
        $this->getRoot()->setTemplate((string) $template);
        return $this;
    }

    /**
     * Retrieve the view model helper
     *
     * @deprecated since >= 2.20.0. The view model helper should be injected into the constructor.
     *             This method will be removed in version 3.0 of this component.
     *
     * @return ViewModel
     */
    protected function getViewModelHelper()
    {
        if (! $this->viewModelHelper) {
            $renderer = $this->getView();
            $helper   = $renderer->plugin('view_model');
            assert($helper instanceof ViewModel);
            $this->viewModelHelper = $helper;
        }

        return $this->viewModelHelper;
    }
}
