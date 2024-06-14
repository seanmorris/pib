<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Migrations;

use Cake\Database\Connection;
use Cake\Database\Driver\Postgres;
use Cake\Database\Query;
use InvalidArgumentException;
use PDO;
use Phinx\Db\Adapter\AdapterInterface;
use Phinx\Db\Adapter\AdapterWrapper;
use ReflectionProperty;

/**
 * Decorates an AdapterInterface in order to proxy some method to the actual
 * connection object.
 */
class CakeAdapter extends AdapterWrapper
{
    /**
     * Database connection
     *
     * @var \Cake\Database\Connection
     */
    protected Connection $connection;

    /**
     * Constructor
     *
     * @param \Phinx\Db\Adapter\AdapterInterface $adapter The original adapter to decorate.
     * @param \Cake\Database\Connection|null $connection The connection to actually use.
     */
    public function __construct(AdapterInterface $adapter, ?Connection $connection = null)
    {
        if ($connection === null) {
            throw new InvalidArgumentException('The cake connection cannot be null');
        }

        parent::__construct($adapter);

        $this->connection = $connection;
        $pdo = $adapter->getConnection();

        if ($pdo->getAttribute(PDO::ATTR_ERRMODE) !== PDO::ERRMODE_EXCEPTION) {
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        }
        $connection->cacheMetadata(false);

        if ($connection->getDriver() instanceof Postgres) {
            $config = $connection->config();
            $schema = empty($config['schema']) ? 'public' : $config['schema'];
            $pdo->exec('SET search_path TO ' . $pdo->quote($schema));
        }

        $driver = $connection->getDriver();
        $prop = new ReflectionProperty($driver, 'pdo');
        $prop->setValue($driver, $pdo);
    }

    /**
     * Gets the CakePHP Connection object.
     *
     * @return \Cake\Database\Connection
     */
    public function getCakeConnection(): Connection
    {
        return $this->connection;
    }

    /**
     * Returns a new Query object
     *
     * @param string $type The type of query to generate (one of the
     *  `\Cake\Database\Query::TYPE_*` constants).
     * @return \Cake\Database\Query
     */
    public function getQueryBuilder(string $type): Query
    {
        return match ($type) {
            Query::TYPE_SELECT => $this->getCakeConnection()->selectQuery(),
            Query::TYPE_INSERT => $this->getCakeConnection()->insertQuery(),
            Query::TYPE_UPDATE => $this->getCakeConnection()->updateQuery(),
            Query::TYPE_DELETE => $this->getCakeConnection()->deleteQuery(),
            default => throw new InvalidArgumentException(
                'Query type must be one of: `select`, `insert`, `update`, `delete`.'
            )
        };
    }

    /**
     * Returns the adapter type name, for example mysql
     *
     * @return string
     */
    public function getAdapterType(): string
    {
        return $this->getAdapter()->getAdapterType();
    }
}
