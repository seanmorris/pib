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
 * @since         DebugKit 3.5.2
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

/**
 * @var \DebugKit\View\AjaxView $this
 * @var array $packages
 */
use function Cake\Core\h;
?>
<div class="c-packages-panel"
     data-base-url="<?= $this->Url->build([
         'plugin' => 'DebugKit',
         'controller' => 'Composer',
         'action' => 'checkDependencies',
     ]) ?>"
     data-csrf-token="<?= $this->getRequest()->getAttribute('csrfToken') ?>"
    >
    <?php if (empty($packages) && empty($devPackages)) : ?>
        <div class="c-flash c-flash--warning">
            'composer.lock' not found
        </div>
    <?php else : ?>
        <div class="c-packages-panel__check-update">
            <button class="o-button">Check for Updates</button>
            <label><input type="checkbox">Direct dependencies only</label>
        </div>
        <div class="c-packages-panel__terminal">
            <div class="c-packages-panel__terminal-loader">
                <?= 'Loading' .
                    $this->Html->image('DebugKit./img/cake.icon.png', ['class' => 'indicator']) ?>
            </div>
        </div>
        <div class="c-packages-panel__section-wrapper">
            <?php if (!empty($packages)) : ?>
                <section>
                    <h3><?= sprintf('Requirements (%d)', count($packages)) ?> </h3>
                    <table class="c-debug-table">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Version</th>
                        </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($packages as $package) : ?>
                            <?php extract($package); ?>
                            <tr>
                                <td title="<?= h($description) ?>">
                                    <a href="https://packagist.org/packages/<?= h($name) ?>"
                                       title="<?= h($description) ?>"
                                       target="_blank"
                                       class="c-packages-panel__link">
                                        <?= h($name) ?>
                                    </a>
                                </td>
                                <td>
                                    <span class="c-packages-panel__version"><?= h($version) ?></span>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                </section>
            <?php endif; ?>
            <?php if (!empty($devPackages)) : ?>
                <section>
                    <h3><?= sprintf('Dev Requirements (%d)', count($devPackages)) ?></h3>
                    <table class="c-debug-table">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Version</th>
                        </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($devPackages as $package) : ?>
                            <?php extract($package); ?>
                            <tr>
                                <td title="<?= h($description) ?>">
                                    <a href="https://packagist.org/packages/<?= h($name) ?>"
                                       title="<?= h($description) ?>"
                                       target="_blank"
                                       class="c-packages-panel__link">
                                        <?= h($name) ?>
                                    </a>
                                </td>
                                <td>
                                    <span class="c-packages-panel__version"><?= h($version) ?></span>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                </section>
            <?php endif; ?>
        </div>
    <?php endif; ?>
</div>
