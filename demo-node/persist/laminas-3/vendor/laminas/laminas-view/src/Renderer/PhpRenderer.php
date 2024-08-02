<?php

declare(strict_types=1);

namespace Laminas\View\Renderer;

use ArrayAccess;
use Laminas\Filter\FilterChain;
use Laminas\ServiceManager\ServiceManager;
use Laminas\View\Exception;
use Laminas\View\Helper\HelperInterface;
use Laminas\View\Helper\ViewModel;
use Laminas\View\HelperPluginManager;
use Laminas\View\Model\ModelInterface as Model;
use Laminas\View\Renderer\RendererInterface as Renderer;
use Laminas\View\Resolver\ResolverInterface as Resolver;
use Laminas\View\Resolver\TemplatePathStack;
use Laminas\View\Variables;
use Throwable;
use Traversable;

use function array_key_exists;
use function array_pop;
use function assert;
use function call_user_func_array;
use function class_exists;
use function extract;
use function get_debug_type;
use function gettype;
use function is_array;
use function is_callable;
use function is_object;
use function is_string;
use function method_exists;
use function ob_end_clean;
use function ob_get_clean;
use function ob_start;
use function sprintf;

// @codingStandardsIgnoreStart
/**
 * Class for Laminas\View\Strategy\PhpRendererStrategy to help enforce private constructs.
 *
 * Note: all private variables in this class are prefixed with "__". This is to
 * mark them as part of the internal implementation, and thus prevent conflict
 * with variables injected into the renderer.
 *
 * Convenience methods for build in helpers (@see __call):
 *
 * @method string asset($asset)
 * @method string|null basePath($file = null)
 * @method \Laminas\View\Helper\Cycle cycle(array $data = array(), $name = \Laminas\View\Helper\Cycle::DEFAULT_NAME)
 * @method \Laminas\View\Helper\DeclareVars declareVars()
 * @method \Laminas\View\Helper\Doctype doctype($doctype = null)
 * @method mixed escapeCss($value, $recurse = \Laminas\View\Helper\Escaper\AbstractHelper::RECURSE_NONE)
 * @method mixed escapeHtml($value, $recurse = \Laminas\View\Helper\Escaper\AbstractHelper::RECURSE_NONE)
 * @method mixed escapeHtmlAttr($value, $recurse = \Laminas\View\Helper\Escaper\AbstractHelper::RECURSE_NONE)
 * @method mixed escapeJs($value, $recurse = \Laminas\View\Helper\Escaper\AbstractHelper::RECURSE_NONE)
 * @method mixed escapeUrl($value, $recurse = \Laminas\View\Helper\Escaper\AbstractHelper::RECURSE_NONE)
 * @method \Laminas\View\Helper\FlashMessenger flashMessenger($namespace = null)
 * @method \Laminas\View\Helper\Gravatar gravatar($email = "", $options = array(), $attribs = array())
 * @method \Laminas\View\Helper\HeadLink headLink(array $attributes = null, $placement = \Laminas\View\Helper\Placeholder\Container\AbstractContainer::APPEND)
 * @method \Laminas\View\Helper\HeadMeta headMeta($content = null, $keyValue = null, $keyType = 'name', $modifiers = array(), $placement = \Laminas\View\Helper\Placeholder\Container\AbstractContainer::APPEND)
 * @method \Laminas\View\Helper\HeadScript headScript($mode = \Laminas\View\Helper\HeadScript::FILE, $spec = null, $placement = 'APPEND', array $attrs = array(), $type = 'text/javascript')
 * @method \Laminas\View\Helper\HeadStyle headStyle($content = null, $placement = 'APPEND', $attributes = array())
 * @method \Laminas\View\Helper\HeadTitle headTitle($title = null, $setType = null)
 * @method \Laminas\View\HtmlAttributesSet htmlAttributes(iterable $attributes = [])
 * @method string htmlFlash($data, array $attribs = array(), array $params = array(), $content = null)
 * @method string htmlList(array $items, $ordered = false, $attribs = false, $escape = true)
 * @method string htmlObject($data = null, $type = null, array $attribs = array(), array $params = array(), $content = null)
 * @method string htmlPage($data, array $attribs = array(), array $params = array(), $content = null)
 * @method string htmlQuicktime($data, array $attribs = array(), array $params = array(), $content = null)
 * @method mixed|null identity()
 * @method \Laminas\View\Helper\InlineScript inlineScript($mode = \Laminas\View\Helper\HeadScript::FILE, $spec = null, $placement = 'APPEND', array $attrs = array(), $type = 'text/javascript')
 * @method string|void json($data, array $jsonOptions = array())
 * @method \Laminas\View\Helper\Layout layout($template = null)
 * @method \Laminas\View\Helper\Navigation navigation($container = null)
 * @method string paginationControl(\Laminas\Paginator\Paginator $paginator = null, $scrollingStyle = null, $partial = null, $params = null)
 * @method string|\Laminas\View\Helper\Partial partial($name = null, $values = null)
 * @method string partialLoop($name = null, $values = null)
 * @method \Laminas\View\Helper\Placeholder\Container\AbstractContainer placeholder($name = null)
 * @method string renderChildModel($child)
 * @method void renderToPlaceholder($script, $placeholder)
 * @method string serverUrl($requestUri = null)
 * @method string url($name = null, array $params = array(), $options = array(), $reuseMatchedParams = false)
 * @method \Laminas\View\Helper\ViewModel viewModel()
 * @method \Laminas\View\Helper\Navigation\Breadcrumbs breadCrumbs($container = null)
 * @method \Laminas\View\Helper\Navigation\Links links($container = null)
 * @method \Laminas\View\Helper\Navigation\Menu menu($container = null)
 * @method \Laminas\View\Helper\Navigation\Sitemap sitemap($container = null)
 * @method string gravatarImage(string $emailAddress, int $imageSize = 80, array $imageAttributes = [], string $defaultImage = 'mm', string $rating = 'g')
 */
class PhpRenderer implements Renderer, TreeRendererInterface
{
    /**
     * @var string Rendered content
     */
    private $__content = '';

    /**
     * @var bool Whether to render trees of view models
     */
    private $__renderTrees = false;

    /**
     * Template being rendered
     *
     * @var null|string
     */
    private $__template;

    /**
     * Queue of templates to render
     * @var array
     */
    private $__templates = [];

    /**
     * Template resolver
     *
     * @var Resolver|null
     */
    private $__templateResolver;

    /**
     * Script file name to execute
     *
     * @var string|null
     */
    private $__file;

    /**
     * Helper plugin manager
     *
     * @var HelperPluginManager|null
     */
    private $__helpers;

    /**
     * @var FilterChain|null
     */
    private $__filterChain;

    /**
     * @var Variables|null
     */
    private $__vars;

    /**
     * @var array Temporary variable stack; used when variables passed to render()
     */
    private $__varsCache = [];
    // @codingStandardsIgnoreEnd

    /**
     * @todo handle passing helper plugin manager, options
     * @todo handle passing filter chain, options
     * @todo handle passing variables object, options
     * @todo handle passing resolver object, options
     * @param array $config Configuration key-value pairs.
     */
    public function __construct($config = [])
    {
        $this->init();
    }

    /**
     * Return the template engine object
     *
     * Returns the object instance, as it is its own template engine
     *
     * @return PhpRenderer
     */
    public function getEngine()
    {
        return $this;
    }

    /**
     * Allow custom object initialization when extending PhpRenderer
     *
     * Triggered by {@link __construct() the constructor} as its final action.
     *
     * @return void
     */
    public function init()
    {
    }

    /**
     * Set script resolver
     *
     * @return PhpRenderer
     * @throws Exception\InvalidArgumentException
     */
    public function setResolver(Resolver $resolver)
    {
        $this->__templateResolver = $resolver;
        return $this;
    }

    /**
     * Retrieve template name or template resolver
     *
     * @param  null|string $name
     * @return string|Resolver
     */
    public function resolver($name = null)
    {
        if (null === $this->__templateResolver) {
            $this->setResolver(new TemplatePathStack());
        }

        if (null !== $name) {
            return $this->__templateResolver->resolve($name, $this);
        }

        return $this->__templateResolver;
    }

    /**
     * Set variable storage
     *
     * Expects either an array, or an object implementing ArrayAccess.
     *
     * @param  array<string, mixed>|ArrayAccess<string, mixed> $variables
     * @return PhpRenderer
     * @throws Exception\InvalidArgumentException
     */
    public function setVars($variables)
    {
        if (! is_array($variables) && ! $variables instanceof ArrayAccess) {
            throw new Exception\InvalidArgumentException(sprintf(
                'Expected array or ArrayAccess object; received "%s"',
                get_debug_type($variables),
            ));
        }

        // Enforce a Variables container
        if (! $variables instanceof Variables) {
            $variablesAsArray = [];
            foreach ($variables as $key => $value) {
                $variablesAsArray[$key] = $value;
            }
            $variables = new Variables($variablesAsArray);
        }

        $this->__vars = $variables;
        return $this;
    }

    /**
     * Get a single variable, or all variables
     *
     * @param string|null $key
     * @return ($key is null ? Variables : mixed)
     */
    public function vars($key = null)
    {
        if (null === $this->__vars) {
            $this->setVars(new Variables());
        }

        assert($this->__vars !== null);

        if (null === $key) {
            return $this->__vars;
        }
        return $this->__vars[$key];
    }

    /**
     * Get a single variable
     *
     * @param string $key
     * @return mixed
     */
    public function get($key)
    {
        if (null === $this->__vars) {
            $this->setVars(new Variables());
        }

        return $this->__vars[$key];
    }

    /**
     * Overloading: proxy to Variables container
     *
     * @param  string $name
     * @return mixed
     */
    public function __get($name)
    {
        $vars = $this->vars();
        return $vars[$name];
    }

    /**
     * Overloading: proxy to Variables container
     *
     * @param  string $name
     * @param  mixed $value
     * @return void
     */
    public function __set($name, $value)
    {
        $vars        = $this->vars();
        $vars[$name] = $value;
    }

    /**
     * Overloading: proxy to Variables container
     *
     * @param  string $name
     * @return bool
     */
    public function __isset($name)
    {
        $vars = $this->vars();
        return isset($vars[$name]);
    }

    /**
     * Overloading: proxy to Variables container
     *
     * @param  string $name
     * @return void
     */
    public function __unset($name)
    {
        $vars = $this->vars();
        if (! isset($vars[$name])) {
            return;
        }
        unset($vars[$name]);
    }

    /**
     * Set helper plugin manager instance
     *
     * @param  string|HelperPluginManager $helpers
     * @return PhpRenderer
     * @throws Exception\InvalidArgumentException
     */
    public function setHelperPluginManager($helpers)
    {
        if (is_string($helpers)) {
            if (! class_exists($helpers)) {
                throw new Exception\InvalidArgumentException(sprintf(
                    'Invalid helper helpers class provided (%s)',
                    $helpers
                ));
            }
            $helpers = new $helpers(new ServiceManager());
        }
        if (! $helpers instanceof HelperPluginManager) {
            throw new Exception\InvalidArgumentException(sprintf(
                'Helper helpers must extend Laminas\View\HelperPluginManager; got type "%s" instead',
                is_object($helpers) ? $helpers::class : gettype($helpers)
            ));
        }
        $helpers->setRenderer($this);
        $this->__helpers = $helpers;

        return $this;
    }

    /**
     * Get helper plugin manager instance
     *
     * @return HelperPluginManager
     */
    public function getHelperPluginManager()
    {
        $pluginManager = $this->__helpers;

        if (! $pluginManager instanceof HelperPluginManager) {
            $pluginManager = new HelperPluginManager(new ServiceManager());
            $this->setHelperPluginManager($pluginManager);
        }

        return $pluginManager;
    }

    /**
     * Get plugin instance
     *
     * @template T
     * @param  string|class-string<T> $name Name of plugin to return
     * @param  null|array $options Options to pass to plugin constructor (if not already instantiated)
     * @return ($name is class-string ? T : HelperInterface|callable)
     */
    public function plugin($name, ?array $options = null)
    {
        return $this->getHelperPluginManager()->get($name, $options);
    }

    /**
     * Overloading: proxy to helpers
     *
     * Proxies to the attached plugin manager to retrieve, return, and potentially
     * execute helpers.
     *
     * * If the helper does not define __invoke, it will be returned
     * * If the helper does define __invoke, it will be called as a functor
     *
     * @param  string $method
     * @param  array $argv
     * @return HelperInterface|callable|mixed
     */
    public function __call($method, $argv)
    {
        /** @psalm-suppress MixedAssignment $plugin */
        $plugin = $this->plugin($method);

        if (is_callable($plugin)) {
            return call_user_func_array($plugin, $argv);
        }

        return $plugin;
    }

    /**
     * Set filter chain
     *
     * @return PhpRenderer
     */
    public function setFilterChain(FilterChain $filters)
    {
        $this->__filterChain = $filters;
        return $this;
    }

    /**
     * Retrieve filter chain for post-filtering script content
     *
     * @return FilterChain
     */
    public function getFilterChain()
    {
        if (null === $this->__filterChain) {
            $this->__filterChain = new FilterChain();
        }
        return $this->__filterChain;
    }

    /**
     * Processes a view script and returns the output.
     *
     * @param  string|Model $nameOrModel Either the template to use, or a
     *                                   ViewModel. The ViewModel must have the
     *                                   template as an option in order to be
     *                                   valid.
     * @param  null|array|Traversable $values Values to use when rendering. If none
     *                                provided, uses those in the composed
     *                                variables container.
     * @return string The script output.
     * @throws Exception\DomainException If a ViewModel is passed, but does not
     *                                   contain a template option.
     * @throws Exception\InvalidArgumentException If the values passed are not
     *                                            an array or ArrayAccess object.
     * @throws Exception\RuntimeException If the template cannot be rendered.
     */
    public function render($nameOrModel, $values = null)
    {
        if ($nameOrModel instanceof Model) {
            $model       = $nameOrModel;
            $nameOrModel = $model->getTemplate();
            if (empty($nameOrModel)) {
                throw new Exception\DomainException(sprintf(
                    '%s: received View Model argument, but template is empty',
                    __METHOD__
                ));
            }
            $options = $model->getOptions();
            foreach ($options as $setting => $value) {
                $method = 'set' . $setting;
                if (method_exists($this, $method)) {
                    $this->$method($value);
                }
                unset($method, $setting, $value);
            }
            unset($options);

            // Give view model awareness via ViewModel helper
            $helper = $this->plugin(ViewModel::class);
            $helper->setCurrent($model);

            $values = $model->getVariables();
            unset($model);
        }

        // find the script file name using the parent private method
        $this->addTemplate($nameOrModel);
        unset($nameOrModel); // remove $name from local scope

        $this->__varsCache[] = $this->vars();

        if (null !== $values) {
            $this->setVars($values);
        }
        unset($values);

        // @codingStandardsIgnoreStart
        /**
         * extract all assigned vars (pre-escaped), but not 'this'.
         * assigns to a double-underscored variable, to prevent naming collisions
         */
        $__vars = $this->vars()->getArrayCopy();
        if (array_key_exists('this', $__vars)) {
            unset($__vars['this']);
        }
        extract($__vars);
        unset($__vars); // remove $__vars from local scope
        // @codingStandardsIgnoreEnd

        $this->__content = '';
        while ($this->__template = array_pop($this->__templates)) {
            $this->__file = $this->resolver($this->__template);
            if (! is_string($this->__file)) {
                throw new Exception\RuntimeException(sprintf(
                    '%s: Unable to render template "%s"; resolver could not resolve to a file',
                    __METHOD__,
                    $this->__template
                ));
            }
            try {
                ob_start();
                $includeReturn   = include $this->__file;
                $this->__content = ob_get_clean();
            } catch (Throwable $ex) {
                ob_end_clean();
                throw $ex;
            }

            if ($includeReturn === false && $this->__content === '') {
                throw new Exception\UnexpectedValueException(sprintf(
                    '%s: Unable to render template "%s"; file include failed',
                    __METHOD__,
                    $this->__file
                ));
            }
        }

        $this->setVars(array_pop($this->__varsCache));

        if ($this->__filterChain instanceof FilterChain) {
            return $this->__filterChain->filter($this->__content); // filter output
        }

        return $this->__content;
    }

    /**
     * Set flag indicating whether or not we should render trees of view models
     *
     * If set to true, the View instance will not attempt to render children
     * separately, but instead pass the root view model directly to the PhpRenderer.
     * It is then up to the developer to render the children from within the
     * view script.
     *
     * @param  bool $renderTrees
     * @return PhpRenderer
     */
    public function setCanRenderTrees($renderTrees)
    {
        $this->__renderTrees = (bool) $renderTrees;
        return $this;
    }

    /**
     * Can we render trees, or are we configured to do so?
     *
     * @return bool
     */
    public function canRenderTrees()
    {
        return $this->__renderTrees;
    }

    /**
     * Add a template to the stack
     *
     * @param  string $template
     * @return PhpRenderer
     */
    public function addTemplate($template)
    {
        $this->__templates[] = $template;
        return $this;
    }

    /**
     * Make sure View variables are cloned when the view is cloned.
     *
     * @return void
     */
    public function __clone()
    {
        $this->__vars = clone $this->vars();
    }
}
