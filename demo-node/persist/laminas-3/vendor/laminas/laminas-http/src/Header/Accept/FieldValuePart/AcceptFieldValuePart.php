<?php

namespace Laminas\Http\Header\Accept\FieldValuePart;

/**
 * Field Value Part
 *
 * @see        http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
 */
class AcceptFieldValuePart extends AbstractFieldValuePart
{
    /**
     * @return string
     */
    public function getSubtype()
    {
        return $this->getInternalValues()->subtype;
    }

    /**
     * @return string
     */
    public function getSubtypeRaw()
    {
        return $this->getInternalValues()->subtypeRaw;
    }

    /**
     * @return string
     */
    public function getFormat()
    {
        return $this->getInternalValues()->format;
    }
}
