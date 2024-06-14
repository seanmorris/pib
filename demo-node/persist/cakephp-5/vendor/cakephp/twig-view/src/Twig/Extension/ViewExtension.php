<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
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
 * Class ViewExtension.
 */
class ViewExtension extends AbstractExtension
{
    /**
     * Get declared functions.
     *
     * @return array<\Twig\TwigFunction>
     */
    public function getFunctions(): array
    {
        return [
            new TwigFunction(
                'cell',
                function ($context, string $name, array $data = [], array $options = []) {
                    return $context['_view']->cell($name, $data, $options);
                },
                ['needs_context' => true, 'is_safe' => ['all']]
            ),
            new TwigFunction(
                'element',
                function ($context, string $name, array $data = [], array $options = []) {
                    return $context['_view']->element($name, $data, $options);
                },
                ['needs_context' => true, 'is_safe' => ['all']]
            ),
            new TwigFunction(
                'fetch',
                function ($context, string $name, string $default = '') {
                    return $context['_view']->fetch($name, $default);
                },
                ['needs_context' => true, 'is_safe' => ['all']]
            ),
            new TwigFunction(
                'helper_*_*',
                function ($context, $helper, $method, array $args = []) {
                    return $context['_view']->{$helper}->{$method}(...$args);
                },
                ['needs_context' => true, 'is_variadic' => true, 'is_safe' => ['all']]
            ),
        ];
    }
}
