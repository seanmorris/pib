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
 * Class StringsExtension.
 */
class StringsExtension extends AbstractExtension
{
    /**
     * Get declared filters.
     *
     * @return array<\Twig\TwigFilter>
     */
    public function getFilters(): array
    {
        return [
            new TwigFilter('substr', 'substr'),
            new TwigFilter('tokenize', 'Cake\Utility\Text::tokenize'),
            new TwigFilter('insert', 'Cake\Utility\Text::insert'),
            new TwigFilter('cleanInsert', 'Cake\Utility\Text::cleanInsert'),
            new TwigFilter('wrap', 'Cake\Utility\Text::wrap'),
            new TwigFilter('wrapBlock', 'Cake\Utility\Text::wrapBlock'),
            new TwigFilter('wordWrap', 'Cake\Utility\Text::wordWrap'),
            new TwigFilter('highlight', 'Cake\Utility\Text::highlight'),
            new TwigFilter('tail', 'Cake\Utility\Text::tail'),
            new TwigFilter('truncate', 'Cake\Utility\Text::truncate'),
            new TwigFilter('excerpt', 'Cake\Utility\Text::excerpt'),
            new TwigFilter('toList', 'Cake\Utility\Text::toList'),
            new TwigFilter('isMultibyte', 'Cake\Utility\Text::isMultibyte'),
            new TwigFilter('utf8', 'Cake\Utility\Text::utf8'),
            new TwigFilter('ascii', 'Cake\Utility\Text::ascii'),
            new TwigFilter('parseFileSize', 'Cake\Utility\Text::parseFileSize'),
            new TwigFilter('none', function ($string): void {
                return;
            }),
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
            new TwigFunction('uuid', 'Cake\Utility\Text::uuid'),
            new TwigFunction('sprintf', 'sprintf'),
        ];
    }
}
