# Changelog

All Notable changes to `Env` will be documented in this file

## 2.1.0 - 2016-10-06
### Fixed
- Single quote variables in single quotes will be treated as strings

## 2.0.0 - 2016-01-07
### Altered
- Must pass `file_get_contents()` or content string to `parser` not a `file`
- Keys must not start with a number
- Make `#` in unquoted into string if no space, e.g. `value#notacomment`

### Removed
- File logic (Env.php)

## 1.1.0 - 2016-01-05
### Added
- Support for parameter expansions: [default value](http://wiki.bash-hackers.org/syntax/pe#use_a_default_value) and [assign default value](http://wiki.bash-hackers.org/syntax/pe#assign_a_default_value)
- Support for php `5.3` and `hhvm`

### Altered
- Updated README
- Test cases

## 1.0.2 - 2016-01-03
### Altered
- Updated README

## 1.0.1 - 2015-12-21
### Fixed
- Fixed composer.json

## 1.0.0 - 2015-12-13
### Altered
- Bump to version 1
- Refactored

## 0.2.0 - 2015-12-13
### Altered
- General refactoring and clean up for 0.2.0

## 0.1.0 - 2015-12-13
### Added
- Initial Release
