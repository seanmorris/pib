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
namespace Migrations\Command;

use Cake\Command\Command;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Migrations\MigrationsDispatcher;
use Symfony\Component\Console\Input\ArgvInput;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * A wrapper command for phinx migrations, used to inject our own
 * console actions so that database configuration already defined
 * for the application can be reused.
 *
 * @property \Migrations\Command\Phinx\Create $Create
 * @property \Migrations\Command\Phinx\Dump $Dump
 * @property \Migrations\Command\Phinx\MarkMigrated $MarkMigrated
 * @property \Migrations\Command\Phinx\Migrate $Migrate
 * @property \Migrations\Command\Phinx\Rollback $Rollback
 * @property \Migrations\Command\Phinx\Status $Status
 */
class MigrationsCommand extends Command
{
    /**
     * Phinx command name.
     *
     * @var string
     */
    protected static string $commandName = '';

    /**
     * @inheritDoc
     */
    public static function defaultName(): string
    {
        if (parent::defaultName() === 'migrations') {
            return 'migrations';
        }
        $command = new MigrationsDispatcher::$phinxCommands[static::$commandName]();
        $name = $command->getName();

        return 'migrations ' . $name;
    }

    /**
     * Array of arguments to run the shell with.
     *
     * @var array<string>
     */
    public array $argv = [];

    /**
     * Defines what options can be passed to the shell.
     * This is required because CakePHP validates the passed options
     * and would complain if something not configured here is present
     *
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function getOptionParser(): ConsoleOptionParser
    {
        if ($this->defaultName() === 'migrations') {
            return parent::getOptionParser();
        }
        $parser = parent::getOptionParser();
        $command = new MigrationsDispatcher::$phinxCommands[static::$commandName]();
        $parser->setDescription($command->getDescription());
        $definition = $command->getDefinition();
        foreach ($definition->getOptions() as $option) {
            if (!empty($option->getShortcut())) {
                $parser->addOption($option->getName(), [
                    'short' => $option->getShortcut(),
                    'help' => $option->getDescription(),
                    ]);
                continue;
            }
            $parser->addOption($option->getName());
        }

        return $parser;
    }

    /**
     * Defines constants that are required by phinx to get running
     *
     * @return void
     */
    public function initialize(): void
    {
        if (!defined('PHINX_VERSION')) {
            define('PHINX_VERSION', 'UNKNOWN');
        }
        parent::initialize();
    }

    /**
     * This acts as a front-controller for phinx. It just instantiates the classes
     * responsible for parsing the command line from phinx and gives full control of
     * the rest of the flow to it.
     *
     * The input parameter of the ``MigrationDispatcher::run()`` method is manually built
     * in case a MigrationsShell is dispatched using ``Shell::dispatch()``.
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return null|int The exit code or null for success
     */
    public function execute(Arguments $args, ConsoleIo $io): ?int
    {
        $app = $this->getApp();
        $input = new ArgvInput($this->argv);
        $app->setAutoExit(false);
        $exitCode = $app->run($input, $this->getOutput());

        if (in_array('-h', $this->argv, true) || in_array('--help', $this->argv, true)) {
            return $exitCode;
        }

        if (
            isset($this->argv[1]) && in_array($this->argv[1], ['migrate', 'rollback'], true) &&
            !in_array('--no-lock', $this->argv, true) &&
            $exitCode === 0
        ) {
            $newArgs = [];
            if (!empty($args->getOption('connection'))) {
                $newArgs[] = '-c';
                $newArgs[] = $args->getOption('connection');
            }

            if (!empty($args->getOption('plugin'))) {
                $newArgs[] = '-p';
                $newArgs[] = $args->getOption('plugin');
            }

            $io->out('');
            $io->out('Dumps the current schema of the database to be used while baking a diff');
            $io->out('');

            $dumpExitCode = $this->executeCommand(MigrationsDumpCommand::class, $newArgs, $io);
        }

        if (isset($dumpExitCode) && $exitCode === 0 && $dumpExitCode !== 0) {
            $exitCode = 1;
        }

        return $exitCode;
    }

    /**
     * Returns the MigrationsDispatcher the Shell will have to use
     *
     * @return \Migrations\MigrationsDispatcher
     */
    protected function getApp(): MigrationsDispatcher
    {
        return new MigrationsDispatcher(PHINX_VERSION);
    }

    /**
     * Returns the instance of OutputInterface the MigrationsDispatcher will have to use.
     *
     * @return \Symfony\Component\Console\Output\OutputInterface
     */
    protected function getOutput(): OutputInterface
    {
        return new ConsoleOutput();
    }

    /**
     * Override the default behavior to save the command called
     * in order to pass it to the command dispatcher
     *
     * @param array $argv Arguments from the CLI environment.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return int|null Exit code or null for success.
     */
    public function run(array $argv, ConsoleIo $io): ?int
    {
        $name = static::defaultName();
        $name = explode(' ', $name);

        array_unshift($argv, ...$name);
        $this->argv = $argv;

        return parent::run($argv, $io);
    }

    /**
     * Output help content
     *
     * @param \Cake\Console\ConsoleOptionParser $parser The option parser.
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return void
     */
    protected function displayHelp(ConsoleOptionParser $parser, Arguments $args, ConsoleIo $io): void
    {
        $this->execute($args, $io);
    }
}
