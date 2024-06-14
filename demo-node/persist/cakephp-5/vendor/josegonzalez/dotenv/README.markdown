[![Build Status](https://img.shields.io/travis/josegonzalez/php-dotenv/master.svg?branch=master&style=flat-square)](https://travis-ci.org/josegonzalez/php-dotenv)
[![Coverage Status](https://img.shields.io/codecov/c/github/josegonzalez/dotenv.svg?style=flat-square)](https://codecov.io/github/josegonzalez/dotenv)
[![Total Downloads](https://img.shields.io/packagist/dt/josegonzalez/dotenv.svg?style=flat-square)](https://packagist.org/packages/josegonzalez/dotenv)
[![Latest Stable Version](https://img.shields.io/packagist/v/josegonzalez/dotenv.svg?style=flat-square)](https://packagist.org/packages/josegonzalez/dotenv)

# PHP Dotenv

A `.env` file parsing and loading library for PHP.

- [What is it and why should I use it?](#what-is-it-and-why-should-i-use-it)
- [Rules to follow](#rules-to-follow)
- [General Security Information](#general-security-information)

## Requirements

* PHP 5.5+

## Installation

_[Using [Composer](http://getcomposer.org/)]_

Run `composer require josegonzalez/dotenv:`

Or add the plugin to your project's `composer.json` - something like this:

```javascript
  {
    "require": {
      "josegonzalez/dotenv": "3.3.0"
    }
  }
```

## Usage

Create a new loader:

```php
<?php
$Loader = new josegonzalez\Dotenv\Loader('path/to/.env');
// Parse the .env file
$Loader->parse();
// Send the parsed .env file to the $_ENV variable
$Loader->toEnv();
?>
```

Most methods return the loader directly, so the following is also possible:

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->toEnv(); // Throws LogicException if ->parse() is not called first
?>
```

You can use a `.env` file with any of the following features:

```shell
# comments are allowed
FOO=bar # you can also have comments on the end of a line
export BAR=baz # you can optionally begin with an `export` statement

# both single and double quotes are allowed
BAZ='qux'
QUX="quux"

# as are escaped quotes or similar:
QUUX="corge \" grault"
CORGE='garply" waldo'

# unquoted values containing [null, true, false] are turned into
# their PHP equivalents
PHP_NULL=null
PHP_TRUE=true
PHP_FALSE=false

# when quoted, they are simply string values
STRING_NULL="null"
STRING_TRUE="true"
STRING_FALSE="false"

# spaces are allowed as well
# in a slightly more relaxed form from bash
 GRAULT =fred
GARPLY = plugh
SPACES=" quote values with spaces" # will contain preceding space

# When using newlines, you should use quoted values
QUOTED_NEWLINE="newline\\nchar"

# you can even have nested variables using `${VAR}` syntax
# remember to define the nested var *before* using it
WALDO=${xyzzy} # not yet defined, so will result in WALDO = `{}`
THUD=${GARPLY} # will be defined as `plugh`

# note that variables beginning with a character
# other than [a-zA-Z_] shall throw a ParseException
01SKIPPED=skipped

# However, numbers *are* allowed elsewhere in the key
NOT_SKIPPED1=not skipped # will have the value `not`
```

> Example `.env` files are available in the [fixtures](https://github.com/josegonzalez/php-dotenv/tree/master/tests/josegonzalez/fixtures) directory.

### Defining Constants

You can also define constants automatically from your env file:

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->define(); // Throws LogicException if ->parse() is not called first
?>
```

Already defined constants will result in an immediate `LogicException`.

### Adding to `$_ENV`

```php
<?php
$overwriteENV = true;
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->toEnv($overwriteENV); // Throws LogicException if ->parse() is not called first
?>
```

Already defined `$_ENV` entries will result in an immediate `LogicException`, unless `$overwriteENV` is set to `true` (default `false`).

### Adding to `$_SERVER`

```php
<?php
$overwriteSERVER = true;
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->toServer($overwriteSERVER); // Throws LogicException if ->parse() is not called first
?>
```

Already defined `$_SERVER` entries will result in an immediate `LogicException`, unless `$overwriteSERVER` is set to `true` (default `false`).

### Making available to `apache_getenv()`

> This should be preferred over `getenv` when using the Apache web server with `mod_php`.

```php
<?php
$overwrite = true;
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->apacheSetenv($overwriteAPACHE); // Throws LogicException if ->parse() is not called first
                                                // May throw a PHP Error if either apache_setenv() or apache_putenv() are not available
?>
```

Already defined `apache_getenv()` entries will result in an immediate `LogicException`, unless `$overwriteAPACHE` is set to `true` (default `false`).

### Making available to `getenv()`

```php
<?php
$overwrite = true;
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->putenv($overwriteENV); // Throws LogicException if ->parse() is not called first
?>
```

Already defined `getenv()` entries will result in an immediate `LogicException`, unless `$overwriteENV` is set to `true` (default `false`).

### Setting key prefixes

```php
<?php
$environment = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->prefix('FOO')
              ->toServer(); // BAR=baz becomes FOOBAR=baz
?>
```

### Return as array

```php
<?php
$environment = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->toArray(); // Throws LogicException if ->parse() is not called first
?>
```

### Return as json

```php
<?php
$jsonEnvironment = (string)((new josegonzalez\Dotenv\Loader('path/to/.env'))->parse());
?>
```

### Require environment variables

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->expect('FOO', 'BAR', 'BAZ'); // Throws RuntimeException if variables are missing
?>
```

### Turning off exceptions

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->raiseExceptions(false)
              ->parse()
              ->expect('FOO', 'BAR', 'BAZ'); // Returns false if variables are missing
?>
```

### Skip existing environment variables

It is possible to skip existing enviroment variables (e.g. in a containerized / Docker setup).

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->parse()
              ->skipExisting() //Skip any environment variables that are already present
              ->putenv();
?>
```

### Filtering environments

It is possible to optionally filter the environment data produced by php-dotenv through the use of filter classes. A filter class has an `__invoke` method like so:

```php
<?php
class LollipopFilter
{
    /**
     * Sets every key's value to the string `lollipop`
     *
     * @param array $environment Array of environment data
     * @param array $config Array of configuration data that includes the callable
     * @return array
     */
    public function __invoke(array $environment, array $config)
    {
        $newEnvironment = [];
        foreach ($environment as $key => $value) {
            $newEnvironment[$key] = 'lollipop';
        }
        return $newEnvironment;
    }
}
?>
```

You can attach filters using the `setFilters()` method, which will override all currently specified filters. If an invalid filter is specified, a LogicException will be thrown.

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->setFilters(['LollipopFilter']); // Takes an array of namespaced class names
?>
```

Note that you can optionally set configuration for your filters. These are passed to the `__invoke` method as the second argument.:

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->setFilters([
                'LollipopFilter' => ['paintshop'],
              ]); // Takes an array of namespaced class names
?>
```

Filters can also be callables functions, which is useful in one-off situations. They are wrapped by the special `CallableFilter`.

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->setFilters([function ($data) {
                return $data;
              }]);
?>
```

If you need special configuration for your callable filters, you can prefix your callable with `__callable__N`, where `N` is the integer index the callable is in your array. The callable itself should be contained in a `callable` config key, as follows:

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->setFilters([
                '__callable__0' => [
                  'callable' => function ($data, $config) {
                    return $data;
                  },
                  'someKey' => 'value',
                ]
              ]);
?>
```

Finally, to invoke a filter, you must call `filter()` after calling `parse()`.

```php
<?php
$Loader = (new josegonzalez\Dotenv\Loader('path/to/.env'))
              ->setFilters(['LollipopFilter'])
              ->parse()
              ->filter();
?>
```

#### Available Filters

The following filters are built into php-dotenv.

- `josegonzalez\Dotenv\Filter\CallableFilter`: Wraps a callable and invokes it upon the environment.
- `josegonzalez\Dotenv\Filter\LowercaseKeyFilter`: Lowercases all the keys for an environment to a single-depth.
- `josegonzalez\Dotenv\Filter\NullFilter`: Returns the environment data without any changes.
- `josegonzalez\Dotenv\Filter\RemapKeysFilter`: Remaps specific keys in a `$config` array to a set of values at a single-depth.
- `josegonzalez\Dotenv\Filter\UnderscoreArrayFilter`: Expands a flat array to a nested array. For example, `['0_Foo_Bar' => 'Far']` becomes `[['Foo' => ['Bar' => 'Far']]]`.
- `josegonzalez\Dotenv\Filter\UppercaseFirstKeyFilter`: Uppercases the first letter for all the keys for an environment to a single-depth..
- `josegonzalez\Dotenv\Filter\UrlParseFilter`: When there is a key with the suffix `_URL`, this filter uses `parse_url` to add extra data to the environment.

### Static Environment Definition

You can also call it via the static `load` method call, which takes an array of arguments. If a method name is specified, the method is called with the value in the `$options` array being sent into the method.

```php
<?php
josegonzalez\Dotenv\Loader::load(array(
  'filepath' => 'path/to/.env',
  'expect' => array('FOO', 'BAR', 'BAZ'),
  'toEnv' => true,
  'toServer' => true,
  'define' => true,
));
?>
```

## Validating External Environments

In some cases it may be necessary to validate that a given array of environment data matches your requirements. You can use the `Loader->expect()` functionality via the standalone `Expect` class:

```php
<?php
use josegonzalez\Dotenv\Expect;

$expect = new Expect($env);
$expect('FOO'); // Raises a RuntimeException if `env` is missing FOO

// You can turn off exception raising using the second `raise` argument
$expect = new Expect($env, false);
$expect('FOO'); // Returns false if `env` is missing FOO
?>
```

## What is it and why should I use it?

When developing and deploying your applications you are typically interacting with various environments - production and development for instance. These environments both execute your code, but will do so using different credentials. You may also wish to distribute your application to developers without accidentally giving them access to important external services.

Simple examples include authentication keys to your email provider or database connection credentials. You would never want to accidentally send testing emails to all your users, or run a `DROP TABLE` statement against production because you ran your unit tests.

How do you tackle these differing credentials? The `php-dotenv` helps solve this issue by allowing you to configure your environments in a universal fashion, making it easy to safely switch between environments, as well as share those environments with multiple projects/languages.

Need more reasons? Check out the [twelve-factor app docs on configuration](http://12factor.net/config).

## Rules to follow

When using `php-dotenv`, you should strive to follow the following rules:

- Add your `.env` file to a gitignore and use a `.env.default` or `.env.example` to set defaults for your projects. This allows your development team to override defaults in a method that works for their local environment.
- Always set sane development defaults for any credential. If necessary, disable features when those credentials are "invalid".
- Where necessary, add comments to credentials with information as to what they are, how they are used, and how one might procure new ones.
- As `php-dotenv` uses more lax procedures for defining environment variables, ensure your `.env` files are compatible with your shell. A good way to test this is to run the following:

    ```shell
    # source in your .env file
    source .env
    # check the environment
    env
    ```
- Avoid running `php-dotenv` in production settings, and instead set environment variables in your webserver, process manager, or in bash before running your commands. A simple way to ensure this is to check for the existence of a sentinel environment variable that is *only* set in production:

    ```php
    // APP_NAME isn't set in staging/dev
    if (!env('APP_NAME')) {
        $loader = new josegonzalez\Dotenv\Loader([
            __DIR__ '/.env',
            __DIR__ '/.env.default'
        ]);
        $loader->parse()->toEnv();
    }
    ```

## General Security Information

If you configure `php-dotenv` to output configuration in any of the ways listed above and then dump them, they may be available to undesired users. For instance, using a project like [filp/whoops](https://github.com/filp/whoops) in conjunction with `$Loader->toServer()` can result in outputting sensitive data to your users if you leave whoops enabled in production.

For this reason, `php-dotenv` never populates data to an environment variable by default and requires that the developer make a conscious decision about how they want to use loaded environment variables

Many error reporting tools have the option of whitelisting or blacklisting sensitive data, and you should familiarize yourself with said tooling.


## License

The MIT License (MIT)

Copyright (c) 2013 Jose Diaz-Gonzalez

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
