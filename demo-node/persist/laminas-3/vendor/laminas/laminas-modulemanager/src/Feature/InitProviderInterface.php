<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Feature;

use Laminas\ModuleManager\ModuleManagerInterface;

interface InitProviderInterface
{
    /**
     * Initialize workflow
     *
     * @return void
     */
    public function init(ModuleManagerInterface $manager);
}
