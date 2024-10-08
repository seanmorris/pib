<?php

namespace Laminas\Config;

use interop\container\containerinterface;
use Laminas\ServiceManager\AbstractPluginManager;
use Laminas\ServiceManager\Exception\InvalidServiceException;
use Laminas\ServiceManager\Factory\InvokableFactory;
use Zend\Config\Writer\Ini;
use Zend\Config\Writer\JavaProperties;
use Zend\Config\Writer\Json;
use Zend\Config\Writer\PhpArray;
use Zend\Config\Writer\Xml;
use Zend\Config\Writer\Yaml;

use function array_merge_recursive;
use function gettype;
use function is_object;
use function sprintf;

class WriterPluginManager extends AbstractPluginManager
{
    /** @var string */
    protected $instanceOf = Writer\AbstractWriter::class;

    /** @var string[] */
    protected $aliases = [
        'ini'            => Writer\Ini::class,
        'Ini'            => Writer\Ini::class,
        'json'           => Writer\Json::class,
        'Json'           => Writer\Json::class,
        'php'            => Writer\PhpArray::class,
        'phparray'       => Writer\PhpArray::class,
        'phpArray'       => Writer\PhpArray::class,
        'PhpArray'       => Writer\PhpArray::class,
        'yaml'           => Writer\Yaml::class,
        'Yaml'           => Writer\Yaml::class,
        'xml'            => Writer\Xml::class,
        'Xml'            => Writer\Xml::class,
        'javaproperties' => Writer\JavaProperties::class,
        'javaProperties' => Writer\JavaProperties::class,
        'JavaProperties' => Writer\JavaProperties::class,

        // Legacy Zend Framework aliases
        Ini::class            => Writer\Ini::class,
        JavaProperties::class => Writer\JavaProperties::class,
        Json::class           => Writer\Json::class,
        PhpArray::class       => Writer\PhpArray::class,
        Yaml::class           => Writer\Yaml::class,
        Xml::class            => Writer\Xml::class,

        // v2 normalized FQCNs
        'zendconfigwriterini'            => Writer\Ini::class,
        'zendconfigwriterjavaproperties' => Writer\JavaProperties::class,
        'zendconfigwriterjson'           => Writer\Json::class,
        'zendconfigwriterphparray'       => Writer\PhpArray::class,
        'zendconfigwriteryaml'           => Writer\Yaml::class,
        'zendconfigwriterxml'            => Writer\Xml::class,
    ];

    /** @var string[] */
    protected $factories = [
        Writer\Ini::class            => InvokableFactory::class,
        Writer\JavaProperties::class => InvokableFactory::class,
        Writer\Json::class           => InvokableFactory::class,
        Writer\PhpArray::class       => InvokableFactory::class,
        Writer\Yaml::class           => InvokableFactory::class,
        Writer\Xml::class            => InvokableFactory::class,
        // Legacy (v2) due to alias resolution; canonical form of resolved
        // alias is used to look up the factory, while the non-normalized
        // resolved alias is used as the requested name passed to the factory.
        'laminasconfigwriterini'            => InvokableFactory::class,
        'laminasconfigwriterjavaproperties' => InvokableFactory::class,
        'laminasconfigwriterjson'           => InvokableFactory::class,
        'laminasconfigwriterphparray'       => InvokableFactory::class,
        'laminasconfigwriteryaml'           => InvokableFactory::class,
        'laminasconfigwriterxml'            => InvokableFactory::class,
    ];

    /**
     * Validate the plugin is of the expected type (v3).
     *
     * Validates against `$instanceOf`.
     *
     * @param mixed $instance
     * @throws InvalidServiceException
     */
    public function validate($instance)
    {
        if (! $instance instanceof $this->instanceOf) {
            throw new InvalidServiceException(sprintf(
                '%s can only create instances of %s; %s is invalid',
                static::class,
                $this->instanceOf,
                is_object($instance) ? $instance::class : gettype($instance)
            ));
        }
    }

    /**
     * Validate the plugin is of the expected type (v2).
     *
     * Proxies to `validate()`.
     *
     * @param mixed $instance
     * @throws Exception\InvalidArgumentException
     */
    public function validatePlugin($instance)
    {
        try {
            $this->validate($instance);
        } catch (InvalidServiceException $e) {
            throw new Exception\InvalidArgumentException($e->getMessage(), $e->getCode(), $e);
        }
    }

    public function __construct(containerinterface $container, array $config = [])
    {
        $config = array_merge_recursive(['aliases' => $this->aliases], $config);
        parent::__construct($container, $config);
    }
}
