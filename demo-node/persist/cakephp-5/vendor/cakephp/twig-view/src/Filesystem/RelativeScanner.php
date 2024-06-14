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

/**
 * Class RelativeScanner.
 *
 * @internal
 */
final class RelativeScanner
{
    /**
     * Return all sections (app & plugins) with an Template directory.
     *
     * @param array<string> $extensions Template extensions to search
     * @return array
     */
    public static function all(array $extensions): array
    {
        return static::strip(Scanner::all($extensions));
    }

    /**
     * Return all templates for a given plugin.
     *
     * @param string $plugin The plugin to find all templates for.
     * @param array<string> $extensions Template extensions to search
     * @return mixed
     */
    public static function plugin(string $plugin, array $extensions): mixed
    {
        return static::strip([
            $plugin => Scanner::plugin($plugin, $extensions),
        ])[$plugin];
    }

    /**
     * Strip the absolute path of template's paths for all given sections.
     *
     * @param array $sections Sections to iterate over.
     * @return array
     */
    protected static function strip(array $sections): array
    {
        foreach ($sections as $section => $paths) {
            $sections[$section] = static::stripAbsolutePath($paths, $section === 'APP' ? null : $section);
        }

        return $sections;
    }

    /**
     * Strip the absolute path of template's paths.
     *
     * @param array $paths Paths to strip.
     * @param string|null $plugin Hold plugin name or null for App.
     * @return array
     */
    protected static function stripAbsolutePath(array $paths, ?string $plugin = null): array
    {
        if ($plugin === null) {
            $allPaths = App::path('templates');
        } else {
            $allPaths = [Plugin::templatePath($plugin)];
        }

        foreach ($allPaths as $templatesPath) {
            array_walk($paths, function (&$path) use ($templatesPath): void {
                if (substr($path, 0, strlen($templatesPath)) === $templatesPath) {
                    $path = substr($path, strlen($templatesPath));
                }
            });
        }

        return $paths;
    }
}
