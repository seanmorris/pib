<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Feature;

use Laminas\Console\Adapter\AdapterInterface;

interface ConsoleBannerProviderInterface
{
    /**
     * Returns a string containing a banner text, that describes the module and/or the application.
     * The banner is shown in the console window, when the user supplies invalid command-line parameters or invokes
     * the application with no parameters.
     *
     * The method is called with active Laminas\Console\Adapter\AdapterInterface that can be used to directly access
     * Console and send output.
     *
     * @return string|null
     */
    public function getConsoleBanner(AdapterInterface $console);
}
