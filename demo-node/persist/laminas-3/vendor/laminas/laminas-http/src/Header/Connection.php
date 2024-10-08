<?php

namespace Laminas\Http\Header;

use function strtolower;
use function trim;

/**
 * Connection Header
 *
 * @link       http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.10
 */
class Connection implements HeaderInterface
{
    public const CONNECTION_CLOSE      = 'close';
    public const CONNECTION_KEEP_ALIVE = 'keep-alive';

    /**
     * Value of this header
     *
     * @var string
     */
    protected $value = self::CONNECTION_KEEP_ALIVE;

    /**
     * @param string $headerLine
     * @return static
     * @throws Exception\InvalidArgumentException
     */
    public static function fromString($headerLine)
    {
        $header = new static();

        [$name, $value] = GenericHeader::splitHeaderLine($headerLine);

        // check to ensure proper header type for this factory
        if (strtolower($name) !== 'connection') {
            throw new Exception\InvalidArgumentException('Invalid header line for Connection string: "' . $name . '"');
        }

        $header->setValue(trim($value));

        return $header;
    }

    /**
     * Set Connection header to define persistent connection
     *
     * @param  bool $flag
     * @return $this
     */
    public function setPersistent($flag)
    {
        $this->value = (bool) $flag
            ? self::CONNECTION_KEEP_ALIVE
            : self::CONNECTION_CLOSE;
        return $this;
    }

    /**
     * Get whether this connection is persistent
     *
     * @return bool
     */
    public function isPersistent()
    {
        return $this->value === self::CONNECTION_KEEP_ALIVE;
    }

    /**
     * Set arbitrary header value
     * RFC allows any token as value, 'close' and 'keep-alive' are commonly used
     *
     * @param string $value
     * @return $this
     */
    public function setValue($value)
    {
        HeaderValue::assertValid($value);
        $this->value = strtolower($value);
        return $this;
    }

    /**
     * Connection header name
     *
     * @return string
     */
    public function getFieldName()
    {
        return 'Connection';
    }

    /**
     * Connection header value
     *
     * @return string
     */
    public function getFieldValue()
    {
        return $this->value;
    }

    /**
     * Return header line
     *
     * @return string
     */
    public function toString()
    {
        return 'Connection: ' . $this->getFieldValue();
    }
}
