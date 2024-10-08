<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Exception\RuntimeException;

use function ltrim;
use function rtrim;
use function sprintf;

/**
 * Helper for retrieving the base path.
 *
 * @final
 */
class BasePath extends AbstractHelper
{
    use DeprecatedAbstractHelperHierarchyTrait;

    /** @var string|null */
    protected $basePath;

    public function __construct(?string $basePath = null)
    {
        if ($basePath !== null) {
            $this->setBasePath($basePath);
        }
    }

    /**
     * Returns site's base path, or file with base path prepended.
     *
     * $file is appended to the base path for simplicity.
     *
     * @param  string|null $file
     * @throws RuntimeException
     * @return string
     */
    public function __invoke($file = null)
    {
        if ($this->basePath === null) {
            throw new RuntimeException('No base path provided');
        }

        if ($file !== null && $file !== '') {
            return sprintf(
                '%s/%s',
                $this->basePath,
                ltrim($file, '/')
            );
        }

        return $this->basePath;
    }

    /**
     * Set the base path.
     *
     * @param  string $basePath
     * @return self
     */
    public function setBasePath($basePath)
    {
        $this->basePath = rtrim($basePath, '/');
        return $this;
    }
}
