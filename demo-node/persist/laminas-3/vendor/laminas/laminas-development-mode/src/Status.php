<?php

declare(strict_types=1);

namespace Laminas\DevelopmentMode;

use function file_exists;
use function sprintf;

use const PHP_EOL;

class Status
{
    public const DEVEL_CONFIG = 'config/development.config.php';

    private string $develConfigFile;

    /**
     * @param string $projectDir Location to resolve project from.
     */
    public function __construct($projectDir = '')
    {
        if ('' === $projectDir) {
            $this->develConfigFile = self::DEVEL_CONFIG;
            return;
        }

        $this->develConfigFile = sprintf('%s/%s', $projectDir, self::DEVEL_CONFIG);
    }

    /**
     * Indicate whether or not development mode is enabled.
     *
     * @return int
     */
    public function __invoke()
    {
        if (file_exists($this->develConfigFile)) {
            // nothing to do
            echo 'Development mode is ENABLED', PHP_EOL;
            return 0;
        }

        echo 'Development mode is DISABLED', PHP_EOL;
        return 0;
    }
}
