<?php

namespace Laminas\Http\Header;

/**
 * If-Unmodified-Since Header
 *
 * @link       http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.28
 */
class IfUnmodifiedSince extends AbstractDate
{
    /**
     * Get header name
     *
     * @return string
     */
    public function getFieldName()
    {
        return 'If-Unmodified-Since';
    }
}
