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
 * @since         DebugKit 2.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

/**
 * @var \DebugKit\View\AjaxView $this
 * @var array<\Cake\Error\Debug\NodeInterface> $paths
 * @var array<\Cake\Error\Debug\NodeInterface> $app
 * @var array<\Cake\Error\Debug\NodeInterface> $cake
 * @var array<\Cake\Error\Debug\NodeInterface> $plugins
 * @var array<\Cake\Error\Debug\NodeInterface> $vendor
 * @var array<\Cake\Error\Debug\NodeInterface> $other
 */

// Backwards compat for old DebugKit data.
if (!isset($cake) && isset($core)) {
    $cake = $core;
}
?>
<div class="c-include-panel">
    <h4>Include Paths</h4>
    <?= $this->Toolbar->dumpNodes(compact('paths')) ?>

    <h4>Included Files</h4>
    <?= $this->Toolbar->dumpNodes(compact('app', 'cake', 'plugins', 'vendor', 'other')) ?>
</div>
