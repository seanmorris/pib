<?php

namespace Laminas\Config;

use interop\container\containerinterface;
use Laminas\ServiceManager\AbstractPluginManager;
use Laminas\ServiceManager\Exception\InvalidServiceException;
use Laminas\ServiceManager\Factory\InvokableFactory;
use Zend\Config\Reader\Ini;
use Zend\Config\Reader\JavaProperties;
use Zend\Config\Reader\Json;
use Zend\Config\Reader\Xml;
use Zend\Config\Reader\Yaml;

use function array_merge_recursive;
use function gettype;
use function is_object;
use function sprintf;

class ReaderPluginManager extends AbstractPluginManager
{
    /** @var string */
    protected $instanceOf = Reader\ReaderInterface::class;

    /** @var string[] */
    protected $aliases = [
        'ini'            => Reader\Ini::class,
        'Ini'            => Reader\Ini::class,
        'json'           => Reader\Json::class,
        'Json'           => Reader\Json::class,
        'xml'            => Reader\Xml::class,
        'Xml'            => Reader\Xml::class,
        'yaml'           => Reader\Yaml::class,
        'Yaml'           => Reader\Yaml::class,
        'javaproperties' => Reader\JavaProperties::class,
        'javaProperties' => Reader\JavaProperties::class,
        'JavaProperties' => Reader\JavaProperties::class,

        // Legacy Zend Framework aliases
        Ini::class            => Reader\Ini::class,
        Json::class           => Reader\Json::class,
        Xml::class            => Reader\Xml::class,
        Yaml::class           => Reader\Yaml::class,
        JavaProperties::class => Reader\JavaProperties::class,

        // v2 normalized FQCNs
        'zendconfigreaderini'            => Reader\Ini::class,
        'zendconfigreaderjson'           => Reader\Json::class,
        'zendconfigreaderxml'            => Reader\Xml::class,
        'zendconfigreaderyaml'           => Reader\Yaml::class,
        'zendconfigreaderjavaproperties' => Reader\JavaProperties::class,
    ];

    /** @var string[] */
    protected $factories = [
        Reader\Ini::class            => InvokableFactory::class,
        Reader\Json::class           => InvokableFactory::class,
        Reader\Xml::class            => InvokableFactory::class,
        Reader\Yaml::class           => InvokableFactory::class,
        Reader\JavaProperties::class => InvokableFactory::class,
        // Legacy (v2) due to alias resolution; canonical form of resolved
        // alias is used to look up the factory, while the non-normalized
        // resolved alias is used as the requested name passed to the factory.
        'laminasconfigreaderini'            => InvokableFactory::class,
        'laminasconfigreaderjson'           => InvokableFactory::class,
        'laminasconfigreaderxml'            => InvokableFactory::class,
        'laminasconfigreaderyaml'           => InvokableFactory::class,
        'laminasconfigreaderjavaproperties' => InvokableFactory::class,
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
