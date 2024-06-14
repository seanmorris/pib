<?php

namespace josegonzalez\Dotenv\Filter;

class NullFilter
{
    /**
     * Returns the environment data without any changes.
     *
     * @param array $environment Array of environment data
     * @return array
     */
    public function __invoke(array $environment)
    {
        return $environment;
    }
}
