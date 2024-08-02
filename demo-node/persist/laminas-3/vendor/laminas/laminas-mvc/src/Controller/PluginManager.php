<?php

namespace Laminas\Mvc\Controller;

use Laminas\Mvc\Controller\Plugin\PluginInterface;
use Laminas\Mvc\Controller\Plugin\AcceptableViewModelSelector;
use Laminas\Mvc\Controller\Plugin\Forward;
use Laminas\Mvc\Controller\Plugin\Layout;
use Laminas\Mvc\Controller\Plugin\Params;
use Laminas\Mvc\Controller\Plugin\Redirect;
use Laminas\Mvc\Controller\Plugin\Url;
use Laminas\Mvc\Controller\Plugin\CreateHttpNotFoundModel;
use Laminas\Mvc\Controller\Plugin\Service\ForwardFactory;
use Laminas\ServiceManager\AbstractPluginManager;
use Laminas\ServiceManager\Exception\InvalidServiceException;
use Laminas\ServiceManager\Factory\InvokableFactory;
use Laminas\Stdlib\DispatchableInterface;

/**
 * Plugin manager implementation for controllers
 *
 * Registers a number of default plugins, and contains an initializer for
 * injecting plugins with the current controller.
 */
class PluginManager extends AbstractPluginManager
{
    /**
     * Plugins must be of this type.
     *
     * @var string
     */
    protected $instanceOf = PluginInterface::class;

    /**
     * @var string[] Default aliases
     */
    protected $aliases = [
        'AcceptableViewModelSelector' => AcceptableViewModelSelector::class,
        'acceptableViewModelSelector' => AcceptableViewModelSelector::class,
        'acceptableviewmodelselector' => AcceptableViewModelSelector::class,
        'Forward'                     => Forward::class,
        'forward'                     => Forward::class,
        'Layout'                      => Layout::class,
        'layout'                      => Layout::class,
        'Params'                      => Params::class,
        'params'                      => Params::class,
        'Redirect'                    => Redirect::class,
        'redirect'                    => Redirect::class,
        'Url'                         => Url::class,
        'url'                         => Url::class,
        'CreateHttpNotFoundModel'     => CreateHttpNotFoundModel::class,
        'createHttpNotFoundModel'     => CreateHttpNotFoundModel::class,
        'createhttpnotfoundmodel'     => CreateHttpNotFoundModel::class,

        // Legacy Zend Framework aliases
        \Zend\Mvc\Controller\Plugin\Forward::class => Forward::class,
        \Zend\Mvc\Controller\Plugin\AcceptableViewModelSelector::class => AcceptableViewModelSelector::class,
        \Zend\Mvc\Controller\Plugin\Layout::class => Layout::class,
        \Zend\Mvc\Controller\Plugin\Params::class => Params::class,
        \Zend\Mvc\Controller\Plugin\Redirect::class => Redirect::class,
        \Zend\Mvc\Controller\Plugin\Url::class => Url::class,
        \Zend\Mvc\Controller\Plugin\CreateHttpNotFoundModel::class => CreateHttpNotFoundModel::class,

        // v2 normalized FQCNs
        'zendmvccontrollerpluginforward' => Forward::class,
        'zendmvccontrollerpluginacceptableviewmodelselector' => AcceptableViewModelSelector::class,
        'zendmvccontrollerpluginlayout' => Layout::class,
        'zendmvccontrollerpluginparams' => Params::class,
        'zendmvccontrollerpluginredirect' => Redirect::class,
        'zendmvccontrollerpluginurl' => Url::class,
        'zendmvccontrollerplugincreatehttpnotfoundmodel' => CreateHttpNotFoundModel::class,
    ];

    /**
     * @var string[]|callable[] Default factories
     */
    protected $factories = [
        Forward::class                     => ForwardFactory::class,
        AcceptableViewModelSelector::class => InvokableFactory::class,
        Layout::class                      => InvokableFactory::class,
        Params::class                      => InvokableFactory::class,
        Redirect::class                    => InvokableFactory::class,
        Url::class                         => InvokableFactory::class,
        CreateHttpNotFoundModel::class     => InvokableFactory::class,

        // v2 normalized names

        'laminasmvccontrollerpluginforward'                     => ForwardFactory::class,
        'laminasmvccontrollerpluginacceptableviewmodelselector' => InvokableFactory::class,
        'laminasmvccontrollerpluginlayout'                      => InvokableFactory::class,
        'laminasmvccontrollerpluginparams'                      => InvokableFactory::class,
        'laminasmvccontrollerpluginredirect'                    => InvokableFactory::class,
        'laminasmvccontrollerpluginurl'                         => InvokableFactory::class,
        'laminasmvccontrollerplugincreatehttpnotfoundmodel'     => InvokableFactory::class,
    ];

    /**
     * @var DispatchableInterface
     */
    protected $controller;

    /**
     * Retrieve a registered instance
     *
     * After the plugin is retrieved from the service locator, inject the
     * controller in the plugin every time it is requested. This is required
     * because a controller can use a plugin and another controller can be
     * dispatched afterwards. If this second controller uses the same plugin
     * as the first controller, the reference to the controller inside the
     * plugin is lost.
     *
     * @param  string     $name
     * @param  null|array $options Options to use when creating the instance.
     * @return DispatchableInterface
     */
    public function get($name, array $options = null)
    {
        $plugin = parent::get($name, $options);
        $this->injectController($plugin);

        return $plugin;
    }

    /**
     * Set controller
     *
     * @return PluginManager
     */
    public function setController(DispatchableInterface $controller)
    {
        $this->controller = $controller;

        return $this;
    }

    /**
     * Retrieve controller instance
     *
     * @return null|DispatchableInterface
     */
    public function getController()
    {
        return $this->controller;
    }

    /**
     * Inject a helper instance with the registered controller
     *
     * @param  object $plugin
     * @return void
     */
    public function injectController($plugin)
    {
        if (! is_object($plugin)) {
            return;
        }
        if (! method_exists($plugin, 'setController')) {
            return;
        }

        $controller = $this->getController();
        if (! $controller instanceof DispatchableInterface) {
            return;
        }

        $plugin->setController($controller);
    }

    /**
     * Validate a plugin
     *
     * {@inheritDoc}
     */
    public function validate($plugin)
    {
        if (! $plugin instanceof $this->instanceOf) {
            throw new InvalidServiceException(sprintf(
                'Plugin of type "%s" is invalid; must implement %s',
                (get_debug_type($plugin)),
                $this->instanceOf
            ));
        }
    }
}
