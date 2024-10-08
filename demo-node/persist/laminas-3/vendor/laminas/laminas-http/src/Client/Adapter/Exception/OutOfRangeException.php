<?php

namespace Laminas\Http\Client\Adapter\Exception;

use Laminas\Http\Client\Exception;

class OutOfRangeException extends Exception\OutOfRangeException implements
    ExceptionInterface
{
}
