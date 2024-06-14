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

use Cake\Core\Configure;
use Cake\Database\Driver\Mysql;
use Cake\Database\Driver\Postgres;
use Cake\Database\Driver\Sqlite;
use Cake\Database\Driver\Sqlserver;
use Cake\Datasource\ConnectionManager;
use InvalidArgumentException;
use Migrations\Util\UtilTrait;
use PDO;
use Phinx\Config\Config;
use Phinx\Config\ConfigInterface;
use ReflectionClass;
use RuntimeException;
use Symfony\Component\Console\Input\InputInterface;

/**
 * Contains a set of methods designed as overrides for
 * the methods in phinx that are responsible for reading the project configuration.
 * This is needed so that we can use the application configuration instead of having
 * a configuration yaml file.
 */
trait ConfigurationTrait
{
    use UtilTrait;

    /**
     * The configuration object that phinx uses for connecting to the database
     *
     * @var \Phinx\Config\Config|null
     */
    protected ?Config $configuration = null;

    /**
     * Connection name to be used for this request
     *
     * @var string
     */
    protected string $connection;

    /**
     * The console input instance
     *
     * @var \Symfony\Component\Console\Input\InputInterface|null
     */
    protected ?InputInterface $input = null;

    /**
     * @return \Symfony\Component\Console\Input\InputInterface
     */
    protected function input(): InputInterface
    {
        if ($this->input === null) {
            throw new RuntimeException('Input not set');
        }

        return $this->input;
    }

    /**
     * Overrides the original method from phinx to just always return true to
     * avoid calling loadConfig method which will throw an exception as we rely on
     * the overridden getConfig method.
     *
     * @return bool
     */
    public function hasConfig(): bool
    {
        return true;
    }

    /**
     * Overrides the original method from phinx in order to return a tailored
     * Config object containing the connection details for the database.
     *
     * @param bool $forceRefresh Refresh config.
     * @return \Phinx\Config\ConfigInterface
     */
    public function getConfig(bool $forceRefresh = false): ConfigInterface
    {
        if ($this->configuration && $forceRefresh === false) {
            return $this->configuration;
        }

        $migrationsPath = $this->getOperationsPath($this->input());
        $seedsPath = $this->getOperationsPath($this->input(), 'Seeds');
        $plugin = $this->getPlugin($this->input());

        if (!is_dir($migrationsPath)) {
            if (!Configure::read('debug')) {
                throw new RuntimeException(sprintf(
                    'Migrations path `%s` does not exist and cannot be created because `debug` is disabled.',
                    $migrationsPath
                ));
            }
            mkdir($migrationsPath, 0777, true);
        }

        if (Configure::read('debug') && !is_dir($seedsPath)) {
            mkdir($seedsPath, 0777, true);
        }

        $phinxTable = $this->getPhinxTable($plugin);

        $connection = $this->getConnectionName($this->input());

        $connectionConfig = (array)ConnectionManager::getConfig($connection);

        $adapterName = $this->getAdapterName($connectionConfig['driver']);
        $dsnOptions = $this->extractDsnOptions($adapterName, $connectionConfig);

        $templatePath = dirname(__DIR__) . DS . 'templates' . DS;
        $config = [
            'paths' => [
                'migrations' => $migrationsPath,
                'seeds' => $seedsPath,
            ],
            'templates' => [
                'file' => $templatePath . 'Phinx' . DS . 'create.php.template',
            ],
            'migration_base_class' => 'Migrations\AbstractMigration',
            'environments' => [
                'default_migration_table' => $phinxTable,
                'default_environment' => 'default',
                'default' => [
                    'adapter' => $adapterName,
                    'host' => $connectionConfig['host'] ?? null,
                    'user' => $connectionConfig['username'] ?? null,
                    'pass' => $connectionConfig['password'] ?? null,
                    'port' => $connectionConfig['port'] ?? null,
                    'name' => $connectionConfig['database'],
                    'charset' => $connectionConfig['encoding'] ?? null,
                    'unix_socket' => $connectionConfig['unix_socket'] ?? null,
                    'suffix' => '',
                    'dsn_options' => $dsnOptions,
                ],
            ],
            'feature_flags' => $this->featureFlags(),
        ];

        if ($adapterName === 'pgsql') {
            if (!empty($connectionConfig['schema'])) {
                $config['environments']['default']['schema'] = $connectionConfig['schema'];
            }
        }

        if ($adapterName === 'mysql') {
            if (!empty($connectionConfig['ssl_key']) && !empty($connectionConfig['ssl_cert'])) {
                $config['environments']['default']['mysql_attr_ssl_key'] = $connectionConfig['ssl_key'];
                $config['environments']['default']['mysql_attr_ssl_cert'] = $connectionConfig['ssl_cert'];
            }

            if (!empty($connectionConfig['ssl_ca'])) {
                $config['environments']['default']['mysql_attr_ssl_ca'] = $connectionConfig['ssl_ca'];
            }
        }

        if ($adapterName === 'sqlite') {
            if (!empty($connectionConfig['cache'])) {
                $config['environments']['default']['cache'] = $connectionConfig['cache'];
            }
            if (!empty($connectionConfig['mode'])) {
                $config['environments']['default']['mode'] = $connectionConfig['mode'];
            }
        }

        if (!empty($connectionConfig['flags'])) {
            $config['environments']['default'] +=
                $this->translateConnectionFlags($connectionConfig['flags'], $adapterName);
        }

        return $this->configuration = new Config($config);
    }

    /**
     * Returns the Migrations feature flags configuration.
     *
     * @return array<string, bool>
     */
    protected function featureFlags(): array
    {
        $options = [
            'unsigned_primary_keys',
            'column_null_default',
        ];

        return array_intersect_key(Configure::read('Migrations', []), array_flip($options));
    }

    /**
     * Returns the correct driver name to use in phinx based on the driver class
     * that was configured for the configuration.
     *
     * @param string $driver The driver name as configured for the CakePHP app.
     * @return string Name of the adapter.
     * @throws \InvalidArgumentException when it was not possible to infer the information
     * out of the provided database configuration
     * @phpstan-param class-string $driver
     */
    public function getAdapterName(string $driver): string
    {
        switch ($driver) {
            case Mysql::class:
            case is_a($driver, Mysql::class, true):
                return 'mysql';
            case Postgres::class:
            case is_a($driver, Postgres::class, true):
                return 'pgsql';
            case Sqlite::class:
            case is_a($driver, Sqlite::class, true):
                return 'sqlite';
            case Sqlserver::class:
            case is_a($driver, Sqlserver::class, true):
                return 'sqlsrv';
        }

        throw new InvalidArgumentException('Could not infer database type from driver');
    }

    /**
     * Returns the connection name that should be used for the migrations.
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input the input object
     * @return string
     */
    protected function getConnectionName(InputInterface $input): string
    {
        return $input->getOption('connection') ?: 'default';
    }

    /**
     * Translates driver specific connection flags (PDO attributes) to
     * Phinx compatible adapter options.
     *
     * Currently Phinx supports of the following flags:
     *
     * - *Most* of `PDO::ATTR_*`
     * - `PDO::MYSQL_ATTR_*`
     * - `PDO::PGSQL_ATTR_*`
     * - `PDO::SQLSRV_ATTR_*`
     *
     * ### Example:
     *
     * ```
     * [
     *     \PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
     *     \PDO::SQLSRV_ATTR_DIRECT_QUERY => true,
     *     // ...
     * ]
     * ```
     *
     * will be translated to:
     *
     * ```
     * [
     *     'mysql_attr_ssl_verify_server_cert' => false,
     *     'sqlsrv_attr_direct_query' => true,
     *     // ...
     * ]
     * ```
     *
     * @param array $flags An array of connection flags.
     * @param string $adapterName The adapter name, eg `mysql` or `sqlsrv`.
     * @return array An array of Phinx compatible connection attribute options.
     */
    protected function translateConnectionFlags(array $flags, string $adapterName): array
    {
        $pdo = new ReflectionClass(PDO::class);
        $constants = $pdo->getConstants();

        $attributes = [];
        foreach ($constants as $name => $value) {
            $name = strtolower($name);
            if (strpos($name, "{$adapterName}_attr_") === 0 || strpos($name, 'attr_') === 0) {
                $attributes[$value] = $name;
            }
        }

        $options = [];
        foreach ($flags as $flag => $value) {
            if (isset($attributes[$flag])) {
                $options[$attributes[$flag]] = $value;
            }
        }

        return $options;
    }

    /**
     * Extracts DSN options from the connection configuration.
     *
     * @param string $adapterName The adapter name.
     * @param array $config The connection configuration.
     * @return array
     */
    protected function extractDsnOptions(string $adapterName, array $config): array
    {
        $dsnOptionsMap = [];

        // SQLServer is currently the only Phinx adapter that supports DSN options
        if ($adapterName === 'sqlsrv') {
            $dsnOptionsMap = [
                'connectionPooling' => 'ConnectionPooling',
                'failoverPartner' => 'Failover_Partner',
                'loginTimeout' => 'LoginTimeout',
                'multiSubnetFailover' => 'MultiSubnetFailover',
                'encrypt' => 'Encrypt',
                'trustServerCertificate' => 'TrustServerCertificate',
            ];
        }

        $suppliedDsnOptions = array_intersect_key($dsnOptionsMap, $config);

        $dsnOptions = [];
        foreach ($suppliedDsnOptions as $alias => $option) {
            $dsnOptions[$option] = $config[$alias];
        }

        return $dsnOptions;
    }
}
