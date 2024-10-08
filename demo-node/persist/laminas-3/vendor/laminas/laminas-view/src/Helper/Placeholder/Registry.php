<?php

declare(strict_types=1);

namespace Laminas\View\Helper\Placeholder;

use Laminas\View\Exception;
use Laminas\View\Helper\Placeholder\Container\AbstractContainer;

use function array_key_exists;
use function class_exists;
use function class_parents;
use function in_array;
use function sprintf;
use function trigger_error;

use const E_USER_DEPRECATED;

/**
 * Registry for placeholder containers
 *
 * @deprecated since >= 2.20.0. This class is currently unused and will be removed in version 3.0 of this component.
 *             There is no replacement.
 */
class Registry
{
    /**
     * Singleton instance
     *
     * @var Registry
     */
    protected static $instance;

    /**
     * Default container class
     *
     * @var string
     */
    protected $containerClass = Container::class;

    /**
     * Placeholder containers
     *
     * @var array
     */
    protected $items = [];

    /**
     * Retrieve or create registry instance
     *
     * @return Registry
     */
    public static function getRegistry()
    {
        trigger_error('Placeholder view helpers should no longer use a singleton registry', E_USER_DEPRECATED);
        if (null === static::$instance) {
            static::$instance = new static();
        }

        return static::$instance;
    }

    /**
     * Unset the singleton
     *
     * Primarily useful for testing purposes; sets {@link $instance} to null.
     *
     * @return void
     */
    public static function unsetRegistry()
    {
        trigger_error('Placeholder view helpers should no longer use a singleton registry', E_USER_DEPRECATED);
        static::$instance = null;
    }

    /**
     * Set the container for an item in the registry
     *
     * @param  string                      $key
     * @return Registry
     */
    public function setContainer($key, AbstractContainer $container)
    {
        $key               = (string) $key;
        $this->items[$key] = $container;

        return $this;
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
     * createContainer
     *
     * @param  string $key
     * @param  array  $value
     * @return AbstractContainer
     */
    public function createContainer($key, array $value = [])
    {
        $key = (string) $key;

        $this->items[$key] = new $this->containerClass($value);

        return $this->items[$key];
    }

    /**
     * Delete a container
     *
     * @param  string $key
     * @return bool
     */
    public function deleteContainer($key)
    {
        $key = (string) $key;
        if (isset($this->items[$key])) {
            unset($this->items[$key]);
            return true;
        }

        return false;
    }

    /**
     * Set the container class to use
     *
     * @param  string $name
     * @throws Exception\InvalidArgumentException
     * @throws Exception\DomainException
     * @return Registry
     */
    public function setContainerClass($name)
    {
        if (! class_exists($name)) {
            throw new Exception\DomainException(
                sprintf(
                    '%s expects a valid registry class name; received "%s", which did not resolve',
                    __METHOD__,
                    $name
                )
            );
        }

        if (! in_array(AbstractContainer::class, class_parents($name), true)) {
            throw new Exception\InvalidArgumentException('Invalid Container class specified');
        }

        $this->containerClass = $name;

        return $this;
    }

    /**
     * Retrieve the container class
     *
     * @return string
     */
    public function getContainerClass()
    {
        return $this->containerClass;
    }
}
