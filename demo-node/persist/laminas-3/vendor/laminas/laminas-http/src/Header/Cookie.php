<?php

namespace Laminas\Http\Header;

use ArrayObject;

use function array_key_exists;
use function array_merge;
use function count;
use function explode;
use function implode;
use function is_array;
use function preg_split;
use function sprintf;
use function strtolower;
use function urldecode;
use function urlencode;

/**
 * @see http://www.ietf.org/rfc/rfc2109.txt
 * @see http://www.w3.org/Protocols/rfc2109/rfc2109
 */
class Cookie extends ArrayObject implements HeaderInterface
{
    /** @var bool */
    protected $encodeValue = true;

    /**
     * @param SetCookie[] $setCookieClass
     * @return static
     */
    public static function fromSetCookieArray(array $setCookies)
    {
        $nvPairs = [];

        foreach ($setCookies as $setCookie) {
            if (! $setCookie instanceof SetCookie) {
                throw new Exception\InvalidArgumentException(sprintf(
                    '%s requires an array of SetCookie objects',
                    __METHOD__
                ));
            }

            if (array_key_exists($setCookie->getName(), $nvPairs)) {
                throw new Exception\InvalidArgumentException(sprintf(
                    'Two cookies with the same name were provided to %s',
                    __METHOD__
                ));
            }

            $nvPairs[$setCookie->getName()] = $setCookie->getValue();
        }

        return new static($nvPairs);
    }

    /**
     * @param string $headerLine
     * @return static
     */
    public static function fromString($headerLine)
    {
        $header = new static();

        [$name, $value] = GenericHeader::splitHeaderLine($headerLine);

        // check to ensure proper header type for this factory
        if (strtolower($name) !== 'cookie') {
            throw new Exception\InvalidArgumentException('Invalid header line for Server string: "' . $name . '"');
        }

        $nvPairs = preg_split('#;\s*#', $value);

        $arrayInfo = [];
        foreach ($nvPairs as $nvPair) {
            $parts = explode('=', $nvPair, 2);
            if (count($parts) !== 2) {
                throw new Exception\RuntimeException('Malformed Cookie header found');
            }
            [$name, $value]   = $parts;
            $arrayInfo[$name] = urldecode($value);
        }

        $header->exchangeArray($arrayInfo);

        return $header;
    }

    public function __construct(array $array = [])
    {
        parent::__construct($array, ArrayObject::ARRAY_AS_PROPS);
    }

    /**
     * @param bool $encodeValue
     * @return $this
     */
    public function setEncodeValue($encodeValue)
    {
        $this->encodeValue = (bool) $encodeValue;
        return $this;
    }

    /**
     * @return bool
     */
    public function getEncodeValue()
    {
        return $this->encodeValue;
    }

    /** @return string */
    public function getFieldName()
    {
        return 'Cookie';
    }

    /** @return string */
    public function getFieldValue()
    {
        $nvPairs = [];

        foreach ($this->flattenCookies($this) as $name => $value) {
            $nvPairs[] = $name . '=' . ($this->encodeValue ? urlencode($value) : $value);
        }

        return implode('; ', $nvPairs);
    }

    /**
     * @param iterable<string, string> $data
     * @param null|string $prefix
     * @return array<string, string>
     */
    protected function flattenCookies($data, $prefix = null)
    {
        $result = [];
        foreach ($data as $key => $value) {
            $key = $prefix ? $prefix . '[' . $key . ']' : $key;
            if (is_array($value)) {
                $result = array_merge($result, $this->flattenCookies($value, $key));
            } else {
                $result[$key] = $value;
            }
        }

        return $result;
    }

    /** @return string */
    public function toString()
    {
        return 'Cookie: ' . $this->getFieldValue();
    }

    /**
     * Get the cookie as a string, suitable for sending as a "Cookie" header in an
     * HTTP request
     *
     * @return string
     */
    public function __toString()
    {
        return $this->toString();
    }
}
