<?php

namespace Laminas\Http\Header\Accept\FieldValuePart;

/**
 * Field Value Part
 *
 * @see        http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
 */
class LanguageFieldValuePart extends AbstractFieldValuePart
{
    /** @return string */
    public function getLanguage()
    {
        return $this->getInternalValues()->typeString;
    }

    /** @return string */
    public function getPrimaryTag()
    {
        return $this->getInternalValues()->type;
    }

    /** @return string */
    public function getSubTag()
    {
        return $this->getInternalValues()->subtype;
    }
}
