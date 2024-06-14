<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         2.8.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\CodeGen;

use Cake\Console\ConsoleIo;

class ImportHelper
{
    /**
     * Normalizes imports included from generated code into [alias => name] format.
     *
     * @param array<string|int, string> $imports Imports
     * @return array<string, string>
     */
    public static function normalize(array $imports): array
    {
        $normalized = [];
        foreach ($imports as $alias => $class) {
            if (is_int($alias)) {
                $last = strrpos($class, '\\', -1);
                if ($last !== false) {
                    $alias = substr($class, strrpos($class, '\\', -1) + 1);
                } else {
                    $alias = $class;
                }
            }

            $normalized[$alias] = $class;
        }

        return $normalized;
    }

    /**
     * Merges imports allowing for duplicates and collisions.
     *
     * @param array<string|int, string> $existing Existing imports to merge into
     * @param array<string|int, string> $imports Imports to merge into existing
     * @param \Cake\Console\ConsoleIo|null $io Used to output warnings on collisions
     * @return array<string, string>
     */
    public static function merge(array $existing, array $imports, ?ConsoleIo $io = null): array
    {
        $existing = static::normalize($existing);
        foreach (static::normalize($imports) as $alias => $class) {
            if (isset($existing[$alias]) && $existing[$alias] !== $class) {
                if ($io) {
                    $io->warning(sprintf(
                        'Import `%s` conflicts with existing import, discarding.',
                        $class
                    ));
                }
                continue;
            }

            $existingAlias = array_search($class, $existing, true);
            if ($existingAlias !== false && $existingAlias != $alias) {
                if ($io) {
                    $io->warning(sprintf(
                        'Import `%s` conflicts with existing import, discarding.',
                        $class
                    ));
                }
                continue;
            }

            $existing[$alias] = $class;
        }

        asort($existing, SORT_STRING | SORT_FLAG_CASE);

        return $existing;
    }
}
