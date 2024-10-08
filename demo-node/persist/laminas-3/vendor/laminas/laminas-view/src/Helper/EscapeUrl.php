<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

/**
 * @final
 */
class EscapeUrl extends Escaper\AbstractHelper
{
    /**
     * @param  string $value
     * @return string
     */
    protected function escape($value)
    {
        return $this->getEscaper()->escapeUrl($value);
    }
}
