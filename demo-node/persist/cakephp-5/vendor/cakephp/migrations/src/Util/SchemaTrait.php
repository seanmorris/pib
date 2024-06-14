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
namespace Migrations\Util;

use Cake\Database\Schema\CachedCollection;
use Cake\Datasource\ConnectionManager;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * Trait gathering schema collection used for caching
 */
trait SchemaTrait
{
    /**
     * Helper method to get the schema collection.
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input Input object.
     * @param \Symfony\Component\Console\Output\OutputInterface $output Output object.
     * @return \Cake\Database\Schema\CachedCollection|null
     */
    protected function _getSchema(InputInterface $input, OutputInterface $output): ?CachedCollection
    {
        /** @var string $connectionName */
        $connectionName = $input->getOption('connection');
        /** @var \Cake\Database\Connection $connection */
        $connection = ConnectionManager::get($connectionName);

        if (!method_exists($connection, 'getSchemaCollection')) {
            $msg = sprintf(
                'The "%s" connection is not compatible with orm caching, ' .
                'as it does not implement a "getSchemaCollection()" method.',
                $connectionName
            );
            $output->writeln('<error>' . $msg . '</error>');

            return null;
        }

        $config = $connection->config();

        if (empty($config['cacheMetadata'])) {
            $output->writeln('Metadata cache was disabled in config. Enable to cache or clear.');

            return null;
        }

        $connection->cacheMetadata(true);

        /**
         * @var \Cake\Database\Schema\CachedCollection
         */
        return $connection->getSchemaCollection();
    }
}
