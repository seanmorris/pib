<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Exception;

use function array_key_exists;
use function sprintf;

/**
 * View helper plugin to fetch asset from resource map.
 *
 * @final
 */
class Asset extends AbstractHelper
{
    use DeprecatedAbstractHelperHierarchyTrait;

    /** @var array<non-empty-string, non-empty-string> */
    protected $resourceMap = [];

    /**
     * @param array<non-empty-string, non-empty-string> $resourceMap
     */
    public function __construct(array $resourceMap = [])
    {
        $this->resourceMap = $resourceMap;
    }

    /**
     * @param non-empty-string $asset
     * @return non-empty-string
     * @throws Exception\InvalidArgumentException
     */
    public function __invoke($asset)
    {
        if (! array_key_exists($asset, $this->resourceMap)) {
            throw new Exception\InvalidArgumentException(sprintf(
                'The asset with the name "%s" has not been defined.',
                $asset
            ));
        }

        return $this->resourceMap[$asset];
    }

    /**
     * @deprecated since 2.20.0, this method will be removed in version 3.0.0 of this component.
     *             The Resource map should be provided to the constructor from version 3.0
     *
     * @param array<non-empty-string, non-empty-string> $resourceMap
     * @return $this
     */
    public function setResourceMap(array $resourceMap)
    {
        $this->resourceMap = $resourceMap;

        return $this;
    }

    /**
     * @deprecated since 2.20.0, this method will be removed in version 3.0.0 of this component.
     *             Runtime retrieval of the resource map from the view will be removed without replacement.
     *
     * @return array<non-empty-string, non-empty-string>
     */
    public function getResourceMap()
    {
        return $this->resourceMap;
    }
}
