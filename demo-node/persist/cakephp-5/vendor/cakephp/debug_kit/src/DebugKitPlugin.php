<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         DebugKit 3.15.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit;

use Cake\Console\CommandCollection;
use Cake\Core\BasePlugin;
use Cake\Core\Configure;
use Cake\Core\PluginApplicationInterface;
use Cake\Error\PhpError;
use Cake\Event\EventInterface;
use Cake\Event\EventManager;
use Cake\Http\MiddlewareQueue;
use DebugKit\Command\BenchmarkCommand;
use DebugKit\Middleware\DebugKitMiddleware;
use DebugKit\Panel\DeprecationsPanel;

/**
 * Plugin class for CakePHP plugin collection.
 */
class DebugKitPlugin extends BasePlugin
{
    /**
     * @var \DebugKit\ToolbarService|null
     */
    protected ?ToolbarService $service = null;

    /**
     * Load all the application configuration and bootstrap logic.
     *
     * @param \Cake\Core\PluginApplicationInterface $app The host application
     * @return void
     */
    public function bootstrap(PluginApplicationInterface $app): void
    {
        $service = new ToolbarService(EventManager::instance(), (array)Configure::read('DebugKit'));

        if (!$service->isEnabled()) {
            return;
        }

        $this->service = $service;
        $this->setDeprecationHandler($service);

        // will load `config/bootstrap.php`.
        parent::bootstrap($app);
    }

    /**
     * Add middleware for the plugin.
     *
     * @param \Cake\Http\MiddlewareQueue $middlewareQueue The middleware queue to update.
     * @return \Cake\Http\MiddlewareQueue
     */
    public function middleware(MiddlewareQueue $middlewareQueue): MiddlewareQueue
    {
        // Only insert middleware if Toolbar Service is available (not in phpunit run)
        if ($this->service) {
            $middlewareQueue->insertAt(0, new DebugKitMiddleware($this->service));
        }

        return $middlewareQueue;
    }

    /**
     * Add console commands for the plugin.
     *
     * @param \Cake\Console\CommandCollection $commands The command collection to update
     * @return \Cake\Console\CommandCollection
     */
    public function console(CommandCollection $commands): CommandCollection
    {
        return $commands->add('benchmark', BenchmarkCommand::class);
    }

    /**
     * set deprecation handler
     *
     * @param \DebugKit\ToolbarService $service The toolbar service instance
     * @return void
     */
    public function setDeprecationHandler(ToolbarService $service): void
    {
        if (!empty($service->getConfig('panels')['DebugKit.Deprecations'])) {
            EventManager::instance()->on('Error.beforeRender', function (EventInterface $event, PhpError $error): void {
                $code = $error->getCode();
                if ($code !== E_USER_DEPRECATED && $code !== E_DEPRECATED) {
                    return;
                }
                $file = $error->getFile();
                $line = $error->getLine();

                // Extract the line/file from the message as deprecationWarning
                // will calculate the application frame when generating the message.
                preg_match('/\\n([^\n,]+?), line: (\d+)\\n/', $error->getMessage(), $matches);
                if ($matches) {
                    $file = $matches[1];
                    $line = $matches[2];
                }

                DeprecationsPanel::addDeprecatedError([
                    'code' => $code,
                    'message' => $error->getMessage(),
                    'file' => $file,
                    'line' => $line,
                ]);
                $event->stopPropagation();
            });
        }
    }
}
