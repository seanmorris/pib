<?php

declare(strict_types=1);

namespace Laminas\DevelopmentMode;

use function getenv;
use function is_resource;
use function printf;
use function var_export;

use const PHP_EOL;
use const STDERR;

/**
 * Automatically switch to and from development mode based on type of composer
 * install/update used.
 *
 * If a development install is being performed (`--dev` flag or absence of
 * `--no-dev` flag), then it will enable development mode. Otherwise, it
 * disables it. This is determined by the value of the `COMPOSER_DEV_MODE`
 * environment variable that Composer sets.
 *
 * If the `COMPOSER_DEV_MODE` environment variable is missing, then the command
 * does nothing.
 */
class AutoComposer
{
    public const COMPOSER_DEV_MODE = 'COMPOSER_DEV_MODE';

    /** @var string|false Value of COMPOSER_DEV_MODE */
    private $composerDevMode;

    /** @var resource */
    private $errorStream;

    /**
     * @param string $projectDir Location to resolve project from.
     * @param null|resource $errorStream Stream to which to write errors; defaults to STDERR
     */
    public function __construct(private $projectDir = '', $errorStream = null)
    {
        $this->composerDevMode = getenv(self::COMPOSER_DEV_MODE);
        $this->errorStream     = is_resource($errorStream) ? $errorStream : STDERR;
    }

    /**
     * Enable or disable developer mode based on composerDevMode.
     *
     * @return int
     */
    public function __invoke()
    {
        if ($this->composerDevMode === '' || $this->composerDevMode === false) {
            // Not running under composer; do nothing.
            echo 'COMPOSER_DEV_MODE not set. Nothing to do.' . PHP_EOL;
            return 0;
        }

        if ($this->composerDevMode === '0') {
            $disable = new Disable($this->projectDir, $this->errorStream);
            return $disable();
        }

        if ($this->composerDevMode === '1') {
            $enable = new Enable($this->projectDir, $this->errorStream);
            return $enable();
        }

        printf(
            'COMPOSER_DEV_MODE set to unexpected value (%s). Nothing to do.%s',
            var_export($this->composerDevMode, true),
            PHP_EOL
        );
        return 1;
    }
}
