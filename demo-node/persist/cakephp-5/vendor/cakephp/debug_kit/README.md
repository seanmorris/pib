# CakePHP DebugKit
![Build Status](https://github.com/cakephp/debug_kit/actions/workflows/ci.yml/badge.svg?branch=master)
[![Coverage Status](https://img.shields.io/codecov/c/github/cakephp/debug_kit.svg?style=flat-square)](https://codecov.io/github/cakephp/debug_kit)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE.txt)
[![Total Downloads](https://img.shields.io/packagist/dt/cakephp/cakephp.svg?style=flat-square)](https://packagist.org/packages/cakephp/debug_kit)

DebugKit provides a debugging toolbar and enhanced debugging tools for CakePHP
applications. It lets you quickly see configuration data, log messages, SQL
queries, and timing data for your application.

:warning: DebugKit is only intended for use in single-user local development
environments. You should avoid using DebugKit in shared development
environments, staging environments, or any environment where you need to keep
configuration data and environment variables hidden. :warning:

## Requirements

* SQLite (pdo_sqlite) or another database driver that CakePHP can talk to. By
  default DebugKit will use SQLite, if you need to use a different database see the Database Configuration section in the documentation linked below.

For details and older versions see [version map](https://github.com/cakephp/debug_kit/wiki#version-map).

## Installation

* Install the plugin with [Composer](https://getcomposer.org/) from your CakePHP Project's ROOT directory (where the **composer.json** file is located)
```sh
php composer.phar require --dev cakephp/debug_kit:"^5.0"
```

* [Load the plugin](https://book.cakephp.org/5/en/plugins.html#loading-a-plugin)
```php
// src/Application.php
$this->addPlugin('DebugKit');
```
* Set `'debug' => true,` in `config/app.php`.

## Is DebugKit not working?

If you don't see a CakePHP icon on the bottom right of your page DebugKit is not be
working correctly. Some common problems are:

1. Your PHP environment doesn't have SQLite installed. Check your application
   logs to confirm if this happening. You can either configure DebugKit to use
   a different database, or install the PDO SQLite 3 extension.
2. Your hostname needs to be added to the `DebugKit.safeTld`. If your local
   domain isn't a known development environment name, DebugKit will disable
   itself to protect a potentially non-development environment.
3. If you are using the [Authorization Plugin](https://github.com/cakephp/authorization)
   you need to set `DebugKit.ignoreAuthorization` to `true` in your config.

## Reporting Issues

If you have a problem with DebugKit please open an issue on [GitHub](https://github.com/cakephp/debug_kit/issues).

## Contributing

If you'd like to contribute to DebugKit, check out the
[roadmap](https://github.com/cakephp/debug_kit/wiki/roadmap) for any
planned features. You can [fork](https://help.github.com/articles/fork-a-repo)
the project, add features, and send [pull
requests](https://help.github.com/articles/using-pull-requests) or open
[issues](https://github.com/cakephp/debug_kit/issues).

## Documentation

Documentation for DebugKit can be found in the
[CakePHP documentation](https://book.cakephp.org/debugkit/5/en/index.html).

## Panels
Panels by other plugins:
- `L10n` by [Setup plugin](https://github.com/dereuromark/cakephp-setup) to show current localization for Date, DateTime, Time objects/values.
