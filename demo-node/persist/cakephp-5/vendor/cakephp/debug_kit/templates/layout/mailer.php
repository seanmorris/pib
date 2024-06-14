<?php
use function Cake\Core\h;
$this->extend('toolbar');
?>

<div style="height:calc(100vh);overflow-y:scroll">
    <?php if (empty($noHeader)) : ?>
        <h2 class="panel-title">
            <?= isset($title) ? h($title) : 'Mailer Previews' . " \u{1f4ee}" ?>
        </h2>
    <?php endif ?>

    <div class="panel-content">
        <?= $this->fetch('content'); ?>
    </div>
</div>
