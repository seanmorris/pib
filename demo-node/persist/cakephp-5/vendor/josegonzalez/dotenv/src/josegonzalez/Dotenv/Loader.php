<?php

namespace josegonzalez\Dotenv;

use InvalidArgumentException;
use josegonzalez\Dotenv\Expect;
use josegonzalez\Dotenv\Filter\CallableFilter;
use LogicException;
use M1\Env\Parser;

class Loader
{

    protected $environment = null;

    protected $exceptions = array();

    protected $filepaths = null;

    protected $filters = array();

    protected $prefix = null;

    protected $raise = true;

    protected $skip = array(
        'apacheSetenv' => false,
        'define' => false,
        'putenv' => false,
        'toEnv' => false,
        'toServer' => false,
    );

    public function __construct($filepaths = null)
    {
        $this->setFilepaths($filepaths);
    }

    public static function load($options = null)
    {
        $filepaths = null;
        if (is_string($options)) {
            $filepaths = $options;
            $options = array();
        } elseif (isset($options['filepath'])) {
            $filepaths = (array)$options['filepath'];
            unset($options['filepath']);
        } elseif (isset($options['filepaths'])) {
            $filepaths = $options['filepaths'];
            unset($options['filepaths']);
        }

        $dotenv = new \josegonzalez\Dotenv\Loader($filepaths);

        if (array_key_exists('raiseExceptions', $options)) {
            $dotenv->raiseExceptions($options['raiseExceptions']);
        }

        $dotenv->parse();

        if (array_key_exists('filters', $options)) {
            $dotenv->setFilters($options['filters']);
            $dotenv->filter();
        }

        $methods = array(
            'skipExisting',
            'prefix',
            'expect',
            'apacheSetenv',
            'define',
            'putenv',
            'toEnv',
            'toServer',
        );
        foreach ($methods as $method) {
            if (array_key_exists($method, $options)) {
                $dotenv->$method($options[$method]);
            }
        }

        return $dotenv;
    }

    public function filepath()
    {
        return current($this->filepaths);
    }

    public function filepaths()
    {
        return $this->filepaths;
    }

    public function setFilepath($filepath = null)
    {
        return $this->setFilepaths($filepath);
    }

    public function setFilepaths($filepaths = null)
    {
        if ($filepaths == null) {
            $filepaths = array(__DIR__ . DIRECTORY_SEPARATOR . '.env');
        }

        if (is_string($filepaths)) {
            $filepaths = array($filepaths);
        }

        $this->filepaths = $filepaths;
        return $this;
    }

    public function filters()
    {
        return $this->filters;
    }

    public function setFilters(array $filters)
    {
        $newList = array();
        $keys = array_keys($filters);
        $count = count($keys);
        for ($i = 0; $i < $count; $i++) {
            if (is_int($keys[$i])) {
                $filter = $filters[$keys[$i]];
                if (is_string($filter)) {
                    $newList[$filter] = null;
                } else {
                    $newList['__callable__' . $i] = array(
                        'callable' => $filter
                    );
                }
            } else {
                $newList[$keys[$i]] = $filters[$keys[$i]];
            }
        }

        $this->filters = $newList;

        foreach ($this->filters as $filterClass => $config) {
            if (substr($filterClass, 0, 12) === '__callable__') {
                if (is_callable($config['callable'])) {
                    continue;
                }
                return $this->raise(
                    'LogicException',
                    sprintf('Invalid filter class')
                );
            }
            if (is_callable($filterClass)) {
                continue;
            }
            if (!class_exists($filterClass)) {
                return $this->raise(
                    'LogicException',
                    sprintf('Invalid filter class %s', $filterClass)
                );
            }
            continue;
        }
        return $this;
    }

    public function filter()
    {
        $this->requireParse('filter');

        $environment = $this->environment;
        foreach ($this->filters as $filterClass => $config) {
            $filter = $filterClass;
            if (is_string($filterClass)) {
                if (substr($filterClass, 0, 12) === '__callable__') {
                    $filter = new CallableFilter;
                }
                if (class_exists($filterClass)) {
                    $filter = new $filterClass;
                }
            }
            $environment = $filter($environment, $config);
        }

        $this->environment = $environment;
        return $this;
    }

    public function parse()
    {
        $contents = false;
        $filepaths = $this->filepaths();

        foreach ($filepaths as $i => $filepath) {
            $isLast = count($filepaths) - 1 === $i;
            if (!file_exists($filepath) && $isLast) {
                return $this->raise(
                    'InvalidArgumentException',
                    sprintf("Environment file '%s' is not found", $filepath)
                );
            }

            if (is_dir($filepath) && $isLast) {
                return $this->raise(
                    'InvalidArgumentException',
                    sprintf("Environment file '%s' is a directory. Should be a file", $filepath)
                );
            }

            if ((!is_readable($filepath) || ($contents = file_get_contents($filepath)) === false) && $isLast) {
                return $this->raise(
                    'InvalidArgumentException',
                    sprintf("Environment file '%s' is not readable", $filepath)
                );
            }

            if ($contents !== false) {
                break;
            }
        }

        $parser = new Parser($contents);
        $this->environment = $parser->getContent();

        return $this;
    }

    public function expect()
    {
        $this->requireParse('expect');

        $expect = new Expect($this->environment, $this->raise);
        call_user_func_array($expect, func_get_args());

        return $this;
    }

    public function apacheSetenv($overwrite = false)
    {
        $this->requireParse('apache_setenv');
        foreach ($this->environment as $key => $value) {
            $prefixedKey = $this->prefixed($key);
            if (apache_getenv($prefixedKey) !== false && !$overwrite) {
                if ($this->skip['apacheSetenv']) {
                    continue;
                }

                return $this->raise(
                    'LogicException',
                    sprintf('Key "%s" has already been defined in apache_getenv()', $prefixedKey)
                );
            }

            apache_setenv($prefixedKey, $value);
        }

        return $this;
    }

    public function define()
    {
        $this->requireParse('define');
        foreach ($this->environment as $key => $value) {
            $prefixedKey = $this->prefixed($key);
            if (defined($prefixedKey)) {
                if ($this->skip['define']) {
                    continue;
                }

                return $this->raise(
                    'LogicException',
                    sprintf('Key "%s" has already been defined', $prefixedKey)
                );
            }

            define($prefixedKey, $value);
        }

        return $this;
    }

    public function putenv($overwrite = false)
    {
        $this->requireParse('putenv');
        foreach ($this->environment as $key => $value) {
            $prefixedKey = $this->prefixed($key);
            if (getenv($prefixedKey) !== false && !$overwrite) {
                if ($this->skip['putenv']) {
                    continue;
                }

                return $this->raise(
                    'LogicException',
                    sprintf('Key "%s" has already been defined in getenv()', $prefixedKey)
                );
            }

            putenv($prefixedKey . '=' . $value);
        }

        return $this;
    }

    public function toEnv($overwrite = false)
    {
        $this->requireParse('toEnv');
        foreach ($this->environment as $key => $value) {
            $prefixedKey = $this->prefixed($key);
            if (array_key_exists($prefixedKey, $_ENV) && !$overwrite) {
                if ($this->skip['toEnv']) {
                    continue;
                }

                return $this->raise(
                    'LogicException',
                    sprintf('Key "%s" has already been defined in $_ENV', $prefixedKey)
                );
            }

            $_ENV[$prefixedKey] = $value;
        }

        return $this;
    }

    public function toServer($overwrite = false)
    {
        $this->requireParse('toServer');
        foreach ($this->environment as $key => $value) {
            $prefixedKey = $this->prefixed($key);
            if (array_key_exists($prefixedKey, $_SERVER) && !$overwrite) {
                if ($this->skip['toServer']) {
                    continue;
                }

                return $this->raise(
                    'LogicException',
                    sprintf('Key "%s" has already been defined in $_SERVER', $prefixedKey)
                );
            }

            $_SERVER[$prefixedKey] = $value;
        }

        return $this;
    }

    public function skipExisting($types = null)
    {
        $args = func_get_args();
        if (isset($args[0]) && is_array($args[0])) {
            $args = $args[0];
        }

        $types = (array)$args;
        if (empty($types)) {
            $types = array_keys($this->skip);
        }

        foreach ((array)$types as $type) {
            $this->skip[$type] = true;
        }

        return $this;
    }

    public function skipped()
    {
        $skipped = array();
        foreach ($this->skip as $key => $value) {
            if ($value == true) {
                $skipped[] = $key;
            }
        }
        return $skipped;
    }

    public function prefix($prefix = null)
    {
        $this->prefix = $prefix;
        return $this;
    }

    public function prefixed($key)
    {
        if (!!$this->prefix) {
            $key = $this->prefix . $key;
        }

        return $key;
    }

    public function raiseExceptions($raise = true)
    {
        $this->raise = $raise;
        return $this;
    }

    public function toArray()
    {
        $this->requireParse('toArray');
        if ($this->environment === null) {
            return null;
        }

        $environment = array();
        foreach ($this->environment as $key => $value) {
            $environment[$this->prefixed($key)] = $value;
        }
        return $environment;
    }

    public function __toString()
    {
        try {
            $data = $this->toArray();
        } catch (LogicException $e) {
            $data = array();
        }

        return json_encode($data);
    }

    protected function requireParse($method)
    {
        if (!is_array($this->environment)) {
            return $this->raise(
                'LogicException',
                sprintf('Environment must be parsed before calling %s()', $method)
            );
        }
    }

    protected function raise($exception, $message)
    {
        if ($this->raise) {
            throw new $exception($message);
        }


        $this->exceptions[] = new $exception($message);
        return false;
    }
}
