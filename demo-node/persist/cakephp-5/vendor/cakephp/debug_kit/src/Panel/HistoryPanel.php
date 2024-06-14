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

use Cake\ORM\Locator\LocatorAwareTrait;
use DebugKit\DebugPanel;

/**
 * Provides debug information on previous requests.
 */
class HistoryPanel extends DebugPanel
{
    use LocatorAwareTrait;

    /**
     * Get the data for the panel.
     *
     * @return array
     */
    public function data(): array
    {
        $table = $this->fetchTable('DebugKit.Requests');
        $recent = $table->find('recent');

        return [
            'requests' => $recent->toArray(),
        ];
    }

    /**
     * Gets the initial text for the history summary
     *
     * @return string
     */
    public function summary(): string
    {
        return '0 xhr';
    }
}
