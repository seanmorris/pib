<?php

declare(strict_types=1);

namespace Laminas\View\Resolver;

use Laminas\View\Helper\ViewModel as ViewModelHelper;
use Laminas\View\Model\ModelInterface;
use Laminas\View\Renderer\RendererInterface;
use Laminas\View\Resolver\ResolverInterface;

use function call_user_func;
use function is_callable;
use function strrpos;
use function substr;

/**
 * Relative fallback resolver - resolves to view templates in a sub-path of the
 * currently set view model's template (if the current renderer has the `view_model` plugin set).
 *
 * This allows for usage of partial template paths such as `some/partial`, resolving to
 * `my/module/script/path/some/partial.phtml`, while rendering template `my/module/script/path/my-view`
 *
 * @final
 */
class RelativeFallbackResolver implements ResolverInterface
{
    public const NS_SEPARATOR = '/';

    private ResolverInterface $resolver;

    public function __construct(ResolverInterface $resolver)
    {
        $this->resolver = $resolver;
    }

    /**
     * {@inheritDoc}
     */
    public function resolve($name, ?RendererInterface $renderer = null)
    {
        $plugin = [$renderer, 'plugin'];

        if (! is_callable($plugin)) {
            return false;
        }

        $helper = call_user_func($plugin, 'view_model');

        if (! $helper instanceof ViewModelHelper) {
            return false;
        }

        $currentModel = $helper->getCurrent();

        if (! $currentModel instanceof ModelInterface) {
            return false;
        }

        $currentTemplate = $currentModel->getTemplate();
        $position        = strrpos($currentTemplate, self::NS_SEPARATOR);

        if ($position === false) {
            return false;
        }

        return $this->resolver->resolve(substr($currentTemplate, 0, $position) . self::NS_SEPARATOR . $name, $renderer);
    }
}
