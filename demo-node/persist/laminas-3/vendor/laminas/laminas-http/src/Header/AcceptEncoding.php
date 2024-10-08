<?php

namespace Laminas\Http\Header;

use Laminas\Http\Header\Accept\FieldValuePart;
use Laminas\Http\Header\Accept\FieldValuePart\EncodingFieldValuePart;

/**
 * Accept Encoding Header
 *
 * @see        http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
 */
class AcceptEncoding extends AbstractAccept
{
    /** @var string */
    protected $regexAddType = '#^([a-zA-Z0-9+-]+|\*)$#';

    /**
     * Get field name
     *
     * @return string
     */
    public function getFieldName()
    {
        return 'Accept-Encoding';
    }

    /**
     * Cast to string
     *
     * @return string
     */
    public function toString()
    {
        return 'Accept-Encoding: ' . $this->getFieldValue();
    }

    /**
     * Add an encoding, with the given priority
     *
     * @param  string $type
     * @param  int|float $priority
     * @return $this
     */
    public function addEncoding($type, $priority = 1)
    {
        return $this->addType($type, $priority);
    }

    /**
     * Does the header have the requested encoding?
     *
     * @param  string $type
     * @return bool
     */
    public function hasEncoding($type)
    {
        return $this->hasType($type);
    }

    /**
     * Parse the keys contained in the header line
     *
     * @see \Laminas\Http\Header\AbstractAccept::parseFieldValuePart()
     *
     * @param string $fieldValuePart
     * @return EncodingFieldValuePart
     */
    protected function parseFieldValuePart($fieldValuePart)
    {
        $internalValues = parent::parseFieldValuePart($fieldValuePart);

        return new FieldValuePart\EncodingFieldValuePart($internalValues);
    }
}
