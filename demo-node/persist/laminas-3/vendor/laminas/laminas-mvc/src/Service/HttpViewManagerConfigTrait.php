<?php

namespace Laminas\Mvc\Service;

use ArrayAccess;
use Interop\Container\ContainerInterface;

trait HttpViewManagerConfigTrait
{
    /**
     * Retrieve view_manager configuration, if present.
     *
     * @return array
     */
    private function getConfig(ContainerInterface $container)
    {
        $config = $container->has('config') ? $container->get('config') : [];

        if (isset($config['view_manager'])
            && (is_array($config['view_manager'])
                || $config['view_manager'] instanceof ArrayAccess
            )
        ) {
            return $config['view_manager'];
        }

        return [];
    }
}
