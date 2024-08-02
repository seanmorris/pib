<?php

namespace Laminas\Http\Client\Adapter\Exception;

use Laminas\Http\Client\Exception;

class InvalidArgumentException extends Exception\InvalidArgumentException implements
    ExceptionInterface
{
}
