<?php

namespace Laminas\Uri\Exception;

class InvalidUriPartException extends InvalidArgumentException
{
    /**
     * Part-specific error codes
     *
     * @var int
     */
    public const INVALID_SCHEME    = 1;
    public const INVALID_USER      = 2;
    public const INVALID_PASSWORD  = 4;
    public const INVALID_USERINFO  = 6;
    public const INVALID_HOSTNAME  = 8;
    public const INVALID_PORT      = 16;
    public const INVALID_AUTHORITY = 30;
    public const INVALID_PATH      = 32;
    public const INVALID_QUERY     = 64;
    public const INVALID_FRAGMENT  = 128;
}
