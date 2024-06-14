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

use Bake\Command\SimpleBakeCommand;
use Cake\Console\CommandCollection;
use Cake\Core\BasePlugin;
use Migrations\Command\MigrationsCacheBuildCommand;
use Migrations\Command\MigrationsCacheClearCommand;
use Migrations\Command\MigrationsCommand;
use Migrations\Command\MigrationsCreateCommand;
use Migrations\Command\MigrationsDumpCommand;
use Migrations\Command\MigrationsMarkMigratedCommand;
use Migrations\Command\MigrationsMigrateCommand;
use Migrations\Command\MigrationsRollbackCommand;
use Migrations\Command\MigrationsSeedCommand;
use Migrations\Command\MigrationsStatusCommand;

/**
 * Plugin class for migrations
 */
class MigrationsPlugin extends BasePlugin
{
    /**
     * Plugin name.
     */
    protected ?string $name = 'Migrations';

    /**
     * Don't try to load routes.
     */
    protected bool $routesEnabled = false;

    /**
     * @var array<string>
     * @psalm-var array<class-string<\Cake\Console\BaseCommand>>
     */
    protected array $migrationCommandsList = [
        MigrationsCommand::class,
        MigrationsCreateCommand::class,
        MigrationsDumpCommand::class,
        MigrationsMarkMigratedCommand::class,
        MigrationsMigrateCommand::class,
        MigrationsCacheBuildCommand::class,
        MigrationsCacheClearCommand::class,
        MigrationsRollbackCommand::class,
        MigrationsSeedCommand::class,
        MigrationsStatusCommand::class,
    ];

    /**
     * Add migrations commands.
     *
     * @param \Cake\Console\CommandCollection $commands The command collection to update
     * @return \Cake\Console\CommandCollection
     */
    public function console(CommandCollection $commands): CommandCollection
    {
        if (class_exists(SimpleBakeCommand::class)) {
            $found = $commands->discoverPlugin($this->getName());

            return $commands->addMany($found);
        }
        $found = [];
        foreach ($this->migrationCommandsList as $class) {
            $name = $class::defaultName();
            // If the short name has been used, use the full name.
            // This allows app commands to have name preference.
            // and app commands to overwrite migration commands.
            if (!$commands->has($name)) {
                $found[$name] = $class;
            }
            // full name
            $found['migrations.' . $name] = $class;
        }

        return $commands->addMany($found);
    }
}
