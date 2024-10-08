<?php

namespace Laminas\Mvc\Service;

use Laminas\Paginator\AdapterPluginManager as PaginatorPluginManager;

class PaginatorPluginManagerFactory extends AbstractPluginManagerFactory
{
    public const PLUGIN_MANAGER_CLASS = PaginatorPluginManager::class;
}
