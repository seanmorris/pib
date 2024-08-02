<?php

namespace Laminas\Http\Client\Adapter\Exception;

use Laminas\Http\Client\Exception;

class RuntimeException extends Exception\RuntimeException implements
    ExceptionInterface
{
}
