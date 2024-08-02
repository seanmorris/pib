<?php

namespace Laminas\Http\Client\Adapter;

use Laminas\Uri\Uri;

/**
 * An interface description for Laminas\Http\Client\Adapter classes.
 *
 * These classes are used as connectors for Laminas\Http\Client, performing the
 * tasks of connecting, writing, reading and closing connection to the server.
 */
interface AdapterInterface
{
    /**
     * Set the configuration array for the adapter
     *
     * @param array $options
     */
    public function setOptions($options = []);

    /**
     * Connect to the remote server
     *
     * @param string  $host
     * @param int     $port
     * @param  bool $secure
     */
    public function connect($host, $port = 80, $secure = false);

    /**
     * Send request to the remote server
     *
     * @param string        $method
     * @param Uri $url
     * @param string        $httpVer
     * @param array         $headers
     * @param string        $body
     * @return string Request as text
     */
    public function write($method, $url, $httpVer = '1.1', $headers = [], $body = '');

    /**
     * Read response from server
     *
     * @return string
     */
    public function read();

    /**
     * Close the connection to the server
     */
    public function close();
}
