<?php

namespace Laminas\Http\Header;

use function implode;
use function sprintf;
use function strtolower;

/**
 * @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.33
 *
 * @throws Exception\InvalidArgumentException
 */
class ProxyAuthenticate implements MultipleHeaderInterface
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
        if (strtolower($name) !== 'proxy-authenticate') {
            throw new Exception\InvalidArgumentException(sprintf(
                'Invalid header line for Proxy-Authenticate string: "%s"',
                $name
            ));
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
        return 'Proxy-Authenticate';
    }

    /** @return string */
    public function getFieldValue()
    {
        return (string) $this->value;
    }

    /** @return string */
    public function toString()
    {
        return 'Proxy-Authenticate: ' . $this->getFieldValue();
    }

    /** @return string */
    public function toStringMultipleHeaders(array $headers)
    {
        $strings = [$this->toString()];
        foreach ($headers as $header) {
            if (! $header instanceof ProxyAuthenticate) {
                throw new Exception\RuntimeException(
                    'The ProxyAuthenticate multiple header implementation can only accept'
                    . ' an array of ProxyAuthenticate headers'
                );
            }
            $strings[] = $header->toString();
        }
        return implode("\r\n", $strings);
    }
}
