<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Mailer;

/**
 * Represents the result of an already sent email
 */
class SentMailResult extends AbstractResult
{
    /**
     * Processes the mailer to extract the headers and parts
     *
     * @param array $headers The headers included in the email
     * @param array $parts The rendered parts in the email
     */
    public function __construct(array $headers, array $parts)
    {
        $this->headers = $headers;
        $this->parts = $parts;
    }
}
