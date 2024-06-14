# Changelog

## [0.4.0](https://github.com/brick/varexporter/releases/tag/0.4.0) - 2023-09-01

Minimum PHP version is now `7.4`. No breaking changes.

## [0.3.8](https://github.com/brick/varexporter/releases/tag/0.3.8) - 2023-01-22

✨ **New feature**

- Support for PHP 8.1 `readonly` properties (#27, #28)

Thanks @AnnaDamm!

## [0.3.7](https://github.com/brick/varexporter/releases/tag/0.3.7) - 2022-06-30

✨ **New feature**

- New option: `VarExporter::INLINE_ARRAY`

🗑️ **Deprecated**

- The `VarExporter::INLINE_NUMERIC_SCALAR_ARRAY` is deprecated, please use `INLINE_SCALAR_LIST` instead

## [0.3.6](https://github.com/brick/varexporter/releases/tag/0.3.6) - 2022-06-15

✨ **New feature**

Support for PHP 8.1 enums (#23).

Thanks @Jacobs63!

## [0.3.5](https://github.com/brick/varexporter/releases/tag/0.3.5) - 2021-02-10

✨ **New feature**

Support for controlling the base indentation level (#17).

Thanks @ADmad!

## [0.3.4](https://github.com/brick/varexporter/releases/tag/0.3.4) - 2021-02-07

✨ **New feature**

Support for trailing comma in non-inline arrays, with the `TRAILING_COMMA_IN_ARRAY` flag (#16).

Thanks @ADmad!

## [0.3.3](https://github.com/brick/varexporter/releases/tag/0.3.3) - 2020-12-24

🐛 **Bug fix**

- Exporting an object with numeric dynamic properties would lead to a `TypeError`

## [0.3.2](https://github.com/brick/varexporter/releases/tag/0.3.2) - 2020-03-13

✨ **New feature**

Support for exporting internal classes implementing `__set_state()`:

- `DateTime`
- `DateTimeImmutable`
- `DateTimeZone`
- `DateInterval`
- `DatePeriod`

Thanks @GameplayJDK!

## [0.3.1](https://github.com/brick/varexporter/releases/tag/0.3.1) - 2020-01-23

✨ **New features**

- Support for closures with `use()` using the `CLOSURE_SNAPSHOT_USE` option (#7)
- Support for arrow functions in PHP 7.4 (#8)

Thanks to @jasny for his awesome work!

## [0.3.0](https://github.com/brick/varexporter/releases/tag/0.3.0) - 2019-12-24

Minimum PHP version is now `7.2`. No breaking changes.

## [0.2.1](https://github.com/brick/varexporter/releases/tag/0.2.1) - 2019-04-16

✨ **New option**: `VarExporter::INLINE_NUMERIC_SCALAR_ARRAY` (#3)

Formats numeric arrays containing only scalar values on a single line.

## [0.2.0](https://github.com/brick/varexporter/releases/tag/0.2.0) - 2019-04-09

✨ **New feature**

- Experimental support for closures 🎉

💥 **Minor BC break**

- `export()` does not throw an exception anymore when encountering a `Closure`.  
  To get the old behaviour back, use the `NO_CLOSURES` option.

## [0.1.2](https://github.com/brick/varexporter/releases/tag/0.1.2) - 2019-04-08

🐛 **Bug fixes**

- Static properties in custom classes were wrongly included—`unset()`—in the output

✨ **Improvements**

- Circular references are now detected, and throw an `ExportException` instead of erroring.

## [0.1.1](https://github.com/brick/varexporter/releases/tag/0.1.1) - 2019-04-08

🐛 **Bug fixes**

- Single-letter properties were wrongly exported using `->{'x'}` notation.

✨ **Improvements**

- Exception messages now contain the path (array keys / object properties) to the failure:

    > `[foo][bar][0]` Type "resource" is not supported.

## [0.1.0](https://github.com/brick/varexporter/releases/tag/0.1.0) - 2019-04-07

First release.

