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
 * @since         DebugKit 0.1
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

/**
 * @var \DebugKit\View\AjaxView $this
 * @var float $requestTime
 * @var int $peakMemory
 * @var array $memory
 */
use function Cake\Core\h;
?>
<div class="c-timer-panel">
    <section>
        <h3>Memory</h3>
        <div class="c-timer-panel__peak-mem-use">
            <strong>Peak Memory Use:</strong>
            <?= $this->Number->toReadableSize($peakMemory) ?>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Message</th>
                    <th>Memory Use</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($memory as $key => $value) : ?>
                <tr>
                    <td><?= h($key) ?></td>
                    <td class="u-text-right"><?= $this->Number->toReadableSize($value) ?></td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </section>

    <section>
        <h3>Timers</h3>
        <div class="c-timer-panel__request-time">
            <strong>Total Request Time:</strong>
            <?= $this->Number->precision($requestTime * 1000, 0) ?> ms
        </div>

        <table>
            <thead>
            <tr>
                <th>Event</th>
                <th>Time in ms</th>
                <th>Timeline</th>
            </tr>
            </thead>
            <tbody>
            <?php
            $rows = [];
            $end = end($timers);
            $maxTime = $end['end'];

            $i = 0;
            $values = array_values($timers);

            foreach ($timers as $timerName => $timeInfo) :
                $indent = 0;
                for ($j = 0; $j < $i; $j++) :
                    if (($values[$j]['end'] > $timeInfo['start']) && ($values[$j]['end']) > $timeInfo['end']) :
                        $indent++;
                    endif;
                endfor;
                $indent = str_repeat("\xC2\xA0\xC2\xA0", $indent);
                ?>
            <tr>
                <td>
                    <?= h($indent . $timeInfo['message']) ?>
                </td>
                <td class="u-text-right"><?= $this->Number->precision($timeInfo['time'] * 1000, 2) ?></td>
                <td>
                    <?= $this->SimpleGraph->bar(
                        $timeInfo['time'] * 1000,
                        $timeInfo['start'] * 1000,
                        [
                            'max' => $maxTime * 1000,
                            'requestTime' => $requestTime * 1000,
                        ]
                    ) ?>
                </td>
                <?php
                $i++;
            endforeach;
            ?>
            </tbody>
        </table>
    </section>
</div>
