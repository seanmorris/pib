<?php

use Cake\Routing\Route\DashedRoute;
use Cake\Routing\RouteBuilder;

return function (RouteBuilder $routes) {
    $routes->plugin('DebugKit', ['path' => '/debug-kit'], function (RouteBuilder $routes) {
        $routes->setExtensions('json');
        $routes->setRouteClass(DashedRoute::class);

        $routes->connect(
            '/toolbar/clear-cache',
            ['controller' => 'Toolbar', 'action' => 'clearCache']
        );
        $routes->connect(
            '/toolbar/*',
            ['controller' => 'Requests', 'action' => 'view']
        );
        $routes->connect(
            '/panels/view/latest-history',
            ['controller' => 'Panels', 'action' => 'latestHistory']
        );
        $routes->connect(
            '/panels/view/*',
            ['controller' => 'Panels', 'action' => 'view']
        );
        $routes->connect(
            '/panels/*',
            ['controller' => 'Panels', 'action' => 'index']
        );

        $routes->connect(
            '/composer/check-dependencies',
            ['controller' => 'Composer', 'action' => 'checkDependencies']
        );

        $routes->scope(
            '/mail-preview',
            ['controller' => 'MailPreview'],
            function (RouteBuilder $routes) {
                $routes->connect('/', ['action' => 'index']);
                $routes->connect('/preview', ['action' => 'email']);
                $routes->connect('/preview/*', ['action' => 'email']);
                $routes->connect('/sent/{panel}/{id}', ['action' => 'sent'], ['pass' => ['panel', 'id']]);
            }
        );

        $routes->get('/', ['controller' => 'Dashboard', 'action' => 'index']);
        $routes->get('/dashboard', ['controller' => 'Dashboard', 'action' => 'index']);
        $routes->post('/dashboard/reset', ['controller' => 'Dashboard', 'action' => 'reset']);
    });
};
