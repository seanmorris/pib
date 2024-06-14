# CakePHP Code Sniffer

![Build Status](https://github.com/cakephp/cakephp-codesniffer/actions/workflows/ci.yml/badge.svg?branch=master)
[![Total Downloads](https://img.shields.io/packagist/dt/cakephp/cakephp-codesniffer.svg?style=flat-square)](https://packagist.org/packages/cakephp/cakephp-codesniffer)
[![Latest Stable Version](https://img.shields.io/packagist/v/cakephp/cakephp-codesniffer.svg?style=flat-square)](https://packagist.org/packages/cakephp/cakephp-codesniffer)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE)

This code works with [squizlabs/php_codesniffer](https://github.com/squizlabs/PHP_CodeSniffer)
and checks code against the coding standards used in CakePHP.

This sniffer package follows [PSR-12](https://www.php-fig.org/psr/psr-12/) completely and ships with a lot of additional fixers on top.

[List of included sniffs](/docs)

## Which version should I use?
See [version map](https://github.com/cakephp/cakephp-codesniffer/wiki).

## Installation

You should install this codesniffer with composer:

	composer require --dev cakephp/cakephp-codesniffer
	vendor/bin/phpcs --config-set installed_paths /path/to/your/app/vendor/cakephp/cakephp-codesniffer

The second command lets `phpcs` know where to find your new sniffs. Ensure that
you do not overwrite any existing `installed_paths` value. Alternatively, install
the [`dealerdirect/phpcodesniffer-composer-installer`](https://github.com/Dealerdirect/phpcodesniffer-composer-installer)
composer package which will handle configuring the `phpcs` `installed_paths` for you.

## Usage

:warning: Warning when these sniffs are installed with composer, ensure that
you have configured the CodeSniffer `installed_paths` setting.

Depending on how you installed the code sniffer changes how you run it. If you have
installed phpcs, and this package with PEAR, you can do the following:

	vendor/bin/phpcs --colors -p -s --standard=CakePHP /path/to/code/

You can also copy the `phpcs.xml.dist` file to your project's root folder as `phpcs.xml`.
This file will import the CakePHP Coding Standard. From there you can edit it to
include/exclude as needed. With this file in place, you can run:

	vendor/bin/phpcs --colors -p -s /path/to/code/

If you are using Composer to manage your CakePHP project, you can also add the below to your composer.json file:

```json
{
    "scripts": {
        "cs-check": "vendor/bin/phpcs --colors -p -s --extensions=php src/ tests/"
    }
}
```

## Running Tests

You can run tests with composer. Because of how PHPCS test suites work, there is
additional configuration state in `phpcs` that is required.

```bash
composer test
```

Once this has been done once, you can use `composer phpunit` to run the
tests for the rules in this repository.

## Contributing

If you'd like to contribute to the Code Sniffer, you can fork the project add
features and send pull requests.

## Releasing CakePHP Code Sniffer

* Create a signed tag
* Write the changelog in the tag commit
