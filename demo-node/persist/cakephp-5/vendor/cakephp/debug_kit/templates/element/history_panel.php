<?php
/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         DebugKit 1.1
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
/**
 * @var \DebugKit\View\AjaxView $this
 * @var \DebugKit\Model\Entity\Panel $panel
 * @var array $requests
 */

use function Cake\Core\h;
?>
<div id="request-history" class="c-history-panel" data-panel-id="<?= $panel->id ?>">
    <?php if (empty($requests)) : ?>
        <p class="c-flash c-flash--warning">
            No requests logged.
            <button type="button" class="js-toolbar-load-panel" data-panel-id="latest-history">
                Reload
            </button>
        </p>
    <?php else : ?>
        <p>
            <?= count($requests) ?> requests available
            <button type="button" class="js-toolbar-load-panel" data-panel-id="latest-history">
                Reload
            </button>
        </p>
        <ul class="c-history-panel__list">
            <li>
                <?php $url = [
                    'plugin' => 'DebugKit',
                    'controller' => 'Panels',
                    'action' => 'index',
                    $panel->request_id,
                ] ?>
                <a class="c-history-panel__link" data-request="<?= $panel->request_id ?>"
                   href="<?= $this->Url->build($url) ?>">
                    <span class="c-history-panel__time"><?= h($panel->request->requested_at) ?></span>
                    <span class="c-history-panel__bubble"><?= h($panel->request->method) ?></span>
                    <span class="c-history-panel__bubble"><?= h($panel->request->status_code) ?></span>
                    <span class="c-history-panel__bubble"><?= h($panel->request->content_type) ?></span>
                    <span class="c-history-panel__url"><?= h($panel->request->url) ?></span>
                </a>
            </li>
            <?php foreach ($requests as $request) : ?>
                <?php $url = ['plugin' => 'DebugKit', 'controller' => 'Panels', 'action' => 'index', $request->id] ?>
                <li>
                    <a class="c-history-panel__link"
                       data-request="<?= $request->id ?>"
                       href="<?= $this->Url->build($url) ?>">
                        <span class="c-history-panel__time"><?= h($request->requested_at) ?></span>
                        <span class="c-history-panel__bubble"><?= h($request->method) ?></span>
                        <span class="c-history-panel__bubble"><?= h($request->status_code) ?></span>
                        <span class="c-history-panel__bubble"><?= h($request->content_type) ?></span>
                        <span class="c-history-panel__url"><?= h($request->url) ?></span>
                    </a>
                </li>
            <?php endforeach; ?>
        </ul>
    <?php endif; ?>
    <script type="text/html" id="list-template">
        <p>
            <button type="button" class="js-toolbar-load-panel" data-panel-id="latest-history">
                Reload
            </button>
        </p>
        <ul class="c-history-panel__list">
            <li>
                <?php $url = [
                    'plugin' => 'DebugKit',
                    'controller' => 'Panels',
                    'action' => 'index',
                    $panel->request_id,
                ] ?>
                <a class="c-history-panel__link"
                   data-request="<?= $panel->request_id ?>"
                   href="<?= $this->Url->build($url) ?>">
                    <span class="c-history-panel__time"><?= h($panel->request->requested_at) ?></span>
                    <span class="c-history-panel__bubble"><?= h($panel->request->method) ?></span>
                    <span class="c-history-panel__bubble"><?= h($panel->request->status_code) ?></span>
                    <span class="c-history-panel__bubble"><?= h($panel->request->content_type) ?></span>
                    <span class="c-history-panel__url"><?= h($panel->request->url) ?></span>
                </a>
            </li>
        </ul>
    </script>

    <script type="text/html" id="list-item-template">
    <li>
        <?php $url = ['plugin' => 'DebugKit', 'controller' => 'Panels', 'action' => 'index'] ?>
        <a class="c-history-panel__link" data-request="{id}" href="<?= $this->Url->build($url) ?>/{id}">
            <span class="c-history-panel__time">{time}</span>
            <span class="c-history-panel__bubble c-history-panel__xhr">XHR</span>
            <span class="c-history-panel__bubble">{method}</span>
            <span class="c-history-panel__bubble">{status}</span>
            <span class="c-history-panel__bubble">{type}</span>
            <span class="c-history-panel__url">{url}</span>
        </a>
    </li>
    </script>
</div>
