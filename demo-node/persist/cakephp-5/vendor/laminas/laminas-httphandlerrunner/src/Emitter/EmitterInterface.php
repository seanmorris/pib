<?php

declare(strict_types=1);

namespace Laminas\HttpHandlerRunner\Emitter;

use Psr\Http\Message\ResponseInterface;

interface EmitterInterface
{
    /**
     * Emit a response.
     *
     * Emits a response, including status line, headers, and the message body,
     * according to the environment.
     *
     * Implementations of this method may be written in such a way as to have
     * side effects, such as usage of header() or pushing output to the
     * output buffer.
     *
     * Implementations MAY raise exceptions if they are unable to emit the
     * response; e.g., if headers have already been sent.
     *
     * Implementations MUST return a boolean. A boolean `true` indicates that
     * the emitter was able to emit the response, while `false` indicates
     * it was not.
     */
    public function emit(ResponseInterface $response): bool;
}
