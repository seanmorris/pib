# TwigView plugin for CakePHP

![Build Status](https://github.com/cakephp/twig-view/actions/workflows/ci.yml/badge.svg?branch=master)
[![Latest Stable Version](https://img.shields.io/github/v/release/cakephp/twig-view?sort=semver&style=flat-square)](https://packagist.org/packages/cakephp/twig-view)
[![Total Downloads](https://img.shields.io/packagist/dt/cakephp/twig-view?style=flat-square)](https://packagist.org/packages/cakephp/twig-view/stats)
[![Code Coverage](https://img.shields.io/coveralls/cakephp/twig-view/master.svg?style=flat-square)](https://coveralls.io/r/cakephp/twig-view?branch=master)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE)


This plugin allows you to use the [Twig Templating Language](https://twig.symfony.com/doc/) for your views.

It provides wrappers for common View opertions and many helpful extensions that expose CakePHP functions and `jasny/twig-extensions` helpers.

## Installation

To install with [Composer](https://getcomposer.org/), use the command below.

```bash
composer require cakephp/twig-view
```

Then, [load the `Cake/TwigView` plugin](https://book.cakephp.org/4/en/plugins.html#loading-a-plugin)
in your `Application` bootstrap just like other Cake plugins.

## Configuration

`TwigView` allows you to configure the Twig Environment through `View` options. You can set these through `ViewBuilder`
in the `Controller` or set them directly in `TwigView`.

```php
// In controller
public function initialize(): void
{
    $this->viewBuilder()->setOption('environment', ['cache' => false]);
}

// In your AppView
public function initialize(): void
{
    $this->setConfig('environment', ['cache' => false]);

    // Call parent TwigView initialize
    parent::initialize();
}
```

### Available Options

- `environment`

    [Twig Environment options](https://twig.symfony.com/doc/3.x/api.html#environment-options).

    Defaults to empty.

- `markdown`

    Which markdown engine is used for `markdown_to_html` filter. Set to `default` to use `DefaultMarkdown` or set
    custom [Twig Markdown extension](https://packagist.org/packages/twig/markdown-extra) `MarkdownInterface` instance.

    If using `default`, require one of:
        - `erusev/parsedown`
        - `league/commonmark`
        - `michelf/php-markdown`

    Defaults to disabled.

## AppView Setup

To start using Twig templates in your application, simply extend `TwigView` in your `AppView`.
In general, it is safe to add your application's setup in `AppView::initialize()`.

```php
namespace App\View;

use Cake\TwigView\View\TwigView;

class AppView extends TwigView
{
    public function initialize(): void
    {
        parent::initialize();

        // Add application-specific extensions
    }
}
```

### Customization

You can override several parts of `TwigView` initialization to create a custom Twig setup.

- File Extensions

    You can specify the file extensions used to search for templates by overriding the
    `$extensions` property.

    ```php
    class AppView extends TwigView
    {
        protected $extensions = [
            '.custom',
        ];
    }
    ```

- Twig Loader

    You can override the template loader used by Twig.

    ```php
    protected function createLoader(): \Twig\Loader\LoaderInterface
    {
        // Return a custom Twig template loader
    }
    ```

- Twig Extensions

    You can override the Twig Extensions loading. If you want to use the built-in
    `View` wrappers, make sure you load `Cake\TwigView\Twig\Extensions\ViewExtension`.

    ```php
    protected function initializeExtensions(): void
    {
        // Load only specific extensions
    }

- Twig Profiler

    You can override the Twig profiler used when `DebugKit` is loaded.

    ```php
        protected function initializeProfiler(): void
        {
            parent::initializeProfiler();
            // Add custom profiler logging using $this->getProfile()
        }
    ```

## Templates

You can create views using Twig templates much like you can with standard CakePHP templates.

Templates are loaded the same way wherever they are used and follow the `View` path conventions.

```twig
{% extends 'Common/base' %}
{{ include('Common/helper') }}
```

- Template names are always relative to `App.path.templates` not the current file.
- File extensions are automatically generated. Defaults to '.twig'.
- Templates can be loaded from plugins the same as `View` templates.

Layout templates are supported and loaded the same way as `View` layouts.

`templates/layout/default.twig`:

```twig
<!DOCTYPE html>
<html>
<head>
    <title>
        {{ fetch('title') }}
    </title>

    {{ fetch('meta') }}
    {{ fetch('css') }}
    {{ fetch('script') }}
</head>
<body>
    {{ fetch('content') }}
</body>
</html>
```

The layout can be set from the template using the `layout` tag.

```twig
{% layout 'Error' %}
```

### Accessing View

You can access the `View` instance using the `_view` global.

`TwigView` provides wrappers for `fetch()`, `cell()` and `element()` rendering.
Cell and element templates are always loaded from **cell/** and **element/** sub-directories
the same as `View` templates.

```twig
{{ fetch('content')}}

{{ cell('myCell')}}
{{ element('myElement') }}
```

`TwigView` also provides wrappers for any loaded helper using a special naming convention - `helper_Name_function()`.

```twig
{{ helper_Text_autoParagraph('some text for a paragarph') }}
```

All wrapper functions are pre-escaped and do not require using `|raw` filter. However, keep in mind that Twig keeps the whitespace when using `{{ }}` to print. Please read the [Twig documentation]((https://twig.symfony.com/doc/3.x/templates.html#whitespace-control)) on how to remove the extra white space when needed.

### Extension Filters

* `low` maps to [`strtolower`](https://php.net/strtolower)
* `up` maps to [`strtoupper`](https://php.net/strtoupper)
* `env` maps to [`env`](https://book.cakephp.org/4/en/core-libraries/global-constants-and-functions.html#global-functions)
* `pluralize` maps to [`Cake\Utility\Inflector::pluralize`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::pluralize)
* `singularize` maps to [`Cake\Utility\Inflector::singularize`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::singularize)
* `camelize` maps to [`Cake\Utility\Inflector::camelize`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::camelize)
* `underscore` maps to [`Cake\Utility\Inflector::underscore`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::underscore)
* `humanize` maps to [`Cake\Utility\Inflector::humanize`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::humanize)
* `tableize` maps to [`Cake\Utility\Inflector::tableize`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::tableize)
* `classify` maps to [`Cake\Utility\Inflector::classify`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::classify)
* `variable` maps to [`Cake\Utility\Inflector::variable`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::variable)
* `slug` maps to [`Cake\Utility\Inflector::slug`](https://book.cakephp.org/4/en/core-libraries/inflector.html#Cake\\Utility\\Inflector::slug)
* `toReadableSize` maps to [`Cake\I18n\Number::toReadableSize`](https://book.cakephp.org/4/en/core-libraries/number.html#Cake\\I18n\\Number::toReadableSize)
* `toPercentage` maps to [`Cake\I18n\Number::toPercentage`](https://book.cakephp.org/4/en/core-libraries/number.html#Cake\\I18n\\Number::toPercentage)
* `cake_number_format` maps to [`Cake\I18n\Number::format`](https://book.cakephp.org/4/en/core-libraries/number.html#Cake\\I18n\\Number::format)
* `formatDelta` maps to [`Cake\I18n\Number::formatDelta`](https://book.cakephp.org/4/en/core-libraries/number.html#Cake\\I18n\\Number::formatDelta)
* `currency` maps to [`Cake\I18n\Number::currency`](https://book.cakephp.org/4/en/core-libraries/number.html#Cake\\I18n\\Number::currency)
* `substr` maps to [`substr`](https://php.net/substr)
* `tokenize` maps to [`Cake\Utility\Text::tokenize`](https://book.cakephp.org/4/en/core-libraries/text.html#simple-string-parsing)
* `insert` maps to [`Cake\Utility\Text::insert`](https://book.cakephp.org/4/en/core-libraries/text.html#formatting-strings)
* `cleanInsert` maps to [`Cake\Utility\Text::cleanInsert`](https://book.cakephp.org/4/en/core-libraries/text.html#formatting-strings)
* `wrap` maps to [`Cake\Utility\Text::wrap`](https://book.cakephp.org/4/en/core-libraries/text.html#wrapping-text)
* `wrapBlock` maps to [`Cake\Utility\Text::wrapBlock`](https://book.cakephp.org/4/en/core-libraries/text.html#wrapping-text)
* `wordWrap` maps to [`Cake\Utility\Text::wordWrap`](https://book.cakephp.org/4/en/core-libraries/text.html#wrapping-text)
* `highlight` maps to [`Cake\Utility\Text::highlight`](https://book.cakephp.org/4/en/core-libraries/text.html#highlighting-substrings)
* `tail` maps to [`Cake\Utility\Text::tail`](https://book.cakephp.org/4/en/core-libraries/text.html#truncating-the-tail-of-a-string)
* `truncate` maps to [`Cake\Utility\Text::truncate`](https://book.cakephp.org/4/en/core-libraries/text.html#truncating-text)
* `excerpt` maps to [`Cake\Utility\Text::excerpt`](https://book.cakephp.org/4/en/core-libraries/text.html#extracting-an-excerpt)
* `toList` maps to [`Cake\Utility\Text::toList`](https://book.cakephp.org/4/en/core-libraries/text.html#converting-an-array-to-sentence-)
* `stripLinks` maps to [`Cake\Utility\Text::stripLinks`](https://book.cakephp.org/4/en/core-libraries/text.html#removing-links)
* `isMultibyte` maps to `Cake\Utility\Text::isMultibyte`
* `utf8` maps to `Cake\Utility\Text::utf8`
* `ascii` maps to `Cake\Utility\Text::ascii`
* `parseFileSize` maps to [`Cake\Utility\Text::parseFileSize`](https://book.cakephp.org/4/en/core-libraries/text.html#simple-string-parsing)
* `serialize` maps to [`serialize`](https://php.net/serialize)
* `unserialize` maps to [`unserialize`](https://php.net/unserialize)
* `md5` maps to [`md5`](https://php.net/md5)
* `base64_encode` maps to [`base64_encode`](https://php.net/base64_encode)
* `base64_decode` maps to [`base64_decode`](https://php.net/base64_decode)
* `string` cast to [`string`](https://php.net/manual/en/language.types.type-juggling.php)

See `jasny/twig-extensions` for the filters they provide.

### Extension Functions

* `in_array` maps to [`in_array`](https://php.net/in_array)
* `explode` maps to [`explode`](https://php.net/explode)
* `array` cast to [`array`](https://php.net/manual/en/language.types.type-juggling.php)
* `array_push` maps to [`push`](https://php.net/array_push)
* `array_prev` maps to [`prev`](https://php.net/prev)
* `array_next` maps to [`next`](https://php.net/next)
* `array_current` maps to [`current`](https://php.net/current)
* `__` maps to [`__`](https://book.cakephp.org/4/en/core-libraries/internationalization-and-localization.html)
* `__d` maps to [`__d`](https://book.cakephp.org/4/en/core-libraries/internationalization-and-localization.html)
* `__n` maps to [`__n`](https://book.cakephp.org/4/en/core-libraries/internationalization-and-localization.html)
* `__x` maps to [`__x`](https://book.cakephp.org/4/en/core-libraries/internationalization-and-localization.html)
* `__dn` maps to [`__dn`](https://book.cakephp.org/4/en/core-libraries/internationalization-and-localization.html)
* `defaultCurrency` maps to [`Cake\I18n\Number::getDefaultCurrency`](https://book.cakephp.org/4/en/core-libraries/number.html#Cake\\I18n\\Number::getDefaultCurrency)
* `uuid` maps to [`Cake\Utility\Text::uuid`](https://book.cakephp.org/4/en/core-libraries/text.html#generating-uuids)
* `time` passed the first and optional second argument into [`new \Cake\I18n\DateTime()`](https://book.cakephp.org/4/en/core-libraries/time.html#creating-time-instances)
* `timezones` maps to `Cake\I18n\DateTime::listTimezones()`

See `jasny/twig-extensions` for the functions they provide.
