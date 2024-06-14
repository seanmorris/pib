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

use Cake\Event\EventInterface;
use Cake\Http\Response;

/**
 * Dashboard and common DebugKit backend.
 *
 * @property \DebugKit\Model\Table\RequestsTable $Requests
 */
class DashboardController extends DebugKitController
{
    /**
     * Before filter handler.
     *
     * @param \Cake\Event\EventInterface $event The event.
     * @return void
     */
    public function beforeFilter(EventInterface $event): void
    {
        parent::beforeFilter($event);

        $this->viewBuilder()->setLayout('dashboard');
    }

    /**
     * Dashboard.
     *
     * @return void
     * @throws \Cake\Http\Exception\NotFoundException
     */
    public function index(): void
    {
        $requestsModel = $this->fetchTable('DebugKit.Requests');

        $data = [
            'driver' => get_class($requestsModel->getConnection()->getDriver()),
            'rows' => $requestsModel->find()->count(),
        ];

        $this->set('connection', $data);
    }

    /**
     * Reset SQLite DB.
     *
     * @return \Cake\Http\Response|null
     */
    public function reset(): ?Response
    {
        $this->request->allowMethod('post');
        /** @var \DebugKit\Model\Table\RequestsTable $requestsModel */
        $requestsModel = $this->fetchTable('DebugKit.Requests');

        $requestsModel->Panels->deleteAll('1=1');
        $requestsModel->deleteAll('1=1');

        return $this->redirect(['action' => 'index']);
    }
}
