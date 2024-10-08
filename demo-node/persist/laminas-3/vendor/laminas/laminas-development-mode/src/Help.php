<?php

declare(strict_types=1);

namespace Laminas\DevelopmentMode;

use function fwrite;
use function is_resource;

class Help
{
    private string $message = <<<EOH
Enable/Disable development mode.

Usage:

development-mode [-h|--help] disable|enable|status

--help|-h                    Print this usage message.
disable                      Disable development mode.
enable                       Enable development mode
                             (do not use in production).
status                       Determine if development mode is currently
                             enabled.
auto-composer                Enable or disable development mode based on
                             the environment variable COMPOSER_DEV_MODE.
                             If the variable is not found, the mode is
                             untouched. If set to something other than "0",
                             it's enabled.

To enable development mode, the following file MUST exist:

- config/development.config.php.dist; this file will be copied to
  config/development.config.php

Optionally:

- config/autoload/development.local.php.dist; this file will be copied to
  config/autoload/development.local.php

When disabling development mode:

- config/development.config.php will be removed if it exists
- config/autoload/development.local.php will be removed if it exists

Additionally, both when disabling and enabling development mode, the
script will remove the file cache/module-config-cache.php (or the file
specified by the combination of the module_listener_options.cache_dir
and module_listener_options.config_cache_key options).

EOH;

    /**
     * Emit the help message.
     *
     * @param null|resource $stream Defaults to STDOUT
     */
    public function __invoke($stream = null)
    {
        if (! is_resource($stream)) {
            echo $this->message;
            return;
        }

        fwrite($stream, $this->message);
    }
}
