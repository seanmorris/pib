<?php

namespace Laminas\Http\Client\Adapter;

/**
 * An interface description for Laminas\Http\Client\Adapter\Stream classes.
 *
 * This interface describes Laminas\Http\Client\Adapter which supports streaming.
 */
interface StreamInterface
{
    /**
     * Set output stream
     *
     * This function sets output stream where the result will be stored.
     *
     * @param resource $stream Stream to write the output to
     */
    public function setOutputStream($stream);
}
