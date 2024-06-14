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
use Twig\TwigFunction;

/**
 * Class I18nExtension.
 */
class I18nExtension extends AbstractExtension
{
    /**
     * Get declared functions.
     *
     * @return array<\Twig\TwigFunction>
     */
    public function getFunctions(): array
    {
        return [
            new TwigFunction('__', 'Cake\I18n\__'),
            new TwigFunction('__n', 'Cake\I18n\__n'),
            new TwigFunction('__d', 'Cake\I18n\__d'),
            new TwigFunction('__dn', 'Cake\I18n\__dn'),
            new TwigFunction('__x', 'Cake\I18n\__x'),
            new TwigFunction('__xn', 'Cake\I18n\__xn'),
            new TwigFunction('__dx', 'Cake\I18n\__dx'),
            new TwigFunction('__dxn', 'Cake\I18n\__dxn'),
        ];
    }
}
