<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Listener\Exception;

use Laminas\ModuleManager\Exception;

class InvalidArgumentException extends Exception\InvalidArgumentException implements ExceptionInterface
{
}
