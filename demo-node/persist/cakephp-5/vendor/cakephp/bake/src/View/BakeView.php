<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         0.1.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\View;

use Cake\Core\Configure;
use Cake\Core\ConventionsTrait;
use Cake\Event\EventDispatcherTrait;
use Cake\Event\EventInterface;
use Cake\TwigView\View\TwigView;
use function Cake\Core\pluginSplit;

class BakeView extends TwigView
{
    /**
     * @use \Cake\Event\EventDispatcherTrait<\Cake\View\View>
     */
    use EventDispatcherTrait;
    use ConventionsTrait;

    /**
     * Folder containing bake templates.
     *
     * @var string
     */
    public const BAKE_TEMPLATE_FOLDER = 'bake';

    /**
     * @inheritDoc
     */
    protected string $layout = 'Bake.default';

    /**
     * Initialize view
     *
     * @return void
     */
    public function initialize(): void
    {
        $this->setConfig('environment', [
            'autoescape' => false,
            'cache' => false,
            'strict_variables' => Configure::read('Bake.twigStrictVariables', false),
        ]);

        parent::initialize();
    }

    /**
     * Renders view for given view file and layout.
     *
     * Render triggers helper callbacks, which are fired before and after the view are rendered,
     * as well as before and after the layout. The helper callbacks are called:
     *
     * - `beforeRender`
     * - `afterRender`
     *
     * View names can point to plugin views/layouts. Using the `Plugin.view` syntax
     * a plugin view/layout can be used instead of the app ones. If the chosen plugin is not found
     * the view will be located along the regular view path cascade.
     *
     * View can also be a template string, rather than the name of a view file
     *
     * @param string|null $template Name of view file to use, or a template string to render
     * @param string|false|null $layout Layout to use. Not used, for consistency with other views only
     * @throws \Cake\Core\Exception\CakeException If there is an error in the view.
     * @return string Rendered content.
     */
    public function render(?string $template = null, string|false|null $layout = null): string
    {
        $viewFileName = $this->_getTemplateFileName($template);
        [, $templateEventName] = pluginSplit($template);
        $templateEventName = str_replace(['/', '\\'], '.', $templateEventName);

        $this->_currentType = static::TYPE_TEMPLATE;
        $this->dispatchEvent('View.beforeRender', [$viewFileName]);
        $this->dispatchEvent('View.beforeRender.' . $templateEventName, [$viewFileName]);
        $this->Blocks->set('content', $this->_render($viewFileName));
        $this->dispatchEvent('View.afterRender', [$viewFileName]);
        $this->dispatchEvent('View.afterRender.' . $templateEventName, [$viewFileName]);

        if ($layout === null) {
            $layout = $this->layout;
        }
        if ($layout && $this->autoLayout) {
            $this->Blocks->set('content', $this->renderLayout('', $layout));
        }

        return $this->Blocks->get('content');
    }

    /**
     * Wrapper for creating and dispatching events.
     *
     * Use the Bake prefix for bake related view events
     *
     * @template TSubject of \Cake\View\View
     * @param string $name Name of the event.
     * @param array $data Any value you wish to be transported with this event to
     * it can be read by listeners.
     *
     * @param TSubject|null $subject The object that this event applies to
     * ($this by default).
     * @return \Cake\Event\EventInterface<\Cake\View\View>
     */
    public function dispatchEvent(string $name, array $data = [], ?object $subject = null): EventInterface
    {
        $name = preg_replace('/^View\./', 'Bake.', $name);

        return parent::dispatchEvent($name, $data, $subject);
    }

    /**
     * Return all possible paths to find view files in order
     *
     * @param ?string $plugin Optional plugin name to scan for view files.
     * @param bool $cached Set to false to force a refresh of view paths. Default true.
     * @return array<string> paths
     */
    protected function _paths(?string $plugin = null, bool $cached = true): array
    {
        $paths = parent::_paths($plugin, false);
        foreach ($paths as &$path) {
            // Append 'bake' to all directories that aren't the application override directory.
            if (strpos($path, 'plugin' . DS . 'Bake') === false) {
                $path .= static::BAKE_TEMPLATE_FOLDER . DS;
            }
        }

        return $paths;
    }
}
