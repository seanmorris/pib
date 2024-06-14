<?php
declare(strict_types=1);

namespace Migrations\Command\Phinx;

use Migrations\Util\SchemaTrait;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class CacheBuild extends BaseCommand
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
            ->setName('orm-cache-build')
            ->setDescription(
                'Build all metadata caches for the connection. ' .
                'If a table name is provided, only that table will be cached.'
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
        /** @var string $name */
        $name = $input->getArgument('name');
        $schema = $this->_getSchema($input, $output);
        if (!$schema) {
            return static::CODE_ERROR;
        }
        $tables = [$name];
        if (empty($name)) {
            $tables = $schema->listTables();
        }
        foreach ($tables as $table) {
            $output->writeln('Building metadata cache for ' . $table);
            $schema->describe($table, ['forceRefresh' => true]);
        }
        $output->writeln('<info>Cache build complete</info>');

        return static::CODE_SUCCESS;
    }
}
