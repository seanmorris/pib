<?php

namespace Laminas\Http\PhpEnvironment;

use Laminas\Http\Header\HeaderInterface;
use Laminas\Http\Header\MultipleHeaderInterface;
use Laminas\Http\Response as HttpResponse;

use function call_user_func;
use function header;
use function headers_sent;

/**
 * HTTP Response for current PHP environment
 */
class Response extends HttpResponse
{
    /**
     * @deprecated This property is deprecated, and will be removed
     *
     * @var bool
     */
    public $headersSent;

    /**
     * The current used version
     * (The value will be detected on getVersion)
     *
     * @var null|string
     */
    protected $version;

    /** @var bool */
    protected $contentSent = false;

    /** @var null|callable */
    private $headersSentHandler;

    /**
     * Return the HTTP version for this response
     *
     * @see \Laminas\Http\AbstractMessage::getVersion()
     *
     * @return string
     */
    public function getVersion()
    {
        if (! $this->version) {
            $this->version = $this->detectVersion();
        }
        return $this->version;
    }

    /**
     * Detect the current used protocol version.
     * If detection failed it falls back to version 1.0.
     *
     * @return string
     */
    protected function detectVersion()
    {
        if (isset($_SERVER['SERVER_PROTOCOL']) && $_SERVER['SERVER_PROTOCOL'] === 'HTTP/1.1') {
            return self::VERSION_11;
        }

        return self::VERSION_10;
    }

    /**
     * @return bool
     */
    public function headersSent()
    {
        return headers_sent();
    }

    /**
     * @return bool
     */
    public function contentSent()
    {
        return $this->contentSent;
    }

    /**
     * @return void
     */
    public function setHeadersSentHandler(callable $handler)
    {
        $this->headersSentHandler = $handler;
    }

    /**
     * Send HTTP headers
     *
     * @return $this
     */
    public function sendHeaders()
    {
        if ($this->headersSent()) {
            if ($this->headersSentHandler) {
                call_user_func($this->headersSentHandler, $this);
            }

            return $this;
        }

        $status = $this->renderStatusLine();
        header($status);

        /** @var HeaderInterface $header */
        foreach ($this->getHeaders() as $header) {
            if ($header instanceof MultipleHeaderInterface) {
                header($header->toString(), false);
                continue;
            }
            header($header->toString());
        }

        $this->headersSent = true;
        return $this;
    }

    /**
     * Send content
     *
     * @return $this
     */
    public function sendContent()
    {
        if ($this->contentSent()) {
            return $this;
        }

        echo $this->getContent();
        $this->contentSent = true;
        return $this;
    }

    /**
     * Send HTTP response
     *
     * @return $this
     */
    public function send()
    {
        $this->sendHeaders()
             ->sendContent();
        return $this;
    }
}
