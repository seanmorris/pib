<?php

declare(strict_types=1);

namespace Laminas\View\Helper\Navigation;

use Interop\Container\ContainerInterface; // phpcs:ignore
use Laminas\ServiceManager\Factory\InvokableFactory;
use Laminas\ServiceManager\ServiceManager;
use Laminas\View\HelperPluginManager;

/**
 * Plugin manager implementation for navigation helpers
 *
 * Enforces that helpers retrieved are instances of
 * Navigation\HelperInterface. Additionally, it registers a number of default
 * helpers.
 *
 * @template InstanceType of HelperInterface|AbstractHelper
 * @psalm-import-type ServiceManagerConfiguration from ServiceManager
 * @extends HelperPluginManager<InstanceType>
 */
class PluginManager extends HelperPluginManager
{
    /** {@inheritDoc} */
    protected $instanceOf = AbstractHelper::class;

    /**
     * Default aliases
     *
     * @var array<string, string>
     */
    protected $aliases = [
        'breadcrumbs' => Breadcrumbs::class,
        'links'       => Links::class,
        'menu'        => Menu::class,
        'sitemap'     => Sitemap::class,

        // Legacy Zend Framework aliases
        'Zend\View\Helper\Navigation\Breadcrumbs' => Breadcrumbs::class,
        'Zend\View\Helper\Navigation\Links'       => Links::class, // phpcs:ignore
        'Zend\View\Helper\Navigation\Menu'        => Menu::class,
        'Zend\View\Helper\Navigation\Sitemap'     => Sitemap::class,

        // v2 normalized FQCNs
        'zendviewhelpernavigationbreadcrumbs' => Breadcrumbs::class,
        'zendviewhelpernavigationlinks'       => Links::class,
        'zendviewhelpernavigationmenu'        => Menu::class,
        'zendviewhelpernavigationsitemap'     => Sitemap::class,
    ];

    /**
     * Default factories
     *
     * {@inheritDoc}
     */
    protected $factories = [
        Breadcrumbs::class => InvokableFactory::class,
        Links::class       => InvokableFactory::class,
        Menu::class        => InvokableFactory::class,
        Sitemap::class     => InvokableFactory::class,

        // v2 canonical FQCNs
        'laminasviewhelpernavigationbreadcrumbs' => InvokableFactory::class,
        'laminasviewhelpernavigationlinks'       => InvokableFactory::class,
        'laminasviewhelpernavigationmenu'        => InvokableFactory::class,
        'laminasviewhelpernavigationsitemap'     => InvokableFactory::class,
    ];

    /**
     * @param ContainerInterface $configOrContainerInstance
     * @param array $v3config
     * @psalm-param ServiceManagerConfiguration $v3config
     */
    public function __construct($configOrContainerInstance = null, array $v3config = [])
    {
        /** @psalm-suppress MissingClosureParamType */
        $this->initializers[] = function (ContainerInterface $container, $instance): void {
            if (! $instance instanceof AbstractHelper) {
                return;
            }

            $instance->setServiceLocator($this->creationContext);
        };

        parent::__construct($configOrContainerInstance, $v3config);
    }
}
