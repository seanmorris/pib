<?php

declare(strict_types=1);

namespace Laminas\HttpHandlerRunner\Exception;

use RuntimeException;

use function sprintf;

class EmitterException extends RuntimeException implements ExceptionInterface
{
    public static function forHeadersSent(string $filename, int $line): self
    {
        return new self(sprintf('Unable to emit response; headers already sent in %s:%d', $filename, $line));
    }

    public static function forOutputSent(): self
    {
        return new self('Output has been emitted previously; cannot emit response');
    }
}
