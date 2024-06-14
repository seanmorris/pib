<?php
/**
 * @var $panel \DebugKit\Model\Entity\Panel
 */

use function Cake\Core\h;
?>
<div class="c-mail-panel">
    <p class="c-flash c-flash--info">
        <?= sprintf(
            'Why not test your emails interactively instead? Go to the %s',
            $this->Html->link(
                'Email previews page',
                ['controller' => 'MailPreview', 'action' => 'index'],
                ['target' => '_blank']
            )
        ) ?>
    </p>
    <?php
    if (empty($emails)) {
        echo '<p>No emails were sent during this request</p>';

        return;
    }
        $url = $this->Url->build([
            'controller' => 'MailPreview',
            'action' => 'sent',
            'panel' => $panel->id,
            'id' => 0,
        ]);
        ?>
    <div class="c-mail-panel__wrapper">
        <div class="c-mail-panel__table-wrapper">
            <table class="c-debug-table">
                <tr>
                    <th>Subject</th>
                </tr>
                <?php foreach ($emails as $index => $email) : ?>
                <tr class="js-debugkit-load-sent-email<?= $index == 0 ? ' highlighted' : '' ?>"
                    data-mail-idx="<?= $index ?>">
                    <td style="cursor:pointer;padding:20px 10px;line-height:20px">
                        <?= "\u{2709}\u{FE0F}" ?>
                        <?= !empty($email['headers']['Subject']) ?
                            h($this->Text->truncate($email['headers']['Subject'])) :
                            '(No Subject)'
                        ?>
                    </td>
                </tr>
                <?php endforeach; ?>
            </table>
        </div>
        <iframe seamless
            class="c-mail-panel__iframe"
            src="<?= h($url) ?>"
        >
        </iframe>
    </div>
</div>
