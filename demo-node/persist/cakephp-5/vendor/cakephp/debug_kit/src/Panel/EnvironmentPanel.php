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
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Panel;

use Cake\Core\Configure;
use Cake\Event\EventInterface;
use DebugKit\DebugPanel;

/**
 * Provides information about your PHP and CakePHP environment to assist with debugging.
 */
class EnvironmentPanel extends DebugPanel
{
    /**
     * Get necessary data about environment to pass back to controller
     *
     * @return array
     */
    protected function _prepare(): array
    {
        $return = [];
        // PHP Data
        $phpVer = phpversion();
        $return['php'] = array_merge(
            ['PHP_VERSION' => $phpVer],
            $_SERVER
        );
        unset($return['php']['argv']);

        // ini Data
        $return['ini'] = [
            'intl.default_locale' => ini_get('intl.default_locale'),
            'memory_limit' => ini_get('memory_limit'),
            'error_reporting' => ini_get('error_reporting'),
            'upload_max_filesize' => ini_get('upload_max_filesize'),
            'post_max_size' => ini_get('post_max_size'),
        ];

        // CakePHP Data
        $return['cake'] = [
            'APP' => APP,
            'APP_DIR' => APP_DIR,
            'CACHE' => CACHE,
            'CAKE' => CAKE,
            'CAKE_CORE_INCLUDE_PATH' => CAKE_CORE_INCLUDE_PATH,
            'CONFIG' => CONFIG,
            'CORE_PATH' => CORE_PATH,
            'CAKE_VERSION' => Configure::version(),
            'DS' => DS,
            'LOGS' => LOGS,
            'ROOT' => ROOT,
            'TESTS' => TESTS,
            'TMP' => TMP,
            'WWW_ROOT' => WWW_ROOT,
        ];

        $hiddenCakeConstants = array_fill_keys(
            [
                'TIME_START', 'SECOND', 'MINUTE', 'HOUR', 'DAY', 'WEEK', 'MONTH', 'YEAR',
            ],
            ''
        );
        $var = get_defined_constants(true);
        $return['app'] = array_diff_key($var['user'], $return['cake'], $hiddenCakeConstants);

        return $return;
    }

    /**
     * Shutdown callback
     *
     * @param \Cake\Event\EventInterface $event Event
     * @return void
     */
    public function shutdown(EventInterface $event): void
    {
        $this->_data = $this->_prepare();
    }
}
