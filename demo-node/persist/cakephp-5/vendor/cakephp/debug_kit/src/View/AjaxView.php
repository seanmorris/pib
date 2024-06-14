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
 * @since         3.2.8
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\View;

use Cake\View\View;

/**
 * A view class that is used for AJAX responses.
 *
 * Currently only switches the default layout and sets the response type
 * which just maps to text/html by default.
 *
 * @property \DebugKit\View\Helper\SimpleGraphHelper $SimpleGraph
 * @property \DebugKit\View\Helper\ToolbarHelper $Toolbar
 */
class AjaxView extends View
{
    /**
     * Initialization hook method.
     *
     * @return void
     */
    public function initialize(): void
    {
        parent::initialize();
        $this->response = $this->response->withType('ajax');
    }
}
