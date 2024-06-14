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

use Cake\Utility\Inflector;
use Migrations\ConfigurationTrait;
use Phinx\Console\Command\Create as CreateCommand;
use Phinx\Util\Util;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class Create extends CreateCommand
{
    use CommandTrait {
        execute as parentExecute;
        beforeExecute as parentBeforeExecute;
    }
    use ConfigurationTrait;

    /**
     * Configures the current command.
     *
     * @return void
     */
    protected function configure(): void
    {
        $this->setName('create')
            ->setDescription('Create a new migration')
            ->addArgument('name', InputArgument::REQUIRED, 'What is the name of the migration?')
            ->setHelp(sprintf(
                '%sCreates a new database migration file%s',
                PHP_EOL,
                PHP_EOL
            ))
            ->addOption('plugin', 'p', InputOption::VALUE_REQUIRED, 'The plugin the file should be created for')
            ->addOption('connection', 'c', InputOption::VALUE_REQUIRED, 'The datasource connection to use')
            ->addOption('source', 's', InputOption::VALUE_REQUIRED, 'The folder where migrations are in')
            ->addOption('template', 't', InputOption::VALUE_REQUIRED, 'Use an alternative template')
            ->addOption(
                'class',
                'l',
                InputOption::VALUE_REQUIRED,
                'Use a class implementing "' . parent::CREATION_INTERFACE . '" to generate the template'
            )
            ->addOption(
                'path',
                null,
                InputOption::VALUE_REQUIRED,
                'Specify the path in which to create this migration'
            );
    }

    /**
     * Configures Phinx Create command CLI options that are unused by this extended
     * command.
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input the input object
     * @param \Symfony\Component\Console\Output\OutputInterface $output the output object
     * @return void
     */
    protected function beforeExecute(InputInterface $input, OutputInterface $output): void
    {
        // Set up as a dummy, its value is not going to be used, as a custom
        // template will always be set.
        $this->addOption('style', null, InputOption::VALUE_OPTIONAL);

        $this->parentBeforeExecute($input, $output);
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
        $result = $this->parentExecute($input, $output);

        $output->writeln('<info>renaming file in CamelCase to follow CakePHP convention...</info>');

        $migrationPaths = $this->getConfig()->getMigrationPaths();
        $migrationPath = array_pop($migrationPaths) . DS;
        /** @var string $name */
        $name = $input->getArgument('name');
        // phpcs:ignore SlevomatCodingStandard.Variables.UnusedVariable.UnusedVariable
        [$phinxTimestamp, $phinxName] = explode('_', Util::mapClassNameToFileName($name), 2);
        $migrationFilename = glob($migrationPath . '*' . $phinxName);

        if (empty($migrationFilename)) {
            $output->writeln('<info>An error occurred while renaming file</info>');
        } else {
            $migrationFilename = $migrationFilename[0];
            $path = dirname($migrationFilename) . DS;
            $name = Inflector::camelize($name);
            $newPath = $path . Util::getCurrentTimestamp() . '_' . $name . '.php';

            $output->writeln('<info>renaming file in CamelCase to follow CakePHP convention...</info>');
            if (rename($migrationFilename, $newPath)) {
                $output->writeln(sprintf('<info>File successfully renamed to %s</info>', $newPath));
            } else {
                $output->writeln(sprintf('<info>An error occurred while renaming file to %s</info>', $newPath));
            }
        }

        return $result;
    }
}
