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

use Cake\Cache\Cache;
use Cake\Log\Engine\ArrayLog;
use DebugKit\Cache\Engine\DebugEngine;
use DebugKit\DebugPanel;

/**
 * A panel for spying on cache engines.
 */
class CachePanel extends DebugPanel
{
    /**
     * @var \Cake\Log\Engine\ArrayLog
     */
    protected ArrayLog $logger;

    /**
     * @var array<\DebugKit\Cache\Engine\DebugEngine>
     */
    protected array $instances = [];

    /**
     * Constructor
     */
    public function __construct()
    {
        $this->logger = new ArrayLog();
    }

    /**
     * Initialize - install cache spies.
     *
     * @return void
     */
    public function initialize(): void
    {
        foreach (Cache::configured() as $name) {
            /** @var array $config */
            $config = Cache::getConfig($name);
            if (isset($config['className']) && $config['className'] instanceof DebugEngine) {
                $instance = $config['className'];
            } elseif (isset($config['className'])) {
                /** @var \Cake\Cache\CacheEngine $engine */
                $engine = Cache::pool($name);
                // Unload from the cache registry so that subsequence calls to
                // Cache::pool($name) use the new config with DebugEngine instance set below.
                Cache::getRegistry()->unload($name);

                $instance = new DebugEngine($engine, $name, $this->logger);
                $instance->init();
                $config['className'] = $instance;

                Cache::drop($name);
                Cache::setConfig($name, $config);
            }
            if (isset($instance)) {
                $this->instances[$name] = $instance;
            }
        }
    }

    /**
     * Get the data for this panel
     *
     * @return array
     */
    public function data(): array
    {
        $metrics = [];
        foreach ($this->instances as $name => $instance) {
            $metrics[$name] = $instance->metrics();
        }
        $logs = $this->logger->read();
        $this->logger->clear();

        return [
            'metrics' => $metrics,
            'logs' => $logs,
        ];
    }
}
