<?php

namespace Laminas\Http\Header;

/**
 * Date Header
 *
 * @link       http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.18
 */
class Date extends AbstractDate
{
    /**
     * Get header name
     *
     * @return string
     */
    public function getFieldName()
    {
        return 'Date';
    }
}
