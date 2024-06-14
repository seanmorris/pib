<?php
/**
 * @var \DebugKit\View\AjaxView $this
 */
use function Cake\Core\h;
?>
<!DOCTYPE html>
<html>
    <head>
        <title><?= isset($title) ? h($title) : "Debug Kit Toolbar" ?></title>
        <?= $this->Html->css('DebugKit./css/reset') ?>
        <?= $this->Html->css('DebugKit./css/style') ?>
    </head>
    <body>
    <?= $this->fetch('content') ?>
    <div class="o-loader">
        <?= $this->Html->image('DebugKit./img/cake.icon.png', ['class' => 'o-loader__indicator'])?>
    </div>
    </body>
    <?= $this->fetch('script') ?>
</html>
