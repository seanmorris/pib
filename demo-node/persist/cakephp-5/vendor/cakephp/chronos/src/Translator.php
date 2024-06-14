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

/**
 * Basic english only 'translator' for diffForHumans()
 *
 * @internal
 */
class Translator
{
    /**
     * Translation strings.
     *
     * @var array
     */
    public static array $strings = [
        'year' => '1 year',
        'year_plural' => '{count} years',
        'month' => '1 month',
        'month_plural' => '{count} months',
        'week' => '1 week',
        'week_plural' => '{count} weeks',
        'day' => '1 day',
        'day_plural' => '{count} days',
        'hour' => '1 hour',
        'hour_plural' => '{count} hours',
        'minute' => '1 minute',
        'minute_plural' => '{count} minutes',
        'second' => '1 second',
        'second_plural' => '{count} seconds',
        'ago' => '{time} ago',
        'from_now' => '{time} from now',
        'after' => '{time} after',
        'before' => '{time} before',
    ];

    /**
     * Check if a translation key exists.
     *
     * @param string $key The key to check.
     * @return bool Whether or not the key exists.
     */
    public function exists(string $key): bool
    {
        return isset(static::$strings[$key]);
    }

    /**
     * Get a plural message.
     *
     * @param string $key The key to use.
     * @param int $count The number of items in the translation.
     * @param array $vars Additional context variables.
     * @return string The translated message or ''.
     */
    public function plural(string $key, int $count, array $vars = []): string
    {
        if ($count === 1) {
            return $this->singular($key, $vars);
        }

        return $this->singular($key . '_plural', ['count' => $count] + $vars);
    }

    /**
     * Get a singular message.
     *
     * @param string $key The key to use.
     * @param array $vars Additional context variables.
     * @return string The translated message or ''.
     */
    public function singular(string $key, array $vars = []): string
    {
        if (isset(static::$strings[$key])) {
            $varKeys = array_keys($vars);
            foreach ($varKeys as $i => $k) {
                $varKeys[$i] = '{' . $k . '}';
            }

            return str_replace($varKeys, $vars, static::$strings[$key]);
        }

        return '';
    }
}
