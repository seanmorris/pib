# Bake plugin for CakePHP

![Build Status](https://github.com/cakephp/bake/actions/workflows/ci.yml/badge.svg?branch=master)
[![Latest Stable Version](https://img.shields.io/github/v/release/cakephp/bake?sort=semver&style=flat-square)](https://packagist.org/packages/cakephp/bake)
[![Coverage Status](https://img.shields.io/codecov/c/github/cakephp/bake.svg?style=flat-square)](https://codecov.io/github/cakephp/bake)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE.txt)

This project provides the code generation functionality for CakePHP. Through a
suite of CLI tools, you can quickly and easily generate code for your application.

## Installation

You can install this plugin into your CakePHP application using [composer](https://getcomposer.org).

The recommended way to install composer packages is:

```
composer require --dev cakephp/bake
```

## Documentation

You can find the documentation for bake [on its own cookbook](https://book.cakephp.org/bake/3).

## Testing

After installing dependencies with composer you can run tests with `phpunit`:

```bash
vendor/bin/phpunit
```

If your changes require changing the templates that bake uses, you can save time updating tests, by
enabling bake's 'overwrite fixture feature'. This will let you re-generate the expected output files
without having to manually edit each one:

```bash
UPDATE_TEST_COMPARISON_FILES=1 vendor/bin/phpunit
```
