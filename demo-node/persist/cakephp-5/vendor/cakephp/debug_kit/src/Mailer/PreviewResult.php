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

use Cake\Mailer\Mailer;

/**
 * Represents the result of a preview for a given mailer
 */
class PreviewResult extends AbstractResult
{
    /**
     * Processes the mailer to extract the headers and parts
     *
     * @param \Cake\Mailer\Mailer $mailer The mailer instance to execute and extract the email data from
     * @param string $method The method to execute in the mailer
     */
    public function __construct(Mailer $mailer, string $method)
    {
        $this->processMailer(clone $mailer, $method);
        $mailer->reset();
    }

    /**
     * Executes the mailer and extracts the relevant information from the generated email
     *
     * @param \Cake\Mailer\Mailer $mailer The mailer instance to execute and extract the email data from
     * @param string $method The method to execute in the mailer
     * @return void
     */
    protected function processMailer(Mailer $mailer, string $method): void
    {
        if (!$mailer->viewBuilder()->getTemplate()) {
            $mailer->viewBuilder()->setTemplate($method);
        }

        $mailer->render();
        $message = $mailer->getMessage();
        $this->parts = [
            'html' => $message->getBodyHtml(),
            'text' => $message->getBodyText(),
        ];

        $extra = ['from', 'sender', 'replyTo', 'readReceipt', 'returnPath', 'to', 'cc', 'subject'];
        $this->headers = array_filter($message->getHeaders($extra));
    }
}
