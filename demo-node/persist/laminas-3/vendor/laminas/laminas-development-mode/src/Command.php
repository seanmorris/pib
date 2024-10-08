<?php

declare(strict_types=1);

namespace Laminas\DevelopmentMode;

use function array_shift;
use function count;
use function fwrite;

use const PHP_EOL;
use const STDERR;

class Command
{
    /**
     * Handle the CLI arguments.
     *
     * @return int
     */
    public function __invoke(array $arguments)
    {
        $help = new Help();

        // Called without arguments
        if (count($arguments) < 1) {
            fwrite(STDERR, 'No arguments provided.' . PHP_EOL . PHP_EOL);
            $help(STDERR);
            return 1;
        }

        $argument = array_shift($arguments);

        switch ($argument) {
            case '-h':
            case '--help':
                $help();
                return 0;
            case 'disable':
                $disable = new Disable();
                return $disable();
            case 'enable':
                $enable = new Enable();
                return $enable();
            case 'status':
                $status = new Status();
                return $status();
            case 'auto-composer':
                $auto = new AutoComposer();
                return $auto();
            default:
                fwrite(STDERR, 'Unrecognized argument.' . PHP_EOL . PHP_EOL);
                $help(STDERR);
                return 1;
        }
    }
}
