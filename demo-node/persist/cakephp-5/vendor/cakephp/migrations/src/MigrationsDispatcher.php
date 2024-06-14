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

use Migrations\Command\Phinx;
use Symfony\Component\Console\Application;

/**
 * Used to register all supported subcommand in order to make
 * them executable by the Symfony Console component
 */
class MigrationsDispatcher extends Application
{
    /**
     * @var array<string, string>
     * @psalm-var array<string, class-string<\Phinx\Console\Command\AbstractCommand>|class-string<\Migrations\Command\Phinx\BaseCommand>>
     */
    public static array $phinxCommands = [
        'Create' => Phinx\Create::class,
        'Dump' => Phinx\Dump::class,
        'MarkMigrated' => Phinx\MarkMigrated::class,
        'Migrate' => Phinx\Migrate::class,
        'Rollback' => Phinx\Rollback::class,
        'Seed' => Phinx\Seed::class,
        'Status' => Phinx\Status::class,
        'CacheBuild' => Phinx\CacheBuild::class,
        'CacheClear' => Phinx\CacheClear::class,
    ];

    /**
     * Initialize the Phinx console application.
     *
     * @param string $version The Application Version
     */
    public function __construct(string $version)
    {
        parent::__construct('Migrations plugin, based on Phinx by Rob Morgan.', $version);
        foreach (static::$phinxCommands as $value) {
            $this->add(new $value());
        }
        $this->setCatchExceptions(false);
    }
}
