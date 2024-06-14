<?php

namespace josegonzalez\Dotenv\Filter;

class CallableFilter
{
    /**
     * Wraps a callable and invokes it upon the environment.
     *
     * @param array $environment Array of environment data
     * @param array $config Array of configuration data that includes the callable
     * @return array
     */
    public function __invoke(array $environment, array $config)
    {
        $callable = $config['callable'];
        return $callable($environment, $config);
    }
}
