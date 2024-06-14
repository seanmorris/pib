<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link          http://cakephp.org CakePHP(tm) Project
 * @since         5.0.0
 * @license       http://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Model\Table;

use Cake\Core\Configure;
use Cake\Error\Debugger;
use Cake\ORM\Query\DeleteQuery;
use Cake\ORM\Query\SelectQuery;
use Cake\ORM\Query\UpdateQuery;

/**
 * Add this trait to your Table class to append the file reference of where a Query object was created.
 *
 * @mixin \Cake\ORM\Table
 */
trait SqlTraceTrait
{
    /**
     * Overwrite parent table method to inject SQL comment
     */
    public function selectQuery(): SelectQuery
    {
        return $this->fileStamp(parent::selectQuery());
    }

    /**
     * Overwrite parent table method to inject SQL comment
     */
    public function updateQuery(): UpdateQuery
    {
        return $this->fileStamp(parent::updateQuery());
    }

    /**
     * Overwrite parent table method to inject SQL comment
     */
    public function deleteQuery(): DeleteQuery
    {
        return $this->fileStamp(parent::deleteQuery());
    }

    /**
     * Applies a comment to a query about which file created it.
     *
     * @template T of \Cake\ORM\Query\SelectQuery|\Cake\ORM\Query\UpdateQuery|\Cake\ORM\Query\DeleteQuery
     * @param \Cake\ORM\Query\SelectQuery|\Cake\ORM\Query\UpdateQuery|\Cake\ORM\Query\DeleteQuery $query The Query to insert a comment into.
     * @psalm-param T $query
     * @param int $start How many entries in the stack trace to skip.
     * @param bool $debugOnly False to always stamp queries with a comment.
     * @return \Cake\ORM\Query\SelectQuery|\Cake\ORM\Query\UpdateQuery|\Cake\ORM\Query\DeleteQuery
     * @psalm-return T
     */
    protected function fileStamp(
        SelectQuery|UpdateQuery|DeleteQuery $query,
        int $start = 1,
        bool $debugOnly = true
    ): SelectQuery|UpdateQuery|DeleteQuery {
        if (!Configure::read('debug') && $debugOnly === true) {
            return $query;
        }

        $traces = Debugger::trace(['start' => $start, 'format' => 'array']);
        $file = '[unknown]';
        $line = '??';

        if (is_array($traces)) {
            foreach ($traces as $trace) {
                $path = $trace['file'];
                $line = $trace['line'];
                $file = Debugger::trimPath($path);
                if ($path === '[internal]') {
                    continue;
                }
                if (defined('CAKE_CORE_INCLUDE_PATH') && strpos($path, CAKE_CORE_INCLUDE_PATH) !== 0) {
                    break;
                }
            }
        }

        return $query->comment(sprintf('%s (line %s)', $file, $line));
    }
}
