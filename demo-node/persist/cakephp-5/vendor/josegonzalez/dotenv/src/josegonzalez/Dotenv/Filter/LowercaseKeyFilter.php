<?php

namespace josegonzalez\Dotenv\Filter;

class LowercaseKeyFilter
{
    /**
     * Lowercases all the keys for an environment to a single-depth.
     *
     * @param array $environment Array of environment data
     * @return array
     */
    public function __invoke(array $environment)
    {
        $newEnvironment = array();
        foreach ($environment as $key => $value) {
            $newEnvironment[strtolower($key)] = $value;
        }
        return $newEnvironment;
    }
}
