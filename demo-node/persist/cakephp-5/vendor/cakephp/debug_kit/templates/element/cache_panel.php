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
 * @since         DebugKit 0.1
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

/**
 * @var \DebugKit\View\AjaxView $this
 * @var array $metrics
 * @var array $logs
 */
use function Cake\Core\h;
?>
<div class="c-cache-panel">
    <?php if (empty($metrics)) : ?>
        <p class="c-flash c-flash--info">There were no cache operations in this request.</p>
    <?php else : ?>
        <h3>Cache Utilities</h3>
        <table class="c-debug-table">
            <thead>
                <tr>
                    <th>Engine</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($metrics as $name => $values) : ?>
                <tr>
                    <td><?= h($name) ?></td>
                    <td class="u-text-right">
                        <button
                            class="o-button js-clear-cache"
                            data-name="<?= h($name) ?>"
                            data-url="<?= $this->Url->build([
                                'plugin' => 'DebugKit',
                                'controller' => 'Toolbar',
                                'action' => 'clearCache',
                            ]) ?>"
                            data-csrf="<?= $this->getRequest()
                                ->getAttribute('csrfToken') ?>"
                        >
                            Clear All Data
                        </button>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <div class="c-cache-panel__messages"></div>

        <h3>Cache Usage Overview</h3>
        <table class="c-debug-table">
            <thead>
                <tr>
                    <th>Engine</th>
                    <th>get hit</th>
                    <th>get miss</th>
                    <th>set</th>
                    <th>delete</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($metrics as $name => $counters) : ?>
                <tr>
                    <td><?= h($name) ?></td>
                    <td class="u-text-right"><?= $counters['get hit'] ?></td>
                    <td class="u-text-right"><?= $counters['get miss'] ?></td>
                    <td class="u-text-right"><?= $counters['set'] ?></td>
                    <td class="u-text-right"><?= $counters['delete'] ?></td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>

        <h3>Cache Logs</h3>
        <table class="c-debug-table">
            <thead>
                <tr>
                    <th>Log</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($logs as $log) : ?>
            <tr>
                <td><?= h($log) ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    <?php endif; ?>
</div>
