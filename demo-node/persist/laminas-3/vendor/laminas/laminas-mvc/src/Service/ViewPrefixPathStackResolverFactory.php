<?php

namespace Laminas\Mvc\Service;

use Interop\Container\ContainerInterface;
use Laminas\ServiceManager\Factory\FactoryInterface;
use Laminas\View\Resolver\PrefixPathStackResolver;

class ViewPrefixPathStackResolverFactory implements FactoryInterface
{
    /**
     * Create the template prefix view resolver
     *
     * Creates a Laminas\View\Resolver\PrefixPathStackResolver and populates it with the
     * ['view_manager']['prefix_template_path_stack']
     *
     * @param  ContainerInterface $container
     * @param  string $name
     * @param  null|array $options
     * @return PrefixPathStackResolver
     */
    public function __invoke(ContainerInterface $container, $name, array $options = null)
    {
        $config   = $container->get('config');
        $prefixes = [];

        if (isset($config['view_manager']['prefix_template_path_stack'])) {
            $prefixes = $config['view_manager']['prefix_template_path_stack'];
        }

        return new PrefixPathStackResolver($prefixes);
    }
}
