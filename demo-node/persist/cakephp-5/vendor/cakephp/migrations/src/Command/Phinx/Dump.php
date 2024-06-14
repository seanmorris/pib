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

use Cake\Database\Connection;
use Cake\Datasource\ConnectionManager;
use Migrations\ConfigurationTrait;
use Migrations\TableFinderTrait;
use Phinx\Console\Command\AbstractCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * Dump command class.
 * A "dump" is a snapshot of a database at a given point in time. It is stored in a
 * .lock file in the same folder as migrations files.
 */
class Dump extends AbstractCommand
{
    use CommandTrait;
    use ConfigurationTrait;
    use TableFinderTrait;

    /**
     * Output object.
     *
     * @var \Symfony\Component\Console\Output\OutputInterface
     */
    protected ?OutputInterface $output = null;

    /**
     * Configures the current command.
     *
     * @return void
     */
    protected function configure(): void
    {
        $this->setName('dump')
            ->setDescription('Dumps the current schema of the database to be used while baking a diff')
            ->setHelp(sprintf(
                '%sDumps the current schema of the database to be used while baking a diff%s',
                PHP_EOL,
                PHP_EOL
            ))
            ->addOption('plugin', 'p', InputOption::VALUE_REQUIRED, 'The plugin the file should be created for')
            ->addOption('connection', 'c', InputOption::VALUE_REQUIRED, 'The datasource connection to use')
            ->addOption('source', 's', InputOption::VALUE_REQUIRED, 'The folder where migrations are in');
    }

    /**
     * @param \Symfony\Component\Console\Output\OutputInterface $output The output object.
     * @return \Symfony\Component\Console\Output\OutputInterface|null
     */
    public function output(?OutputInterface $output = null): ?OutputInterface
    {
        if ($output !== null) {
            $this->output = $output;
        }

        return $this->output;
    }

    /**
     * Dumps the current schema to be used when baking a diff
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input the input object
     * @param \Symfony\Component\Console\Output\OutputInterface $output the output object
     * @return int
     */
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $this->setInput($input);
        $this->bootstrap($input, $output);
        $this->output($output);

        $path = $this->getOperationsPath($input);
        /** @var string $connectionName */
        $connectionName = $input->getOption('connection') ?: 'default';
        $connection = ConnectionManager::get($connectionName);
        assert($connection instanceof Connection);
        $collection = $connection->getSchemaCollection();

        $options = [
            'require-table' => false,
            'plugin' => $this->getPlugin($input),
        ];
        $tables = $this->getTablesToBake($collection, $options);

        $dump = [];
        if ($tables) {
            foreach ($tables as $table) {
                $schema = $collection->describe($table);
                $dump[$table] = $schema;
            }
        }

        $filePath = $path . DS . 'schema-dump-' . $connectionName . '.lock';
        $output->writeln(sprintf('<info>Writing dump file `%s`...</info>', $filePath));
        if (file_put_contents($filePath, serialize($dump))) {
            $output->writeln(sprintf('<info>Dump file `%s` was successfully written</info>', $filePath));

            return BaseCommand::CODE_SUCCESS;
        }

        $output->writeln(sprintf(
            '<error>An error occurred while writing dump file `%s`</error>',
            $filePath
        ));

        return BaseCommand::CODE_ERROR;
    }
}
