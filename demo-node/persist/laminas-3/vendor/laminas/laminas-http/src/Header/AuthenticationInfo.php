<?php

namespace Laminas\Http\Header;

use function sprintf;
use function strtolower;

/**
 * @see http://www.ietf.org/rfc/rfc2617.txt
 *
 * @throws Exception\InvalidArgumentException
 */
class AuthenticationInfo implements HeaderInterface
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
        if (strtolower($name) !== 'authentication-info') {
            throw new Exception\InvalidArgumentException(sprintf(
                'Invalid header line for Authentication-Info string: "%s"',
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
        return 'Authentication-Info';
    }

    /** @return string */
    public function getFieldValue()
    {
        return (string) $this->value;
    }

    /** @return string */
    public function toString()
    {
        return 'Authentication-Info: ' . $this->getFieldValue();
    }
}
