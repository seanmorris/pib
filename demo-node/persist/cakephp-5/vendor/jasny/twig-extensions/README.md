Jasny Twig Extensions
=======================

[![Build Status](https://travis-ci.org/jasny/twig-extensions.svg?branch=master)](https://travis-ci.org/jasny/twig-extensions)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/jasny/twig-extensions/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/jasny/twig-extensions/?branch=master)
[![Code Coverage](https://scrutinizer-ci.com/g/jasny/twig-extensions/badges/coverage.png?b=master)](https://scrutinizer-ci.com/g/jasny/twig-extensions/?branch=master)
[![SensioLabsInsight](https://insight.sensiolabs.com/projects/20fdb2a4-7565-441b-8920-48a7c09113a1/mini.png)](https://insight.sensiolabs.com/projects/20fdb2a4-7565-441b-8920-48a7c09113a1)
[![Packagist Stable Version](https://img.shields.io/packagist/v/jasny/twig-extensions.svg)](https://packagist.org/packages/jasny/twig-extensions)
[![Packagist License](https://img.shields.io/packagist/l/jasny/twig-extensions.svg)](https://packagist.org/packages/jasny/twig-extensions)

A number of useful filters for Twig.

## Installation

Jasny's Twig Extensions can be easily installed using [composer](http://getcomposer.org/)

    composer require jasny/twig-extensions

## Usage

```php
$twig = new Twig_Environment($loader, $options);
$twig->addExtension(new Jasny\Twig\DateExtension());
$twig->addExtension(new Jasny\Twig\PcreExtension());
$twig->addExtension(new Jasny\Twig\TextExtension());
$twig->addExtension(new Jasny\Twig\ArrayExtension());
```

To use in a symfony project [register the extensions as a service](http://symfony.com/doc/current/cookbook/templating/twig_extension.html#register-an-extension-as-a-service).

```yaml
services:
  twig.extension.date:
    class: Jasny\Twig\DateExtension
    tags:
      - { name: twig.extension }

  twig.extension.pcre:
    class: Jasny\Twig\PcreExtension
    tags:
      - { name: twig.extension }
  
  twig.extension.text:
    class: Jasny\Twig\TextExtension
    tags:
      - { name: twig.extension }

  twig.extension.array:
    class: Jasny\Twig\ArrayExtension
    tags:
      - { name: twig.extension }
```


## Date extension

Format a date base on the current locale. Requires the [intl extension](http://www.php.net/intl).

* localdate     - Format the date value as a string based on the current locale
* localtime     - Format the time value as a string based on the current locale
* localdatetime - Format the date/time value as a string based on the current locale
* age           - Get the age (in years) based on a date
* duration      - Get the duration string from seconds

```php
Locale::setDefault(LC_ALL, "en_US"); // vs "nl_NL"
```

```
{{"now"|localdate('long')}}                 <!-- July 12, 2013 --> <!-- 12 juli 2013 -->
{{"now"|localtime('short')}}                <!-- 5:53 PM --> <!-- 17:53 -->
{{"2013-10-01 23:15:00"|localdatetime}}     <!-- 10/01/2013 11:15 PM --> <!-- 01-10-2013 23:15 -->
{{"22-08-1981"|age}}                        <!-- 35 -->
{{ 3600|duration }}                         <!-- 1h -->
```


## PCRE

Exposes [PCRE](http://www.php.net/pcre) to Twig.

* preg_quote   - Quote regular expression characters
* preg_match   - Perform a regular expression match
* preg_get     - Perform a regular expression match and returns the matched group
* preg_get_all - Perform a regular expression match and return the group for all matches
* preg_grep    - Perform a regular expression match and return an array of entries that match the pattern
* preg_replace - Perform a regular expression search and replace
* preg_filter  - Perform a regular expression search and replace, returning only matched subjects.
* preg_split   - Split text into an array using a regular expression

```
{% if client.email|preg_match('/^.+@.+\.\w+$/') %}Email: {{ client.email }}{% endif %}
Website: {{ client.website|preg_replace('~^https?://~')
First name: {{ client.fullname|preg_get('/^\S+/') }}
<ul>
  {% for item in items|preg_split('/\s+/')|preg_filter('/-test$/', 'invert') %}
    <li>{{ item }}</li>
  {% endfor %}
</ul>
```


## Text ##

Convert text to HTML + string functions

* paragraph - Add HTML paragraph and line breaks to text
* line - Get a single line of text
* less - Cut of text on a pagebreak
* truncate - Cut of text if it's to long
* linkify - Turn all URLs in clickable links (also supports Twitter @user and #subject)


## Array ##

Brings PHP's array functions to Twig

* sum - Calculate the sum of values in an array
* product - Calculate the product of values in an array
* values - Return all the values of an array
* as_array - Cast an object to an associated array
* html_attr - Turn an array into an HTML attribute string
