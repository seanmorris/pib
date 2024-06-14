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

/**
 * Task class for creating all view template files.
 */
class TemplateAllCommand extends BakeCommand
{
    /**
     * @var \Bake\Command\TemplateCommand
     */
    protected TemplateCommand $templateCommand;

    /**
     * @inheritDoc
     */
    public static function defaultName(): string
    {
        return 'bake template all';
    }

    /**
     * initialize
     *
     * @return void
     */
    public function initialize(): void
    {
        parent::initialize();
        $this->templateCommand = new TemplateCommand();
    }

    /**
     * Execute the command.
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return int The exit code
     */
    public function execute(Arguments $args, ConsoleIo $io): int
    {
        $this->extractCommonProperties($args);
        /** @var \Cake\Database\Connection $connection */
        $connection = ConnectionManager::get($this->connection);
        $scanner = new TableScanner($connection);

        foreach ($scanner->listUnskipped() as $table) {
            $templateArgs = new Arguments([$table], $args->getOptions(), ['name']);
            $this->templateCommand->execute($templateArgs, $io);
        }

        return static::CODE_SUCCESS;
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @param \Cake\Console\ConsoleOptionParser $parser The option parser to update.
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser = $this->_setCommonOptions($parser);
        $parser
            ->setDescription('Bake all view template files.')
            ->addOption('prefix', [
                'help' => 'The routing prefix to generate views for.',
            ])->addOption('index-columns', [
                'help' => 'Limit for the number of index columns',
                'default' => '0',
            ]);

        return $parser;
    }
}
