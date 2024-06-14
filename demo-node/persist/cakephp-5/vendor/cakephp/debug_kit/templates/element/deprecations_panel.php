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
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

/**
 * @var \DebugKit\View\AjaxView $this
 * @var array $paths
 * @var array $app
 * @var array $cake
 * @var array $plugins
 * @var array $vendor
 * @var array $other
 */

use function Cake\Core\h;

$printer = function ($section, $data) {
?>
    <h3><?= h(ucfirst($section)) ?> </h3>
    <ul class="o-list o-list--deprecation-list">
    <?php foreach ($data as $message): ?>
        <li>
            <strong><?= h($message['niceFile']) ?>:<?= h($message['line']) ?></strong>
            <br>
            <?= h($message['message']) ?>
        </li>
    <?php endforeach; ?>
    </ul>
    <?php
}
?>
<div class="c-deprecations-panel">
    <?php
    if (count($app)) :
        $printer('app', $app);
    endif;

    if (count($plugins)) :
        foreach ($plugins as $plugin => $pluginData) :
            $printer($plugin, $pluginData);
        endforeach;
    endif;

    if (count($cake)) :
        $printer('cake', $cake);
    endif;

    if (count($vendor)) :
        foreach ($vendor as $vendorSection => $vendorData) :
            $printer($vendorSection, $vendorData);
        endforeach;
    endif;

    if (count($other)) :
        $printer('other', $other);
    endif;?>
</div>
