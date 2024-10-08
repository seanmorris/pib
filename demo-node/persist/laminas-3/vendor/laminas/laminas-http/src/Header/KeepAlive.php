<?php

namespace Laminas\Http\Header;

use function strtolower;

/**
 * @throws Exception\InvalidArgumentException
 * @todo Search for RFC for this header
 */
class KeepAlive implements HeaderInterface
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
        if (strtolower($name) !== 'keep-alive') {
            throw new Exception\InvalidArgumentException('Invalid header line for Keep-Alive string: "' . $name . '"');
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
        return 'Keep-Alive';
    }

    /** @return string */
    public function getFieldValue()
    {
        return (string) $this->value;
    }

    /** @return string */
    public function toString()
    {
        return 'Keep-Alive: ' . $this->getFieldValue();
    }
}
