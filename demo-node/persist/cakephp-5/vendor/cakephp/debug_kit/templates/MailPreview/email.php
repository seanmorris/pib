<?php
use function Cake\Core\h;
?>
<style>
    html, body {
        height: 100%;
    }

    body {
        margin: 0;
    }

    iframe.messageBody {
        border: 0;
        height: calc(100vh);
        width: 100%;
    }
</style>

<?php if (!$this->request->getQuery('part')) : ?>
    <?= $this->element('preview_header'); ?>
<?php endif; ?>

<?php if (!empty($part)) : ?>
    <iframe seamless name="messageBody" class="messageBody" src="?part=<?= h($part); ?>&plugin=<?= h($plugin); ?>"></iframe>
<?php else : ?>
    <p>You are trying to preview an email that does not have any content.</p>
<?php endif; ?>

<script>
    function formatChanged(form) {
        let part_name = form.options[form.selectedIndex].value
        let iframe = document.getElementsByName('messageBody')[0];
        iframe.contentWindow.location.replace('?part=' + part_name + '&plugin=<?= h($plugin); ?>');
    }
</script>
