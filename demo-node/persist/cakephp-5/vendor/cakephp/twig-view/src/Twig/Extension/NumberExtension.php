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

use Twig\Extension\AbstractExtension;
use Twig\TwigFilter;
use Twig\TwigFunction;

/**
 * Class NumberExtension.
 */
class NumberExtension extends AbstractExtension
{
    /**
     * Get declared functions.
     *
     * @return array<\Twig\TwigFilter>
     */
    public function getFilters(): array
    {
        return [
            new TwigFilter('toReadableSize', 'Cake\I18n\Number::toReadableSize'),
            new TwigFilter('toPercentage', 'Cake\I18n\Number::toPercentage'),
            new TwigFilter('cake_number_format', 'Cake\I18n\Number::format'),
            new TwigFilter('formatDelta', 'Cake\I18n\Number::formatDelta'),
            new TwigFilter('currency', 'Cake\I18n\Number::currency'),
        ];
    }

    /**
     * Get declared functions.
     *
     * @return array<\Twig\TwigFunction>
     */
    public function getFunctions(): array
    {
        return [
            new TwigFunction('defaultCurrency', 'Cake\I18n\Number::getDefaultCurrency'),
        ];
    }
}
