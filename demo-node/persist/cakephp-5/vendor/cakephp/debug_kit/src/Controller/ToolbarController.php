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
namespace DebugKit\Controller;

use Cake\Cache\Cache;
use Cake\Http\Exception\NotFoundException;
use Cake\View\JsonView;

/**
 * Provides utility features need by the toolbar.
 */
class ToolbarController extends DebugKitController
{
    /**
     * @inheritDoc
     */
    public function initialize(): void
    {
        parent::initialize();

        $this->viewBuilder()->setClassName(JsonView::class);
    }

    /**
     * Clear a named cache.
     *
     * @return void
     * @throws \Cake\Http\Exception\NotFoundException
     */
    public function clearCache(): void
    {
        $this->request->allowMethod('post');
        $name = $this->request->getData('name');
        if (!$name) {
            throw new NotFoundException('Invalid cache engine name.');
        }
        $success = Cache::clear($name);
        $message = $success ?
            sprintf('%s cache cleared.', $name) :
            sprintf('%s cache could not be cleared.', $name);
        $this->set(compact('success', 'message'));
        $this->viewBuilder()->setOption('serialize', ['success', 'message']);
    }
}
