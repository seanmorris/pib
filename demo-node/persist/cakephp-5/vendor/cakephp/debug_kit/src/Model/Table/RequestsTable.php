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
namespace DebugKit\Model\Table;

use Cake\Core\Configure;
use Cake\Database\Driver\Sqlite;
use Cake\Log\Log;
use Cake\ORM\Query\SelectQuery;
use Cake\ORM\Table;
use PDOException;

/**
 * The requests table tracks basic information about each request.
 *
 * @property \DebugKit\Model\Table\PanelsTable $Panels
 * @method \DebugKit\Model\Entity\Request get(mixed $primaryKey, array|string $finder = 'all', \Psr\SimpleCache\CacheInterface|string|null $cache = null, \Closure|string|null $cacheKey = null, ...$args)
 * @method \DebugKit\Model\Entity\Request newEntity($data = null, array $options = [])
 * @method \DebugKit\Model\Entity\Request[] newEntities(array $data, array $options = [])
 * @method \DebugKit\Model\Entity\Request save(\Cake\Datasource\EntityInterface $entity, $options = [])
 * @method \DebugKit\Model\Entity\Request patchEntity(\Cake\Datasource\EntityInterface $entity, array $data, array $options = [])
 * @method \DebugKit\Model\Entity\Request[] patchEntities($entities, array $data, array $options = [])
 * @method \DebugKit\Model\Entity\Request findOrCreate($search, callable $callback = null, array $options = [])
 */
class RequestsTable extends Table
{
    use LazyTableTrait;
    use SqlTraceTrait;

    /**
     * initialize method
     *
     * @param array $config Config data.
     * @return void
     */
    public function initialize(array $config): void
    {
        $this->hasMany('DebugKit.Panels', [
            'sort' => ['Panels.title' => 'ASC'],
        ]);
        $this->addBehavior('Timestamp', [
            'events' => [
                'Model.beforeSave' => ['requested_at' => 'new'],
            ],
        ]);
        $this->ensureTables(['requests', 'panels']);
    }

    /**
     * DebugKit tables are special.
     *
     * @return string
     */
    public static function defaultConnectionName(): string
    {
        return 'debug_kit';
    }

    /**
     * Finder method to get recent requests as a simple array
     *
     * @param \Cake\ORM\Query\SelectQuery $query The query
     * @return \Cake\ORM\Query\SelectQuery The query.
     */
    public function findRecent(SelectQuery $query): SelectQuery
    {
        return $query->orderBy(['Requests.requested_at' => 'DESC'])
            ->limit(10);
    }

    /**
     * Check if garbage collection should be run
     *
     * @return bool
     */
    protected function shouldGc(): bool
    {
        return rand(1, 100) === 100;
    }

    /**
     * Garbage collect old request data.
     *
     * Delete request data that is older than latest 20 requests.
     * You can use the `DebugKit.requestCount` config to change this limit.
     * This method will only trigger periodically.
     *
     * @return void
     */
    public function gc(): void
    {
        if (!$this->shouldGc()) {
            return;
        }

        try {
            $noPurge = $this->find()
                ->select(['id'])
                ->enableHydration(false)
                ->orderBy(['requested_at' => 'desc'])
                ->limit(Configure::read('DebugKit.requestCount') ?: 20)
                ->all()
                ->extract('id')
                ->toArray();

            if (empty($noPurge)) {
                return;
            }

            $query = $this->Panels->deleteQuery()
                ->where(['request_id NOT IN' => $noPurge]);
            $statement = $query->execute();
            $statement->closeCursor();

            $query = $this->deleteQuery()
                ->where(['id NOT IN' => $noPurge]);

            $statement = $query->execute();
            $statement->closeCursor();

            $conn = $this->getConnection();
            if ($conn->getDriver() instanceof Sqlite) {
                $conn->execute('VACUUM;');
            }
        } catch (PDOException $e) {
            Log::warning('Unable to garbage collect requests table. This is probably due to concurrent requests.');
            Log::warning((string)$e);
        }
    }
}
