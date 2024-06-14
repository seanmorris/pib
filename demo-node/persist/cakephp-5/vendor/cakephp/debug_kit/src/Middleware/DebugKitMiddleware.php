<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Middleware;

use Cake\Core\Configure;
use Cake\Event\EventManager;
use DebugKit\ToolbarService;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

/**
 * Middleware that enables DebugKit for the layers below.
 */
class DebugKitMiddleware implements MiddlewareInterface
{
    /**
     * @var \DebugKit\ToolbarService
     */
    protected ToolbarService $service;

    /**
     * Constructor
     *
     * @param \DebugKit\ToolbarService $service The configured service, or null.
     */
    public function __construct(?ToolbarService $service = null)
    {
        $service = $service ?: new ToolbarService(EventManager::instance(), (array)Configure::read('DebugKit'));
        $this->service = $service;
    }

    /**
     * Invoke the middleware.
     *
     * DebugKit will augment the response and add the toolbar if possible.
     *
     * @param \Psr\Http\Message\ServerRequestInterface $request The request.
     * @param \Psr\Http\Server\RequestHandlerInterface $handler The request handler.
     * @return \Psr\Http\Message\ResponseInterface A response.
     */
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        if ($this->service->isEnabled()) {
            $this->service->loadPanels();
            $this->service->initializePanels();
        }
        $response = $handler->handle($request);

        if (!$this->service->isEnabled()) {
            return $response;
        }

        /** @psalm-suppress ArgumentTypeCoercion */
        $row = $this->service->saveData($request, $response);
        if (!$row) {
            return $response;
        }

        return $this->service->injectScripts($row, $response);
    }
}
