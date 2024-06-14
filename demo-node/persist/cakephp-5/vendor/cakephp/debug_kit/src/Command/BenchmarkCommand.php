<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         DebugKit 1.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Command;

use Cake\Command\Command;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Utility\Text;

/**
 * Benchmark Command Class
 *
 * Provides basic benchmarking of application requests
 * functionally similar to Apache AB
 *
 * @since         DebugKit 1.0
 */
class BenchmarkCommand extends Command
{
    /**
     * The console io
     *
     * @var \Cake\Console\ConsoleIo
     */
    protected ConsoleIo $io;

    /**
     * Execute.
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return int|null The exit code or null for success
     */
    public function execute(Arguments $args, ConsoleIo $io): ?int
    {
        $this->io = $io;
        /** @var string $url */
        $url = $args->getArgumentAt(0);
        $times = [];

        $io->out(Text::insert('-> Testing :url', compact('url')));
        $io->out('');
        $count = 10;
        if ($args->hasOption('n')) {
            $count = (float)$args->getOption('n');
        }
        $timeout = 100;
        if ($args->hasOption('t')) {
            $timeout = (float)$args->getOption('t');
        }

        for ($i = 0; $i < $count; $i++) {
            if (floor($timeout - array_sum($times)) <= 0 || $count <= 1) {
                break;
            }

            $start = microtime(true);
            file_get_contents($url);
            $stop = microtime(true);

            $times[] = $stop - $start;
        }
        $this->_results($times);

        return static::CODE_SUCCESS;
    }

    /**
     * Prints calculated results
     *
     * @param array<float> $times Array of time values
     * @return void
     */
    protected function _results(array $times): void
    {
        $duration = array_sum($times);
        $requests = count($times);

        $this->io->out(Text::insert('Total Requests made: :requests', compact('requests')));
        $this->io->out(Text::insert('Total Time elapsed: :duration (seconds)', compact('duration')));

        $this->io->out('');

        $this->io->out(Text::insert('Requests/Second: :rps req/sec', [
            'rps' => round($requests / $duration, 3),
        ]));

        $this->io->out(Text::insert('Average request time: :average-time seconds', [
            'average-time' => round($duration / $requests, 3),
        ]));

        $this->io->out(Text::insert('Standard deviation of average request time: :std-dev', [
            'std-dev' => round($this->_deviation($times, true), 3),
        ]));

        if (!empty($times)) {
            $this->io->out(Text::insert('Longest/shortest request: :longest sec/:shortest sec', [
                'longest' => round(max($times), 3),
                'shortest' => round(min($times), 3),
            ]));
        }

        $this->io->out('');
    }

    /**
     * One-pass, numerically stable calculation of population variance.
     *
     * Donald E. Knuth (1998).
     * The Art of Computer Programming, volume 2: Seminumerical Algorithms, 3rd edn.,
     * p. 232. Boston: Addison-Wesley.
     *
     * @param array $times Array of values
     * @param bool $sample If true, calculates an unbiased estimate of the population
     *                           variance from a finite sample.
     * @return float Variance
     */
    protected function _variance(array $times, bool $sample = true): float
    {
        $n = $mean = $M2 = 0;

        foreach ($times as $time) {
            $n += 1;
            $delta = $time - $mean;
            $mean = $mean + $delta / $n;
            $M2 = $M2 + $delta * ($time - $mean);
        }

        if ($sample) {
            $n -= 1;
        }

        return $M2 / $n;
    }

    /**
     * Calculate the standard deviation.
     *
     * @param array $times Array of values
     * @param bool $sample ''
     * @return float Standard deviation
     */
    protected function _deviation(array $times, bool $sample = true): float
    {
        return sqrt($this->_variance($times, $sample));
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @param \Cake\Console\ConsoleOptionParser $parser The parser to build
     * @return \Cake\Console\ConsoleOptionParser
     */
    protected function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser->setDescription(
            'Allows you to obtain some rough benchmarking statistics' .
            'about a fully qualified URL.'
        )
        ->addArgument('url', [
            'help' => 'The URL to request.',
            'required' => true,
        ])
        ->addOption('n', [
            'default' => 10,
            'help' => 'Number of iterations to perform.',
        ])
        ->addOption('t', [
            'default' => 100,
            'help' =>
                'Maximum total time for all iterations, in seconds. ' .
                'If a single iteration takes more than the timeout, only one request will be made',
        ])
        ->setEpilog(
            'Example Use: `cake benchmark --n 10 --t 100 http://localhost/testsite`. ' .
            '<info>Note:</info> this benchmark does not include browser render times.'
        );

        return $parser;
    }
}
