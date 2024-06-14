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
 * @var string $error
 * @var bool|null $sort
 * @var array $variables
 * @var array $errors
 */
?>
<div class="c-variables-panel">
    <?php
    if (isset($error)) :
        printf('<p class="c-flash c-flash--warning">%s</p>', $error);
    endif;

    if (isset($varsMaxDepth)) {
        $msg = sprintf('%s levels of nested data shown.', $varsMaxDepth);
        $msg .= ' You can overwrite this via the config key';
        $msg .= ' <strong>DebugKit.variablesPanelMaxDepth</strong><br>';
        $msg .= 'Increasing the depth value can lead to an out of memory error.';
        printf('<p class="c-flash c-flash--info">%s</p>', $msg);
    }

    // New node based data.
    if (!empty($variables)) :?>
        <div class="o-checkbox">
            <label>
                <input
                    type="checkbox"
                    class="js-debugkit-sort-variables"
                    <?= $sort ? ' checked="checked"' : '' ?>>
                Sort variables by name
            </label>
        </div>
        <?php
        $this->Toolbar->setSort($sort ?? false);
        echo $this->Toolbar->dumpNodes($variables);
    endif;

    if (!empty($errors)) :
        echo '<h4>Validation errors</h4>';
        echo $this->Toolbar->dumpNodes($errors);
    endif;
    ?>
</div>
