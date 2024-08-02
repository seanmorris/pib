<?php

namespace Laminas\Http\Header;

use function strtolower;

/**
 * @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.22
 *
 * @throws Exception\InvalidArgumentException
 */
class From implements HeaderInterface
{
    /** @var string */
    protected $value;

    /**
     * @param string $headerLine
     * @return static
     */
    public static function fromString($headerLine)
    {
        [$name, $value] = GenericHeader::splitHeaderLine($headerLine);

        // check to ensure proper header type for this factory
        if (strtolower($name) !== 'from') {
            throw new Exception\InvalidArgumentException('Invalid header line for From string: "' . $name . '"');
        }

        // @todo implementation details
        return new static($value);
    }

    /** @param null|string $value */
    public function __construct($value = null)
    {
        if ($value !== null) {
            HeaderValue::assertValid($value);
            $this->value = $value;
        }
    }

    /** @return string */
    public function getFieldName()
    {
        return 'From';
    }

    /** @return string */
    public function getFieldValue()
    {
        return (string) $this->value;
    }

    /** @return string */
    public function toString()
    {
        return 'From: ' . $this->getFieldValue();
    }
}
