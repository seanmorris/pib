# CakePHP Chronos

![Build Status](https://github.com/cakephp/chronos/actions/workflows/ci.yml/badge.svg?branch=master)
[![Latest Stable Version](https://img.shields.io/github/v/release/cakephp/chronos?sort=semver&style=flat-square)](https://packagist.org/packages/cakephp/chronos)
[![Total Downloads](https://img.shields.io/packagist/dt/cakephp/chronos?style=flat-square)](https://packagist.org/packages/cakephp/chronos/stats)
[![Code Coverage](https://img.shields.io/coveralls/cakephp/chronos/master.svg?style=flat-square)](https://coveralls.io/r/cakephp/chronos?branch=master)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE)

Chronos focuses on providing immutable date/datetime objects.
Immutable objects help ensure that datetime objects aren't accidentally
modified keeping data more predictable.

# Installation

Installing with composer:

```
$ composer require cakephp/chronos
```

You can then use Chronos:

```php
<?php
require 'vendor/autoload.php';

use Cake\Chronos\Chronos;

printf("Now: %s", Chronos::now());
```

# Differences with nesbot/carbon

Chronos was originally compatible with Carbon but has diverged and no longer
extends the PHP DateTime and DateTimeImmutable classes.

# Immutable Object Changes

Immutable objects have a number of advantages:

1. Using immutable objects is always free of side-effects.
2. Dates and times don't accidentally change underneath other parts of your code.

With those benefits in mind, there are a few things you need to keep in mind
when modifying immutable objects:

```php
// This will lose modifications
$date = new Chronos('2015-10-21 16:29:00');
$date->modify('+2 hours');

// This will keep modifications
$date = new Chronos('2015-10-21 16:29:00');
$date = $date->modify('+2 hours');
```

# Calendar Dates

PHP only offers datetime objects as part of the native extensions. Chronos adds
a number of conveniences to the traditional DateTime object and introduces
a `ChronosDate` object. `ChronosDate` instances their time frozen to `00:00:00` and the timezone
set to the server default timezone. This makes them ideal when working with
calendar dates as the time components will always match.

```php
use Cake\Chronos\ChronosDate;

$today = new ChronosDate();
echo $today;
// Outputs '2015-10-21'

echo $today->modify('+3 hours');
// Outputs '2015-10-21'
```

Like instances of `Chronos`, `ChronosDate` objects are also *immutable*.

# Documentation

A more descriptive documentation can be found at [book.cakephp.org/chronos/3/en/](https://book.cakephp.org/chronos/3/en/).

# API Documentation

API documentation can be found on [api.cakephp.org/chronos](https://api.cakephp.org/chronos).
