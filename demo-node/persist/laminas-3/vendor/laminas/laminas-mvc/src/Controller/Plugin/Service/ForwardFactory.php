<?php

namespace Laminas\Mvc\Controller\Plugin\Service;

use Interop\Container\ContainerInterface;
use Laminas\Mvc\Controller\Plugin\Forward;
use Laminas\ServiceManager\Exception\ServiceNotCreatedException;
use Laminas\ServiceManager\Factory\FactoryInterface;

class ForwardFactory implements FactoryInterface
{
    /**
     * {@inheritDoc}
     *
     * @return Forward
     * @throws ServiceNotCreatedException if Controllermanager service is not found in application service locator
     */
    public function __invoke(ContainerInterface $container, $name, array $options = null)
    {
        if (! $container->has('ControllerManager')) {
            throw new ServiceNotCreatedException(sprintf(
                '%s requires that the application service manager contains a "%s" service; none found',
                self::class,
                'ControllerManager'
            ));
        }
        $controllers = $container->get('ControllerManager');

        return new Forward($controllers);
    }
}
