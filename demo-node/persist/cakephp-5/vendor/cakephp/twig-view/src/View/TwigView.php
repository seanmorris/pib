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

namespace Cake\TwigView\View;

use Cake\Core\Configure;
use Cake\Core\Plugin;
use Cake\TwigView\Panel\TwigPanel;
use Cake\TwigView\Twig\Extension;
use Cake\TwigView\Twig\FileLoader;
use Cake\TwigView\Twig\TokenParser;
use Cake\View\Exception\MissingLayoutException;
use Cake\View\Exception\MissingTemplateException;
use Cake\View\View;
use Jasny\Twig\ArrayExtension;
use Jasny\Twig\DateExtension;
use Jasny\Twig\PcreExtension;
use Jasny\Twig\TextExtension;
use RuntimeException;
use Twig\Environment;
use Twig\Extension\DebugExtension;
use Twig\Extension\StringLoaderExtension;
use Twig\Extra\Markdown\DefaultMarkdown;
use Twig\Extra\Markdown\MarkdownExtension;
use Twig\Extra\Markdown\MarkdownInterface;
use Twig\Extra\Markdown\MarkdownRuntime;
use Twig\Loader\LoaderInterface;
use Twig\Profiler\Profile;
use Twig\RuntimeLoader\RuntimeLoaderInterface;

/**
 * Class TwigView.
 */
class TwigView extends View
{
    /**
     * @var \Twig\Environment|null
     */
    protected static ?Environment $twig = null;

    /**
     * @var \Twig\Profiler\Profile|null
     */
    protected static ?Profile $profile = null;

    /**
     * Default config options.
     *
     * Use ViewBuilder::setOption()/setOptions() in your controller to set these options.
     *
     * - `environment` - Array of config you would pass into \Twig\Environment to overwrite the default settings.
     *     See https://twig.symfony.com/doc/3.x/api.html#environment-options.
     * - `markdown` - Set to 'default' to use `DefaultMarkdown` or
     *     provide custom Twig\Extra\Markdown\MarkdownInterface instance.
     *     See https://twig.symfony.com/doc/3.x/filters/markdown_to_html.html.
     *
     * @var array<string, mixed>
     */
    protected array $_defaultConfig = [
        'environment' => [
        ],
        'markdown' => null,
    ];

    /**
     * @inheritDoc
     */
    protected string $_ext = '.twig';

    /**
     * List of extensions searched when loading templates.
     *
     * @var array<string>
     */
    protected array $extensions = [
        '.twig',
    ];

    /**
     * Initialize view.
     *
     * @return void
     */
    public function initialize(): void
    {
        parent::initialize();

        if (static::$twig === null) {
            // Cache instance to avoid re-creating when rendering Cells
            static::$twig = $this->createEnvironment();

            $this->initializeTokenParser();
            $this->initializeExtensions();

            if (Configure::read('debug') && Plugin::isLoaded('DebugKit')) {
                $this->initializeProfiler();
            }
        }

        if (Configure::read('debug') && Plugin::isLoaded('DebugKit')) {
            TwigPanel::setExtensions($this->extensions);
        }
    }

    /**
     * Get Twig Environment instance.
     *
     * @return \Twig\Environment
     */
    public function getTwig(): Environment
    {
        if (static::$twig === null) {
            throw new RuntimeException('Twig Environment instance not created.');
        }

        return static::$twig;
    }

    /**
     * Gets Twig Profile if profiler enabled.
     *
     * @return \Twig\Profiler\Profile|null
     */
    public function getProfile(): ?Profile
    {
        return static::$profile;
    }

    /** Gets the template file extensions.
     *
     * @return array<string>
     */
    public function getExtensions(): array
    {
        return $this->extensions;
    }

    /**
     * Creates the Twig LoaderInterface instance.
     *
     * @return \Twig\Loader\LoaderInterface
     */
    protected function createLoader(): LoaderInterface
    {
        return new FileLoader($this->extensions);
    }

    /**
     * Creates the Twig Environment.
     *
     * @return \Twig\Environment
     */
    protected function createEnvironment(): Environment
    {
        $debug = Configure::read('debug', false);
        $cachePath = CACHE . 'twig_view' . DS;

        $config = $this->getConfig('environment') + [
            'charset' => Configure::read('App.encoding', 'UTF-8'),
            'debug' => $debug,
            'cache' => $debug ? false : $cachePath,
            'strict_variables' => $debug,
        ];

        if ($config['cache'] === true) {
            $config['cache'] = $cachePath;
        }

        $env = new Environment($this->createLoader(), $config);
        // Must add before any templates are rendered so can be updated in _render().
        $env->addGlobal('_view', $this);

        return $env;
    }

    /**
     * Adds custom Twig token parsers.
     *
     * @return void
     */
    protected function initializeTokenParser(): void
    {
        $this->getTwig()->addTokenParser(new TokenParser\LayoutParser());
    }

    // phpcs:disable CakePHP.Commenting.FunctionComment.InvalidReturnVoid

    /**
     * Adds Twig extensions.
     *
     * @return void
     */
    protected function initializeExtensions(): void
    {
        $twig = $this->getTwig();

        // Twig core extensions
        $twig->addExtension(new StringLoaderExtension());

        if (Configure::read('debug', false)) {
            $twig->addExtension(new DebugExtension());
        }

        // CakePHP bridging extensions
        $twig->addExtension(new Extension\ArraysExtension());
        $twig->addExtension(new Extension\BasicExtension());
        $twig->addExtension(new Extension\ConfigureExtension());
        $twig->addExtension(new Extension\I18nExtension());
        $twig->addExtension(new Extension\InflectorExtension());
        $twig->addExtension(new Extension\NumberExtension());
        $twig->addExtension(new Extension\StringsExtension());
        $twig->addExtension(new Extension\TimeExtension());
        $twig->addExtension(new Extension\UtilsExtension());
        $twig->addExtension(new Extension\ViewExtension());

        // Markdown extension
        $markdown = $this->getConfig('markdown');
        if ($markdown !== null) {
            $twig->addExtension(new MarkdownExtension());

            $engine = $markdown === 'default' ? new DefaultMarkdown() : $markdown;
            $twig->addRuntimeLoader(new class ($engine) implements RuntimeLoaderInterface {
                /**
                 * @var \Twig\Extra\Markdown\MarkdownInterface
                 */
                private MarkdownInterface $engine;

                /**
                 * @param \Twig\Extra\Markdown\MarkdownInterface $engine MarkdownInterface instance
                 */
                public function __construct(MarkdownInterface $engine)
                {
                    $this->engine = $engine;
                }

                /**
                 * @param string $class FQCN
                 * @return object|null
                 */
                public function load(string $class): ?object
                {
                    if ($class === MarkdownRuntime::class) {
                        return new MarkdownRuntime($this->engine);
                    }

                    return null;
                }
            });
        }

        // jasny/twig-extensions
        $twig->addExtension(new DateExtension());
        $twig->addExtension(new ArrayExtension());
        $twig->addExtension(new PcreExtension());
        $twig->addExtension(new TextExtension());
    }

    // phpcs:enable

    /**
     * Initializes Twig profiler extension.
     *
     * @return void
     */
    protected function initializeProfiler(): void
    {
        static::$profile = new Profile();
        $this->getTwig()->addExtension(new Extension\ProfilerExtension(static::$profile));
    }

    /**
     * @inheritDoc
     */
    protected function _evaluate(string $templateFile, array $dataForView): string
    {
        // Set _view for each render because Twig Environment is shared between views.
        $this->getTwig()->addGlobal('_view', $this);

        $dataForView = array_merge(
            $dataForView,
            iterator_to_array($this->helpers()->getIterator())
        );

        return $this->getTwig()->load($templateFile)->render($dataForView);
    }

    /**
     * @inheritDoc
     */
    protected function _getTemplateFileName(?string $name = null): string
    {
        foreach ($this->extensions as $extension) {
            $this->_ext = $extension;
            try {
                return parent::_getTemplateFileName($name);
            } catch (MissingTemplateException $exception) {
                $missingException = $exception;
            }
        }

        throw $missingException ?? new MissingTemplateException($name ?? $this->getTemplate());
    }

    /**
     * @inheritDoc
     */
    protected function _getLayoutFileName(?string $name = null): string
    {
        foreach ($this->extensions as $extension) {
            $this->_ext = $extension;
            try {
                return parent::_getLayoutFileName($name);
            } catch (MissingLayoutException $exception) {
                $missingException = $exception;
            }
        }

        throw $missingException ?? new MissingLayoutException($name ?? $this->getLayout());
    }

    /**
     * @inheritDoc
     */
    protected function _getElementFileName(string $name, bool $pluginCheck = true): string|false
    {
        foreach ($this->extensions as $extension) {
            $this->_ext = $extension;
            $result = parent::_getElementFileName($name, $pluginCheck);
            if ($result !== false) {
                return $result;
            }
        }

        return false;
    }
}
