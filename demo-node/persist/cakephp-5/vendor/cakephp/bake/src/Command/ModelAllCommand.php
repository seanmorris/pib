<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         2.0.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\Command;

use Bake\Utility\TableScanner;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\Locator\LocatorAwareTrait;

/**
 * Command for generating all model files.
 */
class ModelAllCommand extends BakeCommand
{
    use LocatorAwareTrait;

    /**
     * @var \Bake\Command\ModelCommand
     */
    protected ModelCommand $modelCommand;

    /**
     * @inheritDoc
     */
    public static function defaultName(): string
    {
        return 'bake model all';
    }

    /**
     * initialize
     *
     * @return void
     */
    public function initialize(): void
    {
        parent::initialize();
        $this->modelCommand = new ModelCommand();
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @param \Cake\Console\ConsoleOptionParser $parser The parser to configure
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser = $this->modelCommand->buildOptionParser($parser);
        $parser
            ->setDescription('Bake all model files with associations and validation.')
            ->setEpilog('');

        return $parser;
    }

    /**
     * Execute the command.
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return int|null The exit code or null for success
     */
    public function execute(Arguments $args, ConsoleIo $io): ?int
    {
        $this->extractCommonProperties($args);
        /** @var \Cake\Database\Connection $connection */
        $connection = ConnectionManager::get($this->connection);
        $scanner = new TableScanner($connection);
        foreach ($scanner->listUnskipped() as $table) {
            $this->getTableLocator()->clear();
            $modelArgs = new Arguments([$table], $args->getOptions(), ['name']);
            $this->modelCommand->execute($modelArgs, $io);
        }

        return static::CODE_SUCCESS;
    }
}
