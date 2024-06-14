<?php $this->extend('toolbar') ?>

<div style="height:calc(100vh);overflow-y:scroll">
    <?php if (empty($noHeader)) : ?>
        <h2 class="panel-title">
            <?= isset($title) ? h($title) : 'DebugKit Dashboard' ?>
        </h2>
    <?php endif ?>

    <div class="panel-content">
        <?= $this->fetch('content'); ?>
    </div>
</div>
