<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         3.3.7
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\View\Helper;

use Cake\Utility\Hash;
use Cake\View\Helper;
use function Cake\Core\h;

/**
 * CredentialsHelper
 *
 * Filter sensitive data in screen, data will be displayed on mouse click
 *
 * @property \Cake\View\Helper\HtmlHelper $Html
 * @property \DebugKit\View\Helper\ToolbarHelper $Toolbar
 */
class CredentialsHelper extends Helper
{
    /**
     * Helpers property
     *
     * @var array
     */
    public array $helpers = ['Html', 'DebugKit.Toolbar'];

    /**
     * Replace credentials in url's by *****
     * Example mysql://username:password@localhost/my_db -> mysql://******@localhost/my_db
     *
     * @param mixed $in variable to filter
     * @return mixed
     */
    public function filter(mixed $in): mixed
    {
        $regexp = '/^([^:;]+:\/\/)([^:;]+:?.*?)@(.*)$/i';
        if (!is_string($in) || empty($in)) {
            return $in;
        }
        preg_match_all($regexp, $in, $tokens);
        if (empty($tokens[0])) {
            return h($in);
        }
        $protocol = Hash::get($tokens, '1.0');
        $credentials = Hash::get($tokens, '2.0');
        $tail = Hash::get($tokens, '3.0');
        $link = $this->Html->tag('a', '******', [
            'class' => 'filtered-credentials',
            'title' => h($credentials),
            'onclick' => 'this.innerHTML = this.title',
        ]);

        return h($protocol) . $link . '@' . h($tail);
    }
}
