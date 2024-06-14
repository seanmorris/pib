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

use Cake\I18n\Number;
use DebugKit\DebugMemory;
use DebugKit\DebugPanel;
use DebugKit\DebugTimer;

/**
 * Provides debug information on all timers used in a request.
 */
class TimerPanel extends DebugPanel
{
    /**
     * Return an array of events to listen to.
     *
     * @return array<string, mixed>
     */
    public function implementedEvents(): array
    {
        $before = function ($name) {
            return function () use ($name): void {
                DebugTimer::start($name);
            };
        };
        $after = function ($name) {
            return function () use ($name): void {
                DebugTimer::stop($name);
            };
        };
        $both = function ($name) use ($before, $after) {
            return [
                ['priority' => 0, 'callable' => $before('Event: ' . $name)],
                ['priority' => 999, 'callable' => $after('Event: ' . $name)],
            ];
        };

        return [
            'Controller.initialize' => [
                ['priority' => 0, 'callable' => function (): void {
                    DebugMemory::record('Controller initialization');
                }],
                ['priority' => 0, 'callable' => $before('Event: Controller.initialize')],
                ['priority' => 999, 'callable' => $after('Event: Controller.initialize')],
            ],
            'Controller.startup' => [
                ['priority' => 0, 'callable' => $before('Event: Controller.startup')],
                ['priority' => 999, 'callable' => $after('Event: Controller.startup')],
                ['priority' => 999, 'callable' => function (): void {
                    DebugMemory::record('Controller action start');
                    DebugTimer::start('Controller: action');
                }],
            ],
            'Controller.beforeRender' => [
                ['priority' => 0, 'callable' => function (): void {
                    DebugTimer::stop('Controller: action');
                }],
                ['priority' => 0, 'callable' => $before('Event: Controller.beforeRender')],
                ['priority' => 999, 'callable' => $after('Event: Controller.beforeRender')],
                ['priority' => 999, 'callable' => function (): void {
                    DebugMemory::record('View Render start');
                    DebugTimer::start('View: Render');
                }],
            ],
            'View.beforeRender' => $both('View.beforeRender'),
            'View.afterRender' => $both('View.afterRender'),
            'View.beforeLayout' => $both('View.beforeLayout'),
            'View.afterLayout' => $both('View.afterLayout'),
            'View.beforeRenderFile' => [
                ['priority' => 0, 'callable' => function ($event, $filename): void {
                    DebugTimer::start('Render File: ' . $filename);
                }],
            ],
            'View.afterRenderFile' => [
                ['priority' => 0, 'callable' => function ($event, $filename): void {
                    DebugTimer::stop('Render File: ' . $filename);
                }],
            ],
            'Controller.shutdown' => [
                ['priority' => 0, 'callable' => $before('Event: Controller.shutdown')],
                ['priority' => 0, 'callable' => function (): void {
                    DebugTimer::stop('View: Render');
                    DebugMemory::record('Controller shutdown');
                }],
                ['priority' => 999, 'callable' => $after('Event: Controller.shutdown')],
            ],
        ];
    }

    /**
     * Get the data for the panel.
     *
     * @return array
     */
    public function data(): array
    {
        return [
            'requestTime' => DebugTimer::requestTime(),
            'timers' => DebugTimer::getAll(),
            'memory' => DebugMemory::getAll(),
            'peakMemory' => DebugMemory::getPeak(),
        ];
    }

    /**
     * Get the summary for the panel.
     *
     * @return string
     */
    public function summary(): string
    {
        $time = Number::precision(DebugTimer::requestTime(), 2) . ' s';
        $memory = Number::toReadableSize(DebugMemory::getPeak());

        return "$time / $memory";
    }
}
