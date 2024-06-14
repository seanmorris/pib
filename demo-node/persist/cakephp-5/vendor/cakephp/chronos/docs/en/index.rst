Chronos
#######

Chronos provides a zero-dependency ``DateTimeImmutable`` extension, Date-only and Time-only classes:

* ``Cake\Chronos\Chronos`` extends ``DateTimeImmutable`` and provides many helpers.
* ``Cake\Chronos\ChronosDate`` represents calendar dates unaffected by time or time zones.
* ``Cake\Chronos\ChronosTime`` represents clock times independent of date or time zones.
* Only safe, immutable objects.
* A pluggable translation system. Only English translations are included in the
  library. However, ``cakephp/i18n`` can be used for full language support.

The ``Chronos`` class extends ``DateTimeImmutable`` and implements ``DateTimeInterface``
which allows users to use type declarations that support either.

 ``ChronosDate`` and ``ChronosTime`` do not extend ``DateTimeImmutable`` and do not
 share an interface. However, they can be converted to a ``DateTimeImmutable`` instance
 using ``toDateTimeImmutable()``.

Installation
------------

To install Chronos, you should use ``composer``. From your
application's ROOT directory (where composer.json file is located) run the
following::

    php composer.phar require "cakephp/chronos:^3.0"

Creating Instances
------------------

There are many ways to get an instance of Chronos or Date. There are a number of
factory methods that work with different argument sets::

    use Cake\Chronos\Chronos;

    $now = Chronos::now();
    $today = Chronos::today();
    $yesterday = Chronos::yesterday();
    $tomorrow = Chronos::tomorrow();

    // Parse relative expressions
    $date = Chronos::parse('+2 days, +3 hours');

    // Date and time integer values.
    $date = Chronos::create(2015, 12, 25, 4, 32, 58);

    // Date or time integer values.
    $date = Chronos::createFromDate(2015, 12, 25);
    $date = Chronos::createFromTime(11, 45, 10);

    // Parse formatted values.
    $date = Chronos::createFromFormat('m/d/Y', '06/15/2015');

Working with Immutable Objects
------------------------------

Chronos provides only *immutable* objects.

If you've used PHP ``DateTimeImmutable`` and ``DateTime`` classes, then you understand
the difference between *mutable* and *immutable* objects.

Immutable objects create copies of an object each time a change is made. Because modifier methods
around datetimes are not always easy to identify, data can be modified accidentally
or without the developer knowing. Immutable objects prevent accidental changes
to data, and make code free of order-based dependency issues. Immutability does
mean that you will need to remember to replace variables when using modifiers::

    // This code doesn't work with immutable objects
    $chronos->addDay(1);
    doSomething($chronos);
    return $chronos;

    // This works like you'd expect
    $chronos = $chronos->addDay(1);
    $chronos = doSomething($chronos);
    return $chronos;

By capturing the return value of each modification your code will work as
expected.

Date Objects
------------

PHP provides only date-time classes that combines both dates and time parts.
Representing calendar dates can be a bit awkward with ``DateTimeImmutable`` as it includes
time and timezones, which aren't part of a 'date'. Chronos provides
``ChronosDate`` that allows you to represent dates. The time these objects
these objects is always fixed to ``00:00:00`` and not affeced by the server time zone
or modify helpers::

    use Cake\Chronos\ChronosDate;

    $today = ChronosDate::today();

    // Changes to the time/timezone are ignored.
    $today->modify('+1 hours');

    // Outputs '2015-12-20'
    echo $today;

Although ``ChronosDate`` uses a fixed time zone internally, you can specify which
time zone to use for current time such as ``now()`` or ``today()``::

    use Cake\Chronos\ChronosDate:

    // Takes the current date from Asia/Tokyo time zone
    $today = ChronosDate::today('Asia/Tokyo');

Modifier Methods
----------------

Chronos objects provide modifier methods that let you modify the value in
a granular way::

    // Set components of the datetime value.
    $halloween = Chronos::create()
        ->year(2015)
        ->month(10)
        ->day(31)
        ->hour(20)
        ->minute(30);

You can also modify parts of the datetime relatively::

    $future = Chronos::create()
        ->addYear(1)
        ->subMonth(2)
        ->addDays(15)
        ->addHours(20)
        ->subMinutes(2);

It is also possible to make big jumps to defined points in time::

    $time = Chronos::create();
    $time->startOfDay();
    $time->endOfDay();
    $time->startOfMonth();
    $time->endOfMonth();
    $time->startOfYear();
    $time->endOfYear();
    $time->startOfWeek();
    $time->endOfWeek();

Or jump to specific days of the week::

    $time->next(Chronos::TUESDAY);
    $time->previous(Chronos::MONDAY);

When modifying dates/times across :abbr:`DST (Daylight Savings Time)` transitions
your operations may gain/lose an additional hours resulting in hour values that
don't add up. You can avoid these issues by first changing your timezone to
``UTC``, modifying the time::

    // Additional hour gained.
    $time = new Chronos('2014-03-30 00:00:00', 'Europe/London');
    debug($time->modify('+24 hours')); // 2014-03-31 01:00:00

    // First switch to UTC, and modify
    $time = $time->setTimezone('UTC')
        ->modify('+24 hours');

Once you are done modifying the time you can add the original timezone to get
the localized time.

Comparison Methods
------------------

Once you have 2 instances of Chronos date/time objects you can compare them in
a variety of ways::

    // Full suite of comparators exist
    // ne, gt, lt, lte.
    $first->eq($second);
    $first->gte($second);

    // See if the current object is between two others.
    $now->between($start, $end);

    // Find which argument is closest or farthest.
    $now->closest($june, $november);
    $now->farthest($june, $november);

You can also inquire about where a given value falls on the calendar::

    $now->isToday();
    $now->isYesterday();
    $now->isFuture();
    $now->isPast();

    // Check the day of the week
    $now->isWeekend();

    // All other weekday methods exist too.
    $now->isMonday();

You can also find out if a value was within a relative time period::

    $time->wasWithinLast('3 days');
    $time->isWithinNext('3 hours');

Generating Differences
----------------------

In addition to comparing datetimes, calculating differences or deltas between
two values is a common task::

    // Get a DateInterval representing the difference
    $first->diff($second);

    // Get difference as a count of specific units.
    $first->diffInHours($second);
    $first->diffInDays($second);
    $first->diffInWeeks($second);
    $first->diffInYears($second);

You can generate human readable differences suitable for use in a feed or
timeline::

    // Difference from now.
    echo $date->diffForHumans();

    // Difference from another point in time.
    echo $date->diffForHumans($other); // 1 hour ago;

Formatting Strings
------------------

Chronos provides a number of methods for displaying our outputting datetime
objects::

    // Uses the format controlled by setToStringFormat()
    echo $date;

    // Different standard formats
    echo $time->toAtomString();      // 1975-12-25T14:15:16-05:00
    echo $time->toCookieString();    // Thursday, 25-Dec-1975 14:15:16 EST
    echo $time->toIso8601String();   // 1975-12-25T14:15:16-05:00
    echo $time->toRfc822String();    // Thu, 25 Dec 75 14:15:16 -0500
    echo $time->toRfc850String();    // Thursday, 25-Dec-75 14:15:16 EST
    echo $time->toRfc1036String();   // Thu, 25 Dec 75 14:15:16 -0500
    echo $time->toRfc1123String();   // Thu, 25 Dec 1975 14:15:16 -0500
    echo $time->toRfc2822String();   // Thu, 25 Dec 1975 14:15:16 -0500
    echo $time->toRfc3339String();   // 1975-12-25T14:15:16-05:00
    echo $time->toRssString();       // Thu, 25 Dec 1975 14:15:16 -0500
    echo $time->toW3cString();       // 1975-12-25T14:15:16-05:00

    // Get the quarter/week
    echo $time->toQuarter();         // 4
    echo $time->toWeek();            // 52

    // Generic formatting
    echo $time->toTimeString();           // 14:15:16
    echo $time->toDateString();           // 1975-12-25
    echo $time->toDateTimeString();       // 1975-12-25 14:15:16
    echo $time->toFormattedDateString();  // Dec 25, 1975
    echo $time->toDayDateTimeString();    // Thu, Dec 25, 1975 2:15 PM

Extracting Date Components
--------------------------

Getting parts of a date object can be done by directly accessing properties::

    $time = new Chronos('2015-12-31 23:59:58.123');
    $time->year;    // 2015
    $time->month;   // 12
    $time->day;     // 31
    $time->hour     // 23
    $time->minute   // 59
    $time->second   // 58
    $time->micro    // 123

Other properties that can be accessed are:

- timezone
- timezoneName
- dayOfWeek
- dayOfMonth
- dayOfYear
- daysInMonth
- timestamp
- quarter
- half

Testing Aids
------------

When writing unit tests, it is helpful to fixate the current time. Chronos lets
you fix the current time for each class. As part of your test suite's bootstrap
process you can include the following::

    Chronos::setTestNow(Chronos::now());
    ChronosDate::setTestNow(ChronosDate::parse(Chronos::now()));

This will fix the current time of all objects to be the point at which the test
suite started.

For example, if you fixate the ``Chronos`` to some moment in the past, any new
instance of ``Chronos`` created with ``now`` or a relative time string, will be
returned relative to the fixated time::

    Chronos::setTestNow(new Chronos('1975-12-25 00:00:00'));

    $time = new Chronos(); // 1975-12-25 00:00:00
    $time = new Chronos('1 hour ago'); // 1975-12-24 23:00:00

To reset the fixation, simply call ``setTestNow()`` again with no parameter or
with ``null`` as a parameter.
