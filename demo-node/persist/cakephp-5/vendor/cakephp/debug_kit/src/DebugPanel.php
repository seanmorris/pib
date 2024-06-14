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
 * @since         DebugKit 0.1
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit;

use Cake\Event\EventInterface;
use Cake\Event\EventListenerInterface;
use Cake\Utility\Inflector;
use function Cake\Core\namespaceSplit;

/**
 * Base class for debug panels.
 *
 * @since         DebugKit 0.1
 */
class DebugPanel implements EventListenerInterface
{
    /**
     * Defines which plugin this panel is from so the element can be located.
     *
     * @var string
     */
    public string $plugin = 'DebugKit';

    /**
     * The data collected about a given request.
     *
     * @var array
     */
    protected array $_data = [];

    /**
     * Get the title for the panel.
     *
     * @return string
     */
    public function title(): string
    {
        // phpcs:ignore SlevomatCodingStandard.Variables.UnusedVariable.UnusedVariable
        [$ns, $name] = namespaceSplit(static::class);
        $name = substr($name, 0, strlen('Panel') * -1);

        return Inflector::humanize(Inflector::underscore($name));
    }

    /**
     * Get the element name for the panel.
     *
     * @return string
     */
    public function elementName(): string
    {
        // phpcs:ignore SlevomatCodingStandard.Variables.UnusedVariable.UnusedVariable
        [$ns, $name] = namespaceSplit(static::class);
        if ($this->plugin) {
            return $this->plugin . '.' . Inflector::underscore($name);
        }

        return Inflector::underscore($name);
    }

    /**
     * Get the data a panel has collected.
     *
     * @return array
     */
    public function data(): array
    {
        return $this->_data;
    }

    /**
     * Get the summary data for a panel.
     *
     * This data is displayed in the toolbar even when the panel is collapsed.
     *
     * @return string
     */
    public function summary(): string
    {
        return '';
    }

    /**
     * Initialize hook method.
     *
     * @return void
     */
    public function initialize(): void
    {
    }

    /**
     * Shutdown callback
     *
     * @param \Cake\Event\EventInterface $event The event.
     * @return void
     */
    public function shutdown(EventInterface $event): void
    {
    }

    /**
     * Get the events this panels supports.
     *
     * @return array<string, mixed>
     */
    public function implementedEvents(): array
    {
        return [
            'Controller.shutdown' => 'shutdown',
        ];
    }
}
