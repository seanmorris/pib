<?php

namespace josegonzalez\Dotenv;

use LogicException;
use RuntimeException;

class Expect
{
    protected $environment = array();

    protected $raise = true;

    public function __construct($environment, $raise = true)
    {
        $this->environment = $environment;
        $this->raise = $raise;
    }

    public function __invoke()
    {
        $args = func_get_args();
        if (count($args) == 0) {
            return $this->raise('LogicException', 'No arguments were passed to expect()');
        }

        if (isset($args[0]) && is_array($args[0])) {
            $args = $args[0];
        }

        $keys = (array) $args;
        $missingEnvs = array();

        foreach ($keys as $key) {
            if (!isset($this->environment[$key])) {
                $missingEnvs[] = $key;
            }
        }

        if (!empty($missingEnvs)) {
            return $this->raise(
                'RuntimeException',
                sprintf("Required ENV vars missing: ['%s']", implode("', '", $missingEnvs))
            );
        }

        return true;
    }

    protected function raise($exception, $message)
    {
        if ($this->raise) {
            throw new $exception($message);
        }

        return false;
    }
}
