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
namespace Migrations;

use Migrations\Command\Phinx\Seed;
use Phinx\Seed\AbstractSeed as BaseAbstractSeed;
use Symfony\Component\Console\Input\ArgvInput;
use Symfony\Component\Console\Input\InputInterface;
use function Cake\Core\pluginSplit;

/**
 * Class AbstractSeed
 * Extends Phinx base AbstractSeed class in order to extend the features the seed class
 * offers.
 */
abstract class AbstractSeed extends BaseAbstractSeed
{
    /**
     * InputInterface this Seed class is being used with.
     *
     * @var \Symfony\Component\Console\Input\InputInterface
     */
    protected InputInterface $input;

    /**
     * Gives the ability to a seeder to call another seeder.
     * This is particularly useful if you need to run the seeders of your applications in a specific sequences,
     * for instance to respect foreign key constraints.
     *
     * @param string $seeder Name of the seeder to call from the current seed
     * @return void
     */
    public function call(string $seeder): void
    {
        $this->getOutput()->writeln('');
        $this->getOutput()->writeln(
            ' ====' .
            ' <info>' . $seeder . ':</info>' .
            ' <comment>seeding</comment>'
        );

        $start = microtime(true);
        $this->runCall($seeder);
        $end = microtime(true);

        $this->getOutput()->writeln(
            ' ====' .
            ' <info>' . $seeder . ':</info>' .
            ' <comment>seeded' .
            ' ' . sprintf('%.4fs', $end - $start) . '</comment>'
        );
        $this->getOutput()->writeln('');
    }

    /**
     * Calls another seeder from this seeder.
     * It will load the Seed class you are calling and run it.
     *
     * @param string $seeder Name of the seeder to call from the current seed
     * @return void
     */
    protected function runCall(string $seeder): void
    {
        [$pluginName, $seeder] = pluginSplit($seeder);

        $argv = [
            'seed',
            '--seed',
            $seeder,
        ];

        $plugin = $pluginName ?: $this->input->getOption('plugin');
        if ($plugin !== null) {
            $argv[] = '--plugin';
            $argv[] = $plugin;
        }

        $connection = $this->input->getOption('connection');
        if ($connection !== null) {
            $argv[] = '--connection';
            $argv[] = $connection;
        }

        $source = $this->input->getOption('source');
        if ($source !== null) {
            $argv[] = '--source';
            $argv[] = $source;
        }

        $seedCommand = new Seed();
        $input = new ArgvInput($argv, $seedCommand->getDefinition());
        $seedCommand->setInput($input);
        $config = $seedCommand->getConfig();

        $seedPaths = $config->getSeedPaths();
        require_once array_pop($seedPaths) . DS . $seeder . '.php';
        /** @var \Phinx\Seed\SeedInterface $seeder */
        $seeder = new $seeder();
        $seeder->setOutput($this->getOutput());
        $seeder->setAdapter($this->getAdapter());
        $seeder->setInput($this->input);
        $seeder->run();
    }

    /**
     * Sets the InputInterface this Seed class is being used with.
     *
     * @param \Symfony\Component\Console\Input\InputInterface $input Input object.
     * @return $this
     */
    public function setInput(InputInterface $input)
    {
        $this->input = $input;

        return $this;
    }
}
