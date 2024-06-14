# Env

[![Author](http://img.shields.io/badge/author-@milescroxford-blue.svg?style=flat-square)](https://twitter.com/milescroxford)
[![Latest Version on Packagist][ico-version]][link-packagist]
[![Software License][ico-license]](LICENSE.md)
[![Build Status][ico-travis]][link-travis]
[![Coverage Status][ico-scrutinizer]][link-scrutinizer]
[![Quality Score][ico-code-quality]][link-code-quality]
[![Downloads][ico-downloads]][link-downloads]
[![StyleCI](https://styleci.io/repos/47935133/shield)](https://styleci.io/repos/47935133)

[![Sensio badge][ico-sensio]][link-sensio]

Env is a lightweight library bringing .env file parser compatibility to PHP. In short - it enables you to read .env files with PHP.

* [Why?](#why)
* [Requirements](#requirements)
* [Install](#install)
* [Usage](#usage)
    * [Basic](#basic)
    * [Context variables](#context)
    * [Syntax](#syntax)
        * [Assignment](#assignment)
        * [Strings](#strings)
        * [Numbers](#numbers)
        * [Booleans](#booleans)
        * [Null](#null)
        * [Variables](#variables)
            * [Default Value/Assignment](#parameter-expansion)
        * [Comments](#comments)
    * [.env example](#env-example)
* [Notes](#notes)
    * [Source](#source)
* [Other library comparisons](#other-library-comparisons)
* [Todo](#todo)
* [Change log](#change-log)
* [Testing](#testing)
* [Contributing](#Contributing)
* [Security](#security)
* [Credits](#credits)
* [License](#license)


## Why?
Env aims to bring a unified parser for env together for PHP rather than having a few incomplete or buggy parsers written 
into other libraries. This library is not meant as a complete package for config loading like other libraries as this 
is out of scope for this library. If you need something like that check out [Vars](http://github.com/m1/Vars) which incorporates
this library so you can load Env and other file types if you want, or checkout [PHP Dotenv](https://github.com/josegonzalez/php-dotenv)
if you only need .env parsing

## Requirements

Env requires PHP version `5.3+` - supported and tested on `5.3`, `5.4`, `5.5`, `5.6`, `7` and `hhvm`.

## Install

Via Composer

``` bash
$ composer require m1/env
```

## Usage

### Basic

test.env
```bash
TEST_1 = VALUE
```

example.php
```php
<?php

//both examples return the same thing

// example 1 -- standard
use M1\Env\Parser;

$env = new Parser(file_get_contents('test.env'));
$arr = $env->getContent();

// example 2 -- statically
$arr = Parser::parse(file_get_contents('test.env'));

var_dump($arr);
// [
//      "TEST_1" => "VALUE"
// ]
```
### Context variables

test_context.env
```bash
TEST_1 = $EXTERNAL
TEST_2 = VALUE
```

example_context.php
```php
<?php

//both examples return the same thing

// example 1 -- standard
use M1\Env\Parser;

$env = new Parser(file_get_contents('test_context.env'), array('EXTERNAL' => 'external'));
$arr = $env->getContent();

// example 2 -- statically
$arr = Parser::parse(file_get_contents('test_context.env'), array('EXTERNAL' => 'external'));

var_dump($arr);
// [
//      "TEST_1" => "external"
//      "TEST_2" => "VALUE"
// ]
```

### Syntax

The Syntax is slightly more relaxed than bash, but still remains quite bash like

#### Assignment
To assign values the syntax is `key = value`, unlike bash the assignment is pretty relaxed, any of the below are valid:
```bash
TEST1 = value
TEST2= VALUE
TEST3 =VALUE
TEST4=VALUE
 TEST5 = VALUE
TEST6  =   VALUE
```

However keys can not start with a number, e.g.:

```bash
1notvalid = nope
```

Will throw a `ParseException`

You can also add `export` to the start of variables to `source` the file in bash ([see here](#source) for more info):

```bash
export TEST1=value
```

#### Strings

Strings can either be in quotes (single or double) or without:

```bash
TEST1 = value
TEST2 = "value"
TEST3 = 'value'
```

To escape new lines or quotes is the standard backslash:

```bash
TEST1 = "value \n value"
TEST2 = "value \"value\" value"
TEST3 = 'value \' value \' value'
```

If you feature two quoted strings as a value then only the first quoted string will be assigned to the key:

```bash
TEST1 = "value value" "this sentence in quotes will not be counted"
```

#### Numbers

Numbers are fairly standard:
```bash
TEST1 = 1
TEST2 = 2
```

Decimal numbers will be automatically cast to floats:
```bash
TEST1 = 1.1 # `float` type
TEST2 = 2   # `int` type
```

If you quote numbers they will be counted as strings, or if you have two numbers on one line:
```bash
TEST1 = 33 33 # `string` type
TEST2 = "22"  # `string` type
```

#### Booleans

Booleans can be `true`, `false`, `yes` and `no`:
```bash
TEST1 = true
TEST2 = false
TEST3 = yes
TEST4 = no
```

Booleans are case-insensitive:
```bash
TEST1 = True
TEST2 = False
TEST3 = YES
TEST4 = NO
```

Booleans in quotes will be treated as strings:
```bash
TEST1 = "true" # `string` type
TEST2 = "YES"  # `string` type
TEST3 = 'NO'   # `string` type
```

#### Null

Both of the below are counted as null values:
```bash
TEST1 =
TEST2 = null
```

Whereas an empty string is counted as a string:
```bash
TEST1 = "" # `string` type
TEST2 = '' # `string` type
```

#### Variables

Variables are based of the bash syntax:
```bash
TEST1 = 'hello'
TEST2 = ${TEST27} # 'hello'
```

The types of variable get passed to the calling variable if there is only one variable. If there are more than one variable,
the calling variable is automatically cast to a string:
```bash
TEST1 = 1 # `int` type
TEST2 = 2 # `int` type
TEST3 = ${TEST1} ${TEST2} # `string` type
TEST4 = true     # `bool` type
TEST5 = ${TEST4} # `bool` type
```

Also if the variable is in quotes then the variable will be automatically cast as a string:
```bash
TEST1 = 1 # `int` type
TEST2 = "${TEST1}" # `string` type
```

But you can use variables without quotes and they'll be cast as strings:
```bash
TEST1 = foo
TEST2 = bar
TEST3 = ${TEST1}/${TEST2} # `string` type
```

Variables are useful to use in strings like so:
```bash
TEST1 = "foo"
TEST2 = 'bar'
TEST3 = "hello ${TEST1} and ${TEST2}"
```

Null values are passed and casted as empty strings if in quotes:
```bash
TEST1 = null
TEST2 = ${TEST1} # `null` type
TEST3 = "${TEST1}" # `string` type
```

Single Quotes with variables will be counted as strings:
```bash
TEST1 = '${hello} # `string` type, will output: '${hello}'
```


##### Parameter Expansion

You can do parameter expansion, so far you can only do [default values](http://wiki.bash-hackers.org/syntax/pe#use_a_default_value) 
and [assign default values](http://wiki.bash-hackers.org/syntax/pe#assign_a_default_value) like in the bash syntax:

```bash
TEST1 = foo
TEST2 = ${TEST3:=bar}
TEST4 = ${TEST5=bar}
TEST6 = ${TEST7:-bar}
TEST8 = ${TEST9-bar}
```

The default value parameter expansion syntax is `:-`, the explanation on the [bash-hackers wiki](http://wiki.bash-hackers.org/syntax/pe#use_a_default_value) for this is:
> SYNTAX:
>
>`${PARAMETER:-WORD}`
>
>`${PARAMETER-WORD}`
>
>If the parameter PARAMETER is unset (never was defined) or null (empty), this one expands to WORD, otherwise it 
>expands to the value of PARAMETER, as if it just was ${PARAMETER}. If you omit the : (colon), like shown in the second 
>form, the default value is only used when the parameter was unset, not when it was empty.

For example:
```bash
TEST1 = foo
TEST2 = ${TEST1:-bar} # TEST1 is set so the value of TEST2 = foo

TEST3 = ${TEST4:-bar} # TEST4 is not set so the value of TEST3 = bar

TEST5 = null
TEST6 = ${TEST5-bar} # TEST5 is set but empty so the value of TEST6 = null
TEST7 = ${TEST6:-bar} # TEST5 is set and empty so the value of TEST7 = bar

```

The assign default value parameter expansion is `:=`, the explanation on the [bash-hackers wiki](http://wiki.bash-hackers.org/syntax/pe#assign_a_default_value) for this is:
> SYNTAX:
>
>`${PARAMETER:=WORD}`
>
>`${PARAMETER=WORD}`
>
>This one works like the using default values, but the default text you give is not only expanded, but also assigned 
>to the parameter, if it was unset or null. Equivalent to using a default value, when you omit the : (colon), as 
>shown in the second form, the default value will only be assigned when the parameter was unset.

For example:
```bash
TEST1 = foo
TEST2 = ${TEST1:=bar} # TEST1 is set so the value of TEST2 = foo

TEST3 = ${TEST4:=bar} # TEST4 is not set so the value of TEST3 = bar and TEST4 = bar

TEST5 = null
TEST6 = ${TEST5=bar} # TEST5 is set but emtpy so the value of TEST6 = null 
TEST7 = ${TEST6=bar} # TEST5 is set and empty so the value of TEST7 = bar and TEST5 = bar
```
#### Comments

To comment, just use the `#` syntax, you can also comment inline like so:
```bash
# This is a comment
TEST1 = bar # and so is this
```

If you put a `#` without a space in a unquoted string, it will be parsed as a string:

```bash
TEST1 = hello#notacomment
```

### .env example

```bash
# Comments are done like this

# Standard key=value
TEST1 = value
TEST2 = value
TEST3 = value # You can also comment inline like this

# Strings
TEST4 = "value"

## The value of the below variable will be TK4 = "value value"
TEST5 = "value value" "this sentence in quotes will not be counted"

## Escape newline
TEST6 = "value \n value"

## Escape double quotes
TEST7 = "value \"value\" value"

## You can also exchange any of the above for single quotes, eg:
TEST8 = 'value'
TEST9 = 'value \' value \' value'

# Numbers
TEST10 = 1
TEST11 = 1.1
TEST12 = 33 33 # Will output as a `string` -- not a number as two numbers are given
TEST13 = "33" # 33 -- `string` type

# Bools -- All of the below are valid booleans
TEST14 = true
TEST15 = false
TEST16 = yes
TEST17 = no

## Booleans are case-insensitive
TEST18 = True
TEST19 = False
TEST20 = YES
TEST21 = NO

TEST22 = "true" # "true" -- `string` type
TEST23 = "YES" # "YES" -- `string` type
TEST24 = 'NO' # "NO" -- `string` type

# Null values
TEST25 =
TEST26 = null

# Variables
TEST27 = 'hello'
TEST28 = ${TEST27} # 'hello'

TEST29 = 1
TEST30 = 2
TEST31 = ${TEST29}   # 1 -- `int` type
TEST32 = "${TEST29}" # 1 -- `string` type
TEST33 = ${TEST29} ${TEST30} # 1 2 -- `string` type

TEST34 = foo
TEST35 = bar
TEST36 = ${TEST34}/${TEST35} # foo/bar -- `string` type

TEST37 = "foo"
TEST38 = 'bar'
TEST39 = "hello ${TEST37} and ${TEST38}" # hello foo and bar -- `string` type

TEST40 = true
TEST41 = false
TEST42 = ${TEST40} # true -- `bool` type
TEST43 = ${TEST40} ${TEST41} # true false -- `string` type

TEST44 = null
TEST45 = ${TEST44} # null -- `null` type
TEST46 = "${TEST44}" # '' -- `string` type
TEST46_5 = '${TEST44}' # '' -- `string` type

TEST47=foo
TEST48=${TEST47:=bar}
TEST49=${TEST50:=foo}
TEST51=${TEST52:-foo}
TEST53=null
TEST54=${TEST53=foo}
TEST55=null
TEST56=${TEST55-foo}
TEST57=${TEST58:=""}
TEST59=${TEST60:=null} # TEST59 = null TEST60 = null -- both `null` types
TEST61=${TEST62:=true} # TEST61 = true TEST62 = true -- both `bool` types

# Comments
TEST63 = hello # comment
TEST64 = "hello # comment"
TEST65 = "hello" #comment
TEST66 = #comment
TEST67 = "#comment"
TEST68 = thisisnota#comment
```

The result from this library and the expected result of the above is:

```php
array(
    "TEST1" => "value",
    "TEST2" => "value",
    "TEST3" => "value",
    "TEST4" => "value",
    "TEST5" => "value value",
    "TEST6" => "value \n value",
    "TEST7" => 'value "value" value',
    "TEST8" => "value",
    "TEST9" => "value ' value ' value",
    "TEST10" => 1,
    "TEST11" => 1.1,
    "TEST12" => "33 33",
    "TEST13" => "33",
    "TEST14" => true,
    "TEST15" => false,
    "TEST16" => true,
    "TEST17" => false,
    "TEST18" => true,
    "TEST19" => false,
    "TEST20" => true,
    "TEST21" => false,
    "TEST22" => "true",
    "TEST23" => "YES",
    "TEST24" => 'NO',
    "TEST25" => null,
    "TEST26" => null,
    "TEST27" => "hello",
    "TEST28" => "hello",
    "TEST29" => 1,
    "TEST30" => 2,
    "TEST31" => 1,
    "TEST32" => "1",
    "TEST33" => "1 2",
    "TEST34" => "foo",
    "TEST35" => "bar",
    "TEST36" => "foo/bar",
    "TEST37" => "foo",
    "TEST38" => 'bar',
    "TEST39" => "hello foo and bar",
    "TEST40" => true,
    "TEST41" => false,
    "TEST42" => true,
    "TEST43" => "true false",
    "TEST44" => null,
    "TEST45" => null,
    "TEST46" => "",
    "TEST46_5" => "${TEST44}",
    'TEST47' => 'foo',
    'TEST48' => 'foo',
    'TEST50' => 'foo',
    'TEST49' => 'foo',
    'TEST51' => 'foo',
    'TEST53' => null,
    'TEST54' => null,
    'TEST55' => null,
    'TEST56' => null,
    'TEST58' => '',
    'TEST57' => '',
    'TEST60' => null,
    'TEST59' => null,
    'TEST62' => true,
    'TEST61' => true,
    'TEST63' => 'hello # comment',
    'TEST64' => 'hello',
    'TEST66' => null,
    'TEST67' => '#comment',
    'TEST68' => 'thisisnota#comment',
);
```
## Notes

### Source

If you need the .env variables in other applications, you can `source` the env, but make sure it's valid bash syntax, as this parser allows a more relaxed form of bash syntax.

```bash
source .env
```

This library will always be able to parse bash syntax, but for now the opposite (env syntax -> bash syntax) may not be true, however this is being worked on to bring a strict parser version for `3.0`

## Other library comparisons

The difference between this library and other similar libraries:

#### `zrcing/phpenv`: 
- Converts all value types to string
- Does not support `null` values
- Does not support `int`, `float` or `bool` types
- Does not support variables

#### `Dotenv\Dotenv`:
- Does not support unquoted values like `33 33`, this should be cast to string. See `TEST12`
- Does not support concatenation of variables unquoted like `${VAR} ${VAR2}`, this should be cast to string. See `TEST33`
- Both of the above crash `Dotenv` without a helpful exception
- Converts all value types to string
- Does not support `null` values
- Does not support `int`, `float` or `bool` types
- Does not support variables
- Does not support [parameter expansions](#parameter-expansion)
- Does not support inline comments where there is no value. See `TEST66`


## Todo
- [Other bash parameter expansions](http://wiki.bash-hackers.org/syntax/pe#display_error_if_null_or_unset)

## Change log

Please see [CHANGELOG](CHANGELOG.md) for more information what has changed recently.

## Testing

``` bash
$ composer test
```

## Contributing

Please see [CONTRIBUTING](CONTRIBUTING.md) and [CONDUCT](CONDUCT.md) for details.

## Security

If you discover any security related issues, please email hello@milescroxford.com instead of using the issue tracker.

## Credits

- [m1][link-author]
- [All Contributors][link-contributors]

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.

[ico-version]: https://img.shields.io/packagist/v/m1/Env.svg?style=flat-square
[ico-license]: https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square
[ico-travis]: https://img.shields.io/travis/m1/Env/master.svg?style=flat-square
[ico-scrutinizer]: https://img.shields.io/scrutinizer/coverage/g/m1/Env.svg?style=flat-square
[ico-hhvm]: https://img.shields.io/hhvm/m1/Env.svg?style=flat-square
[ico-code-quality]: https://img.shields.io/scrutinizer/g/m1/Env.svg?style=flat-square
[ico-downloads]: https://img.shields.io/packagist/dt/m1/Env.svg?style=flat-square
[ico-sensio]: https://insight.sensiolabs.com/projects/1fb8cbab-f611-45b5-8a45-0113e433eab7/big.png

[link-packagist]: https://packagist.org/packages/m1/Env
[link-travis]: https://travis-ci.org/m1/Env
[link-scrutinizer]: https://scrutinizer-ci.com/g/m1/Env/code-structure
[link-code-quality]: https://scrutinizer-ci.com/g/m1/Env
[link-downloads]: https://packagist.org/packages/m1/Env
[link-author]: https://github.com/m1
[link-contributors]: ../../contributors
[link-sensio]: https://insight.sensiolabs.com/projects/1fb8cbab-f611-45b5-8a45-0113e433eab7
