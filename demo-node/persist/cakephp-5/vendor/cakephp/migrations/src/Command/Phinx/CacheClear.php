<?php
declare(strict_types=1);

namespace Migrations\Command\Phinx;

use Migrations\Util\SchemaTrait;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class CacheClear extends BaseCommand
{
    use SchemaTrait;

    /**
     * Configures the current command.
     *
     * @return void
     */
    protected function configure(): void
    {
        $this
            ->setName('orm-cache-clear')
            ->setDescription(
                'Clear all metadata caches for the connection. ' .
                'If a table name is provided, only that table will be removed.'
            )
            ->addOption(
                'connection',
                null,
                InputOption::VALUE_OPTIONAL,
                'The connection to build/clear metadata cache data for.',
                'default'
            )
            ->addArgument(
                'name',
                InputArgument::OPTIONAL,
                'A specific table you want to clear/refresh cached data for.'
            );
    }

    /**
     * @inheritDoc
     */
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $schema = $this->_getSchema($input, $output);
        /** @var string $name */
        $name = $input->getArgument('name');
        if (!$schema) {
            return static::CODE_ERROR;
        }
        $tables = [$name];
        if (empty($name)) {
            $tables = $schema->listTables();
        }
        $cacher = $schema->getCacher();
        foreach ($tables as $table) {
            $output->writeln(sprintf(
                'Clearing metadata cache for %s',
                $table
            ));
            $cacher->delete($table);
        }
        $output->writeln('<info>Cache clear complete<info>');

        return static::CODE_SUCCESS;
    }
}
