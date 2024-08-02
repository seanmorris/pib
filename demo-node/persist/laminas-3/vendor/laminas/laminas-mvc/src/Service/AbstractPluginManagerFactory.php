<?php

namespace Laminas\Mvc\Service;

use Interop\Container\ContainerInterface;
use Laminas\ServiceManager\AbstractPluginManager;
use Laminas\ServiceManager\Factory\FactoryInterface;

abstract class AbstractPluginManagerFactory implements FactoryInterface
{
    public const PLUGIN_MANAGER_CLASS = 'AbstractPluginManager';

    /**
     * Create and return a plugin manager.
     *
     * Classes that extend this should provide a valid class for
     * the PLUGIN_MANGER_CLASS constant.
     *
     * @param  ContainerInterface $container
     * @param  string $name
     * @param  null|array $options
     * @return AbstractPluginManager
     */
    public function __invoke(ContainerInterface $container, $name, array $options = null)
    {
        $options            = $options ?: [];
        $pluginManagerClass = static::PLUGIN_MANAGER_CLASS;
        return new $pluginManagerClass($container, $options);
    }
}
