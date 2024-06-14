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

/**
 * Class InflectorExtension.
 */
class InflectorExtension extends AbstractExtension
{
    /**
     * Get filters for this extension.
     *
     * @return array<\Twig\TwigFilter>
     */
    public function getFilters(): array
    {
        return [
            new TwigFilter('pluralize', 'Cake\Utility\Inflector::pluralize'),
            new TwigFilter('singularize', 'Cake\Utility\Inflector::singularize'),
            new TwigFilter('camelize', 'Cake\Utility\Inflector::camelize'),
            new TwigFilter('underscore', 'Cake\Utility\Inflector::underscore'),
            new TwigFilter('humanize', 'Cake\Utility\Inflector::humanize'),
            new TwigFilter('tableize', 'Cake\Utility\Inflector::tableize'),
            new TwigFilter('classify', 'Cake\Utility\Inflector::classify'),
            new TwigFilter('variable', 'Cake\Utility\Inflector::variable'),
            new TwigFilter('dasherize', 'Cake\Utility\Inflector::dasherize'),
            new TwigFilter('slug', 'Cake\Utility\Text::slug'),
        ];
    }
}
