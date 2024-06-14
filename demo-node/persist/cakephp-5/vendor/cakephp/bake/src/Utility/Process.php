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
namespace Bake\Utility;

use Cake\Console\ConsoleIo;
use RuntimeException;

/**
 * Minimal wrapper around calling a subprocess.
 *
 * @internal
 */
class Process
{
    /**
     * @var \Cake\Console\ConsoleIo
     */
    protected ConsoleIo $io;

    /**
     * Constructor
     *
     * @param \Cake\Console\ConsoleIo $io The console io
     */
    public function __construct(ConsoleIo $io)
    {
        $this->io = $io;
    }

    /**
     * Call a subprocess
     *
     * @param string $command The command to call
     * @return string The output
     * @throws \RuntimeException Raised when the called command fails.
     */
    public function call(string $command): string
    {
        $descriptorSpec = [
            0 => ['pipe', 'r'],
            1 => ['pipe', 'w'],
            2 => ['pipe', 'w'],
        ];
        $this->io->verbose('Running ' . $command);
        $process = proc_open(
            $command,
            $descriptorSpec,
            $pipes
        );
        if (!is_resource($process)) {
            throw new RuntimeException("Could not start subprocess for `$command`");
        }
        fclose($pipes[0]);

        $output = stream_get_contents($pipes[1]);
        fclose($pipes[1]);

        $error = stream_get_contents($pipes[2]);
        fclose($pipes[2]);
        $exit = proc_close($process);

        if ($exit !== 0) {
            throw new RuntimeException($error);
        }

        return $output;
    }
}
