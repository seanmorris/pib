# Changelog

All notable changes to `array-to-xml` will be documented in this file

## 3.2.3 - 2024-XX-XX

### What's Changed

- Convert boolean values to proper xml representation by @radeno in https://github.com/spatie/array-to-xml/pull/228

## 3.2.2 - 2023-11-14

### What's Changed

- Bump stefanzweifel/git-auto-commit-action from 4 to 5 by @dependabot in https://github.com/spatie/array-to-xml/pull/224
- Conver null based on option by @radeno in https://github.com/spatie/array-to-xml/pull/226

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.2.1...3.2.2

## 3.2.1 - 2023-11-08

### What's Changed

- Bump actions/checkout from 3 to 4 by @dependabot in https://github.com/spatie/array-to-xml/pull/222
- Use proper NULL value when we wanna use with XSD by @radeno in https://github.com/spatie/array-to-xml/pull/225

### New Contributors

- @radeno made their first contribution in https://github.com/spatie/array-to-xml/pull/225

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.2.0...3.2.1

## 3.2.0 - 2023-07-19

### What's Changed

- Bump dependabot/fetch-metadata from 1.4.0 to 1.5.1 by @dependabot in https://github.com/spatie/array-to-xml/pull/217
- Bump dependabot/fetch-metadata from 1.5.1 to 1.6.0 by @dependabot in https://github.com/spatie/array-to-xml/pull/218
- Added Closure value support by @SuperDJ in https://github.com/spatie/array-to-xml/pull/219

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.1.6...3.2.0

## 3.1.6 - 2023-05-11

### What's Changed

- V3 - Code smell ('incorrect' method call) by @ExeQue in https://github.com/spatie/array-to-xml/pull/208
- Bump dependabot/fetch-metadata from 1.3.5 to 1.3.6 by @dependabot in https://github.com/spatie/array-to-xml/pull/210
- Bump dependabot/fetch-metadata from 1.3.6 to 1.4.0 by @dependabot in https://github.com/spatie/array-to-xml/pull/214
- Add addXmlDeclaration parameter by @silnex in https://github.com/spatie/array-to-xml/pull/216

### New Contributors

- @silnex made their first contribution in https://github.com/spatie/array-to-xml/pull/216

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.1.5...3.1.6

## 3.1.5 - 2022-12-24

### What's Changed

- Add Dependabot Automation by @patinthehat in https://github.com/spatie/array-to-xml/pull/196
- Bump actions/checkout from 2 to 3 by @dependabot in https://github.com/spatie/array-to-xml/pull/197
- Fix PHP version by @parallels999 in https://github.com/spatie/array-to-xml/pull/198
- fix deprecated `passing null as string type` by @trin4ik in https://github.com/spatie/array-to-xml/pull/204

### New Contributors

- @dependabot made their first contribution in https://github.com/spatie/array-to-xml/pull/197
- @parallels999 made their first contribution in https://github.com/spatie/array-to-xml/pull/198
- @trin4ik made their first contribution in https://github.com/spatie/array-to-xml/pull/204

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.1.4...3.1.5

## 3.1.4 - 2022-11-24

### What's Changed

- PHP 8.2 support by @SuperDJ in https://github.com/spatie/array-to-xml/pull/194
- Added more types by @SuperDJ in https://github.com/spatie/array-to-xml/pull/195

### New Contributors

- @SuperDJ made their first contribution in https://github.com/spatie/array-to-xml/pull/194

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.1.3...3.1.4

## 3.1.3 - 2022-05-08

## What's Changed

- Rewrite phpunit tests to pest by @otsch in https://github.com/spatie/array-to-xml/pull/183
- PHP 8.1 fix deprecated null parameters by @gigerIT in https://github.com/spatie/array-to-xml/pull/187

## New Contributors

- @otsch made their first contribution in https://github.com/spatie/array-to-xml/pull/183
- @gigerIT made their first contribution in https://github.com/spatie/array-to-xml/pull/187

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.1.2...3.1.3

## 3.1.2 - 2022-03-03

## What's Changed

- Fix basic collection with namespace by @vaclavvanik in https://github.com/spatie/array-to-xml/pull/182

## New Contributors

- @vaclavvanik made their first contribution in https://github.com/spatie/array-to-xml/pull/182

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.1.1...3.1.2

## 3.1.1 - 2022-02-11

## What's Changed

- Fix a typo in the result by @olsza in https://github.com/spatie/array-to-xml/pull/172

## New Contributors

- @olsza made their first contribution in https://github.com/spatie/array-to-xml/pull/172

**Full Changelog**: https://github.com/spatie/array-to-xml/compare/3.1.0...3.1.1

## 3.1.0 - 2021-09-12

- add support for processing instructions

## 3.0.1 - 2021-09-05

- allow null inside array to be converted to xml (#170)

## 3.0.0 - 2021-04-23

- require PHP 8+
- drop support for PHP 7.x
- convert syntax to PHP 8

## 2.16.0 - 2020-11-18

- add escapable colons in custom keys (#151)

## 2.15.1 - 2020-11-12

- add support for PHP 8

## 2.15.0 - 2020-10-29

- add $xmlStandalone as a new parameter (#148)

## 2.14.0 - 2020-09-14

- add support for dropping XML declaration (#145)

## 2.13.0 - 2020-08-24

- add support for custom keys (#140)

## 2.12.1 - 2020-06-17

- add XML prettification (#136)

## 2.11.2 - 2019-08-21

- fix XML structure when using numeric keys

## 2.11.1 - 2019-07-25

- do not interpret "0" as a non-empty value

## 2.11.0 - 2019-09-26

- drop support for PHP 7.1

## 2.10.0 - 2019-09-26

- add `setDomProperties`

## 2.9.0 - 2019-05-06

- add support for numeric keys

## 2.8.1 - 2019-03-15

- fix tests
- drop support for PHP 7.0

## 2.8.0 - 2018-11-29

- added support for mixed content

## 2.7.3 - 2018-10-30

- fix for `DomExeception`s being thrown

## 2.7.2 - 2018-09-17

- remove control characters

## 2.7.1 - 2018-02-02

- fix setting attributes

## 2.7.0 - 2017-09-07

- allow wrapping data in a CDATA section

## 2.6.1- 2017-08-29

- add fix for multiple empty/self-closing child elements

## 2.6.0 - 2017-08-25

- add support for naming a root element and adding properties to it

## 2.5.2 - 2017-08-03

- avoid pulling in the snapshot package on install

## 2.5.1 - 2017-05-30

- PHP 7 is now required

## 2.5.0 - 2017-05-22

- allow encoding and version to be set

## 2.4.0 - 2017-02-18

- attributes and value can be set in SimpleXMLElement style

## 2.3.0 - 2017-02-18

- attributes and value can be set in SimpleXMLElement style

## 2.2.1 - 2016-12-08

- fixed an error when there is a special character to the value set in _value

## 2.2.0 - 2016-06-04

- added `toDom` method

## 2.1.1 - 2016-02-23

- Fixed typo in the name of the `addSequentialNode`-function

## 2.1.0 - 2015-10-08

- Add ability to use attributes

## 2.0.0 - 2015-10-08

- Add support to collection arrays and dynamically XML convertion when keys are numeric

## 1.0.3 - 2015-10-03

- handle values with special characters

## 1.0.1 - 2015-03-18

- use DOMDocument for better validation
- added an option to opt out of the automatic space replacement

## 1.0.0 - 2015-03-17

- initial release
