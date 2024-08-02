<?php

declare(strict_types=1);

namespace Laminas\View\Model;

use function array_key_exists;

/**
 * @deprecated
 */
class ConsoleModel extends ViewModel
{
    public const RESULT = 'result';

    /**
     * Console output doesn't support containers.
     *
     * @var string|null
     */
    protected $captureTo;

    /**
     * Console output should always be terminal.
     *
     * @var bool
     */
    protected $terminate = true;

    /**
     * Set error level to return after the application ends.
     *
     * @param int $errorLevel
     * @return $this
     */
    public function setErrorLevel($errorLevel)
    {
        $this->options['errorLevel'] = $errorLevel;
        return $this;
    }

    /**
     * @return int
     */
    public function getErrorLevel()
    {
        if (array_key_exists('errorLevel', $this->options)) {
            return $this->options['errorLevel'];
        }
    }

    /**
     * Set result text.
     *
     * @param string  $text
     * @return ConsoleModel
     */
    public function setResult($text)
    {
        $this->setVariable(self::RESULT, $text);
        return $this;
    }

    /**
     * Get result text.
     *
     * @return mixed
     */
    public function getResult()
    {
        return $this->getVariable(self::RESULT);
    }
}
