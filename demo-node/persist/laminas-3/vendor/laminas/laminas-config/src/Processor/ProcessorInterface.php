<?php

namespace Laminas\Config\Processor;

use Laminas\Config\Config;

interface ProcessorInterface
{
    /**
     * Process the whole Config structure and recursively parse all its values.
     *
     * @return Config
     */
    public function process(Config $value);

    /**
     * Process a single value
     *
     * @param  mixed $value
     * @return mixed
     */
    public function processValue($value);
}
