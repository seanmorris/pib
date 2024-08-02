<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Listener\Exception;

use Brick\VarExporter\ExportException;
use RuntimeException;
use Throwable;

use function sprintf;

final class ConfigCannotBeCachedException extends RuntimeException
{
    private function __construct(string $message = "", int $code = 0, ?Throwable $previous = null)
    {
        parent::__construct($message, $code, $previous);
    }

    /** @internal */
    public static function fromExporterException(ExportException $exportException): self
    {
        return new self(
            sprintf(
                'Cannot export config into a cache file. Config contains uncacheable entries: %s',
                $exportException->getMessage()
            ),
            $exportException->getCode(),
            $exportException
        );
    }
}
