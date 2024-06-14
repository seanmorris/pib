<?php
/**
 * @var \App\View\AppView $this
 */

use function Cake\Core\h;
?>
<h1>Debug Kit Dashboard</h1>

<h2>Database</h2>
<ul>
    <li>Driver: <?= h($connection['driver']); ?></li>
    <?php if (isset($connection['rows'])): ?>
    <li>Requests: <?= $this->Number->format($connection['rows']) ?></li>
    <?php endif; ?>
</ul>
<?php if (!empty($connection['rows'])): ?>
    <?= $this->Form->postLink(
        'Reset database',
        ['_method' => 'POST', 'action' => 'reset'],
        ['confirm' => 'Are you sure?']
    ); ?>
<?php endif; ?>

<h3>Actions</h3>
<ul>
    <li><?= $this->Html->link('Mail Preview', ['controller' => 'MailPreview']); ?></li>
</ul>
