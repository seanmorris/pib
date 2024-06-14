3.x Migration Guide
###################

Chronos 3.x contains breaking changes that could impact your application. This
guide provides an overview of the breaking changes made in 3.x

Minimum of PHP 8.1
==================

Chronos 3.x requires at least PHP 8.1. This allows chronos to provide more
comprehensive typehinting and better performance by leveraging features found in
newer PHP versions.

MutableDateTime and MutableDate removed
=======================================

The ``MutableDateTime`` and ``MutableDate`` classes have been removed. Long term
PHP will be deprecating and removing mutable datetime classes in favour of
immutable ones. Chronos has long favoured immutable objects and removing the
mutable variants helps simplify the internals of Chronos and encourages safer
development practices.
