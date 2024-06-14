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
namespace DebugKit\Panel;

use ArrayObject;
use Cake\Core\App;
use Cake\Mailer\TransportFactory;
use DebugKit\DebugPanel;
use DebugKit\Mailer\Transport\DebugKitTransport;
use ReflectionClass;

/**
 * Provides debug information on the Emails sent during the request
 */
class MailPanel extends DebugPanel
{
    /**
     * The list of emails produced during the request
     *
     * @var \ArrayObject|null
     */
    protected ?ArrayObject $emailLog = null;

    /**
     * Initialize hook - configures the email transport.
     *
     * @return void
     */
    public function initialize(): void
    {
        $reflection = new ReflectionClass(TransportFactory::class);
        $property = $reflection->getProperty('_config');
        $property->setAccessible(true);
        /** @var array<\Cake\Mailer\AbstractTransport|array> $configs */
        $configs = $property->getValue();

        $log = $this->emailLog = new ArrayObject();

        foreach ($configs as $name => $transport) {
            if (is_object($transport)) {
                if (!$transport instanceof DebugKitTransport) {
                    $configs[$name] = new DebugKitTransport(['debugKitLog' => $log], $transport);
                }
                continue;
            }

            $className = App::className($transport['className'], 'Mailer/Transport', 'Transport');
            if (!$className || $className === DebugKitTransport::class) {
                continue;
            }

            $transport['originalClassName'] = $transport['className'];
            $transport['className'] = 'DebugKit.DebugKit';
            $transport['debugKitLog'] = $log;

            $configs[$name] = $transport;
        }
        $reflection->setStaticPropertyValue('_config', $configs);
    }

    /**
     * Get the data this panel wants to store.
     *
     * @return array
     */
    public function data(): array
    {
        return [
            'emails' => isset($this->emailLog) ? $this->emailLog->getArrayCopy() : [],
        ];
    }

    /**
     * Get summary data from the queries run.
     *
     * @return string
     */
    public function summary(): string
    {
        if (empty($this->emailLog)) {
            return '';
        }

        return (string)count($this->emailLog);
    }
}
