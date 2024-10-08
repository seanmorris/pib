<?php

namespace Laminas\Http\Header;

use Laminas\Uri\UriFactory;

use function explode;
use function strtolower;

/**
 * @see http://tools.ietf.org/id/draft-abarth-origin-03.html#rfc.section.2
 *
 * @throws Exception\InvalidArgumentException
 */
class Origin implements HeaderInterface
{
    /** @var string */
    protected $value = '';

    /**
     * @param string $headerLine
     * @return static
     */
    public static function fromString($headerLine)
    {
        [$name, $value] = explode(': ', $headerLine, 2);

        // check to ensure proper header type for this factory
        if (strtolower($name) !== 'origin') {
            throw new Exception\InvalidArgumentException('Invalid header line for Origin string: "' . $name . '"');
        }

        $uri = UriFactory::factory($value);
        if (! $uri->isValid()) {
            throw new Exception\InvalidArgumentException('Invalid header value for Origin key: "' . $name . '"');
        }

        return new static($value);
    }

    /**
     * @param string|null $value
     */
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
        return 'Origin';
    }

    /** @return string */
    public function getFieldValue()
    {
        return (string) $this->value;
    }

    /** @return string */
    public function toString()
    {
        return 'Origin: ' . $this->getFieldValue();
    }
}
