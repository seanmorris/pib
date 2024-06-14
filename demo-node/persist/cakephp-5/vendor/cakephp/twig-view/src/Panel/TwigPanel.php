<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * Copyright (c) 2014 Cees-Jan Kiewiet
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         1.0.0
 * @license       https://opensource.org/licenses/mit-license.php MIT License
 */

namespace Cake\TwigView\Panel;

use Cake\TwigView\Filesystem\TreeScanner;
use DebugKit\DebugPanel;

class TwigPanel extends DebugPanel
{
    /**
     * @var array<string>
     */
    protected static array $extensions = [];

    /**
     * Plugin name.
     *
     * @var string
     */
    public string $plugin = 'Cake/TwigView';

    /**
     * Get the data for the twig panel.
     *
     * @return array
     */
    public function data(): array
    {
        return [
            'templates' => TreeScanner::all(static::$extensions),
        ];
    }

    /**
     * Sets the template file extensions to search.
     *
     * @param array<string> $extensions Template extensions to search
     * @return void
     */
    public static function setExtensions(array $extensions): void
    {
        static::$extensions = $extensions;
    }
}
