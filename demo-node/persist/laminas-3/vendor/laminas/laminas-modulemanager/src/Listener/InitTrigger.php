<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Listener;

use Laminas\ModuleManager\Feature\InitProviderInterface;
use Laminas\ModuleManager\ModuleEvent;

use function method_exists;

class InitTrigger extends AbstractListener
{
    /** @return void */
    public function __invoke(ModuleEvent $e)
    {
        $module = $e->getModule();
        if (
            ! $module instanceof InitProviderInterface
            && ! method_exists($module, 'init')
        ) {
            return;
        }

        $module->init($e->getTarget());
    }
}
