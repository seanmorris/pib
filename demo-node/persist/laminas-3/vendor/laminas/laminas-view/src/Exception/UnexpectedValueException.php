<?php

declare(strict_types=1);

namespace Laminas\View\Exception;

use UnexpectedValueException as UnexpectedValue;

class UnexpectedValueException extends UnexpectedValue implements ExceptionInterface
{
}
