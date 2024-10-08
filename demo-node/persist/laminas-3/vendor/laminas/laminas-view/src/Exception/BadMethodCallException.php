<?php

declare(strict_types=1);

namespace Laminas\View\Exception;

use BadMethodCallException as BadMethodCall;

class BadMethodCallException extends BadMethodCall implements ExceptionInterface
{
}
