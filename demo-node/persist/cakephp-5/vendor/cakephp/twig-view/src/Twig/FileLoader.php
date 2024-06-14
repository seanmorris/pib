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

namespace Cake\TwigView\Twig;

use Cake\Core\App;
use Cake\Core\Plugin;
use Twig\Error\LoaderError;
use Twig\Loader\LoaderInterface;
use Twig\Source;
use function Cake\Core\pluginSplit;

/**
 * Template file loader.
 *
 * Supports loading files from template paths and plugins.
 */
class FileLoader implements LoaderInterface
{
    /**
     * @var array<string>
     */
    protected array $extensions;

    /**
     * @param array<string> $extensions Template file extensions
     */
    public function __construct(array $extensions)
    {
        $this->extensions = $extensions;
    }

    /**
     * @inheritDoc
     */
    public function getSourceContext(string $name): Source
    {
        $path = $this->findTemplate($name);

        return new Source(file_get_contents($path), $name, $path);
    }

    /**
     * @inheritDoc
     */
    public function getCacheKey(string $name): string
    {
        return $this->findTemplate($name);
    }

    /**
     * @inheritDoc
     */
    public function isFresh(string $name, int $time): bool
    {
        $path = $this->findTemplate($name);

        return filemtime($path) < $time;
    }

    /**
     * @inheritDoc
     */
    public function exists(string $name)
    {
        try {
            $this->findTemplate($name);
        } catch (LoaderError $e) {
            return false;
        }

        return true;
    }

    /**
     * @param string $name Template name
     * @return string
     */
    public function findTemplate(string $name): string
    {
        if (file_exists($name)) {
            return $name;
        }

        [$plugin, $name] = pluginSplit($name);
        $name = str_replace('/', DIRECTORY_SEPARATOR, $name);

        if ($plugin !== null) {
            $templatePath = Plugin::templatePath($plugin);
            $path = $this->checkExtensions($templatePath . $name);
            if ($path !== null) {
                return $path;
            }

            $error = "Could not find template `{$name}` in plugin `{$plugin}` in these paths:\n\n"
                . "- `{$templatePath}`\n";
            throw new LoaderError($error);
        }

        foreach (App::path('templates') as $templatePath) {
            $path = $this->checkExtensions($templatePath . $name);
            if ($path !== null) {
                return $path;
            }
        }

        $error = "Could not find template `{$name}` in these paths:\n\n";
        foreach (App::path('templates') as $templatePath) {
            $error .= "- `{$templatePath}`\n";
        }
        throw new LoaderError($error);
    }

    /**
     * Check partial path with all template file extensions to see
     * which file exists.
     *
     * @param string $partial Template path excluding extension
     * @return string|null
     */
    public function checkExtensions(string $partial): ?string
    {
        foreach ($this->extensions as $extension) {
            $path = $partial . $extension;
            if (file_exists($path)) {
                return $path;
            }
        }

        return null;
    }
}
