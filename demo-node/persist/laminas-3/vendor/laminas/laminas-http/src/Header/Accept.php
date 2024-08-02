<?php

namespace Laminas\Http\Header;

use Laminas\Http\Header\Accept\FieldValuePart;

use function strpos;
use function substr;
use function trim;

/**
 * Accept Header
 *
 * @see        http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
 */
class Accept extends AbstractAccept
{
    /** @var string */
    protected $regexAddType = '#^([a-zA-Z+-]+|\*)/(\*|[a-zA-Z0-9+-]+)$#';

    /**
     * Get field name
     *
     * @return string
     */
    public function getFieldName()
    {
        return 'Accept';
    }

    /**
     * Cast to string
     *
     * @return string
     */
    public function toString()
    {
        return 'Accept: ' . $this->getFieldValue();
    }

    /**
     * Add a media type, with the given priority
     *
     * @param  string $type
     * @param  int|float $priority
     * @param  array $params
     * @return $this
     */
    public function addMediaType($type, $priority = 1, array $params = [])
    {
        return $this->addType($type, $priority, $params);
    }

    /**
     * Does the header have the requested media type?
     *
     * @param  string $type
     * @return bool
     */
    public function hasMediaType($type)
    {
        return $this->hasType($type);
    }

    /**
     * Parse the keys contained in the header line
     *
     * @see    \Laminas\Http\Header\AbstractAccept::parseFieldValuePart()
     *
     * @param  string $fieldValuePart
     * @return FieldValuePart\AcceptFieldValuePart
     */
    protected function parseFieldValuePart($fieldValuePart)
    {
        $raw = $fieldValuePart;
        if ($pos = strpos($fieldValuePart, '/')) {
            $type = trim(substr($fieldValuePart, 0, $pos));
        } else {
            $type = trim($fieldValuePart);
        }

        $params = $this->getParametersFromFieldValuePart($fieldValuePart);

        if ($pos = strpos($fieldValuePart, ';')) {
            $fieldValuePart = trim(substr($fieldValuePart, 0, $pos));
        }

        if (strpos($fieldValuePart, '/')) {
            $subtypeWhole = $format = $subtype = trim(substr($fieldValuePart, strpos($fieldValuePart, '/') + 1));
        } else {
            $subtypeWhole = '';
            $format       = '*';
            $subtype      = '*';
        }

        $pos = strpos($subtype, '+');
        if (false !== $pos) {
            $format  = trim(substr($subtype, $pos + 1));
            $subtype = trim(substr($subtype, 0, $pos));
        }

        $aggregated = [
            'typeString' => trim($fieldValuePart),
            'type'       => $type,
            'subtype'    => $subtype,
            'subtypeRaw' => $subtypeWhole,
            'format'     => $format,
            'priority'   => $params['q'] ?? 1,
            'params'     => $params,
            'raw'        => trim($raw),
        ];

        return new FieldValuePart\AcceptFieldValuePart((object) $aggregated);
    }
}
