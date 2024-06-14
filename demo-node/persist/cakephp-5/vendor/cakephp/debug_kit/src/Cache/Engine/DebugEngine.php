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
namespace DebugKit\Cache\Engine;

use Cake\Cache\CacheEngine;
use Cake\Cache\CacheRegistry;
use Psr\Log\LoggerInterface;
use function Cake\Core\namespaceSplit;

/**
 * A spying proxy for cache engines.
 *
 * Used by the CachePanel to wrap and track metrics related to caching.
 */
class DebugEngine extends CacheEngine
{
    /**
     * Proxied engine
     *
     * @var \Cake\Cache\CacheEngine
     */
    protected CacheEngine $_engine;

    /**
     * @var \Psr\Log\LoggerInterface
     */
    protected LoggerInterface $logger;

    /**
     * @var string
     */
    protected string $name;

    /**
     * Hit/miss metrics.
     *
     * @var array<string, int>
     */
    protected array $metrics = [
        'set' => 0,
        'delete' => 0,
        'get hit' => 0,
        'get miss' => 0,
    ];

    /**
     * Constructor
     *
     * @param \Cake\Cache\CacheEngine|array<string, mixed> $config Config data or the proxied adapter.
     * @param string $name The name of the proxied cache engine.
     * @param \Psr\Log\LoggerInterface $logger Logger for collecting cache operation logs.
     */
    public function __construct(CacheEngine|array $config, string $name, LoggerInterface $logger)
    {
        if ($config instanceof CacheEngine) {
            $this->_engine = $config;
        } else {
            $this->_config = $config;
        }

        $this->logger = $logger;
        $this->name = $name;
    }

    /**
     * Initialize the proxied Cache Engine
     *
     * @param array $config Array of setting for the engine.
     * @return bool True, this engine cannot fail to initialize.
     */
    public function init(array $config = []): bool
    {
        /** @psalm-suppress RedundantPropertyInitializationCheck */
        if (!isset($this->_engine)) {
            $registry = new CacheRegistry();
            $this->_engine = $registry->load('spies', $this->_config);
            unset($registry);
        }

        return true;
    }

    /**
     * Get the internal engine
     *
     * @return \Cake\Cache\CacheEngine
     */
    public function engine(): CacheEngine
    {
        return $this->_engine;
    }

    /**
     * Get the metrics for this object.
     *
     * @return array
     */
    public function metrics(): array
    {
        return $this->metrics;
    }

    /**
     * Track a metric.
     *
     * @param string $metric The metric to increment.
     * @return void
     */
    protected function track(string $metric): void
    {
        $this->metrics[$metric]++;
    }

    /**
     * Log a cache operation
     *
     * @param string $operation The operation performed.
     * @param float $duration The duration of the operation.
     * @param string|null $key The cache key.
     * @return void
     */
    protected function log(string $operation, float $duration, ?string $key = null): void
    {
        $key = $key ? " `{$key}`" : '';
        $duration = number_format($duration, 5);
        $this->logger->log('info', ":{$this->name}: {$operation}{$key} - {$duration}ms");
    }

    /**
     * @inheritDoc
     */
    public function set($key, $value, $ttl = null): bool
    {
        $start = microtime(true);
        $result = $this->_engine->set($key, $value, $ttl);
        $duration = microtime(true) - $start;

        $this->track('set');
        $this->log('set', $duration, $key);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function setMultiple($values, $ttl = null): bool
    {
        $start = microtime(true);
        $result = $this->_engine->setMultiple($values);
        $duration = microtime(true) - $start;

        $this->track('set');
        $this->log('setMultiple', $duration);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function get(string $key, mixed $default = null): mixed
    {
        $start = microtime(true);
        $result = $this->_engine->get($key, $default);
        $duration = microtime(true) - $start;
        $metric = 'hit';
        if ($result === null) {
            $metric = 'miss';
        }

        $this->track("get {$metric}");
        $this->log('get', $duration, $key);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function getMultiple($keys, $default = null): iterable
    {
        $start = microtime(true);
        $result = $this->_engine->getMultiple($keys, $default);
        $duration = microtime(true) - $start;

        $this->track('get hit');
        $this->log('getMultiple', $duration);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function increment(string $key, int $offset = 1): int|false
    {
        $start = microtime(true);
        $result = $this->_engine->increment($key, $offset);
        $duration = microtime(true) - $start;

        $this->track('set');
        $this->log('increment', $duration, $key);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function decrement(string $key, int $offset = 1): int|false
    {
        $start = microtime(true);
        $result = $this->_engine->decrement($key, $offset);
        $duration = microtime(true) - $start;

        $this->track('set');
        $this->log('decrement', $duration, $key);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function delete($key): bool
    {
        $start = microtime(true);
        $result = $this->_engine->delete($key);
        $duration = microtime(true) - $start;

        $this->track('delete');
        $this->log('delete', $duration, $key);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function deleteMultiple($keys): bool
    {
        $start = microtime(true);
        $result = $this->_engine->deleteMultiple($keys);
        $duration = microtime(true) - $start;

        $this->track('delete');
        $this->log('deleteMultiple', $duration);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function clear(): bool
    {
        $start = microtime(true);
        $result = $this->_engine->clear();
        $duration = microtime(true) - $start;

        $this->track('delete');
        $this->log('clear', $duration);

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function groups(): array
    {
        return $this->_engine->groups();
    }

    /**
     * Returns the config.
     *
     * @param string|null $key The key to get or null for the whole config.
     * @param mixed $default The return value when the key does not exist.
     * @return mixed Config value being read.
     */
    public function getConfig(?string $key = null, mixed $default = null): mixed
    {
        return $this->_engine->getConfig($key, $default);
    }

    /**
     * Sets the config.
     *
     * @param array|string $key The key to set, or a complete array of configs.
     * @param mixed|null $value The value to set.
     * @param bool $merge Whether to recursively merge or overwrite existing config, defaults to true.
     * @return $this
     * @throws \Cake\Core\Exception\CakeException When trying to set a key that is invalid.
     */
    public function setConfig(array|string $key, mixed $value = null, bool $merge = true)
    {
        $this->_engine->setConfig($key, $value, $merge);

        return $this;
    }

    /**
     * @inheritDoc
     */
    public function clearGroup(string $group): bool
    {
        $start = microtime(true);
        $result = $this->_engine->clearGroup($group);
        $duration = microtime(true) - $start;

        $this->track('delete');
        $this->log('clearGroup', $duration, $group);

        return $result;
    }

    /**
     * Magic __toString() method to get the CacheEngine's name
     *
     * @return string Returns the CacheEngine's name
     */
    public function __toString(): string
    {
        /** @psalm-suppress RedundantPropertyInitializationCheck */
        if (isset($this->_engine)) {
            // phpcs:ignore SlevomatCodingStandard.Variables.UnusedVariable.UnusedVariable
            [$ns, $class] = namespaceSplit(get_class($this->_engine));

            return str_replace('Engine', '', $class);
        }

        return $this->_config['className'];
    }
}
