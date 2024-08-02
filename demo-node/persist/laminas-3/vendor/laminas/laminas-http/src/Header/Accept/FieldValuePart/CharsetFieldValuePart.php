<?php

namespace Laminas\Http\Header\Accept\FieldValuePart;

/**
 * Field Value Part
 *
 * @see        http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
 */
class CharsetFieldValuePart extends AbstractFieldValuePart
{
    /**
     * @return string
     */
    public function getCharset()
    {
        return $this->getInternalValues()->type;
    }
}
