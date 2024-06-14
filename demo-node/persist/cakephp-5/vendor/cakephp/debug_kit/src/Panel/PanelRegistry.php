<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Panel;

use Cake\Core\App;
use Cake\Core\ObjectRegistry;
use Cake\Event\EventDispatcherInterface;
use Cake\Event\EventDispatcherTrait;
use Cake\Event\EventManager;
use DebugKit\DebugPanel;
use RuntimeException;

/**
 * Registry object for panels.
 *
 * @extends \Cake\Core\ObjectRegistry<\DebugKit\DebugPanel>
 * @implements \Cake\Event\EventDispatcherInterface<object>
 */
class PanelRegistry extends ObjectRegistry implements EventDispatcherInterface
{
    /**
     * @use \Cake\Event\EventDispatcherTrait<object>
     */
    use EventDispatcherTrait;

    /**
     * Constructor
     *
     * @param \Cake\Event\EventManager $eventManager Event Manager that panels should bind to.
     *   Typically this is the global manager.
     */
    public function __construct(EventManager $eventManager)
    {
        $this->setEventManager($eventManager);
    }

    /**
     * Resolve a panel class name.
     *
     * Part of the template method for Cake\Utility\ObjectRegistry::load()
     *
     * @param string $class Partial class name to resolve.
     * @return string|null Either the correct class name, null if the class is not found.
     */
    protected function _resolveClassName(string $class): ?string
    {
        return App::className($class, 'Panel', 'Panel');
    }

    /**
     * Throws an exception when a component is missing.
     *
     * Part of the template method for Cake\Utility\ObjectRegistry::load()
     *
     * @param string $class The classname that is missing.
     * @param string $plugin The plugin the component is missing in.
     * @return void
     * @throws \RuntimeException
     */
    protected function _throwMissingClassError(string $class, ?string $plugin): void
    {
        throw new RuntimeException(sprintf("Unable to find '%s' panel.", $class));
    }

    /**
     * Create the panels instance.
     *
     * Part of the template method for Cake\Utility\ObjectRegistry::load()
     *
     * @param \DebugKit\DebugPanel|class-string<\DebugKit\DebugPanel> $class The classname to create.
     * @param string $alias The alias of the panel.
     * @param array $config An array of config to use for the panel.
     * @return \DebugKit\DebugPanel The constructed panel class.
     */
    protected function _create(object|string $class, string $alias, array $config): DebugPanel
    {
        if (is_string($class)) {
            $instance = new $class($this, $config);
        } else {
            $instance = $class;
        }

        $this->getEventManager()->on($instance);

        return $instance;
    }
}
