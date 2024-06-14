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
namespace Bake\Utility;

use Bake\View\BakeView;
use Cake\Core\ConventionsTrait;
use Cake\Event\Event;
use Cake\Event\EventManager;
use Cake\View\Exception\MissingTemplateException;
use Cake\View\View;
use Cake\View\ViewVarsTrait;

/**
 * Used by other tasks to generate templated output, Acts as an interface to BakeView
 */
class TemplateRenderer
{
    use ConventionsTrait;
    use ViewVarsTrait;

    /**
     * BakeView instance
     *
     * @var \Bake\View\BakeView|null
     */
    protected ?BakeView $view = null;

    /**
     * Template theme
     *
     * @var string|null
     */
    protected ?string $theme;

    /**
     * Constructor
     *
     * @param ?string $theme The template theme/plugin to use.
     */
    public function __construct(?string $theme = null)
    {
        $this->theme = $theme;
    }

    /**
     * Get view instance
     *
     * @return \Cake\View\View
     * @triggers Bake.initialize $view
     */
    public function getView(): View
    {
        if ($this->view) {
            return $this->view;
        }

        $this->viewBuilder()
            ->addhelpers(['Bake.Bake', 'Bake.DocBlock'])
            ->setTheme($this->theme);

        $view = $this->createView(BakeView::class);
        $event = new Event('Bake.initialize', $view);
        EventManager::instance()->dispatch($event);
        /** @var \Bake\View\BakeView $view */
        $view = $event->getSubject();
        $this->view = $view;

        return $this->view;
    }

    /**
     * Runs the template
     *
     * @param string $template bake template to render
     * @param array|null $vars Additional vars to set to template scope.
     * @return string contents of generated code template
     */
    public function generate(string $template, ?array $vars = null): string
    {
        if ($vars !== null) {
            $this->set($vars);
        }

        $view = $this->getView();

        try {
            return $view->render($template);
        } catch (MissingTemplateException $e) {
            $message = sprintf('No bake template found for "%s" skipping file generation.', $template);
            throw new MissingTemplateException($message);
        }
    }
}
