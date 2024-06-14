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
 * @since         DebugKit 2.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit;

use Cake\Error\Debugger;

/**
 * Contains methods for Profiling memory usage.
 */
class DebugMemory
{
    /**
     * An array of recorded memory use points.
     *
     * @var array
     */
    protected static array $_points = [];

    /**
     * Get current memory usage
     *
     * @return int number of bytes ram currently in use. 0 if memory_get_usage() is not available.
     */
    public static function getCurrent(): int
    {
        return memory_get_usage();
    }

    /**
     * Get peak memory use
     *
     * @return int peak memory use (in bytes). Returns 0 if memory_get_peak_usage() is not available
     */
    public static function getPeak(): int
    {
        return memory_get_peak_usage();
    }

    /**
     * Stores a memory point in the internal tracker.
     * Takes a optional message name which can be used to identify the memory point.
     * If no message is supplied a debug_backtrace will be done to identify the memory point.
     *
     * @param string $message Message to identify this memory point.
     * @return bool
     */
    public static function record(?string $message = null): bool
    {
        $memoryUse = self::getCurrent();
        if (!$message) {
            $trace = debug_backtrace();
            $file = $trace[0]['file'] ?? 'unknown file';
            $line = $trace[0]['line'] ?? 'n/a';
            $message = Debugger::trimPath($file) . ' line ' . $line;
        }
        if (isset(self::$_points[$message])) {
            $originalMessage = $message;
            $i = 1;
            while (isset(self::$_points[$message])) {
                $i++;
                $message = $originalMessage . ' #' . $i;
            }
        }
        self::$_points[$message] = $memoryUse;

        return true;
    }

    /**
     * Get all the stored memory points
     *
     * @param bool $clear Whether you want to clear the memory points as well. Defaults to false.
     * @return array Array of memory marks stored so far.
     */
    public static function getAll(bool $clear = false): array
    {
        $marks = self::$_points;
        if ($clear) {
            self::$_points = [];
        }

        return $marks;
    }

    /**
     * Clear out any existing memory points
     *
     * @return void
     */
    public static function clear(): void
    {
        self::$_points = [];
    }
}
