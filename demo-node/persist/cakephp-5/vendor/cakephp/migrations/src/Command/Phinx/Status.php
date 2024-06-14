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

use Migrations\ConfigurationTrait;
use Phinx\Console\Command\Status as StatusCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * @method \Migrations\CakeManager getManager()
 */
class Status extends StatusCommand
{
    use CommandTrait;
    use ConfigurationTrait;

    /**
     * Configures the current command.
     *
     * @return void
     */
    protected function configure(): void
    {
        $this->setName('status')
            ->setDescription('Show migration status')
            ->addOption(
                '--format',
                '-f',
                InputOption::VALUE_REQUIRED,
                'The output format: text or json. Defaults to text.'
            )
            ->setHelp('prints a list of all migrations, along with their current status')
            ->addOption('--plugin', '-p', InputOption::VALUE_REQUIRED, 'The plugin containing the migrations')
            ->addOption('--connection', '-c', InputOption::VALUE_REQUIRED, 'The datasource connection to use')
            ->addOption('--source', '-s', InputOption::VALUE_REQUIRED, 'The folder where migrations are in');
    }

    /**
     * Show the migration status.
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input the input object
     * @param \Symfony\Component\Console\Output\OutputInterface $output the output object
     * @return int
     */
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $this->beforeExecute($input, $output);
        $this->bootstrap($input, $output);

        /** @var string|null $environment */
        $environment = $input->getOption('environment');
        /** @var string|null $format */
        $format = $input->getOption('format');

        if ($environment === null) {
            $environment = $this->getManager()->getConfig()->getDefaultEnvironment();
            $output->writeln('<comment>warning</comment> no environment specified, defaulting to: ' . $environment);
        } else {
            $output->writeln('<info>using environment</info> ' . $environment);
        }
        if ($format !== null) {
            $output->writeln('<info>using format</info> ' . $format);
        }

        $migrations = $this->getManager()->printStatus($environment, $format);

        switch ($format) {
            case 'json':
                $flags = 0;
                if ($input->getOption('verbose')) {
                    $flags = JSON_PRETTY_PRINT;
                }
                $migrationString = (string)json_encode($migrations, $flags);
                $this->getManager()->getOutput()->writeln($migrationString);
                break;
            default:
                $this->display($migrations);
                break;
        }

        return BaseCommand::CODE_SUCCESS;
    }

    /**
     * Will output the status of the migrations
     *
     * @param array<array<string, mixed>> $migrations Migrations array.
     * @return void
     */
    protected function display(array $migrations): void
    {
        $output = $this->getManager()->getOutput();

        if (!empty($migrations)) {
            $output->writeln('');
            $output->writeln(' Status  Migration ID    Migration Name ');
            $output->writeln('-----------------------------------------');

            foreach ($migrations as $migration) {
                $status = $migration['status'] === 'up' ? '     <info>up</info> ' : '   <error>down</error> ';
                $maxNameLength = $this->getManager()->maxNameLength;
                $name = $migration['name'] ?
                    ' <comment>' . str_pad($migration['name'], $maxNameLength, ' ') . ' </comment>' :
                    ' <error>** MISSING **</error>';

                $missingComment = '';
                if (!empty($migration['missing'])) {
                    $missingComment = ' <error>** MISSING **</error>';
                }

                $output->writeln(
                    $status .
                    sprintf(' %14.0f ', $migration['id']) .
                    $name .
                    $missingComment
                );
            }

            $output->writeln('');
        } else {
            $msg = 'There are no available migrations. Try creating one using the <info>create</info> command.';
            $output->writeln('');
            $output->writeln($msg);
            $output->writeln('');
        }
    }
}
