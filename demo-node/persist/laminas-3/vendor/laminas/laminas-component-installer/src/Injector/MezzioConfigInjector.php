<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\Injector;

use Laminas\ComponentInstaller\ConfigDiscovery\DiscoveryInterface;
use Laminas\ComponentInstaller\ConfigDiscovery\MezzioConfig as MezzioConfigDiscovery;

use function preg_quote;
use function sprintf;

/**
 * @internal
 */
final class MezzioConfigInjector extends AbstractInjector
{
    use ConditionalDiscoveryTrait;

    public const DEFAULT_CONFIG_FILE = 'config/config.php';

    /** @var list<InjectorInterface::TYPE_*> */
    protected array $allowedTypes = [
        self::TYPE_CONFIG_PROVIDER,
    ];

    /** @var non-empty-string */
    protected string $configFile = self::DEFAULT_CONFIG_FILE;

    /**
     * Discovery class, for testing if this injector is valid for the given
     * configuration.
     *
     * @var class-string<DiscoveryInterface>
     */
    protected string $discoveryClass = MezzioConfigDiscovery::class;

    /**
     * Patterns and replacements to use when registering a code item.
     *
     * Pattern is set in constructor due to PCRE quoting issues.
     *
     * @var array<
     *     InjectorInterface::TYPE_*,
     *     array{pattern: non-empty-string, replacement: string}
     * >
     */
    protected array $injectionPatterns = [];

    /**
     * Pattern to use to determine if the code item is registered.
     *
     * Set in constructor due to PCRE quoting issues.
     *
     * @var non-empty-string
     */
    protected string $isRegisteredPattern = 'overridden-by-constructor';

    /** @var array{pattern: non-empty-string, replacement: string} */
    protected array $removalPatterns = [
        'pattern'     => '/^\s+%s::class,\s*$/m',
        'replacement' => '',
    ];

    /**
     * {@inheritDoc}
     *
     * Sets $isRegisteredPattern and pattern for $injectionPatterns to ensure
     * proper PCRE quoting.
     */
    public function __construct(string $projectRoot = '')
    {
        $this->isRegisteredPattern = '/new (?:'
            . preg_quote('\\')
            . '?'
            . preg_quote('Mezzio\ConfigManager\\')
            . ')?ConfigManager\(\s*(?:array\(|\[).*\s+%s::class/s';

        $this->injectionPatterns[self::TYPE_CONFIG_PROVIDER] = [
            'pattern'     => sprintf(
                '/(new (?:%s?%s)?ConfigManager\(\s*(?:array\(|\[)\s*)$/m',
                preg_quote('\\'),
                preg_quote('Mezzio\ConfigManager\\')
            ),
            'replacement' => "\$1\n    %s::class,",
        ];

        parent::__construct($projectRoot);
    }

    protected function getDefaultConfigFile(): string
    {
        return self::DEFAULT_CONFIG_FILE;
    }

    protected function getDiscoveryClass(): string
    {
        return $this->discoveryClass;
    }
}
