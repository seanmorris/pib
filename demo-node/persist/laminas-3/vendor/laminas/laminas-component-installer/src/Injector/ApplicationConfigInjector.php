<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller\Injector;

/**
 * @internal
 */
final class ApplicationConfigInjector extends AbstractInjector
{
    /** @var non-empty-string */
    protected string $configFile = 'config/application.config.php';

    /**
     * Patterns and replacements to use when registering a code item.
     *
     * @var array<
     *     InjectorInterface::TYPE_*,
     *     array{pattern: non-empty-string, replacement: string}
     * >
     */
    protected array $injectionPatterns = [
        self::TYPE_COMPONENT          => [
            'pattern'     => '/^(\s+)(\'modules\'\s*\=\>\s*(?:array\s*\(|\[))\s*$/m',
            'replacement' => "\$1\$2\n\$1    '%s',",
        ],
        self::TYPE_MODULE             => [
            'pattern'     => "/('modules'\s*\=\>\s*(?:array\s*\(|\[).*?)\n(\s+)(\)|\])/s",
            'replacement' => "\$1\n\$2    '%s',\n\$2\$3",
        ],
        self::TYPE_DEPENDENCY         => [
            'pattern'     => '/^(\s+)(\'modules\'\s*\=\>\s*(?:array\s*\(|\[)[^)\]]*\'%s\')/m',
            'replacement' => "\$1\$2,\n\$1    '%s'",
        ],
        self::TYPE_BEFORE_APPLICATION => [
            'pattern'     => '/^(\s+)(\'modules\'\s*\=\>\s*(?:array\s*\(|\[)[^)\]]*)(\'%s\')/m',
            'replacement' => "\$1\$2'%s',\n$1    \$3",
        ],
    ];

    /** @var non-empty-string */
    protected string $isRegisteredPattern = '/\'modules\'\s*\=\>\s*(?:array\(|\[)[^)\]]*\'%s\'/s';

    /** @var array{pattern: non-empty-string, replacement: string} */
    protected array $removalPatterns = [
        'pattern'     => '/^\s+\'%s\',\s*$/m',
        'replacement' => '',
    ];

    /**
     * @param non-empty-string|null $configFile
     */
    public function __construct(string $projectRoot = '', ?string $configFile = null)
    {
        $this->configFile = $configFile ?? $this->configFile;
        parent::__construct($projectRoot);
    }
}
