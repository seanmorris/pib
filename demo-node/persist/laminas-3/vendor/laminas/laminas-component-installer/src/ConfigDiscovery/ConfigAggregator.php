<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\ConfigDiscovery;

use function preg_quote;
use function sprintf;

/**
 * @internal
 */
final class ConfigAggregator extends AbstractDiscovery
{
    /**
     * Configuration file to look for.
     *
     * @var non-empty-string
     */
    protected string $configFile;

    /**
     * Expected pattern to match if the configuration file exists.
     *
     * Pattern is set in constructor to ensure PCRE quoting is correct.
     *
     * @var non-empty-string
     */
    protected string $expected;

    /**
     * @param non-empty-string $configFile
     */
    public function __construct(string $projectDirectory = '', string $configFile = 'config/config.php')
    {
        $this->configFile = $configFile;
        $this->expected   = sprintf(
            '/new (?:%s?%s)?ConfigAggregator\(\s*(?:array\(|\[)/s',
            preg_quote('\\'),
            preg_quote('Laminas\ConfigAggregator\\')
        );

        parent::__construct($projectDirectory);
    }
}
