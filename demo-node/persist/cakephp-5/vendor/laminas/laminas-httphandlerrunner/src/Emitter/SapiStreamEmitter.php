<?php

declare(strict_types=1);

namespace Laminas\HttpHandlerRunner\Emitter;

use Psr\Http\Message\ResponseInterface;

use function flush;
use function preg_match;
use function strlen;
use function substr;

/**
 * @psalm-type ParsedRangeType = array{0:string,1:int,2:int,3:'*'|int}
 */
class SapiStreamEmitter implements EmitterInterface
{
    use SapiEmitterTrait;

    public function __construct(
        /** @param int Maximum output buffering size for each iteration. */
        private int $maxBufferLength = 8192
    ) {
    }

    /**
     * Emits a response for a PHP SAPI environment.
     *
     * Emits the status line and headers via the header() function, and the
     * body content via the output buffer.
     */
    public function emit(ResponseInterface $response): bool
    {
        $this->assertNoPreviousOutput();
        $this->emitHeaders($response);
        $this->emitStatusLine($response);

        flush();

        $range = $this->parseContentRange($response->getHeaderLine('Content-Range'));

        if (null === $range || 'bytes' !== $range[0]) {
            $this->emitBody($response);
            return true;
        }

        $this->emitBodyRange($range, $response);
        return true;
    }

    /**
     * Emit the message body.
     */
    private function emitBody(ResponseInterface $response): void
    {
        $body = $response->getBody();

        if ($body->isSeekable()) {
            $body->rewind();
        }

        if (! $body->isReadable()) {
            echo $body;
            return;
        }

        while (! $body->eof()) {
            echo $body->read($this->maxBufferLength);
        }
    }

    /**
     * Emit a range of the message body.
     *
     * @psalm-param ParsedRangeType $range
     */
    private function emitBodyRange(array $range, ResponseInterface $response): void
    {
        [, $first, $last] = $range;

        $body = $response->getBody();

        $length = $last - $first + 1;

        if ($body->isSeekable()) {
            $body->seek($first);

            $first = 0;
        }

        if (! $body->isReadable()) {
            echo substr($body->getContents(), $first, $length);
            return;
        }

        $remaining = $length;

        while ($remaining >= $this->maxBufferLength && ! $body->eof()) {
            $contents   = $body->read($this->maxBufferLength);
            $remaining -= strlen($contents);

            echo $contents;
        }

        if ($remaining > 0 && ! $body->eof()) {
            echo $body->read($remaining);
        }
    }

    /**
     * Parse content-range header
     * http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.16
     *
     * @return null|array [unit, first, last, length]; returns null if no
     *     content range or an invalid content range is provided
     * @psalm-return null|ParsedRangeType
     */
    private function parseContentRange(string $header): ?array
    {
        if (! preg_match('/(?P<unit>[\w]+)\s+(?P<first>\d+)-(?P<last>\d+)\/(?P<length>\d+|\*)/', $header, $matches)) {
            return null;
        }

        return [
            $matches['unit'],
            (int) $matches['first'],
            (int) $matches['last'],
            $matches['length'] === '*' ? '*' : (int) $matches['length'],
        ];
    }
}
