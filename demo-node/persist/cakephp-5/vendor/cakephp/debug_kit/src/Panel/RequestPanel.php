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
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Panel;

use Cake\Core\Configure;
use Cake\Error\Debugger;
use Cake\Event\EventInterface;
use DebugKit\DebugPanel;
use Exception;

/**
 * Provides debug information on the Current request params.
 */
class RequestPanel extends DebugPanel
{
    /**
     * Data collection callback.
     *
     * @param \Cake\Event\EventInterface $event The shutdown event.
     * @return void
     */
    public function shutdown(EventInterface $event): void
    {
        /** @var \Cake\Controller\Controller $controller */
        $controller = $event->getSubject();
        $request = $controller->getRequest();
        $maxDepth = Configure::read('DebugKit.maxDepth', 5);

        $attributes = [];
        foreach ($request->getAttributes() as $attr => $value) {
            try {
                serialize($value);
            } catch (Exception $e) {
                $value = "Could not serialize `{$attr}`. It failed with {$e->getMessage()}";
            }
            $attributes[$attr] = Debugger::exportVarAsNodes($value, $maxDepth);
        }

        $this->_data = [
            'params' => $request->getAttribute('params'),
            'attributes' => $attributes,
            'query' => Debugger::exportVarAsNodes($request->getQueryParams(), $maxDepth),
            'data' => Debugger::exportVarAsNodes($request->getData(), $maxDepth),
            'cookie' => Debugger::exportVarAsNodes($request->getCookieParams(), $maxDepth),
            'get' => Debugger::exportVarAsNodes($_GET, $maxDepth),
            'matchedRoute' => $request->getParam('_matchedRoute'),
            'headers' => [
                'response' => headers_sent($file, $line),
                'file' => $file,
                'line' => $line,
            ],
        ];
    }
}
