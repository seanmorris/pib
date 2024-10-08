<?php

namespace Laminas\Http\Header;

interface MultipleHeaderInterface extends HeaderInterface
{
    public function toStringMultipleHeaders(array $headers);
}
