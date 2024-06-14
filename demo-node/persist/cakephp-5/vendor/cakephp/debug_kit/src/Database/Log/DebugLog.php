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
 * @since         3.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Database\Log;

use Cake\Database\Log\LoggedQuery;
use Psr\Log\AbstractLogger;
use Psr\Log\LoggerInterface;
use Stringable;

/**
 * DebugKit Query logger.
 *
 * This logger decorates the existing logger if it exists,
 * and stores log messages internally so they can be displayed
 * or stored for future use.
 */
class DebugLog extends AbstractLogger
{
    /**
     * Logs from the current request.
     *
     * @var array
     */
    protected array $_queries = [];

    /**
     * Decorated logger.
     *
     * @var \Psr\Log\LoggerInterface|null
     */
    protected ?LoggerInterface $_logger = null;

    /**
     * Name of the connection being logged.
     *
     * @var string
     */
    protected string $_connectionName;

    /**
     * Total time (ms) of all queries
     *
     * @var float
     */
    protected float $_totalTime = 0;

    /**
     * Set to true to capture schema reflection queries
     * in the SQL log panel.
     *
     * @var bool
     */
    protected bool $_includeSchema = false;

    /**
     * Constructor
     *
     * @param \Psr\Log\LoggerInterface|null $logger The logger to decorate and spy on.
     * @param string $name The name of the connection being logged.
     * @param bool $includeSchema Whether or not schema reflection should be included.
     */
    public function __construct(?LoggerInterface $logger, string $name, bool $includeSchema = false)
    {
        $this->_logger = $logger;
        $this->_connectionName = $name;
        $this->_includeSchema = $includeSchema;
    }

    /**
     * Set the schema include flag.
     *
     * @param bool $value Set
     * @return $this
     */
    public function setIncludeSchema(bool $value)
    {
        $this->_includeSchema = $value;

        return $this;
    }

    /**
     * Get the connection name.
     *
     * @return string
     */
    public function name(): string
    {
        return $this->_connectionName;
    }

    /**
     * Get the stored logs.
     *
     * @return array
     */
    public function queries(): array
    {
        return $this->_queries;
    }

    /**
     * Get the total time
     *
     * @return float
     */
    public function totalTime(): float
    {
        return $this->_totalTime;
    }

    /**
     * @inheritDoc
     */
    public function log($level, string|Stringable $message, array $context = []): void
    {
        $query = $context['query'] ?? null;

        if ($this->_logger) {
            $this->_logger->log($level, $message, $context);
        }

        // This specific to Elastic Search
        if (!$query instanceof LoggedQuery && isset($context['request']) && isset($context['response'])) {
            $took = $context['response']['took'] ?? 0;
            $this->_totalTime += $took;

            $this->_queries[] = [
                'query' => json_encode([
                    'method' => $context['request']['method'],
                    'path' => $context['request']['path'],
                    'data' => $context['request']['data'],
                ], JSON_PRETTY_PRINT),
                'took' => $took,
                'rows' => $context['response']['hits']['total']['value'] ?? $context['response']['hits']['total'] ?? 0,
            ];

            return;
        }

        if (
            !$query instanceof LoggedQuery ||
            ($this->_includeSchema === false && $this->isSchemaQuery($query))
        ) {
            return;
        }

        $data = $query->jsonSerialize();

        $this->_totalTime += $data['took'];

        $this->_queries[] = [
            'query' => (string)$query,
            'took' => $data['took'],
            'rows' => $data['numRows'],
        ];
    }

    /**
     * Sniff SQL statements for things only found in schema reflection.
     *
     * @param \Cake\Database\Log\LoggedQuery $query The query to check.
     * @return bool
     */
    protected function isSchemaQuery(LoggedQuery $query): bool
    {
        /** @psalm-suppress InternalMethod */
        $querystring = $query->jsonSerialize()['query'];

        return // Multiple engines
            strpos($querystring, 'FROM information_schema') !== false ||
            // Postgres
            strpos($querystring, 'FROM pg_catalog') !== false ||
            // MySQL
            strpos($querystring, 'SHOW TABLE') === 0 ||
            strpos($querystring, 'SHOW FULL COLUMNS') === 0 ||
            strpos($querystring, 'SHOW INDEXES') === 0 ||
            // Sqlite
            strpos($querystring, 'FROM sqlite_master') !== false ||
            strpos($querystring, 'PRAGMA') === 0 ||
            // Sqlserver
            strpos($querystring, 'FROM INFORMATION_SCHEMA') !== false ||
            strpos($querystring, 'FROM sys.') !== false;
    }
}
