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
 * @since         DebugKit 1.3
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Model\Behavior;

use Cake\Event\EventInterface;
use Cake\ORM\Behavior;
use Cake\ORM\Query\SelectQuery;
use DebugKit\DebugTimer;

/**
 * Class TimedBehavior
 */
class TimedBehavior extends Behavior
{
    /**
     * beforeFind, starts a timer for a find operation.
     *
     * @param \Cake\Event\EventInterface $event The beforeFind event
     * @param \Cake\ORM\Query\SelectQuery $query SelectQuery
     * @return \Cake\ORM\Query\SelectQuery
     */
    public function beforeFind(EventInterface $event, SelectQuery $query): SelectQuery
    {
        /** @var \Cake\Datasource\RepositoryInterface $table */
        $table = $event->getSubject();
        $alias = $table->getAlias();
        DebugTimer::start($alias . '_find', $alias . '->find()');

        return $query->formatResults(function ($results) use ($alias) {
            DebugTimer::stop($alias . '_find');

            return $results;
        });
    }

    /**
     * beforeSave, starts a time before a save is initiated.
     *
     * @param \Cake\Event\EventInterface $event The beforeSave event
     * @return void
     */
    public function beforeSave(EventInterface $event): void
    {
        /** @var \Cake\Datasource\RepositoryInterface $table */
        $table = $event->getSubject();
        $alias = $table->getAlias();
        DebugTimer::start($alias . '_save', $alias . '->save()');
    }

    /**
     * afterSave, stop the timer started from a save.
     *
     * @param \Cake\Event\EventInterface $event The afterSave event
     * @return void
     */
    public function afterSave(EventInterface $event): void
    {
        /** @var \Cake\Datasource\RepositoryInterface $table */
        $table = $event->getSubject();
        $alias = $table->getAlias();
        DebugTimer::stop($alias . '_save');
    }
}
