<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Feature;

use Traversable;

interface ConfigProviderInterface
{
    /**
     * Returns configuration to merge with application configuration
     *
     * @return array|Traversable
     */
    public function getConfig();
}
