<?php

namespace Laminas\Config\Writer;

use Laminas\Config\Exception;

use function gettype;
use function is_object;
use function is_scalar;
use function is_string;
use function sprintf;

class JavaProperties extends AbstractWriter
{
    public const DELIMITER_DEFAULT = ':';

    /**
     * Delimiter for key/value pairs.
     *
     * @var string
     */
    private $delimiter;

    /**
     * @param string $delimiter Delimiter to use for key/value pairs; defaults
     *     to self::DELIMITER_DEFAULT (':')
     * @throws Exception\InvalidArgumentException For invalid $delimiter values.
     */
    public function __construct($delimiter = self::DELIMITER_DEFAULT)
    {
        if (! is_string($delimiter) || '' === $delimiter) {
            throw new Exception\InvalidArgumentException(sprintf(
                'Invalid delimiter of type "%s"; must be a non-empty string',
                is_object($delimiter) ? $delimiter::class : gettype($delimiter)
            ));
        }

        $this->delimiter = $delimiter;
    }

    /**
     * processConfig(): defined by AbstractWriter.
     *
     * @param  array $config
     * @return string
     * @throws Exception\UnprocessableConfigException For non-scalar values in the $config array.
     */
    public function processConfig(array $config)
    {
        $string = '';

        foreach ($config as $key => $value) {
            if (! is_scalar($value)) {
                throw new Exception\UnprocessableConfigException(sprintf(
                    '%s configuration writer can only process scalar values; received "%s" for key "%s"',
                    self::class,
                    is_object($value) ? $value::class : gettype($value),
                    $key
                ));
            }

            $value = $value ?? '';

            $string .= sprintf(
                "%s%s%s\n",
                $key,
                $this->delimiter,
                $value
            );
        }

        return $string;
    }
}
