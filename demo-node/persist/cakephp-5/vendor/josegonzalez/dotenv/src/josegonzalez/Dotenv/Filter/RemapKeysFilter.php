<?php

namespace josegonzalez\Dotenv\Filter;

class RemapKeysFilter
{
    /**
     * Remaps specific keys in a $config array to a set of values at a single-depth.
     *
     * @param array $environment Array of environment data
     * @param array $config Array of keys to remap to specific values
     * @return array
     */
    public function __invoke(array $environment, array $config)
    {
        foreach ($config as $key => $value) {
            if (array_key_exists($key, $environment)) {
                $environment[$value] = $environment[$key];
                unset($environment[$key]);
            }
        }
        return $environment;
    }
}
