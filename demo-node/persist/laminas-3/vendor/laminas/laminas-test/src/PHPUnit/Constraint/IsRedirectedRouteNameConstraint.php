<?php

declare(strict_types=1);

namespace Laminas\Test\PHPUnit\Constraint;

use Laminas\Http\Header\Location;
use Laminas\Http\PhpEnvironment\Response;
use Laminas\Mvc\Application;
use Laminas\Mvc\Controller\AbstractController;
use Laminas\Mvc\Controller\ControllerManager;
use Laminas\Mvc\Controller\Plugin\Url;
use Laminas\Router\RouteMatch;
use Laminas\Test\PHPUnit\Controller\AbstractHttpControllerTestCase;
use PHPUnit\Framework\Constraint\Constraint;
use RuntimeException;

use function gettype;
use function is_object;
use function is_string;
use function sprintf;

final class IsRedirectedRouteNameConstraint extends Constraint
{
    private AbstractHttpControllerTestCase $activeTestCase;

    public function __construct(AbstractHttpControllerTestCase $activeTestCase)
    {
        $this->activeTestCase = $activeTestCase;
    }

    public function toString(): string
    {
        return 'is the redirected route name';
    }

    /** @param mixed $other */
    public function matches($other): bool
    {
        if (! is_string($other)) {
            return false;
        }

        $httpResponse = $this->activeTestCase->getResponse();
        if (! $httpResponse instanceof Response) {
            return false;
        }

        $headerLocation = $httpResponse->getHeaders()->get('Location');

        if (! $headerLocation instanceof Location) {
            return false;
        }

        $controllerClass = $this->getControllerFullClass();
        $urlPlugin       = $controllerClass->plugin('url');

        if (! $urlPlugin instanceof Url) {
            throw new RuntimeException('Url controller plugin not found; cannot determine if URL matches route');
        }

        return $headerLocation->getFieldValue() === $urlPlugin->fromRoute($other);
    }

    private function getControllerFullClass(): AbstractController
    {
        $application = $this->activeTestCase->getApplication();
        if (! $application instanceof Application) {
            throw new RuntimeException('Invalid application instance/value present in controller');
        }

        $routeMatch = $application->getMvcEvent()->getRouteMatch();
        if (! $routeMatch instanceof RouteMatch) {
            throw new RuntimeException(
                'No RouteMatch instance discovered; cannot determine matched controller class name'
            );
        }

        $controllerIdentifier = $routeMatch->getParam('controller');
        if (! is_string($controllerIdentifier)) {
            throw new RuntimeException('Invalid controller identifier found in route match params');
        }

        $controllerManager = $this->activeTestCase->getApplicationServiceLocator()->get('ControllerManager');
        if (! $controllerManager instanceof ControllerManager) {
            throw new RuntimeException('Invalid ControllerManager found in ServiceManager');
        }

        $controller = $controllerManager->get($controllerIdentifier);
        if (! $controller instanceof AbstractController) {
            throw new RuntimeException(sprintf(
                'Invalid controller pulled from ControllerManager by identifier "%s"; received "%s"',
                $controllerIdentifier,
                is_object($controller) ? $controller::class : gettype($controller)
            ));
        }

        return $controller;
    }
}
