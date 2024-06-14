<?php

namespace josegonzalez\Dotenv\Filter;

class UrlParseFilter
{
    /**
     * When there is a key with the suffix `_URL`, this filter uses `parse_url`
     * to add extra data to the environment.
     *
     * @param array $environment Array of environment data
     * @return array
     */
    public function __invoke(array $environment)
    {
        $newEnvironment = array();
        foreach ($environment as $key => $value) {
            $newEnvironment[$key] = $value;
            if (substr($key, -4) === '_URL') {
                $prefix = substr($key, 0, -3);
                $url = parse_url($value);
                $newEnvironment[$prefix . 'SCHEME'] = $this->get($url, 'scheme', '');
                $newEnvironment[$prefix . 'HOST'] = $this->get($url, 'host', '');
                $newEnvironment[$prefix . 'PORT'] = $this->get($url, 'port', '');
                $newEnvironment[$prefix . 'USER'] = $this->get($url, 'user', '');
                $newEnvironment[$prefix . 'PASS'] = $this->get($url, 'pass', '');
                $newEnvironment[$prefix . 'PATH'] = $this->get($url, 'path', '');
                $newEnvironment[$prefix . 'QUERY'] = $this->get($url, 'query', '');
                $newEnvironment[$prefix . 'FRAGMENT'] = $this->get($url, 'fragment', '');
            }
        }
        return $newEnvironment;
    }

    public function get(array $data, $key, $default = null)
    {
        if (isset($data[$key])) {
            return $data[$key];
        }

        return $default;
    }
}
