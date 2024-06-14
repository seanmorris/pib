<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         0.1.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\Utility\Model;

use Cake\ORM\Table;
use Cake\Utility\Inflector;
use Exception;
use function Cake\Core\namespaceSplit;

/**
 * Utility class to filter Model Table associations
 */
class AssociationFilter
{
    /**
     * Detect existing belongsToMany associations and cleanup the hasMany aliases based on existing
     * belongsToMany associations provided
     *
     * @param \Cake\ORM\Table $table Table
     * @param array<string> $aliases array of aliases
     * @return array<string> $aliases
     */
    public function filterHasManyAssociationsAliases(Table $table, array $aliases): array
    {
        $belongsToManyJunctionsAliases = $this->belongsToManyJunctionAliases($table);

        return array_values(array_diff($aliases, $belongsToManyJunctionsAliases));
    }

    /**
     * Get the array of junction aliases for all the BelongsToMany associations
     *
     * @param \Cake\ORM\Table $table Table
     * @return array<string> Junction aliases of all the BelongsToMany associations
     */
    public function belongsToManyJunctionAliases(Table $table): array
    {
        $extractor = function ($val) {
            return $val->junction()->getAlias();
        };

        return array_map($extractor, $table->associations()->getByType('BelongsToMany'));
    }

    /**
     * Returns filtered associations for controllers models. HasMany association are filtered if
     * already existing in BelongsToMany
     *
     * @param \Cake\ORM\Table $model The model to build associations for.
     * @return array associations
     */
    public function filterAssociations(Table $model): array
    {
        $belongsToManyJunctionsAliases = $this->belongsToManyJunctionAliases($model);
        $keys = ['BelongsTo', 'HasOne', 'HasMany', 'BelongsToMany'];
        $associations = [];

        foreach ($keys as $type) {
            foreach ($model->associations()->getByType($type) as $assoc) {
                $target = $assoc->getTarget();
                $assocName = $assoc->getName();
                $alias = $target->getAlias();
                //filter existing HasMany
                if ($type === 'HasMany' && in_array($alias, $belongsToManyJunctionsAliases)) {
                    continue;
                }
                $targetClass = get_class($target);
                [, $className] = namespaceSplit($targetClass);

                $navLink = true;
                $modelClass = get_class($model);
                if ($modelClass !== Table::class && $targetClass === $modelClass) {
                    $navLink = false;
                }

                $className = preg_replace('/(.*)Table$/', '\1', $className);
                if ($className === '') {
                    $className = $alias;
                }

                try {
                    $associations[$type][$assocName] = [
                        'property' => $assoc->getProperty(),
                        'variable' => Inflector::variable($assocName),
                        'primaryKey' => (array)$target->getPrimaryKey(),
                        'displayField' => $target->getDisplayField(),
                        'foreignKey' => $assoc->getForeignKey(),
                        'alias' => $alias,
                        'controller' => $className,
                        'fields' => $target->getSchema()->columns(),
                        'navLink' => $navLink,
                    ];
                } catch (Exception $e) {
                    // Do nothing it could be a bogus association name.
                }
            }
        }

        return $associations;
    }
}
