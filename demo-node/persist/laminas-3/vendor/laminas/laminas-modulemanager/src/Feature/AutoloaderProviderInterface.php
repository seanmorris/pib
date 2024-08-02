<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Feature;

interface AutoloaderProviderInterface
{
    /**
     * Return an array for passing to Laminas\Loader\AutoloaderFactory.
     *
     * @return array
     */
    public function getAutoloaderConfig();
}
