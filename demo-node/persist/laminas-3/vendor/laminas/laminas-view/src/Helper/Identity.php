<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\Authentication\AuthenticationServiceInterface;
use Laminas\View\Exception\RuntimeException;

/**
 * View helper plugin to fetch the authenticated identity.
 */
class Identity extends AbstractHelper
{
    use DeprecatedAbstractHelperHierarchyTrait;

    /** @var AuthenticationServiceInterface|null */
    protected $authenticationService;

    public function __construct(?AuthenticationServiceInterface $authenticationService = null)
    {
        $this->authenticationService = $authenticationService;
    }

    /**
     * Retrieve the current identity, if any.
     *
     * If none available, returns null.
     *
     * @return mixed|null
     */
    public function __invoke()
    {
        $service = $this->authenticationService;
        if (! $service instanceof AuthenticationServiceInterface) {
            throw new RuntimeException('No AuthenticationServiceInterface instance provided');
        }

        return $service->hasIdentity()
            ? $service->getIdentity()
            : null;
    }

    /**
     * Set AuthenticationService instance
     *
     * @deprecated since >= 2.20.0. The authentication service should be provided to the constructor. This method will
     *             be removed in version 3.0 of this component
     *
     * @return $this
     */
    public function setAuthenticationService(AuthenticationServiceInterface $authenticationService)
    {
        $this->authenticationService = $authenticationService;

        return $this;
    }

    /**
     * Get AuthenticationService instance
     *
     * @deprecated since >= 2.20.0. The authentication service should be provided to the constructor. This method will
     *             be removed in version 3.0 of this component
     *
     * @return null|object
     */
    public function getAuthenticationService()
    {
        return $this->authenticationService;
    }
}
