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

namespace Cake\TwigView\Twig\Extension;

use Cake\I18n\DateTime;
use Twig\Extension\AbstractExtension;
use Twig\TwigFunction;

/**
 * Class TimeExtension.
 */
class TimeExtension extends AbstractExtension
{
    /**
     * Get declared functions.
     *
     * @return array<\Twig\TwigFunction>
     */
    public function getFunctions(): array
    {
        return [
            new TwigFunction('time', function ($time = null, $timezone = null) {
                return new DateTime($time, $timezone);
            }),
            new TwigFunction('timezones', 'Cake\I18n\DateTime::listTimezones'),
        ];
    }
}
