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

use Cake\Datasource\ConnectionManager;
use Migrations\CakeAdapter;
use Migrations\CakeManager;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

trait CommandTrait
{
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
        $this->beforeExecute($input, $output);

        return parent::execute($input, $output);
    }

    /**
     * Overrides the action execute method in order to vanish the idea of environments
     * from phinx. CakePHP does not believe in the idea of having in-app environments
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input the input object
     * @param \Symfony\Component\Console\Output\OutputInterface $output the output object
     * @return void
     */
    protected function beforeExecute(InputInterface $input, OutputInterface $output): void
    {
        $this->setInput($input);
        $this->addOption('--environment', '-e', InputArgument::OPTIONAL);
        $input->setOption('environment', 'default');
    }

    /**
     * A callback method that is used to inject the PDO object created from phinx into
     * the CakePHP connection. This is needed in case the user decides to use tables
     * from the ORM and executes queries.
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input the input object
     * @param \Symfony\Component\Console\Output\OutputInterface $output the output object
     * @return void
     */
    public function bootstrap(InputInterface $input, OutputInterface $output): void
    {
        parent::bootstrap($input, $output);
        $name = $this->getConnectionName($input);
        $this->connection = $name;
        ConnectionManager::alias($name, 'default');
        /** @var \Cake\Database\Connection $connection */
        $connection = ConnectionManager::get($name);

        $manager = $this->getManager();

        if (!$manager instanceof CakeManager) {
            $this->setManager(new CakeManager($this->getConfig(), $input, $output));
        }
        /** @var \Phinx\Migration\Manager\Environment $env */
        /** @psalm-suppress PossiblyNullReference */
        $env = $this->getManager()->getEnvironment('default');
        $adapter = $env->getAdapter();
        if (!$adapter instanceof CakeAdapter) {
            $env->setAdapter(new CakeAdapter($adapter, $connection));
        }
    }

    /**
     * Sets the input object that should be used for the command class. This object
     * is used to inspect the extra options that are needed for CakePHP apps.
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input the input object
     * @return void
     */
    public function setInput(InputInterface $input): void
    {
        $this->input = $input;
    }
}
