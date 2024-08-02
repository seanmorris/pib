<?php

declare(strict_types=1);

namespace Laminas\View\Helper\Service;

use ArrayAccess;
use Laminas\View\Helper\BasePath;
use Psr\Container\ContainerInterface;

use function assert;
use function is_array;
use function is_string;

final class BasePathFactory
{
    public function __invoke(ContainerInterface $container): BasePath
    {
        $config = $container->has('config')
            ? $container->get('config')
            : [];

        assert(is_array($config) || $config instanceof ArrayAccess);

        // The expected location in config for the base path in an MVC application
        // is config.view_manager.base_path
        // @link https://docs.laminas.dev/laminas-mvc/services/#viewmanager

        $viewConfig = $config['view_manager'] ?? [];
        assert(is_array($viewConfig));

        $basePath = $viewConfig['base_path'] ?? null;
        assert(is_string($basePath) || $basePath === null);

        return new BasePath($basePath);
    }
}
