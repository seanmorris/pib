<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Listener;

use Generator;
use Laminas\ModuleManager\ModuleEvent;

use function class_exists;
use function in_array;
use function sprintf;

class ModuleResolverListener extends AbstractListener
{
    /**
     * Class names that are invalid as module classes, due to inability to instantiate.
     *
     * @var string[]
     */
    protected $invalidClassNames = [
        Generator::class,
    ];

    /**
     * @return object|false False if module class does not exist
     */
    public function __invoke(ModuleEvent $e)
    {
        $moduleName = $e->getModuleName();

        $class = sprintf('%s\Module', $moduleName);
        if (class_exists($class)) {
            return new $class();
        }

        if (
            class_exists($moduleName)
            && ! in_array($moduleName, $this->invalidClassNames, true)
        ) {
            return new $moduleName();
        }

        return false;
    }
}
