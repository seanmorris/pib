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

namespace Cake\TwigView\Filesystem;

use Cake\Core\App;
use Cake\Core\Plugin;
use FilesystemIterator;
use Iterator;
use RecursiveDirectoryIterator;
use RecursiveIteratorIterator;
use RegexIterator;

/**
 * Class Scanner.
 *
 * @internal
 */
final class Scanner
{
    /**
     * Return all sections (app & plugins) with an Template directory.
     *
     * @param array<string> $extensions Template extensions to search
     * @return array
     */
    public static function all(array $extensions): array
    {
        $sections = [];

        foreach (App::path('templates') as $path) {
            if (is_dir($path)) {
                $sections['APP'] = $sections['APP'] ?? [];
                $sections['APP'] = array_merge($sections['APP'], static::iteratePath($path, $extensions));
            }
        }

        foreach (static::pluginsWithTemplates() as $plugin) {
            $path = Plugin::templatePath($plugin);
            if (is_dir($path)) {
                $sections[$plugin] = $sections[$plugin] ?? [];
                $sections[$plugin] = array_merge($sections[$plugin], static::iteratePath($path, $extensions));
            }
        }

        return static::clearEmptySections($sections);
    }

    /**
     * Return all templates for a given plugin.
     *
     * @param string $plugin The plugin to find all templates for.
     * @param array<string> $extensions Template extensions to search
     * @return array<string>
     */
    public static function plugin(string $plugin, array $extensions): array
    {
        $path = Plugin::templatePath($plugin);

        return static::iteratePath($path, $extensions);
    }

    /**
     * Check sections a remove the ones without anything in them.
     *
     * @param array $sections Sections to check.
     * @return array
     */
    protected static function clearEmptySections(array $sections): array
    {
        array_walk($sections, function ($templates, $index) use (&$sections): void {
            if (count($templates) === 0) {
                unset($sections[$index]);
            }
        });

        return $sections;
    }

    /**
     * Finds all plugins with a Template directory.
     *
     * @return array
     */
    protected static function pluginsWithTemplates(): array
    {
        $plugins = Plugin::loaded();

        array_walk($plugins, function ($plugin, $index) use (&$plugins): void {
            $path = Plugin::templatePath($plugin);

            if (!is_dir($path)) {
                unset($plugins[$index]);
            }
        });

        return $plugins;
    }

    /**
     * Iterage over the given path and return all matching .tpl files in it.
     *
     * @param string $path Path to iterate over.
     * @param array<string> $extensions Template extensions to search
     * @return array<string>
     */
    protected static function iteratePath(string $path, array $extensions): array
    {
        return static::walkIterator(static::setupIterator($path, $extensions));
    }

    /**
     * Setup iterator for given path.
     *
     * @param string $path Path to setup iterator for.
     * @param array<string> $extensions Template extensions to search
     * @return \Iterator
     */
    protected static function setupIterator(string $path, array $extensions): Iterator
    {
        $extPattern = '(?:' . implode('|', array_map('preg_quote', $extensions)) . ')';

        return new RegexIterator(new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator(
                $path,
                FilesystemIterator::KEY_AS_PATHNAME |
                FilesystemIterator::CURRENT_AS_FILEINFO |
                FilesystemIterator::SKIP_DOTS
            ),
            RecursiveIteratorIterator::CHILD_FIRST,
            RecursiveIteratorIterator::CATCH_GET_CHILD
        ), '/.+' . $extPattern . '$/', RegexIterator::GET_MATCH);
    }

    /**
     * Walk over the iterator and compile all templates.
     *
     * @param \Iterator $iterator Iterator to walk.
     * @return array<string>
     */
    protected static function walkIterator(Iterator $iterator): array
    {
        $items = [];

        $array = iterator_to_array($iterator);
        uasort($array, function ($a, $b) {
            if ($a == $b) {
                return 0;
            }

            return $a < $b ? -1 : 1;
        });

        foreach ($array as $paths) {
            foreach ($paths as $path) {
                $items[] = $path;
            }
        }

        return $items;
    }
}
