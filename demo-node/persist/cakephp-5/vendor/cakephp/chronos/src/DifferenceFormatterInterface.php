<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Cake\Chronos;

use DateTimeInterface;

/**
 * Interface for formatting differences in text.
 */
interface DifferenceFormatterInterface
{
    /**
     * Get the difference in a human readable format.
     *
     * @param \Cake\Chronos\ChronosDate|\DateTimeInterface $first The datetime to start with.
     * @param \Cake\Chronos\ChronosDate|\DateTimeInterface|null $second The datetime to compare against.
     * @param bool $absolute removes time difference modifiers ago, after, etc
     * @return string The difference between the two days in a human readable format
     */
    public function diffForHumans(
        ChronosDate|DateTimeInterface $first,
        ChronosDate|DateTimeInterface|null $second = null,
        bool $absolute = false
    ): string;
}
