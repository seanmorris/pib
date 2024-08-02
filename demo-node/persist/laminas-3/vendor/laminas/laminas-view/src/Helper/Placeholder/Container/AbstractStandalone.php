<?php

declare(strict_types=1);

namespace Laminas\View\Helper\Placeholder\Container;

use ArrayAccess;
use Countable;
use Iterator;
use IteratorAggregate;
use Laminas\Escaper\Escaper;
use Laminas\View\Exception;
use Laminas\View\Helper\AbstractHelper;
use Laminas\View\Helper\Placeholder\Container;
use ReturnTypeWillChange;

use function call_user_func_array;
use function class_exists;
use function class_parents;
use function count;
use function in_array;
use function method_exists;
use function sprintf;
use function strtolower;

/**
 * Base class for targeted placeholder helpers
 *
 * @template TKey
 * @template TValue
 * @implements IteratorAggregate<TKey, TValue>
 * @implements ArrayAccess<TKey, TValue>
 * @method static setSeparator(string $separator)
 * @method string getSeparator()
 * @method static setIndent(int|string $indent)
 * @method string getIndent()
 * @method static setPrefix(string $prefix)
 * @method string getPrefix()
 * @method static setPostfix(string $postfix)
 * @method string getPostfix()
 */
abstract class AbstractStandalone extends AbstractHelper implements
    IteratorAggregate,
    Countable,
    ArrayAccess
{
    /**
     * Flag whether to automatically escape output, must also be
     * enforced in the child class if __toString/toString is overridden
     *
     * @var bool
     */
    protected $autoEscape = true;

    /** @var AbstractContainer<TKey, TValue>|null */
    protected $container;

    /**
     * Default container class
     *
     * @var class-string<AbstractContainer>
     */
    protected $containerClass = Container::class;

    /** @var array<string, Escaper> */
    protected $escapers = [];

    public function __construct()
    {
        $this->setContainer($this->getContainer());
    }

    /**
     * Overload
     *
     * Proxy to container methods
     *
     * @param  string $method
     * @param  array $args
     * @throws Exception\BadMethodCallException
     * @return $this|mixed
     */
    public function __call($method, $args)
    {
        $container = $this->getContainer();
        if (method_exists($container, $method)) {
            $return = call_user_func_array([$container, $method], $args);
            if ($return === $container) {
                // If the container is returned, we really want the current object
                return $this;
            }
            return $return;
        }

        throw new Exception\BadMethodCallException('Method "' . $method . '" does not exist');
    }

    /**
     * Overloading: set property value
     *
     * @param TKey $key
     * @param TValue $value
     * @return void
     */
    public function __set($key, $value)
    {
        $container       = $this->getContainer();
        $container[$key] = $value;
    }

    /**
     * Overloading: retrieve property
     *
     * @param TKey $key
     * @return TValue|null
     */
    public function __get($key)
    {
        $container = $this->getContainer();
        if (isset($container[$key])) {
            return $container[$key];
        }
    }

    /**
     * Overloading: check if property is set
     *
     * @param TKey $key
     * @return bool
     */
    public function __isset($key)
    {
        $container = $this->getContainer();
        return isset($container[$key]);
    }

    /**
     * Overloading: unset property
     *
     * @param TKey $key
     * @return void
     */
    public function __unset($key)
    {
        $container = $this->getContainer();
        if (isset($container[$key])) {
            unset($container[$key]);
        }
    }

    /**
     * Cast to string representation
     *
     * @return string
     */
    public function __toString()
    {
        return $this->toString();
    }

    /**
     * String representation
     *
     * @return string
     */
    public function toString()
    {
        return $this->getContainer()->toString();
    }

    /**
     * Escape a string
     *
     * @param  string $string
     * @return string
     */
    protected function escape($string)
    {
        return $this->getEscaper()->escapeHtml((string) $string);
    }

    /**
     * Escape an attribute value
     *
     * @param  string $string
     * @return string
     */
    protected function escapeAttribute($string)
    {
        return $this->getEscaper()->escapeHtmlAttr((string) $string);
    }

    /**
     * Set whether or not auto escaping should be used
     *
     * @param  bool $autoEscape whether or not to auto escape output
     * @return $this
     */
    public function setAutoEscape($autoEscape = true)
    {
        $this->autoEscape = (bool) $autoEscape;
        return $this;
    }

    /**
     * Return whether autoEscaping is enabled or disabled
     *
     * @return bool
     */
    public function getAutoEscape()
    {
        return $this->autoEscape;
    }

    /**
     * Set container on which to operate
     *
     * @return $this
     */
    public function setContainer(AbstractContainer $container)
    {
        $this->container = $container;
        return $this;
    }

    /**
     * Retrieve placeholder container
     *
     * @return AbstractContainer<TKey, TValue>
     */
    public function getContainer()
    {
        if (! $this->container instanceof AbstractContainer) {
            $this->container = new $this->containerClass();
        }
        return $this->container;
    }

    /**
     * Delete a container
     *
     * @return bool
     */
    public function deleteContainer()
    {
        if (null !== $this->container) {
            $this->container = null;
            return true;
        }

        return false;
    }

    /**
     * Set the container class to use
     *
     * @param class-string<AbstractContainer> $name
     * @throws Exception\InvalidArgumentException
     * @throws Exception\DomainException
     * @return $this
     */
    public function setContainerClass($name)
    {
        if (! class_exists($name)) {
            throw new Exception\DomainException(
                sprintf(
                    '%s expects a valid container class name; received "%s", which did not resolve',
                    __METHOD__,
                    $name
                )
            );
        }

        if (! in_array(AbstractContainer::class, class_parents($name))) {
            throw new Exception\InvalidArgumentException('Invalid Container class specified');
        }

        $this->containerClass = $name;
        return $this;
    }

    /**
     * Retrieve the container class
     *
     * @return class-string<AbstractContainer>
     */
    public function getContainerClass()
    {
        return $this->containerClass;
    }

    /**
     * Set Escaper instance
     *
     * @return $this
     */
    public function setEscaper(Escaper $escaper)
    {
        $encoding                  = $escaper->getEncoding();
        $this->escapers[$encoding] = $escaper;

        return $this;
    }

    /**
     * Get Escaper instance
     *
     * Lazy-loads one if none available
     *
     * @param  string $enc Encoding to use
     * @return Escaper
     */
    public function getEscaper($enc = 'UTF-8')
    {
        $enc = strtolower($enc);
        if (! isset($this->escapers[$enc])) {
            $this->setEscaper(new Escaper($enc));
        }

        return $this->escapers[$enc];
    }

    /**
     * Countable
     *
     * @return int
     */
    #[ReturnTypeWillChange]
    public function count()
    {
        $container = $this->getContainer();
        return count($container);
    }

    /**
     * ArrayAccess: offsetExists
     *
     * @param TKey $offset
     * @return bool
     */
    #[ReturnTypeWillChange]
    public function offsetExists($offset)
    {
        return $this->getContainer()->offsetExists($offset);
    }

    /**
     * ArrayAccess: offsetGet
     *
     * @param TKey $offset
     * @return TValue
     */
    #[ReturnTypeWillChange]
    public function offsetGet($offset)
    {
        return $this->getContainer()->offsetGet($offset);
    }

    /**
     * ArrayAccess: offsetSet
     *
     * @param TKey $offset
     * @param TValue $value
     * @return void
     */
    #[ReturnTypeWillChange]
    public function offsetSet($offset, $value)
    {
        $this->getContainer()->offsetSet($offset, $value);
    }

    /**
     * ArrayAccess: offsetUnset
     *
     * @param TKey $offset
     * @return void
     */
    #[ReturnTypeWillChange]
    public function offsetUnset($offset)
    {
        $this->getContainer()->offsetUnset($offset);
    }

    /**
     * IteratorAggregate: get Iterator
     *
     * @return Iterator
     */
    #[ReturnTypeWillChange]
    public function getIterator()
    {
        return $this->getContainer()->getIterator();
    }
}
