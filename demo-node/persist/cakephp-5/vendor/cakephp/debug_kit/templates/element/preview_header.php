<?php
/**
 * @var \DebugKit\Mailer\AbstractResult $email
 */
use function Cake\Core\h;
?>
    <header>
        <table>
            <tr>
                <td>View As</td>
                <td>
                    <?php $partNames = array_keys($email->getParts()) ?>
                    <?= $this->Form->control('part', [
                        'type' => 'select',
                        'label' => false,
                        'value' => $this->request->getQuery('part') ?: 'html',
                        'onChange' => 'formatChanged(this);',
                        'options' => array_combine($partNames, $partNames),
                    ]);
                    ?>
                </td>
            </tr>
            <?php foreach ($email->getHeaders() as $name => $header) :?>
                <tr>
                    <td><?= h($name) ?></td>
                    <td><?= h($header) ?></td>
                </tr>
            <?php endforeach ?>
        </table>
    </header>
