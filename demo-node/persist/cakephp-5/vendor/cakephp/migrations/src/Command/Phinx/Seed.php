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
use Phinx\Console\Command\SeedRun;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class Seed extends SeedRun
{
    use CommandTrait {
        execute as parentExecute;
    }
    use ConfigurationTrait;
    /**
     * @use \Cake\Event\EventDispatcherTrait<\Migrations\Command\Phinx\Seed>
     */
    use EventDispatcherTrait;

    /**
     * Configures the current command.
     *
     * @return void
     */
    protected function configure(): void
    {
        $this->setName('seed')
            ->setDescription('Seed the database with data')
            ->setHelp('runs all available migrations, optionally up to a specific version')
            ->addOption(
                '--seed',
                null,
                InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY,
                'What is the name of the seeder?'
            )
            ->addOption('--plugin', '-p', InputOption::VALUE_REQUIRED, 'The plugin containing the migrations')
            ->addOption('--connection', '-c', InputOption::VALUE_REQUIRED, 'The datasource connection to use')
            ->addOption('--source', '-s', InputOption::VALUE_REQUIRED, 'The folder where migrations are in');
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
        $event = $this->dispatchEvent('Migration.beforeSeed');
        if ($event->isStopped()) {
            return $event->getResult() ? BaseCommand::CODE_SUCCESS : BaseCommand::CODE_ERROR;
        }

        $seed = $input->getOption('seed');
        if (!empty($seed) && !is_array($seed)) {
            $input->setOption('seed', [$seed]);
        }

        $this->setInput($input);
        $this->bootstrap($input, $output);
        $this->getManager()->setInput($input);
        $result = $this->parentExecute($input, $output);
        $this->dispatchEvent('Migration.afterSeed');

        return $result;
    }
}
