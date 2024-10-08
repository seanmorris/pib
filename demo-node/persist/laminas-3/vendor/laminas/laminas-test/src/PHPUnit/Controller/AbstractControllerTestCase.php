<?php

declare(strict_types=1);

namespace Laminas\Test\PHPUnit\Controller;

use Exception;
use Laminas\EventManager\ResponseCollection;
use Laminas\EventManager\StaticEventManager;
use Laminas\Http\Request as HttpRequest;
use Laminas\Http\Response;
use Laminas\Mvc\Application;
use Laminas\Mvc\ApplicationInterface;
use Laminas\Mvc\Controller\ControllerManager;
use Laminas\Mvc\MvcEvent;
use Laminas\Router\RouteMatch;
use Laminas\ServiceManager\ServiceManager;
use Laminas\Stdlib\Exception\LogicException;
use Laminas\Stdlib\Parameters;
use Laminas\Stdlib\RequestInterface;
use Laminas\Stdlib\ResponseInterface;
use Laminas\Test\PHPUnit\Constraint\IsCurrentModuleNameConstraint;
use Laminas\Uri\Http as HttpUri;
use Laminas\View\Model\ModelInterface;
use PHPUnit\Framework\Assert;
use PHPUnit\Framework\ExpectationFailedException;
use PHPUnit\Framework\TestCase;
use Throwable;

use function array_diff;
use function array_intersect;
use function array_key_exists;
use function array_merge;
use function assert;
use function class_exists;
use function count;
use function get_class;
use function http_build_query;
use function implode;
use function method_exists;
use function parse_str;
use function sprintf;
use function strrpos;
use function strtolower;
use function substr;
use function trigger_error;

use const E_USER_NOTICE;

abstract class AbstractControllerTestCase extends TestCase
{
    /** @var ApplicationInterface */
    protected $application;

    /** @var array */
    protected $applicationConfig;

    /**
     * Trace error when exception is throwed in application
     *
     * @var bool
     */
    protected $traceError = true;

    /**
     * Reset the application for isolation
     */
    protected function setUp(): void
    {
        $this->reset();
    }

    /**
     * Restore params
     */
    protected function tearDown(): void
    {
        // Prevent memory leak
        $this->reset();
    }

    /**
     * Create a failure message.
     *
     * If $traceError is true, appends exception details, if any.
     *
     * @deprecated (use LaminasContraint instead)
     *
     * @param string $message
     * @return string
     */
    protected function createFailureMessage($message)
    {
        if (! $this->traceError) {
            return $message;
        }

        $exception = $this->getApplication()->getMvcEvent()->getParam('exception');
        if (! $exception instanceof Throwable && ! $exception instanceof Exception) {
            return $message;
        }

        $messages = [];
        do {
            $messages[] = sprintf(
                "Exception '%s' with message '%s' in %s:%d",
                $exception::class,
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine()
            );
        } while ($exception = $exception->getPrevious());

        return sprintf("%s\n\nExceptions raised:\n%s\n", $message, implode("\n\n", $messages));
    }

    /**
     * Get the trace error flag
     *
     * @return bool
     */
    public function getTraceError()
    {
        return $this->traceError;
    }

    /**
     * Set the trace error flag
     *
     * @param  bool                       $traceError
     * @return AbstractControllerTestCase
     */
    public function setTraceError($traceError)
    {
        $this->traceError = $traceError;

        return $this;
    }

    /**
     * Get the application config
     *
     * @return array the application config
     */
    public function getApplicationConfig()
    {
        return $this->applicationConfig;
    }

    /**
     * Set the application config
     *
     * @param  array                      $applicationConfig
     * @return AbstractControllerTestCase
     * @throws LogicException
     */
    public function setApplicationConfig($applicationConfig)
    {
        if (null !== $this->application && null !== $this->applicationConfig) {
            throw new LogicException(
                'Application config can not be set, the application is already built'
            );
        }

        // do not cache module config on testing environment
        if (isset($applicationConfig['module_listener_options']['config_cache_enabled'])) {
            $applicationConfig['module_listener_options']['config_cache_enabled'] = false;
        }
        $this->applicationConfig = $applicationConfig;

        return $this;
    }

    /**
     * Get the application object
     *
     * @return ApplicationInterface
     */
    public function getApplication()
    {
        if ($this->application) {
            return $this->application;
        }
        $appConfig         = $this->applicationConfig;
        $this->application = Application::init($appConfig);

        $events = $this->application->getEventManager();
        $this->application->getServiceManager()->get('SendResponseListener')->detach($events);

        return $this->application;
    }

    /**
     * Get the service manager of the application object
     *
     * @return ServiceManager
     */
    public function getApplicationServiceLocator()
    {
        return $this->getApplication()->getServiceManager();
    }

    /**
     * Get the application request object
     *
     * @return RequestInterface
     */
    public function getRequest()
    {
        return $this->getApplication()->getRequest();
    }

    /**
     * Get the application response object
     *
     * @return Response
     */
    public function getResponse()
    {
        $response = $this->getApplication()->getMvcEvent()->getResponse();

        assert($response instanceof Response);

        return $response;
    }

    /**
     * Set the request URL
     *
     * @param  string                     $url
     * @param  string|null                $method
     * @param  array|null                 $params
     * @return AbstractControllerTestCase
     */
    public function url($url, $method = HttpRequest::METHOD_GET, $params = [])
    {
        $request     = $this->getRequest();
        $query       = $request->getQuery()->toArray();
        $post        = $request->getPost()->toArray();
        $uri         = new HttpUri($url);
        $queryString = $uri->getQuery();

        if ($queryString) {
            parse_str($queryString, $query);
        }

        if ($params) {
            switch ($method) {
                case HttpRequest::METHOD_POST:
                    $post = $params;
                    break;
                case HttpRequest::METHOD_GET:
                case HttpRequest::METHOD_DELETE:
                    $query = array_merge($query, $params);
                    break;
                case HttpRequest::METHOD_PUT:
                case HttpRequest::METHOD_PATCH:
                    $content = http_build_query($params);
                    $request->setContent($content);
                    break;
                default:
                    trigger_error(
                        'Additional params is only supported by GET, POST, PUT and PATCH HTTP method',
                        E_USER_NOTICE
                    );
            }
        }

        $request->setMethod($method);
        $request->setQuery(new Parameters($query));
        $request->setPost(new Parameters($post));
        $request->setUri($uri);
        $request->setRequestUri($uri->getPath());

        return $this;
    }

    /**
     * Dispatch the MVC with a URL
     * Accept a HTTP (simulate a customer action)
     *
     * The URL provided set the request URI in the request object.
     *
     * @param string      $url
     * @param string|null $method
     * @param array|null  $params
     * @param bool        $isXmlHttpRequest
     * @return void
     * @throws Exception
     */
    public function dispatch($url, $method = null, $params = [], $isXmlHttpRequest = false)
    {
        if (
            ! $method
            && $this->getRequest() instanceof HttpRequest
        ) {
            $method = $this->getRequest()->getMethod();
        } elseif (! $method) {
            $method = HttpRequest::METHOD_GET;
        }

        if ($isXmlHttpRequest) {
            $headers = $this->getRequest()->getHeaders();
            $headers->addHeaderLine('X_REQUESTED_WITH', 'XMLHttpRequest');
        }

        $this->url($url, $method, $params);
        $this->getApplication()->run();
    }

    /**
     * Reset the request
     *
     * @param bool $keepPersistence
     * @return AbstractControllerTestCase
     */
    public function reset($keepPersistence = false)
    {
        // force to re-create all components
        $this->application = null;

        // reset server data
        if (! $keepPersistence) {
            // Do not create a global session variable if it doesn't already
            // exist. Otherwise calling this function could mark tests risky,
            // as it changes global state.
            if (array_key_exists('_SESSION', $GLOBALS)) {
                $_SESSION = [];
            }
            $_COOKIE = [];
        }

        $_GET  = [];
        $_POST = [];

        // reset singleton
        if (class_exists(StaticEventManager::class)) {
            StaticEventManager::resetInstance();
        }

        return $this;
    }

    /**
     * Trigger an application event
     *
     * @param  string                                $eventName
     * @return ResponseCollection
     */
    public function triggerApplicationEvent($eventName)
    {
        $events = $this->getApplication()->getEventManager();
        $event  = $this->getApplication()->getMvcEvent();

        if ($eventName !== MvcEvent::EVENT_ROUTE && $eventName !== MvcEvent::EVENT_DISPATCH) {
            return $events->trigger($eventName, $event);
        }

        $shortCircuit = static function ($r) use ($event): bool {
            if ($r instanceof ResponseInterface) {
                return true;
            }

            if ($event->getError()) {
                return true;
            }

            return false;
        };

        $event->setName($eventName);
        return $events->triggerEventUntil($shortCircuit, $event);
    }

    /**
     * Assert modules were loaded with the module manager
     *
     * @param array $modules
     * @return void
     */
    public function assertModulesLoaded(array $modules)
    {
        $moduleManager = $this->getApplicationServiceLocator()->get('ModuleManager');
        $modulesLoaded = $moduleManager->getModules();
        $list          = array_diff($modules, $modulesLoaded);
        if ($list) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Several modules are not loaded "%s"', implode(', ', $list))
            ));
        }
        $this->assertEquals(count($list), 0);
    }

    /**
     * Assert modules were not loaded with the module manager
     *
     * @param array $modules
     * @return void
     */
    public function assertNotModulesLoaded(array $modules)
    {
        $moduleManager = $this->getApplicationServiceLocator()->get('ModuleManager');
        $modulesLoaded = $moduleManager->getModules();
        $list          = array_intersect($modules, $modulesLoaded);
        if ($list) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Several modules WAS not loaded "%s"', implode(', ', $list))
            ));
        }
        $this->assertEquals(count($list), 0);
    }

    /**
     * Retrieve the response status code
     *
     * @return int
     */
    protected function getResponseStatusCode()
    {
        return $this->getResponse()->getStatusCode();
    }

    /**
     * Assert response status code
     *
     * @param int $code
     * @return void
     */
    public function assertResponseStatusCode($code)
    {
        $match = $this->getResponseStatusCode();
        if ($code !== $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Failed asserting response code "%s", actual status code is "%s"', $code, $match)
            ));
        }
        $this->assertEquals($code, $match);
    }

    /**
     * Assert not response status code
     *
     * @param int $code
     * @return void
     */
    public function assertNotResponseStatusCode($code)
    {
        $match = $this->getResponseStatusCode();
        if ($code === $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Failed asserting response code was NOT "%s"', $code)
            ));
        }
        $this->assertNotEquals($code, $match);
    }

    /**
     * Assert the application exception and message
     *
     * @param string $type application exception type
     * @param string|null $message application exception message
     * @psalm-return never
     */
    public function assertApplicationException($type, $message = null)
    {
        $exception = $this->getApplication()->getMvcEvent()->getParam('exception');
        if (! $exception) {
            throw new ExpectationFailedException($this->createFailureMessage(
                'Failed asserting application exception, param "exception" does not exist'
            ));
        }
        if (true === $this->traceError) {
            // set exception as null because we know and have assert the exception
            $this->getApplication()->getMvcEvent()->setParam('exception', null);
        }

        if (! method_exists($this, 'expectException')) {
            // For old PHPUnit 4
            $this->setExpectedException($type, $message);
        } else {
            $this->expectException($type);
            if (! empty($message)) {
                $this->expectExceptionMessage($message);
            }
        }

        throw $exception;
    }

    /**
     * Get the full current controller class name
     *
     * @return string
     */
    protected function getControllerFullClassName()
    {
        return get_class($this->getControllerFullClass());
    }

    /**
     * Get the current controller class
     *
     * @return object
     */
    protected function getControllerFullClass()
    {
        $routeMatch = $this->getApplication()->getMvcEvent()->getRouteMatch();
        if (! $routeMatch) {
            Assert::fail('No route matched');
        }

        $controllerIdentifier = $routeMatch->getParam('controller');
        Assert::assertIsString($controllerIdentifier, 'No string controller identifier discovered in route match');

        $controllerManager = $this->getApplicationServiceLocator()->get('ControllerManager');
        if (! $controllerManager instanceof ControllerManager) {
            Assert::fail('Invalid ControllerManager instance in ServiceManager');
        }

        $controller = $controllerManager->get($controllerIdentifier);
        Assert::assertIsObject(
            $controller,
            sprintf('Did not receive an object back for the controller %s', $controllerIdentifier)
        );

        return $controller;
    }

    /**
     * Assert that the application route match used the given module
     *
     * @param string $module
     * @return void
     */
    public function assertModuleName($module)
    {
        self::assertThat($module, new IsCurrentModuleNameConstraint($this));
    }

    /**
     * Assert that the application route match used NOT the given module
     *
     * @param string $module
     * @return void
     */
    public function assertNotModuleName($module)
    {
        self::assertThat(
            $module,
            self::logicalNot(new IsCurrentModuleNameConstraint($this))
        );
    }

    /**
     * Assert that the application route match used the given controller class
     *
     * @param string $controller
     * @return void
     */
    public function assertControllerClass($controller)
    {
        $controllerClass = $this->getControllerFullClassName();
        $match           = substr($controllerClass, strrpos($controllerClass, '\\') + 1);
        $match           = strtolower($match);
        $controller      = strtolower($controller);
        if ($controller !== $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Failed asserting controller class "%s", actual controller class is "%s"', $controller, $match)
            ));
        }
        $this->assertEquals($controller, $match);
    }

    /**
     * Assert that the application route match used NOT the given controller class
     *
     * @param string $controller
     * @return void
     */
    public function assertNotControllerClass($controller)
    {
        $controllerClass = $this->getControllerFullClassName();
        $match           = substr($controllerClass, strrpos($controllerClass, '\\') + 1);
        $match           = strtolower($match);
        $controller      = strtolower($controller);
        if ($controller === $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Failed asserting controller class was NOT "%s"', $controller)
            ));
        }
        $this->assertNotEquals($controller, $match);
    }

    /**
     * Assert that the application route match used the given controller name
     *
     * @param string $controller
     * @return void
     */
    public function assertControllerName($controller)
    {
        $routeMatch = $this->getApplication()->getMvcEvent()->getRouteMatch();
        if (! $routeMatch) {
            throw new ExpectationFailedException($this->createFailureMessage('No route matched'));
        }
        $match      = $routeMatch->getParam('controller');
        $match      = strtolower($match);
        $controller = strtolower($controller);
        if ($controller !== $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Failed asserting controller name "%s", actual controller name is "%s"', $controller, $match)
            ));
        }
        $this->assertEquals($controller, $match);
    }

    /**
     * Assert that the application route match used NOT the given controller name
     *
     * @param string $controller
     * @return void
     */
    public function assertNotControllerName($controller)
    {
        $routeMatch = $this->getApplication()->getMvcEvent()->getRouteMatch();
        if (! $routeMatch) {
            throw new ExpectationFailedException($this->createFailureMessage('No route matched'));
        }
        $match      = $routeMatch->getParam('controller');
        $match      = strtolower($match);
        $controller = strtolower($controller);
        if ($controller === $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Failed asserting controller name was NOT "%s"', $controller)
            ));
        }
        $this->assertNotEquals($controller, $match);
    }

    /**
     * Assert that the application route match used the given action
     *
     * @param string $action
     * @return void
     */
    public function assertActionName($action)
    {
        $routeMatch = $this->getApplication()->getMvcEvent()->getRouteMatch();
        if (! $routeMatch) {
            throw new ExpectationFailedException($this->createFailureMessage('No route matched'));
        }
        $match  = $routeMatch->getParam('action');
        $match  = strtolower($match);
        $action = strtolower($action);
        if ($action !== $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Failed asserting action name "%s", actual action name is "%s"', $action, $match)
            ));
        }
        $this->assertEquals($action, $match);
    }

    /**
     * Assert that the application route match used NOT the given action
     *
     * @param string $action
     * @return void
     */
    public function assertNotActionName($action)
    {
        $routeMatch = $this->getApplication()->getMvcEvent()->getRouteMatch();
        if (! $routeMatch) {
            throw new ExpectationFailedException($this->createFailureMessage('No route matched'));
        }
        $match  = $routeMatch->getParam('action');
        $match  = strtolower($match);
        $action = strtolower($action);
        if ($action === $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf('Failed asserting action name was NOT "%s"', $action)
            ));
        }
        $this->assertNotEquals($action, $match);
    }

    /**
     * Assert that the application route match used the given route name
     *
     * @param string $route
     * @return void
     */
    public function assertMatchedRouteName($route)
    {
        $routeMatch = $this->getApplication()->getMvcEvent()->getRouteMatch();
        if (! $routeMatch) {
            throw new ExpectationFailedException($this->createFailureMessage('No route matched'));
        }
        $match = $routeMatch->getMatchedRouteName();
        $match = strtolower($match);
        $route = strtolower($route);
        if ($route !== $match) {
            throw new ExpectationFailedException($this->createFailureMessage(
                sprintf(
                    'Failed asserting matched route name was "%s", actual matched route name is "%s"',
                    $route,
                    $match
                )
            ));
        }
        $this->assertEquals($route, $match);
    }

    /**
     * Assert that the application route match used NOT the given route name
     *
     * @param string $route
     * @return void
     */
    public function assertNotMatchedRouteName($route)
    {
        $application = $this->getApplication();
        if (! $application instanceof Application) {
            Assert::fail(sprintf(
                'Unexpected Application instance composed in test case; must be of type %s',
                Application::class
            ));
        }

        $routeMatch = $application->getMvcEvent()->getRouteMatch();
        if (! $routeMatch) {
            Assert::fail('No route matched');
        }

        $match = $routeMatch->getMatchedRouteName();
        $match = strtolower($match);
        $route = strtolower($route);
        if ($route === $match) {
            Assert::fail(sprintf('Failed asserting route matched was NOT "%s"', $route));
        }

        $this->assertNotEquals($route, $match);
    }

    /**
     * Assert that the application did not match any route
     *
     * @return void
     */
    public function assertNoMatchedRoute()
    {
        $application = $this->getApplication();
        if (! $application instanceof Application) {
            Assert::fail(sprintf(
                'Unexpected Application instance composed in test case; must be of type %s',
                Application::class
            ));
        }

        $routeMatch = $application->getMvcEvent()->getRouteMatch();

        if (! $routeMatch instanceof RouteMatch) {
            Assert::assertTrue(true);
            return;
        }

        $match = $routeMatch->getMatchedRouteName();
        $match = strtolower($match);
        Assert::fail(sprintf(
            'Failed asserting that no route matched, actual matched route name is "%s"',
            $match
        ));
    }

    /**
     * Assert template name
     * Assert that a template was used somewhere in the view model tree
     *
     * @param string $templateName
     * @return void
     */
    public function assertTemplateName($templateName)
    {
        $application = $this->getApplication();
        if (! $application instanceof Application) {
            $this->fail(sprintf(
                'Unexpected Application instance composed in test case; must be of type %s',
                Application::class
            ));
        }

        $viewModel = $application->getMvcEvent()->getViewModel();
        $this->assertTrue($this->searchTemplates($viewModel, $templateName));
    }

    /**
     * Assert not template name
     * Assert that a template was not used somewhere in the view model tree
     *
     * @param string $templateName
     * @return void
     */
    public function assertNotTemplateName($templateName)
    {
        $viewModel = $this->getApplication()->getMvcEvent()->getViewModel();
        $this->assertFalse($this->searchTemplates($viewModel, $templateName));
    }

    /**
     * Recursively search a view model and it's children for the given templateName
     *
     * @param ModelInterface $viewModel
     * @param  string    $templateName
     * @return boolean
     */
    protected function searchTemplates($viewModel, $templateName)
    {
        if ($viewModel->getTemplate($templateName) === $templateName) {
            return true;
        }
        foreach ($viewModel->getChildren() as $child) {
            return $this->searchTemplates($child, $templateName);
        }

        return false;
    }
}
