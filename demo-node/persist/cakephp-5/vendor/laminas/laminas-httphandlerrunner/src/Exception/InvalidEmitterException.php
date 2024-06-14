<?php

declare(strict_types=1);

namespace Laminas\HttpHandlerRunner\Exception;

use InvalidArgumentException;
use Laminas\HttpHandlerRunner\Emitter;

use function get_debug_type;
use function sprintf;

class InvalidEmitterException extends InvalidArgumentException implements ExceptionInterface
{
    /**
     * @param mixed $emitter Invalid emitter type
     */
    public static function forEmitter(mixed $emitter): self
    {
        return new self(sprintf(
            '%s can only compose %s implementations; received %s',
            Emitter\EmitterStack::class,
            Emitter\EmitterInterface::class,
            get_debug_type($emitter)
        ));
    }
}
