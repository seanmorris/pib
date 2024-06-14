<?php

declare(strict_types=1);

namespace Laminas\HttpHandlerRunner\Emitter;

use Laminas\HttpHandlerRunner\Exception;
use Psr\Http\Message\ResponseInterface;
use ReturnTypeWillChange;
use SplStack;

/**
 * Provides an EmitterInterface implementation that acts as a stack of Emitters.
 *
 * The implementations emit() method iterates itself.
 *
 * When iterating the stack, the first emitter to return a boolean
 * true value will short-circuit iteration.
 *
 * @template-extends SplStack<EmitterInterface>
 */
class EmitterStack extends SplStack implements EmitterInterface
{
    /**
     * Emit a response
     *
     * Loops through the stack, calling emit() on each; any that return a
     * boolean true value will short-circuit, skipping any remaining emitters
     * in the stack.
     *
     * As such, return a boolean false value from an emitter to indicate it
     * cannot emit the response, allowing the next emitter to try.
     */
    public function emit(ResponseInterface $response): bool
    {
        foreach ($this as $emitter) {
            if (false !== $emitter->emit($response)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Set an emitter on the stack by index.
     *
     * @param int $offset
     * @param EmitterInterface $value
     * @return void
     * @throws Exception\InvalidEmitterException If not an EmitterInterface instance.
     */
    #[ReturnTypeWillChange]
    public function offsetSet($offset, $value)
    {
        $this->validateEmitter($value);
        parent::offsetSet($offset, $value);
    }

    /**
     * Push an emitter to the stack.
     *
     * @param EmitterInterface $value
     * @return void
     * @throws Exception\InvalidEmitterException If not an EmitterInterface instance.
     */
    #[ReturnTypeWillChange]
    public function push($value)
    {
        $this->validateEmitter($value);
        parent::push($value);
    }

    /**
     * Unshift an emitter to the stack.
     *
     * @param EmitterInterface $value
     * @return void
     * @throws Exception\InvalidEmitterException If not an EmitterInterface instance.
     */
    #[ReturnTypeWillChange]
    public function unshift($value)
    {
        $this->validateEmitter($value);
        parent::unshift($value);
    }

    /**
     * Validate that an emitter implements EmitterInterface.
     *
     * @throws Exception\InvalidEmitterException For non-emitter instances.
     * @psalm-assert EmitterInterface $emitter
     */
    private function validateEmitter(mixed $emitter): void
    {
        if (! $emitter instanceof EmitterInterface) {
            throw Exception\InvalidEmitterException::forEmitter($emitter);
        }
    }
}
