<?php

declare(strict_types=1);

namespace Laminas\HttpHandlerRunner\Emitter;

use Laminas\HttpHandlerRunner\Exception\EmitterException;
use Psr\Http\Message\ResponseInterface;

use function assert;
use function function_exists;
use function header;
use function headers_sent;
use function is_int;
use function is_string;
use function ob_get_length;
use function ob_get_level;
use function sprintf;
use function ucwords;

trait SapiEmitterTrait
{
    /**
     * Checks to see if content has previously been sent.
     *
     * If either headers have been sent or the output buffer contains content,
     * raises an exception.
     *
     * @throws EmitterException If headers have already been sent.
     * @throws EmitterException If output is present in the output buffer.
     */
    private function assertNoPreviousOutput(): void
    {
        $filename = null;
        $line     = null;
        if ($this->headersSent($filename, $line)) {
            assert(is_string($filename) && is_int($line));
            throw EmitterException::forHeadersSent($filename, $line);
        }

        if (ob_get_level() > 0 && ob_get_length() > 0) {
            throw EmitterException::forOutputSent();
        }
    }

    /**
     * Emit the status line.
     *
     * Emits the status line using the protocol version and status code from
     * the response; if a reason phrase is available, it, too, is emitted.
     *
     * It is important to mention that this method should be called after
     * `emitHeaders()` in order to prevent PHP from changing the status code of
     * the emitted response.
     *
     * @see \Laminas\HttpHandlerRunner\Emitter\SapiEmitterTrait::emitHeaders()
     */
    private function emitStatusLine(ResponseInterface $response): void
    {
        $reasonPhrase = $response->getReasonPhrase();
        $statusCode   = $response->getStatusCode();

        $this->header(sprintf(
            'HTTP/%s %d%s',
            $response->getProtocolVersion(),
            $statusCode,
            $reasonPhrase ? ' ' . $reasonPhrase : ''
        ), true, $statusCode);
    }

    /**
     * Emit response headers.
     *
     * Loops through each header, emitting each; if the header value
     * is an array with multiple values, ensures that each is sent
     * in such a way as to create aggregate headers (instead of replace
     * the previous).
     */
    private function emitHeaders(ResponseInterface $response): void
    {
        $statusCode = $response->getStatusCode();

        foreach ($response->getHeaders() as $header => $values) {
            assert(is_string($header));
            $name  = $this->filterHeader($header);
            $first = $name !== 'Set-Cookie';
            foreach ($values as $value) {
                $this->header(sprintf(
                    '%s: %s',
                    $name,
                    $value
                ), $first, $statusCode);
                $first = false;
            }
        }
    }

    /**
     * Filter a header name to wordcase
     */
    private function filterHeader(string $header): string
    {
        return ucwords($header, '-');
    }

    private function headersSent(?string &$filename = null, ?int &$line = null): bool
    {
        if (function_exists('Laminas\HttpHandlerRunner\Emitter\headers_sent')) {
            // phpcs:ignore SlevomatCodingStandard.Namespaces.ReferenceUsedNamesOnly.ReferenceViaFullyQualifiedName
            return \Laminas\HttpHandlerRunner\Emitter\headers_sent($filename, $line);
        }

        return headers_sent($filename, $line);
    }

    private function header(string $headerName, bool $replace, int $statusCode): void
    {
        if (function_exists('Laminas\HttpHandlerRunner\Emitter\header')) {
            // phpcs:ignore SlevomatCodingStandard.Namespaces.ReferenceUsedNamesOnly.ReferenceViaFullyQualifiedName
            \Laminas\HttpHandlerRunner\Emitter\header($headerName, $replace, $statusCode);
            return;
        }

        header($headerName, $replace, $statusCode);
    }
}
