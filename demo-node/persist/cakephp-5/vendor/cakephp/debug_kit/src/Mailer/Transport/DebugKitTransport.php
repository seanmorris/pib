<?php
declare(strict_types=1);

namespace DebugKit\Mailer\Transport;

use ArrayObject;
use Cake\Core\App;
use Cake\Mailer\AbstractTransport;
use Cake\Mailer\Message;

/**
 * Debug Transport class, useful for emulating the email sending process and inspecting
 * the resulting email message before actually sending it during development
 */
class DebugKitTransport extends AbstractTransport
{
    /**
     * The transport object this class is decorating
     *
     * @var \Cake\Mailer\AbstractTransport|null
     */
    protected ?AbstractTransport $originalTransport = null;

    /**
     * A reference to the object were emails will be pushed to
     * for logging.
     *
     * @var \ArrayObject
     */
    protected ArrayObject $emailLog;

    /**
     * Constructor
     *
     * @param array $config Configuration options.
     * @param \Cake\Mailer\AbstractTransport|null $originalTransport The transport that is to be decorated
     */
    public function __construct(array $config = [], ?AbstractTransport $originalTransport = null)
    {
        $this->emailLog = $config['debugKitLog'];

        if ($originalTransport !== null) {
            $this->originalTransport = $originalTransport;

            return;
        }

        $className = false;
        if (!empty($config['originalClassName'])) {
            /** @var class-string<\Cake\Mailer\AbstractTransport> $className */
            $className = App::className(
                $config['originalClassName'],
                'Mailer/Transport',
                'Transport'
            );
        }

        if ($className) {
            unset($config['originalClassName'], $config['debugKitLog']);
            /** @psalm-suppress UnsafeInstantiation */
            $this->originalTransport = new $className($config);
        }
    }

    /**
     * @inheritDoc
     */
    public function send(Message $message): array
    {
        $headers = $message->getHeaders(['from', 'sender', 'replyTo', 'readReceipt', 'returnPath', 'to', 'cc']);
        $parts = [
            'text' => $message->getBodyText(),
            'html' => $message->getBodyHtml(),
        ];

        $headers['Subject'] = $message->getOriginalSubject();
        $result = ['headers' => $headers, 'message' => $parts];
        $this->emailLog[] = $result;

        if ($this->originalTransport !== null) {
            return $this->originalTransport->send($message);
        }

        return $result;
    }

    /**
     * Proxy unknown methods to the wrapped object
     *
     * @param string $method The method to call
     * @param array $args The args to call $method with.
     * @return mixed
     */
    public function __call(string $method, array $args): mixed
    {
        /** @var callable $callable */
        $callable = [$this->originalTransport, $method];

        return call_user_func_array($callable, $args);
    }

    /**
     * Proxy property reads to the wrapped object
     *
     * @param string $name The property to read.
     * @return mixed
     */
    public function __get(string $name): mixed
    {
        return $this->originalTransport->{$name};
    }

    /**
     * Proxy property changes to the wrapped object
     *
     * @param string $name The property to read.
     * @param mixed $value The property value.
     * @return void
     */
    public function __set(string $name, mixed $value): void
    {
        $this->originalTransport->{$name} = $value;
    }

    /**
     * Proxy property changes to the wrapped object
     *
     * @param string $name The property to read.
     * @return bool
     */
    public function __isset(string $name): bool
    {
        return isset($this->originalTransport->{$name});
    }

    /**
     * Proxy property changes to the wrapped object
     *
     * @param string $name The property to delete.
     * @return void
     */
    public function __unset(string $name): void
    {
        unset($this->originalTransport->{$name});
    }
}
