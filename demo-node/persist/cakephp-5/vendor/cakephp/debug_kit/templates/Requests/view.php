<?php
/**
 * @var \DebugKit\View\AjaxView $this
 * @var \DebugKit\Model\Entity\Request $toolbar
 */

use Cake\Routing\Router;
use Cake\Core\Configure;
use Cake\Utility\Inflector;
use function Cake\Core\h;

?>
<div class="c-panel-content-container js-panel-content-container">
    <span class="c-panel-content-container__close js-panel-close"></span>
    <div class="c-panel-content-container__content">
        <!-- content here -->
    </div>
</div>

<ul id="toolbar" class="c-toolbar">
     <li class="c-toolbar__scroll-button c-toolbar__scroll-button--left js-toolbar-scroll-left">
        <span class="c-panel__button">
            &#x3008;
        </span>
    </li>
    <li class="c-toolbar__scroll-button c-toolbar__scroll-button--right js-toolbar-scroll-right">
        <span class="c-panel__button">
            &#x3009;
        </span>
    </li>
    <li class="c-toolbar__inner-wrapper">
        <ul class="c-toolbar__inner-ul">
        <?php foreach ($toolbar->panels as $panel) : ?>
            <li class="c-panel js-panel-button is-hidden"
                data-id="<?= $panel->id ?>"
                data-panel-type="<?= Inflector::variable($panel->title) ?>">
                <span class="c-panel__button">
                    <?= h($panel->title) ?>
                </span>
                <?php if (!empty($panel->summary)) : ?>
                <span class="c-panel__summary">
                    <?= h($panel->summary) ?>
                </span>
                <?php endif ?>
            </li>
        <?php endforeach; ?>
        </ul>
    </li>
    <li class="c-toolbar__button js-toolbar-toggle">
        <?= $this->Html->image('DebugKit./img/cake.icon.png', [
            'alt' => 'Debug Kit', 'title' => 'CakePHP ' . Configure::version() . ' Debug Kit'
        ]) ?>
    </li>
</ul>
<?php
    $this->Html->script('DebugKit./js/jquery', [
        'block' => true,
    ]);
    $this->Html->script('DebugKit./js/main', [
        'type' => 'module',
        'block' => true,
        'id' => '__debug_kit_app',
        'data-id' => $toolbar->id,
        'data-url' => Router::url('/', true),
        'data-webroot' => $this->getRequest()->getAttribute('webroot'),
    ]);
    ?>
