<?php

namespace Laminas\Http\Header;

use function strtolower;

/**
 * Accept Ranges Header
 *
 * @see        http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.5
 */
class AcceptRanges implements HeaderInterface
{
    /** @var null|string */
    protected $rangeUnit;

    /**
     * @param string $headerLine
     * @return static
     */
    public static function fromString($headerLine)
    {
        [$name, $value] = GenericHeader::splitHeaderLine($headerLine);

        // check to ensure proper header type for this factory
        if (strtolower($name) !== 'accept-ranges') {
            throw new Exception\InvalidArgumentException(
                'Invalid header line for Accept-Ranges string'
            );
        }

        return new static($value);
    }

    /** @param null|string $rangeUnit */
    public function __construct($rangeUnit = null)
    {
        if ($rangeUnit !== null) {
            $this->setRangeUnit($rangeUnit);
        }
    }

    /** @return string */
    public function getFieldName()
    {
        return 'Accept-Ranges';
    }

    /** @return string */
    public function getFieldValue()
    {
        return $this->getRangeUnit();
    }

    /**
     * @param string $rangeUnit
     * @return static
     */
    public function setRangeUnit($rangeUnit)
    {
        HeaderValue::assertValid($rangeUnit);
        $this->rangeUnit = $rangeUnit;
        return $this;
    }

    /** @return string */
    public function getRangeUnit()
    {
        return (string) $this->rangeUnit;
    }

    /** @return string */
    public function toString()
    {
        return 'Accept-Ranges: ' . $this->getFieldValue();
    }
}
