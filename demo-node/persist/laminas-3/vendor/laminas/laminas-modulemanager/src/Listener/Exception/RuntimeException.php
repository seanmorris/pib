<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Listener\Exception;

use Laminas\ModuleManager\Exception;

class RuntimeException extends Exception\RuntimeException implements ExceptionInterface
{
}
