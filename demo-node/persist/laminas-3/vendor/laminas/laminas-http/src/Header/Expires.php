<?php

namespace Laminas\Http\Header;

use function date;

use const DATE_W3C;

/**
 * Expires Header
 *
 * @link       http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21
 */
class Expires extends AbstractDate
{
    /**
     * Get header name
     *
     * @return string
     */
    public function getFieldName()
    {
        return 'Expires';
    }

    /**
     * @param int|string|DateTime $date
     * @return static
     */
    public function setDate($date)
    {
        if ($date === '0' || $date === 0) {
            $date = date(DATE_W3C, 0); // Thu, 01 Jan 1970 00:00:00 GMT
        }
        return parent::setDate($date);
    }
}
