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
namespace Migrations\Command\Phinx;

use Cake\Event\EventDispatcherTrait;
use Migrations\ConfigurationTrait;
use Phinx\Console\Command\Rollback as RollbackCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class Rollback extends RollbackCommand
{
    use CommandTrait {
        execute as parentExecute;
    }
    use ConfigurationTrait;
    /**
     * @use \Cake\Event\EventDispatcherTrait<\Migrations\Command\Phinx\Rollback>
     */
    use EventDispatcherTrait;

    /**
     * Configures the current command.
     *
     * @return void
     */
    protected function configure(): void
    {
        $this->setName('rollback')
            ->setDescription('Rollback the last or to a specific migration')
            ->setHelp('reverts the last migration, or optionally up to a specific version')
            ->addOption('--target', '-t', InputOption::VALUE_REQUIRED, 'The version number to rollback to')
            ->addOption('--date', '-d', InputOption::VALUE_REQUIRED, 'The date to migrate to')
            ->addOption('--plugin', '-p', InputOption::VALUE_REQUIRED, 'The plugin containing the migrations')
            ->addOption('--connection', '-c', InputOption::VALUE_REQUIRED, 'The datasource connection to use')
            ->addOption('--source', '-s', InputOption::VALUE_REQUIRED, 'The folder where migrations are in')
            ->addOption('--force', '-f', InputOption::VALUE_NONE, 'Force rollback to ignore breakpoints')
            ->addOption(
                '--dry-run',
                '-x',
                InputOption::VALUE_NONE,
                'Dump queries to standard output instead of executing it'
            )
            ->addOption(
                '--fake',
                null,
                InputOption::VALUE_NONE,
                "Mark any rollbacks selected as run, but don't actually execute them"
            )
            ->addOption(
                '--no-lock',
                null,
                InputOption::VALUE_NONE,
                'Whether a lock file should be generated after rolling back'
            );
    }

    /**
     * Overrides the action execute method in order to vanish the idea of environments
     * from phinx. CakePHP does not believe in the idea of having in-app environments
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input the input object
     * @param \Symfony\Component\Console\Output\OutputInterface $output the output object
     * @return int
     */
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $event = $this->dispatchEvent('Migration.beforeRollback');
        if ($event->isStopped()) {
            return $event->getResult() ? BaseCommand::CODE_SUCCESS : BaseCommand::CODE_ERROR;
        }
        $result = $this->parentExecute($input, $output);
        $this->dispatchEvent('Migration.afterRollback');

        return $result;
    }
}
