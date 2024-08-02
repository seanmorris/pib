<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Exception\InvalidArgumentException;
use Laminas\View\Helper\Placeholder\Container;
use Laminas\View\Helper\Placeholder\Container\AbstractContainer;

use function array_key_exists;

/**
 * Helper for passing data between otherwise segregated Views. It's called
 * Placeholder to make its typical usage obvious, but can be used just as easily
 * for non-Placeholder things. That said, the support for this is only
 * guaranteed to effect subsequently rendered templates, and of course Layouts.
 */
class Placeholder extends AbstractHelper
{
    /**
     * Placeholder items
     *
     * @var array<string, AbstractContainer>
     */
    protected $items = [];

    /**
     * Default container class
     *
     * @var class-string<AbstractContainer>
     */
    protected $containerClass = Container::class;

    /**
     * Placeholder helper
     *
     * @param  string $name
     * @throws InvalidArgumentException
     * @return AbstractContainer
     */
    public function __invoke($name = null)
    {
        if ($name === null) {
            throw new InvalidArgumentException(
                'Placeholder: missing argument. $name is required by placeholder($name)'
            );
        }

        return $this->getContainer((string) $name);
    }

    /**
     * createContainer
     *
     * @param  string $key
     * @param  array $value
     * @return AbstractContainer
     */
    public function createContainer($key, array $value = [])
    {
        $key = (string) $key;

        $this->items[$key] = new $this->containerClass($value);
        return $this->items[$key];
    }

    /**
     * Retrieve a placeholder container
     *
     * @param  string $key
     * @return AbstractContainer
     */
    public function getContainer($key)
    {
        $key = (string) $key;
        if (isset($this->items[$key])) {
            return $this->items[$key];
        }

        return $this->createContainer($key);
    }

    /**
     * Does a particular container exist?
     *
     * @param  string $key
     * @return bool
     */
    public function containerExists($key)
    {
        $key = (string) $key;
        return array_key_exists($key, $this->items);
    }

    /**
     * Delete a specific container by name
     *
     * @param  string $key
     * @return void
     */
    public function deleteContainer($key)
    {
        $key = (string) $key;
        unset($this->items[$key]);
    }

    /**
     * Remove all containers
     *
     * @return void
     */
    public function clearContainers()
    {
        $this->items = [];
    }
}
