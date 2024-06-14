<?php
/**
 * @var \Cake\Routing\Route\Route[] $routes
 * @var string $matchedRoute
 */

use Cake\Core\Plugin as CorePlugin;
use Cake\Utility\Hash;
use Cake\Utility\Text;
use function Cake\Core\h;

$routes = Cake\Routing\Router::routes();

$amountOfRoutesPerGroup = $duplicateRoutes = [];
foreach ($routes as $route) {
    // Count the amount
    $group = $route->defaults['plugin'] ?? 'app';
    if (!array_key_exists($group, $amountOfRoutesPerGroup)) {
        $amountOfRoutesPerGroup[$group] = 0;
    }
    $amountOfRoutesPerGroup[$group]++;

    if (!array_key_exists($route->template, $duplicateRoutes)) {
        $duplicateRoutes[$route->template] = 0;
    }
    $duplicateRoutes[$route->template]++;
}

$pluginNames = [];
foreach (CorePlugin::loaded() as $pluginName) {
    if (!empty($amountOfRoutesPerGroup[$pluginName])) {
        $name = sprintf('%s (%s)', $pluginName, $amountOfRoutesPerGroup[$pluginName]);
        $pluginNames[$name] = Text::slug($pluginName);
    }
}

?>
<div class="c-routes-panel">
    <div class="c-routes-panel__button-wrapper">
        <button type="button" class="o-button js-toggle-plugin-route" data-plugin=".c-routes-panel__route-entry--app">
            App
            <?= !empty($amountOfRoutesPerGroup['app']) ? ' (' . $amountOfRoutesPerGroup['app'] . ')' : '' ?>
        </button>
        <?php foreach ($pluginNames as $pluginName => $parsedName) : ?>
            <button type="button" class="o-button js-toggle-plugin-route <?=
                    strpos($pluginName, 'DebugKit') === 0 ? ' is-active' : '' ?>"
                    data-plugin=".c-routes-panel__route-entry--plugin-<?= $parsedName ?>">
                <?= $pluginName ?>
            </button>
        <?php endforeach; ?>
    </div>
    <table class="c-debug-table">
        <thead>
        <tr>
            <th>Route name</th>
            <th class="u-text-left">URI template</th>
            <th class="u-text-left">Defaults</th>
        </tr>
        </thead>
        <tbody>
        <?php foreach ($routes as $route) : ?>
            <?php
            $class = '';
            if (empty($route->defaults['plugin'])) :
                $class = 'c-routes-panel__route-entry c-routes-panel__route-entry--app';
            else :
                $class = 'c-routes-panel__route-entry ' .
                    'c-routes-panel__route-entry--plugin c-routes-panel__route-entry--plugin-' .
                    Text::slug($route->defaults['plugin']);

                // Hide DebugKit internal routes by default
                if ($route->defaults['plugin'] === 'DebugKit') {
                    $class .= ' is-hidden';
                }
            endif;

            // Highlight current route
            if ($matchedRoute === $route->template) {
                $class .= ' highlighted';
            }

            // Mark duplicate routes
            if ($duplicateRoutes[$route->template] > 1) {
                $class .= ' duplicate-route';
            }

            ?>
            <tr class="<?= $class ?>">
                <td><?= h(Hash::get($route->options, '_name', $route->getName())) ?></td>
                <td class="u-text-left"><?= h($route->template) ?></td>
                <td class="u-text-left"><pre><?= json_encode($route->defaults, JSON_PRETTY_PRINT) ?></pre></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
</div>
