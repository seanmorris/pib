<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @copyright     Copyright (c) Brian Nesbitt <brian@nesbot.com>
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Cake\Chronos;

use DateInterval;
use DatePeriod;
use DateTimeImmutable;
use DateTimeInterface;
use DateTimeZone;
use InvalidArgumentException;
use RuntimeException;
use Stringable;

/**
 * An Immutable extension on the native DateTime object.
 *
 * Adds a number of convenience APIs methods and the ability
 * to easily convert into a mutable object.
 *
 * @property-read int $year
 * @property-read int $yearIso
 * @property-read int<1, 12> $month
 * @property-read int<1, 31> $day
 * @property-read int<0, 23> $hour
 * @property-read int<0, 59> $minute
 * @property-read int<0, 59> $second
 * @property-read int<0, 999999> $micro
 * @property-read int<0, 999999> $microsecond
 * @property-read int $timestamp seconds since the Unix Epoch
 * @property-read \DateTimeZone $timezone the current timezone
 * @property-read \DateTimeZone $tz alias of timezone
 * @property-read int<1, 7> $dayOfWeek 1 (for Monday) through 7 (for Sunday)
 * @property-read int<0, 365> $dayOfYear 0 through 365
 * @property-read int<1, 5> $weekOfMonth 1 through 5
 * @property-read int<1, 53> $weekOfYear ISO-8601 week number of year, weeks starting on Monday
 * @property-read int<1, 31> $daysInMonth number of days in the given month
 * @property-read int $age does a diffInYears() with default parameters
 * @property-read int<1, 4> $quarter the quarter of this instance, 1 - 4
 * @property-read int<1, 2> $half the half of the year, with 1 for months Jan...Jun and 2 for Jul...Dec.
 * @property-read int $offset the timezone offset in seconds from UTC
 * @property-read int $offsetHours the timezone offset in hours from UTC
 * @property-read bool $dst daylight savings time indicator, true if DST, false otherwise
 * @property-read bool $local checks if the timezone is local, true if local, false otherwise
 * @property-read bool $utc checks if the timezone is UTC, true if UTC, false otherwise
 * @property-read string $timezoneName
 * @property-read string $tzName
 * @psalm-immutable
 * @psalm-consistent-constructor
 */
class Chronos extends DateTimeImmutable implements Stringable
{
    use FormattingTrait;

    /**
     * @var int
     */
    public const MONDAY = 1;

    /**
     * @var int
     */
    public const TUESDAY = 2;

    /**
     * @var int
     */
    public const WEDNESDAY = 3;

    /**
     * @var int
     */
    public const THURSDAY = 4;

    /**
     * @var int
     */
    public const FRIDAY = 5;

    /**
     * @var int
     */
    public const SATURDAY = 6;

    /**
     * @var int
     */
    public const SUNDAY = 7;

    /**
     * @var int
     */
    public const YEARS_PER_CENTURY = 100;

    /**
     * @var int
     */
    public const YEARS_PER_DECADE = 10;

    /**
     * @var int
     */
    public const MONTHS_PER_YEAR = 12;

    /**
     * @var int
     */
    public const MONTHS_PER_QUARTER = 3;

    /**
     * @var int
     */
    public const WEEKS_PER_YEAR = 52;

    /**
     * @var int
     */
    public const DAYS_PER_WEEK = 7;

    /**
     * @var int
     */
    public const HOURS_PER_DAY = 24;

    /**
     * @var int
     */
    public const MINUTES_PER_HOUR = 60;

    /**
     * @var int
     */
    public const SECONDS_PER_MINUTE = 60;

    /**
     * Default format to use for __toString method when type juggling occurs.
     *
     * @var string
     */
    public const DEFAULT_TO_STRING_FORMAT = 'Y-m-d H:i:s';

    /**
     * A test Chronos instance to be returned when now instances are created
     *
     * There is a single test now for all date/time classes provided by Chronos.
     * This aims to emulate stubbing out 'now' which is a single global fact.
     *
     * @var \Cake\Chronos\Chronos|null
     */
    protected static ?Chronos $testNow = null;

    /**
     * Format to use for __toString method when type juggling occurs.
     *
     * @var string
     */
    protected static string $toStringFormat = self::DEFAULT_TO_STRING_FORMAT;

    /**
     * Days of weekend
     *
     * @var array
     */
    protected static array $weekendDays = [Chronos::SATURDAY, Chronos::SUNDAY];

    /**
     * Names of days of the week.
     *
     * @var array
     */
    protected static array $days = [
        Chronos::MONDAY => 'Monday',
        Chronos::TUESDAY => 'Tuesday',
        Chronos::WEDNESDAY => 'Wednesday',
        Chronos::THURSDAY => 'Thursday',
        Chronos::FRIDAY => 'Friday',
        Chronos::SATURDAY => 'Saturday',
        Chronos::SUNDAY => 'Sunday',
    ];

    /**
     * First day of week
     *
     * @var int
     */
    protected static int $weekStartsAt = Chronos::MONDAY;

    /**
     * Last day of week
     *
     * @var int
     */
    protected static int $weekEndsAt = Chronos::SUNDAY;

    /**
     * Instance of the diff formatting object.
     *
     * @var \Cake\Chronos\DifferenceFormatterInterface|null
     */
    protected static ?DifferenceFormatterInterface $diffFormatter = null;

    /**
     * Regex for relative period.
     *
     * @var string
     */
    // phpcs:disable Generic.Files.LineLength.TooLong
    protected static string $relativePattern = '/this|next|last|tomorrow|yesterday|midnight|today|[+-]|first|last|ago/i';

    /**
     * Errors from last time createFromFormat() was called.
     *
     * @var array|false
     */
    protected static array|false $lastErrors = false;

    /**
     * Create a new Chronos instance.
     *
     * Please see the testing aids section (specifically static::setTestNow())
     * for more on the possibility of this constructor returning a test instance.
     *
     * @param \Cake\Chronos\ChronosDate|\Cake\Chronos\ChronosTime|\DateTimeInterface|string|int|null $time Fixed or relative time
     * @param \DateTimeZone|string|null $timezone The timezone for the instance
     */
    public function __construct(
        ChronosDate|ChronosTime|DateTimeInterface|string|int|null $time = 'now',
        DateTimeZone|string|null $timezone = null
    ) {
        if (is_int($time) || (is_string($time) && ctype_digit($time))) {
            parent::__construct("@{$time}");

            return;
        }

        if ($timezone !== null) {
            $timezone = $timezone instanceof DateTimeZone ? $timezone : new DateTimeZone($timezone);
        }

        if (is_object($time)) {
            if ($time instanceof DateTimeInterface) {
                $timezone = $time->getTimezone();
            }
            $time = $time->format('Y-m-d H:i:s.u');
        }

        $testNow = static::getTestNow();
        if ($testNow === null) {
            parent::__construct($time ?? 'now', $timezone);

            return;
        }

        $relative = static::hasRelativeKeywords($time);
        if ($time && $time !== 'now' && !$relative) {
            parent::__construct($time, $timezone);

            return;
        }

        $testNow = clone $testNow;
        $relativeTime = self::isTimeExpression($time);
        if (!$relativeTime && $timezone !== $testNow->getTimezone()) {
            $testNow = $testNow->setTimezone($timezone ?? date_default_timezone_get());
        }

        if ($relative) {
            $testNow = $testNow->modify($time ?? 'now');
        }

        parent::__construct($testNow->format('Y-m-d H:i:s.u'), $timezone);
    }

    /**
     * Set a Chronos instance (real or mock) to be returned when a "now"
     * instance is created.  The provided instance will be returned
     * specifically under the following conditions:
     *   - A call to the static now() method, ex. Chronos::now()
     *   - When a null (or blank string) is passed to the constructor or parse(), ex. new Chronos(null)
     *   - When the string "now" is passed to the constructor or parse(), ex. new Chronos('now')
     *   - When a string containing the desired time is passed to Chronos::parse()
     *
     * Note the timezone parameter was left out of the examples above and
     * has no affect as the mock value will be returned regardless of its value.
     *
     * To clear the test instance call this method using the default
     * parameter of null.
     *
     * @param \Cake\Chronos\Chronos|string|null $testNow The instance to use for all future instances.
     * @return void
     */
    public static function setTestNow(Chronos|string|null $testNow = null): void
    {
        static::$testNow = is_string($testNow) ? static::parse($testNow) : $testNow;
    }

    /**
     * Get the Chronos instance (real or mock) to be returned when a "now"
     * instance is created.
     *
     * @return \Cake\Chronos\Chronos|null The current instance used for testing
     */
    public static function getTestNow(): ?Chronos
    {
        return static::$testNow;
    }

    /**
     * Determine if there is a valid test instance set. A valid test instance
     * is anything that is not null.
     *
     * @return bool True if there is a test instance, otherwise false
     */
    public static function hasTestNow(): bool
    {
        return static::$testNow !== null;
    }

    /**
     * Determine if there is just a time in the time string
     *
     * @param string|null $time The time string to check.
     * @return bool true if there is a keyword, otherwise false
     */
    private static function isTimeExpression(?string $time): bool
    {
        // Just a time
        if (is_string($time) && preg_match('/^[0-2]?[0-9]:[0-5][0-9](?::[0-5][0-9](?:\.[0-9]{1,6})?)?$/', $time)) {
            return true;
        }

        return false;
    }

    /**
     * Determine if there is a relative keyword in the time string, this is to
     * create dates relative to now for test instances. e.g.: next tuesday
     *
     * @param string|null $time The time string to check.
     * @return bool true if there is a keyword, otherwise false
     */
    public static function hasRelativeKeywords(?string $time): bool
    {
        if (self::isTimeExpression($time)) {
            return true;
        }
        // skip common format with a '-' in it
        if ($time && preg_match('/[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}/', $time) !== 1) {
            return preg_match(static::$relativePattern, $time) > 0;
        }

        return false;
    }

    /**
     * Get weekend days
     *
     * @return array
     */
    public static function getWeekendDays(): array
    {
        return static::$weekendDays;
    }

    /**
     * Set weekend days
     *
     * @param array $days Which days are 'weekends'.
     * @return void
     */
    public static function setWeekendDays(array $days): void
    {
        static::$weekendDays = $days;
    }

    /**
     * Get the first day of week
     *
     * @return int
     */
    public static function getWeekStartsAt(): int
    {
        return static::$weekStartsAt;
    }

    /**
     * Set the first day of week
     *
     * @param int $day The day the week starts with.
     * @return void
     */
    public static function setWeekStartsAt(int $day): void
    {
        static::$weekStartsAt = $day;
    }

    /**
     * Get the last day of week
     *
     * @return int
     */
    public static function getWeekEndsAt(): int
    {
        return static::$weekEndsAt;
    }

    /**
     * Set the last day of week
     *
     * @param int $day The day the week ends with.
     * @return void
     */
    public static function setWeekEndsAt(int $day): void
    {
        static::$weekEndsAt = $day;
    }

    /**
     * Get the difference formatter instance or overwrite the current one.
     *
     * @param \Cake\Chronos\DifferenceFormatterInterface|null $formatter The formatter instance when setting.
     * @return \Cake\Chronos\DifferenceFormatterInterface The formatter instance.
     */
    public static function diffFormatter(?DifferenceFormatterInterface $formatter = null): DifferenceFormatterInterface
    {
        if ($formatter === null) {
            if (static::$diffFormatter === null) {
                static::$diffFormatter = new DifferenceFormatter();
            }

            return static::$diffFormatter;
        }

        return static::$diffFormatter = $formatter;
    }

    /**
     * Create an instance from a DateTimeInterface
     *
     * @param \DateTimeInterface $other The datetime instance to convert.
     * @return static
     */
    public static function instance(DateTimeInterface $other): static
    {
        return new static($other);
    }

    /**
     * Create an instance from a string.  This is an alias for the
     * constructor that allows better fluent syntax as it allows you to do
     * Chronos::parse('Monday next week')->fn() rather than
     * (new Chronos('Monday next week'))->fn()
     *
     * @param \Cake\Chronos\ChronosDate|\Cake\Chronos\ChronosTime|\DateTimeInterface|string|int|null $time The strtotime compatible string to parse
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name.
     * @return static
     */
    public static function parse(
        ChronosDate|ChronosTime|DateTimeInterface|string|int|null $time = 'now',
        DateTimeZone|string|null $timezone = null
    ): static {
        return new static($time, $timezone);
    }

    /**
     * Get an instance for the current date and time
     *
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name.
     * @return static
     */
    public static function now(DateTimeZone|string|null $timezone = null): static
    {
        return new static('now', $timezone);
    }

    /**
     * Create an instance for today
     *
     * @param \DateTimeZone|string|null $timezone The timezone to use.
     * @return static
     */
    public static function today(DateTimeZone|string|null $timezone = null): static
    {
        return new static('midnight', $timezone);
    }

    /**
     * Create an instance for tomorrow
     *
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name the new instance should use.
     * @return static
     */
    public static function tomorrow(DateTimeZone|string|null $timezone = null): static
    {
        return new static('tomorrow, midnight', $timezone);
    }

    /**
     * Create an instance for yesterday
     *
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name the new instance should use.
     * @return static
     */
    public static function yesterday(DateTimeZone|string|null $timezone = null): static
    {
        return new static('yesterday, midnight', $timezone);
    }

    /**
     * Create an instance for the greatest supported date.
     *
     * @return static
     */
    public static function maxValue(): static
    {
        return static::createFromTimestamp(PHP_INT_MAX);
    }

    /**
     * Create an instance for the lowest supported date.
     *
     * @return static
     */
    public static function minValue(): static
    {
        $max = PHP_INT_SIZE === 4 ? PHP_INT_MAX : PHP_INT_MAX / 10;

        return static::createFromTimestamp(~$max);
    }

    /**
     * Create an instance from a specific date and time.
     *
     * If any of $year, $month or $day are set to null their now() values
     * will be used.
     *
     * If $hour is null it will be set to its now() value and the default values
     * for $minute, $second and $microsecond will be their now() values.
     * If $hour is not null then the default values for $minute, $second
     * and $microsecond will be 0.
     *
     * @param int|null $year The year to create an instance with.
     * @param int|null $month The month to create an instance with.
     * @param int|null $day The day to create an instance with.
     * @param int|null $hour The hour to create an instance with.
     * @param int|null $minute The minute to create an instance with.
     * @param int|null $second The second to create an instance with.
     * @param int|null $microsecond The microsecond to create an instance with.
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name the new instance should use.
     * @return static
     */
    public static function create(
        ?int $year = null,
        ?int $month = null,
        ?int $day = null,
        ?int $hour = null,
        ?int $minute = null,
        ?int $second = null,
        ?int $microsecond = null,
        DateTimeZone|string|null $timezone = null
    ): static {
        $now = static::now();
        $year = $year ?? (int)$now->format('Y');
        $month = $month ?? $now->format('m');
        $day = $day ?? $now->format('d');

        if ($hour === null) {
            $hour = $now->format('H');
            $minute = $minute ?? $now->format('i');
            $second = $second ?? $now->format('s');
            $microsecond = $microsecond ?? $now->format('u');
        } else {
            $minute = $minute ?? 0;
            $second = $second ?? 0;
            $microsecond = $microsecond ?? 0;
        }

        $instance = static::createFromFormat(
            'Y-m-d H:i:s.u',
            sprintf('%s-%s-%s %s:%02s:%02s.%06s', 0, $month, $day, $hour, $minute, $second, $microsecond),
            $timezone
        );

        return $instance->addYears($year);
    }

    /**
     * Create an instance from just a date. The time portion is set to now.
     *
     * @param int|null $year The year to create an instance with.
     * @param int|null $month The month to create an instance with.
     * @param int|null $day The day to create an instance with.
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name the new instance should use.
     * @return static
     */
    public static function createFromDate(
        ?int $year = null,
        ?int $month = null,
        ?int $day = null,
        DateTimeZone|string|null $timezone = null
    ): static {
        return static::create($year, $month, $day, null, null, null, null, $timezone);
    }

    /**
     * Create an instance from just a time. The date portion is set to today.
     *
     * @param int|null $hour The hour to create an instance with.
     * @param int|null $minute The minute to create an instance with.
     * @param int|null $second The second to create an instance with.
     * @param int|null $microsecond The microsecond to create an instance with.
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name the new instance should use.
     * @return static
     */
    public static function createFromTime(
        ?int $hour = null,
        ?int $minute = null,
        ?int $second = null,
        ?int $microsecond = null,
        DateTimeZone|string|null $timezone = null
    ): static {
        return static::create(null, null, null, $hour, $minute, $second, $microsecond, $timezone);
    }

    /**
     * Create an instance from a specific format
     *
     * @param string $format The date() compatible format string.
     * @param string $time The formatted date string to interpret.
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name the new instance should use.
     * @return static
     * @throws \InvalidArgumentException
     */
    public static function createFromFormat(
        string $format,
        string $time,
        DateTimeZone|string|null $timezone = null
    ): static {
        if ($timezone !== null) {
            $dateTime = parent::createFromFormat($format, $time, $timezone ? static::safeCreateDateTimeZone($timezone) : null);
        } else {
            $dateTime = parent::createFromFormat($format, $time);
        }

        static::$lastErrors = DateTimeImmutable::getLastErrors();
        if (!$dateTime) {
            $message = static::$lastErrors ? implode(PHP_EOL, static::$lastErrors['errors']) : 'Unknown error';

            throw new InvalidArgumentException($message);
        }

        return $dateTime;
    }

    /**
     * Returns parse warnings and errors from the last ``createFromFormat()``
     * call.
     *
     * Returns the same data as DateTimeImmutable::getLastErrors().
     *
     * @return array|false
     */
    public static function getLastErrors(): array|false
    {
        return static::$lastErrors;
    }

    /**
     * Creates an instance from an array of date and time values.
     *
     * The 'year', 'month' and 'day' values must all be set for a date. The time
     * values all default to 0.
     *
     * The 'timezone' value can be any format supported by `\DateTimeZone`.
     *
     * Allowed values:
     *  - year
     *  - month
     *  - day
     *  - hour
     *  - minute
     *  - second
     *  - microsecond
     *  - meridian ('am' or 'pm')
     *  - timezone
     *
     * @param array<int|string> $values Array of date and time values.
     * @return static
     */
    public static function createFromArray(array $values): static
    {
        $values += ['hour' => 0, 'minute' => 0, 'second' => 0, 'microsecond' => 0, 'timezone' => null];

        $formatted = '';
        if (
            isset($values['year'], $values['month'], $values['day']) &&
            (
                is_numeric($values['year']) &&
                is_numeric($values['month']) &&
                is_numeric($values['day'])
            )
        ) {
            $formatted .= sprintf('%04d-%02d-%02d ', $values['year'], $values['month'], $values['day']);
        }

        if (isset($values['meridian']) && (int)$values['hour'] === 12) {
            $values['hour'] = 0;
        }
        if (isset($values['meridian'])) {
            $values['hour'] = strtolower((string)$values['meridian']) === 'am' ? (int)$values['hour'] : (int)$values['hour'] + 12;
        }
        $formatted .= sprintf(
            '%02d:%02d:%02d.%06d',
            $values['hour'],
            $values['minute'],
            $values['second'],
            $values['microsecond']
        );

        assert(!is_int($values['timezone']), 'Timezone cannot be of type `int`');

        return static::parse($formatted, $values['timezone']);
    }

    /**
     * Create an instance from a timestamp
     *
     * @param int $timestamp The timestamp to create an instance from.
     * @param \DateTimeZone|string|null $timezone The DateTimeZone object or timezone name the new instance should use.
     * @return static
     */
    public static function createFromTimestamp(int $timestamp, DateTimeZone|string|null $timezone = null): static
    {
        return static::now($timezone)->setTimestamp($timestamp);
    }

    /**
     * Creates a DateTimeZone from a string or a DateTimeZone
     *
     * @param \DateTimeZone|string|null $object The value to convert.
     * @return \DateTimeZone
     * @throws \InvalidArgumentException
     */
    protected static function safeCreateDateTimeZone(DateTimeZone|string|null $object): DateTimeZone
    {
        if ($object === null) {
            return new DateTimeZone(date_default_timezone_get());
        }

        if ($object instanceof DateTimeZone) {
            return $object;
        }

        return new DateTimeZone($object);
    }

    /**
     * Create a new DateInterval instance from specified values.
     *
     * @param int|null $years The year to use.
     * @param int|null $months The month to use.
     * @param int|null $weeks The week to use.
     * @param int|null $days The day to use.
     * @param int|null $hours The hours to use.
     * @param int|null $minutes The minutes to use.
     * @param int|null $seconds The seconds to use.
     * @param int|null $microseconds The microseconds to use.
     * @return \DateInterval
     */
    public static function createInterval(
        ?int $years = null,
        ?int $months = null,
        ?int $weeks = null,
        ?int $days = null,
        ?int $hours = null,
        ?int $minutes = null,
        ?int $seconds = null,
        ?int $microseconds = null,
    ): DateInterval {
        $spec = 'P';

        $rollover = static::rolloverTime($microseconds, 1_000_000);
        $seconds = $seconds === null ? $rollover : $seconds + (int)$rollover;

        $rollover = static::rolloverTime($seconds, 60);
        $minutes = $minutes === null ? $rollover : $minutes + (int)$rollover;

        $rollover = static::rolloverTime($minutes, 60);
        $hours = $hours === null ? $rollover : $hours + (int)$rollover;

        $rollover = static::rolloverTime($hours, 24);
        $days = $days === null ? $rollover : $days + (int)$rollover;

        if ($years) {
            $spec .= $years . 'Y';
        }
        if ($months) {
            $spec .= $months . 'M';
        }
        if ($weeks) {
            $spec .= $weeks . 'W';
        }
        if ($days) {
            $spec .= $days . 'D';
        }

        if ($hours || $minutes || $seconds) {
            $spec .= 'T';

            if ($hours) {
                $spec .= $hours . 'H';
            }
            if ($minutes) {
                $spec .= $minutes . 'M';
            }
            if ($seconds) {
                $spec .= $seconds . 'S';
            }
        }

        if ($microseconds && $spec === 'P') {
            $spec .= 'T0S';
        }

        $instance = new DateInterval($spec);

        if ($microseconds) {
            $instance->f = $microseconds / 1000000;
        }

        return $instance;
    }

    /**
     * Updates value to remaininger and returns rollover value for time
     * unit or null if no rollover.
     *
     * @param int|null $value Time unit value
     * @param int $max Time unit max value
     * @return int|null
     */
    protected static function rolloverTime(?int &$value, int $max): ?int
    {
        if ($value === null || $value < $max) {
            return null;
        }

        $rollover = intdiv($value, $max);
        $value = $value % $max;

        return $rollover;
    }

    /**
     * Sets the date and time.
     *
     * @param int $year The year to set.
     * @param int $month The month to set.
     * @param int $day The day to set.
     * @param int $hour The hour to set.
     * @param int $minute The minute to set.
     * @param int $second The second to set.
     * @return static
     */
    public function setDateTime(
        int $year,
        int $month,
        int $day,
        int $hour,
        int $minute,
        int $second = 0
    ): static {
        return $this->setDate($year, $month, $day)->setTime($hour, $minute, $second);
    }

    /**
     * Sets the date.
     *
     * @param int $year The year to set.
     * @param int $month The month to set.
     * @param int $day The day to set.
     * @return static
     */
    public function setDate(int $year, int $month, int $day): static
    {
        return parent::setDate($year, $month, $day);
    }

    /**
     * Sets the date according to the ISO 8601 standard
     *
     * @param int $year Year of the date.
     * @param int $week Week of the date.
     * @param int $dayOfWeek Offset from the first day of the week.
     * @return static
     */
    public function setISODate(int $year, int $week, int $dayOfWeek = 1): static
    {
        return parent::setISODate($year, $week, $dayOfWeek);
    }

    /**
     * Sets the time.
     *
     * @param int $hours Hours of the time
     * @param int $minutes Minutes of the time
     * @param int $seconds Seconds of the time
     * @param int $microseconds Microseconds of the time
     * @return static
     */
    public function setTime(int $hours, int $minutes, int $seconds = 0, int $microseconds = 0): static
    {
        return parent::setTime($hours, $minutes, $seconds, $microseconds);
    }

    /**
     * Creates a new instance with date modified according to DateTimeImmutable::modifier().
     *
     * @param string $modifier Date modifier
     * @return static
     * @throws \InvalidArgumentException
     * @see https://www.php.net/manual/en/datetimeimmutable.modify.php
     */
    public function modify(string $modifier): static
    {
        $new = parent::modify($modifier);
        if ($new === false) {
            throw new InvalidArgumentException('Unable to modify date using: ' . $modifier);
        }

        return $new;
    }

    /**
     * Returns the difference between this instance and target.
     *
     * @param \DateTimeInterface $target Target instance
     * @param bool $absolute Whether the interval is forced to be positive
     * @return \DateInterval
     */
    public function diff(DateTimeInterface $target, bool $absolute = false): DateInterval
    {
        return parent::diff($target, $absolute);
    }

    /**
     * Returns formatted date string according to DateTimeImmutable::format().
     *
     * @param string $format String format
     * @return string
     */
    public function format(string $format): string
    {
        return parent::format($format);
    }

    /**
     * Returns the timezone offset.
     *
     * @return int
     */
    public function getOffset(): int
    {
        return parent::getOffset();
    }

    /**
     * Sets the date and time based on a Unix timestamp.
     *
     * @param int $timestamp Unix timestamp representing the date
     * @return static
     */
    public function setTimestamp(int $timestamp): static
    {
        return parent::setTimestamp($timestamp);
    }

    /**
     * Gets the Unix timestamp for this instance.
     *
     * @return int
     */
    public function getTimestamp(): int
    {
        return parent::getTimestamp();
    }

    /**
     * Set the instance's timezone from a string or object
     *
     * @param \DateTimeZone|string $value The DateTimeZone object or timezone name to use.
     * @return static
     */
    public function setTimezone(DateTimeZone|string $value): static
    {
        return parent::setTimezone(static::safeCreateDateTimeZone($value));
    }

    /**
     * Return time zone set for this instance.
     *
     * @return \DateTimeZone
     */
    public function getTimezone(): DateTimeZone
    {
        $tz = parent::getTimezone();
        if ($tz === false) {
            throw new RuntimeException('Time zone could not be retrieved.');
        }

        return $tz;
    }

    /**
     * Set the time by time string
     *
     * @param string $time Time as string.
     * @return static
     */
    public function setTimeFromTimeString(string $time): static
    {
        $time = explode(':', $time);
        $hour = $time[0];
        $minute = $time[1] ?? 0;
        $second = $time[2] ?? 0;

        return $this->setTime((int)$hour, (int)$minute, (int)$second);
    }

    /**
     * Set the instance's timestamp
     *
     * @param int $value The timestamp value to set.
     * @return static
     */
    public function timestamp(int $value): static
    {
        return $this->setTimestamp($value);
    }

    /**
     * Set the instance's year
     *
     * @param int $value The year value.
     * @return static
     */
    public function year(int $value): static
    {
        return $this->setDate($value, $this->month, $this->day);
    }

    /**
     * Set the instance's month
     *
     * @param int $value The month value.
     * @return static
     */
    public function month(int $value): static
    {
        return $this->setDate($this->year, $value, $this->day);
    }

    /**
     * Set the instance's day
     *
     * @param int $value The day value.
     * @return static
     */
    public function day(int $value): static
    {
        return $this->setDate($this->year, $this->month, $value);
    }

    /**
     * Set the instance's hour
     *
     * @param int $value The hour value.
     * @return static
     */
    public function hour(int $value): static
    {
        return $this->setTime($value, $this->minute, $this->second);
    }

    /**
     * Set the instance's minute
     *
     * @param int $value The minute value.
     * @return static
     */
    public function minute(int $value): static
    {
        return $this->setTime($this->hour, $value, $this->second);
    }

    /**
     * Set the instance's second
     *
     * @param int $value The seconds value.
     * @return static
     */
    public function second(int $value): static
    {
        return $this->setTime($this->hour, $this->minute, $value);
    }

    /**
     * Set the instance's microsecond
     *
     * @param int $value The microsecond value.
     * @return static
     */
    public function microsecond(int $value): static
    {
        return $this->setTime($this->hour, $this->minute, $this->second, $value);
    }

    /**
     * Add years to the instance. Positive $value travel forward while
     * negative $value travel into the past.
     *
     * If the new ChronosDate does not exist, the last day of the month is used
     * instead instead of overflowing into the next month.
     *
     * ### Example:
     *
     * ```
     *  (new Chronos('2015-01-03'))->addYears(1); // Results in 2016-01-03
     *
     *  (new Chronos('2012-02-29'))->addYears(1); // Results in 2013-02-28
     * ```
     *
     * @param int $value The number of years to add.
     * @return static
     */
    public function addYears(int $value): static
    {
        $month = $this->month;
        $date = $this->modify($value . ' years');

        if ($date->month !== $month) {
            return $date->modify('last day of previous month');
        }

        return $date;
    }

    /**
     * Remove years from the instance.
     *
     * Has the same behavior as `addYears()`.
     *
     * @param int $value The number of years to remove.
     * @return static
     */
    public function subYears(int $value): static
    {
        return $this->addYears(-$value);
    }

    /**
     * Add years with overflowing to the instance. Positive $value
     * travels forward while negative $value travels into the past.
     *
     * If the new ChronosDate does not exist, the days overflow into the next month.
     *
     * ### Example:
     *
     * ```
     *  (new Chronos('2012-02-29'))->addYearsWithOverflow(1); // Results in 2013-03-01
     * ```
     *
     * @param int $value The number of years to add.
     * @return static
     */
    public function addYearsWithOverflow(int $value): static
    {
        return $this->modify($value . ' year');
    }

    /**
     * Remove years with overflow from the instance
     *
     * Has the same behavior as `addYeasrWithOverflow()`.
     *
     * @param int $value The number of years to remove.
     * @return static
     */
    public function subYearsWithOverflow(int $value): static
    {
        return $this->addYearsWithOverflow(-1 * $value);
    }

    /**
     * Add months to the instance. Positive $value travels forward while
     * negative $value travels into the past.
     *
     * When adding or subtracting months, if the resulting time is a date
     * that does not exist, the result of this operation will always be the
     * last day of the intended month.
     *
     * ### Example:
     *
     * ```
     *  (new Chronos('2015-01-03'))->addMonths(1); // Results in 2015-02-03
     *
     *  (new Chronos('2015-01-31'))->addMonths(1); // Results in 2015-02-28
     * ```
     *
     * @param int $value The number of months to add.
     * @return static
     */
    public function addMonths(int $value): static
    {
        $day = $this->day;
        $date = $this->modify($value . ' months');

        if ($date->day !== $day) {
            return $date->modify('last day of previous month');
        }

        return $date;
    }

    /**
     * Remove months from the instance
     *
     * Has the same behavior as `addMonths()`.
     *
     * @param int $value The number of months to remove.
     * @return static
     */
    public function subMonths(int $value): static
    {
        return $this->addMonths(-$value);
    }

    /**
     * Add months with overflowing to the instance. Positive $value
     * travels forward while negative $value travels into the past.
     *
     * If the new ChronosDate does not exist, the days overflow into the next month.
     *
     * ### Example:
     *
     * ```
     *  (new Chronos('2012-01-30'))->addMonthsWithOverflow(1); // Results in 2013-03-01
     * ```
     *
     * @param int $value The number of months to add.
     * @return static
     */
    public function addMonthsWithOverflow(int $value): static
    {
        return $this->modify($value . ' months');
    }

    /**
     * Add months with overflowing to the instance. Positive $value
     * travels forward while negative $value travels into the past.
     *
     * If the new ChronosDate does not exist, the days overflow into the next month.
     *
     * ### Example:
     *
     * ```
     *  (new Chronos('2012-01-30'))->addMonthsWithOverflow(1); // Results in 2013-03-01
     * ```
     *
     * @param int $value The number of months to remove.
     * @return static
     */
    public function subMonthsWithOverflow(int $value): static
    {
        return $this->addMonthsWithOverflow(-1 * $value);
    }

    /**
     * Add days to the instance. Positive $value travels forward while
     * negative $value travels into the past.
     *
     * @param int $value The number of days to add.
     * @return static
     */
    public function addDays(int $value): static
    {
        return $this->modify("$value days");
    }

    /**
     * Remove days from the instance
     *
     * @param int $value The number of days to remove.
     * @return static
     */
    public function subDays(int $value): static
    {
        return $this->addDays(-$value);
    }

    /**
     * Add weekdays to the instance. Positive $value travels forward while
     * negative $value travels into the past.
     *
     * @param int $value The number of weekdays to add.
     * @return static
     */
    public function addWeekdays(int $value): static
    {
        return $this->modify($value . ' weekdays, ' . $this->format('H:i:s'));
    }

    /**
     * Remove weekdays from the instance
     *
     * @param int $value The number of weekdays to remove.
     * @return static
     */
    public function subWeekdays(int $value): static
    {
        return $this->addWeekdays(-$value);
    }

    /**
     * Add weeks to the instance. Positive $value travels forward while
     * negative $value travels into the past.
     *
     * @param int $value The number of weeks to add.
     * @return static
     */
    public function addWeeks(int $value): static
    {
        return $this->modify("$value week");
    }

    /**
     * Remove weeks to the instance
     *
     * @param int $value The number of weeks to remove.
     * @return static
     */
    public function subWeeks(int $value): static
    {
        return $this->addWeeks(-$value);
    }

    /**
     * Add hours to the instance. Positive $value travels forward while
     * negative $value travels into the past.
     *
     * @param int $value The number of hours to add.
     * @return static
     */
    public function addHours(int $value): static
    {
        return $this->modify("$value hour");
    }

    /**
     * Remove hours from the instance
     *
     * @param int $value The number of hours to remove.
     * @return static
     */
    public function subHours(int $value): static
    {
        return $this->addHours(-$value);
    }

    /**
     * Add minutes to the instance. Positive $value travels forward while
     * negative $value travels into the past.
     *
     * @param int $value The number of minutes to add.
     * @return static
     */
    public function addMinutes(int $value): static
    {
        return $this->modify("$value minute");
    }

    /**
     * Remove minutes from the instance
     *
     * @param int $value The number of minutes to remove.
     * @return static
     */
    public function subMinutes(int $value): static
    {
        return $this->addMinutes(-$value);
    }

    /**
     * Add seconds to the instance. Positive $value travels forward while
     * negative $value travels into the past.
     *
     * @param int $value The number of seconds to add.
     * @return static
     */
    public function addSeconds(int $value): static
    {
        return $this->modify("$value second");
    }

    /**
     * Remove seconds from the instance
     *
     * @param int $value The number of seconds to remove.
     * @return static
     */
    public function subSeconds(int $value): static
    {
        return $this->addSeconds(-$value);
    }

    /**
     * Sets the time to 00:00:00
     *
     * @return static
     */
    public function startOfDay(): static
    {
        return $this->modify('midnight');
    }

    /**
     * Sets the time to 23:59:59 or 23:59:59.999999
     * if `$microseconds` is true.
     *
     * @param bool $microseconds Whether to set microseconds
     * @return static
     */
    public function endOfDay(bool $microseconds = false): static
    {
        if ($microseconds) {
            return $this->modify('23:59:59.999999');
        }

        return $this->modify('23:59:59');
    }

    /**
     * Sets the date to the first day of the month and the time to 00:00:00
     *
     * @return static
     */
    public function startOfMonth(): static
    {
        return $this->modify('first day of this month midnight');
    }

    /**
     * Sets the date to end of the month and time to 23:59:59
     *
     * @return static
     */
    public function endOfMonth(): static
    {
        return $this->modify('last day of this month, 23:59:59');
    }

    /**
     * Sets the date to the first day of the year and the time to 00:00:00
     *
     * @return static
     */
    public function startOfYear(): static
    {
        return $this->modify('first day of january midnight');
    }

    /**
     * Sets the date to end of the year and time to 23:59:59
     *
     * @return static
     */
    public function endOfYear(): static
    {
        return $this->modify('last day of december, 23:59:59');
    }

    /**
     * Sets the date to the first day of the decade and the time to 00:00:00
     *
     * @return static
     */
    public function startOfDecade(): static
    {
        $year = $this->year - $this->year % Chronos::YEARS_PER_DECADE;

        return $this->modify("first day of january $year, midnight");
    }

    /**
     * Sets the date to end of the decade and time to 23:59:59
     *
     * @return static
     */
    public function endOfDecade(): static
    {
        $year = $this->year - $this->year % Chronos::YEARS_PER_DECADE + Chronos::YEARS_PER_DECADE - 1;

        return $this->modify("last day of december $year, 23:59:59");
    }

    /**
     * Sets the date to the first day of the century and the time to 00:00:00
     *
     * @return static
     */
    public function startOfCentury(): static
    {
        $year = $this->startOfYear()
            ->year($this->year - 1 - ($this->year - 1) % Chronos::YEARS_PER_CENTURY + 1)
            ->year;

        return $this->modify("first day of january $year, midnight");
    }

    /**
     * Sets the date to end of the century and time to 23:59:59
     *
     * @return static
     */
    public function endOfCentury(): static
    {
        $y = $this->year - 1
            - ($this->year - 1)
            % Chronos::YEARS_PER_CENTURY
            + Chronos::YEARS_PER_CENTURY;

        $year = $this->endOfYear()
            ->year($y)
            ->year;

        return $this->modify("last day of december $year, 23:59:59");
    }

    /**
     * Sets the date to the first day of week (defined in $weekStartsAt) and the time to 00:00:00
     *
     * @return static
     */
    public function startOfWeek(): static
    {
        $dateTime = $this;
        if ($dateTime->dayOfWeek !== static::$weekStartsAt) {
            $dateTime = $dateTime->previous(static::$weekStartsAt);
        }

        return $dateTime->startOfDay();
    }

    /**
     * Sets the date to end of week (defined in $weekEndsAt) and time to 23:59:59
     *
     * @return static
     */
    public function endOfWeek(): static
    {
        $dateTime = $this;
        if ($dateTime->dayOfWeek !== static::$weekEndsAt) {
            $dateTime = $dateTime->next(static::$weekEndsAt);
        }

        return $dateTime->endOfDay();
    }

    /**
     * Modify to the next occurrence of a given day of the week.
     * If no dayOfWeek is provided, modify to the next occurrence
     * of the current day of the week.  Use the supplied consts
     * to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int|null $dayOfWeek The day of the week to move to.
     * @return static
     */
    public function next(?int $dayOfWeek = null): static
    {
        if ($dayOfWeek === null) {
            $dayOfWeek = $this->dayOfWeek;
        }

        $day = static::$days[$dayOfWeek];

        return $this->modify("next $day, midnight");
    }

    /**
     * Modify to the previous occurrence of a given day of the week.
     * If no dayOfWeek is provided, modify to the previous occurrence
     * of the current day of the week.  Use the supplied consts
     * to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int|null $dayOfWeek The day of the week to move to.
     * @return static
     */
    public function previous(?int $dayOfWeek = null): static
    {
        if ($dayOfWeek === null) {
            $dayOfWeek = $this->dayOfWeek;
        }

        $day = static::$days[$dayOfWeek];

        return $this->modify("last $day, midnight");
    }

    /**
     * Modify to the first occurrence of a given day of the week
     * in the current month. If no dayOfWeek is provided, modify to the
     * first day of the current month.  Use the supplied consts
     * to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int|null $dayOfWeek The day of the week to move to.
     * @return static
     */
    public function firstOfMonth(?int $dayOfWeek = null): static
    {
        $day = $dayOfWeek === null ? 'day' : static::$days[$dayOfWeek];

        return $this->modify("first $day of this month, midnight");
    }

    /**
     * Modify to the last occurrence of a given day of the week
     * in the current month. If no dayOfWeek is provided, modify to the
     * last day of the current month.  Use the supplied consts
     * to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int|null $dayOfWeek The day of the week to move to.
     * @return static
     */
    public function lastOfMonth(?int $dayOfWeek = null): static
    {
        $day = $dayOfWeek === null ? 'day' : static::$days[$dayOfWeek];

        return $this->modify("last $day of this month, midnight");
    }

    /**
     * Modify to the given occurrence of a given day of the week
     * in the current month. If the calculated occurrence is outside the scope
     * of the current month, then return false and no modifications are made.
     * Use the supplied consts to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int $nth The offset to use.
     * @param int $dayOfWeek The day of the week to move to.
     * @return static|false
     */
    public function nthOfMonth(int $nth, int $dayOfWeek): static|false
    {
        $dateTime = $this->firstOfMonth();
        $check = $dateTime->format('Y-m');
        $dateTime = $dateTime->modify("+$nth " . static::$days[$dayOfWeek]);

        return $dateTime->format('Y-m') === $check ? $dateTime : false;
    }

    /**
     * Modify to the first occurrence of a given day of the week
     * in the current quarter. If no dayOfWeek is provided, modify to the
     * first day of the current quarter.  Use the supplied consts
     * to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int|null $dayOfWeek The day of the week to move to.
     * @return static
     */
    public function firstOfQuarter(?int $dayOfWeek = null): static
    {
        return $this
            ->day(1)
            ->month($this->quarter * Chronos::MONTHS_PER_QUARTER - 2)
            ->firstOfMonth($dayOfWeek);
    }

    /**
     * Modify to the last occurrence of a given day of the week
     * in the current quarter. If no dayOfWeek is provided, modify to the
     * last day of the current quarter.  Use the supplied consts
     * to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int|null $dayOfWeek The day of the week to move to.
     * @return static
     */
    public function lastOfQuarter(?int $dayOfWeek = null): static
    {
        return $this
            ->day(1)
            ->month($this->quarter * Chronos::MONTHS_PER_QUARTER)
            ->lastOfMonth($dayOfWeek);
    }

    /**
     * Modify to the given occurrence of a given day of the week
     * in the current quarter. If the calculated occurrence is outside the scope
     * of the current quarter, then return false and no modifications are made.
     * Use the supplied consts to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int $nth The offset to use.
     * @param int $dayOfWeek The day of the week to move to.
     * @return static|false
     */
    public function nthOfQuarter(int $nth, int $dayOfWeek): static|false
    {
        $dateTime = $this->day(1)->month($this->quarter * Chronos::MONTHS_PER_QUARTER);
        $lastMonth = $dateTime->month;
        $year = $dateTime->year;
        $dateTime = $dateTime->firstOfQuarter()->modify("+$nth" . static::$days[$dayOfWeek]);

        return $lastMonth < $dateTime->month || $year !== $dateTime->year ? false : $dateTime;
    }

    /**
     * Modify to the first occurrence of a given day of the week
     * in the current year. If no dayOfWeek is provided, modify to the
     * first day of the current year.  Use the supplied consts
     * to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int|null $dayOfWeek The day of the week to move to.
     * @return static
     */
    public function firstOfYear(?int $dayOfWeek = null): static
    {
        $day = $dayOfWeek === null ? 'day' : static::$days[$dayOfWeek];

        return $this->modify("first $day of january, midnight");
    }

    /**
     * Modify to the last occurrence of a given day of the week
     * in the current year. If no dayOfWeek is provided, modify to the
     * last day of the current year.  Use the supplied consts
     * to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int|null $dayOfWeek The day of the week to move to.
     * @return static
     */
    public function lastOfYear(?int $dayOfWeek = null): static
    {
        $day = $dayOfWeek === null ? 'day' : static::$days[$dayOfWeek];

        return $this->modify("last $day of december, midnight");
    }

    /**
     * Modify to the given occurrence of a given day of the week
     * in the current year. If the calculated occurrence is outside the scope
     * of the current year, then return false and no modifications are made.
     * Use the supplied consts to indicate the desired dayOfWeek, ex. Chronos::MONDAY.
     *
     * @param int $nth The offset to use.
     * @param int $dayOfWeek The day of the week to move to.
     * @return static|false
     */
    public function nthOfYear(int $nth, int $dayOfWeek): static|false
    {
        $dateTime = $this->firstOfYear()->modify("+$nth " . static::$days[$dayOfWeek]);

        return $this->year === $dateTime->year ? $dateTime : false;
    }

    /**
     * Determines if the instance is equal to another
     *
     * @param \DateTimeInterface $other The instance to compare with.
     * @return bool
     */
    public function equals(DateTimeInterface $other): bool
    {
        return $this == $other;
    }

    /**
     * Determines if the instance is not equal to another
     *
     * @param \DateTimeInterface $other The instance to compare with.
     * @return bool
     */
    public function notEquals(DateTimeInterface $other): bool
    {
        return !$this->equals($other);
    }

    /**
     * Determines if the instance is greater (after) than another
     *
     * @param \DateTimeInterface $other The instance to compare with.
     * @return bool
     */
    public function greaterThan(DateTimeInterface $other): bool
    {
        return $this > $other;
    }

    /**
     * Determines if the instance is greater (after) than or equal to another
     *
     * @param \DateTimeInterface $other The instance to compare with.
     * @return bool
     */
    public function greaterThanOrEquals(DateTimeInterface $other): bool
    {
        return $this >= $other;
    }

    /**
     * Determines if the instance is less (before) than another
     *
     * @param \DateTimeInterface $other The instance to compare with.
     * @return bool
     */
    public function lessThan(DateTimeInterface $other): bool
    {
        return $this < $other;
    }

    /**
     * Determines if the instance is less (before) or equal to another
     *
     * @param \DateTimeInterface $other The instance to compare with.
     * @return bool
     */
    public function lessThanOrEquals(DateTimeInterface $other): bool
    {
        return $this <= $other;
    }

    /**
     * Determines if the instance is between two others
     *
     * @param \DateTimeInterface $start Start of target range
     * @param \DateTimeInterface $end End of target range
     * @param bool $equals Whether to include the beginning and end of range
     * @return bool
     */
    public function between(DateTimeInterface $start, DateTimeInterface $end, bool $equals = true): bool
    {
        if ($start > $end) {
            [$start, $end] = [$end, $start];
        }

        if ($equals) {
            return $this->greaterThanOrEquals($start) && $this->lessThanOrEquals($end);
        }

        return $this->greaterThan($start) && $this->lessThan($end);
    }

    /**
     * Get the closest date from the instance.
     *
     * @param \DateTimeInterface $first The instance to compare with.
     * @param \DateTimeInterface $second The instance to compare with.
     * @param \DateTimeInterface ...$others Others instances to compare with.
     * @return static
     */
    public function closest(DateTimeInterface $first, DateTimeInterface $second, DateTimeInterface ...$others): static
    {
        $winner = $first;
        $closestDiffInSeconds = $this->diffInSeconds($first);
        foreach ([$second, ...$others] as $other) {
            $otherDiffInSeconds = $this->diffInSeconds($other);
            if ($otherDiffInSeconds < $closestDiffInSeconds) {
                $winner = $other;
                $closestDiffInSeconds = $otherDiffInSeconds;
            }
        }

        if ($winner instanceof static) {
            return $winner;
        }

        return new static($winner);
    }

    /**
     * Get the farthest date from the instance.
     *
     * @param \DateTimeInterface $first The instance to compare with.
     * @param \DateTimeInterface $second The instance to compare with.
     * @param \DateTimeInterface ...$others Others instances to compare with.
     * @return static
     */
    public function farthest(DateTimeInterface $first, DateTimeInterface $second, DateTimeInterface ...$others): static
    {
        $winner = $first;
        $farthestDiffInSeconds = $this->diffInSeconds($first);
        foreach ([$second, ...$others] as $other) {
            $otherDiffInSeconds = $this->diffInSeconds($other);
            if ($otherDiffInSeconds > $farthestDiffInSeconds) {
                $winner = $other;
                $farthestDiffInSeconds = $otherDiffInSeconds;
            }
        }

        if ($winner instanceof static) {
            return $winner;
        }

        return new static($winner);
    }

    /**
     * Get the minimum instance between a given instance (default now) and the current instance.
     *
     * @param \DateTimeInterface|null $other The instance to compare with.
     * @return static
     */
    public function min(?DateTimeInterface $other = null): static
    {
        $other = $other ?? static::now($this->tz);
        $winner = $this->lessThan($other) ? $this : $other;
        if ($winner instanceof static) {
            return $winner;
        }

        return new static($winner);
    }

    /**
     * Get the maximum instance between a given instance (default now) and the current instance.
     *
     * @param \DateTimeInterface|null $other The instance to compare with.
     * @return static
     */
    public function max(?DateTimeInterface $other = null): static
    {
        $other = $other ?? static::now($this->tz);
        $winner = $this->greaterThan($other) ? $this : $other;
        if ($winner instanceof static) {
            return $winner;
        }

        return new static($winner);
    }

    /**
     * Modify the current instance to the average of a given instance (default now) and the current instance.
     *
     * @param \DateTimeInterface|null $other The instance to compare with.
     * @return static
     */
    public function average(?DateTimeInterface $other = null): static
    {
        $other ??= static::now($this->tz);

        return $this->addSeconds((int)($this->diffInSeconds($other, false) / 2));
    }

    /**
     * Determines if the instance is a weekday
     *
     * @return bool
     */
    public function isWeekday(): bool
    {
        return !$this->isWeekend();
    }

    /**
     * Determines if the instance is a weekend day
     *
     * @return bool
     */
    public function isWeekend(): bool
    {
        return in_array($this->dayOfWeek, Chronos::getWeekendDays(), true);
    }

    /**
     * Determines if the instance is yesterday
     *
     * @return bool
     */
    public function isYesterday(): bool
    {
        return $this->toDateString() === static::yesterday($this->tz)->toDateString();
    }

    /**
     * Determines if the instance is today
     *
     * @return bool
     */
    public function isToday(): bool
    {
        return $this->toDateString() === static::now($this->tz)->toDateString();
    }

    /**
     * Determines if the instance is tomorrow
     *
     * @return bool
     */
    public function isTomorrow(): bool
    {
        return $this->toDateString() === static::tomorrow($this->tz)->toDateString();
    }

    /**
     * Determines if the instance is within the next week
     *
     * @return bool
     */
    public function isNextWeek(): bool
    {
        return $this->format('W o') === static::now($this->tz)->addWeeks(1)->format('W o');
    }

    /**
     * Determines if the instance is within the last week
     *
     * @return bool
     */
    public function isLastWeek(): bool
    {
        return $this->format('W o') === static::now($this->tz)->subWeeks(1)->format('W o');
    }

    /**
     * Determines if the instance is within the next month
     *
     * @return bool
     */
    public function isNextMonth(): bool
    {
        return $this->format('m Y') === static::now($this->tz)->addMonths(1)->format('m Y');
    }

    /**
     * Determines if the instance is within the last month
     *
     * @return bool
     */
    public function isLastMonth(): bool
    {
        return $this->format('m Y') === static::now($this->tz)->subMonths(1)->format('m Y');
    }

    /**
     * Determines if the instance is within the next year
     *
     * @return bool
     */
    public function isNextYear(): bool
    {
        return $this->year === static::now($this->tz)->addYears(1)->year;
    }

    /**
     * Determines if the instance is within the last year
     *
     * @return bool
     */
    public function isLastYear(): bool
    {
        return $this->year === static::now($this->tz)->subYears(1)->year;
    }

    /**
     * Determines if the instance is within the first half of year
     *
     * @return bool
     */
    public function isFirstHalf(): bool
    {
        return $this->half === 1;
    }

    /**
     * Determines if the instance is within the second half of year
     *
     * @return bool
     */
    public function isSecondHalf(): bool
    {
        return $this->half === 2;
    }

    /**
     * Determines if the instance is in the future, ie. greater (after) than now
     *
     * @return bool
     */
    public function isFuture(): bool
    {
        return $this->greaterThan(static::now($this->tz));
    }

    /**
     * Determines if the instance is in the past, ie. less (before) than now
     *
     * @return bool
     */
    public function isPast(): bool
    {
        return $this->lessThan(static::now($this->tz));
    }

    /**
     * Determines if the instance is a leap year
     *
     * @return bool
     */
    public function isLeapYear(): bool
    {
        return $this->format('L') === '1';
    }

    /**
     * Checks if the passed in date is the same day as the instance current day.
     *
     * @param \DateTimeInterface $other The instance to check against.
     * @return bool
     */
    public function isSameDay(DateTimeInterface $other): bool
    {
        if (!$other instanceof static) {
            $other = new static($other);
        }

        return $this->toDateString() === $other->toDateString();
    }

    /**
     * Returns whether the passed in date is the same month and year.
     *
     * @param \DateTimeInterface $other The instance to check against.
     * @return bool
     */
    public function isSameMonth(DateTimeInterface $other): bool
    {
        return $this->format('Y-m') === $other->format('Y-m');
    }

    /**
     * Returns whether passed in date is the same year.
     *
     * @param \DateTimeInterface $other The instance to check against.
     * @return bool
     */
    public function isSameYear(DateTimeInterface $other): bool
    {
        return $this->format('Y') === $other->format('Y');
    }

    /**
     * Checks if this day is a Sunday.
     *
     * @return bool
     */
    public function isSunday(): bool
    {
        return $this->dayOfWeek === Chronos::SUNDAY;
    }

    /**
     * Checks if this day is a Monday.
     *
     * @return bool
     */
    public function isMonday(): bool
    {
        return $this->dayOfWeek === Chronos::MONDAY;
    }

    /**
     * Checks if this day is a Tuesday.
     *
     * @return bool
     */
    public function isTuesday(): bool
    {
        return $this->dayOfWeek === Chronos::TUESDAY;
    }

    /**
     * Checks if this day is a Wednesday.
     *
     * @return bool
     */
    public function isWednesday(): bool
    {
        return $this->dayOfWeek === Chronos::WEDNESDAY;
    }

    /**
     * Checks if this day is a Thursday.
     *
     * @return bool
     */
    public function isThursday(): bool
    {
        return $this->dayOfWeek === Chronos::THURSDAY;
    }

    /**
     * Checks if this day is a Friday.
     *
     * @return bool
     */
    public function isFriday(): bool
    {
        return $this->dayOfWeek === Chronos::FRIDAY;
    }

    /**
     * Checks if this day is a Saturday.
     *
     * @return bool
     */
    public function isSaturday(): bool
    {
        return $this->dayOfWeek === Chronos::SATURDAY;
    }

    /**
     * Returns true if this object represents a date within the current week
     *
     * @return bool
     */
    public function isThisWeek(): bool
    {
        return static::now($this->getTimezone())->format('W o') === $this->format('W o');
    }

    /**
     * Returns true if this object represents a date within the current month
     *
     * @return bool
     */
    public function isThisMonth(): bool
    {
        return static::now($this->getTimezone())->format('m Y') === $this->format('m Y');
    }

    /**
     * Returns true if this object represents a date within the current year
     *
     * @return bool
     */
    public function isThisYear(): bool
    {
        return static::now($this->getTimezone())->format('Y') === $this->format('Y');
    }

    /**
     * Check if its the birthday. Compares the date/month values of the two dates.
     *
     * @param \DateTimeInterface|null $other The instance to compare with or null to use current day.
     * @return bool
     */
    public function isBirthday(?DateTimeInterface $other = null): bool
    {
        $other ??= static::now($this->tz);

        return $this->format('md') === $other->format('md');
    }

    /**
     * Returns true this instance happened within the specified interval
     *
     * @param string|int $timeInterval the numeric value with space then time type.
     *    Example of valid types: 6 hours, 2 days, 1 minute.
     * @return bool
     */
    public function wasWithinLast(string|int $timeInterval): bool
    {
        $now = new static();
        $interval = $now->modify('-' . $timeInterval);
        $thisTime = $this->format('U');

        return $thisTime >= $interval->format('U') && $thisTime <= $now->format('U');
    }

    /**
     * Returns true this instance will happen within the specified interval
     *
     * @param string|int $timeInterval the numeric value with space then time type.
     *    Example of valid types: 6 hours, 2 days, 1 minute.
     * @return bool
     */
    public function isWithinNext(string|int $timeInterval): bool
    {
        $now = new static();
        $interval = $now->modify('+' . $timeInterval);
        $thisTime = $this->format('U');

        return $thisTime <= $interval->format('U') && $thisTime >= $now->format('U');
    }

    /**
     * Get the difference by the given interval using a filter callable
     *
     * @param \DateInterval $interval An interval to traverse by
     * @param callable $callback The callback to use for filtering.
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffFiltered(
        DateInterval $interval,
        callable $callback,
        ?DateTimeInterface $other = null,
        bool $absolute = true,
        int $options = 0
    ): int {
        $start = $this;
        $end = $other ?? static::now($this->tz);
        $inverse = false;

        if ($end < $start) {
            $start = $end;
            $end = $this;
            $inverse = true;
        }

        $period = new DatePeriod($start, $interval, $end, $options);
        $vals = array_filter(iterator_to_array($period), function (DateTimeInterface $date) use ($callback) {
            return $callback(static::instance($date));
        });

        $diff = count($vals);

        return $inverse && !$absolute ? -$diff : $diff;
    }

    /**
     * Get the difference in years
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInYears(?DateTimeInterface $other = null, bool $absolute = true): int
    {
        $diff = $this->diff($other ?? static::now($this->tz), $absolute);

        return $diff->invert ? -$diff->y : $diff->y;
    }

    /**
     * Get the difference in months
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInMonths(?DateTimeInterface $other = null, bool $absolute = true): int
    {
        $diff = $this->diff($other ?? static::now($this->tz), $absolute);
        $months = $diff->y * Chronos::MONTHS_PER_YEAR + $diff->m;

        return $diff->invert ? -$months : $months;
    }

    /**
     * Get the difference in months ignoring the timezone. This means the months are calculated
     * in the specified timezone without converting to UTC first. This prevents the day from changing
     * which can change the month.
     *
     * For example, if comparing `2019-06-01 Asia/Tokyo` and `2019-10-01 Asia/Tokyo`,
     * the result would be 4 months instead of 3 when using normal `DateTime::diff()`.
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInMonthsIgnoreTimezone(?DateTimeInterface $other = null, bool $absolute = true): int
    {
        $utcTz = new DateTimeZone('UTC');
        $source = new static($this->format('Y-m-d H:i:s.u'), $utcTz);

        $other ??= static::now($this->tz);
        $other = new static($other->format('Y-m-d H:i:s.u'), $utcTz);

        return $source->diffInMonths($other, $absolute);
    }

    /**
     * Get the difference in weeks
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInWeeks(?DateTimeInterface $other = null, bool $absolute = true): int
    {
        return (int)($this->diffInDays($other, $absolute) / Chronos::DAYS_PER_WEEK);
    }

    /**
     * Get the difference in days
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInDays(?DateTimeInterface $other = null, bool $absolute = true): int
    {
        $diff = $this->diff($other ?? static::now($this->tz), $absolute);

        return $diff->invert ? -(int)$diff->days : (int)$diff->days;
    }

    /**
     * Get the difference in days using a filter callable
     *
     * @param callable $callback The callback to use for filtering.
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffInDaysFiltered(
        callable $callback,
        ?DateTimeInterface $other = null,
        bool $absolute = true,
        int $options = 0
    ): int {
        return $this->diffFiltered(new DateInterval('P1D'), $callback, $other, $absolute, $options);
    }

    /**
     * Get the difference in hours using a filter callable
     *
     * @param callable $callback The callback to use for filtering.
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffInHoursFiltered(
        callable $callback,
        ?DateTimeInterface $other = null,
        bool $absolute = true,
        int $options = 0
    ): int {
        return $this->diffFiltered(new DateInterval('PT1H'), $callback, $other, $absolute, $options);
    }

    /**
     * Get the difference in weekdays
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffInWeekdays(?DateTimeInterface $other = null, bool $absolute = true, int $options = 0): int
    {
        return $this->diffInDaysFiltered(function (Chronos $date) {
            return $date->isWeekday();
        }, $other, $absolute, $options);
    }

    /**
     * Get the difference in weekend days using a filter
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffInWeekendDays(?DateTimeInterface $other = null, bool $absolute = true, int $options = 0): int
    {
        return $this->diffInDaysFiltered(function (Chronos $date) {
            return $date->isWeekend();
        }, $other, $absolute, $options);
    }

    /**
     * Get the difference in hours
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInHours(?DateTimeInterface $other = null, bool $absolute = true): int
    {
        return (int)(
            $this->diffInSeconds($other, $absolute)
            / Chronos::SECONDS_PER_MINUTE
            / Chronos::MINUTES_PER_HOUR
        );
    }

    /**
     * Get the difference in minutes
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInMinutes(?DateTimeInterface $other = null, bool $absolute = true): int
    {
        return (int)($this->diffInSeconds($other, $absolute) / Chronos::SECONDS_PER_MINUTE);
    }

    /**
     * Get the difference in seconds
     *
     * @param \DateTimeInterface|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInSeconds(?DateTimeInterface $other = null, bool $absolute = true): int
    {
        $other ??= static::now($this->tz);
        $value = $other->getTimestamp() - $this->getTimestamp();

        return $absolute ? abs($value) : $value;
    }

    /**
     * The number of seconds since midnight.
     *
     * @return int
     */
    public function secondsSinceMidnight(): int
    {
        return $this->diffInSeconds($this->startOfDay());
    }

    /**
     * The number of seconds until 23:59:59.
     *
     * @return int
     */
    public function secondsUntilEndOfDay(): int
    {
        return $this->diffInSeconds($this->endOfDay());
    }

    /**
     * Convenience method for getting the remaining time from a given time.
     *
     * @param \DateTimeInterface $other The date to get the remaining time from.
     * @return \DateInterval|bool The DateInterval object representing the difference between the two dates or FALSE on failure.
     */
    public static function fromNow(DateTimeInterface $other): DateInterval|bool
    {
        $timeNow = new static();

        return $timeNow->diff($other);
    }

    /**
     * Get the difference in a human readable format.
     *
     * When comparing a value in the past to default now:
     * 1 hour ago
     * 5 months ago
     *
     * When comparing a value in the future to default now:
     * 1 hour from now
     * 5 months from now
     *
     * When comparing a value in the past to another value:
     * 1 hour before
     * 5 months before
     *
     * When comparing a value in the future to another value:
     * 1 hour after
     * 5 months after
     *
     * @param \DateTimeInterface|null $other The datetime to compare with.
     * @param bool $absolute removes time difference modifiers ago, after, etc
     * @return string
     */
    public function diffForHumans(?DateTimeInterface $other = null, bool $absolute = false): string
    {
        return static::diffFormatter()->diffForHumans($this, $other, $absolute);
    }

    /**
     * Returns a DateTimeImmutable instance
     *
     * This method returns a PHP DateTimeImmutable without Chronos extensions.
     *
     * @return \DateTimeImmutable
     */
    public function toNative(): DateTimeImmutable
    {
        return new DateTimeImmutable($this->format('Y-m-d H:i:s.u'), $this->getTimezone());
    }

    /**
     * Get a part of the object
     *
     * @param string $name The property name to read.
     * @return \DateTimeZone|string|float|int|bool The property value.
     * @throws \InvalidArgumentException
     */
    public function __get(string $name): string|float|int|bool|DateTimeZone
    {
        static $formats = [
            'year' => 'Y',
            'yearIso' => 'o',
            'month' => 'n',
            'day' => 'j',
            'hour' => 'G',
            'minute' => 'i',
            'second' => 's',
            'micro' => 'u',
            'microsecond' => 'u',
            'dayOfWeek' => 'N',
            'dayOfYear' => 'z',
            'weekOfYear' => 'W',
            'daysInMonth' => 't',
            'timestamp' => 'U',
        ];

        switch (true) {
            case isset($formats[$name]):
                return (int)$this->format($formats[$name]);

            case $name === 'dayOfWeekName':
                return $this->format('l');

            case $name === 'weekOfMonth':
                return (int)ceil($this->day / Chronos::DAYS_PER_WEEK);

            case $name === 'age':
                return $this->diffInYears();

            case $name === 'quarter':
                return (int)ceil($this->month / 3);

            case $name === 'half':
                return $this->month <= 6 ? 1 : 2;

            case $name === 'offset':
                return $this->getOffset();

            case $name === 'offsetHours':
                return $this->getOffset() / Chronos::SECONDS_PER_MINUTE / Chronos::MINUTES_PER_HOUR;

            case $name === 'dst':
                return $this->format('I') === '1';

            case $name === 'local':
                return $this->offset === $this->setTimezone(date_default_timezone_get())->offset;

            case $name === 'utc':
                return $this->offset === 0;

            case $name === 'timezone' || $name === 'tz':
                return $this->getTimezone();

            case $name === 'timezoneName' || $name === 'tzName':
                return $this->getTimezone()->getName();

            default:
                throw new InvalidArgumentException(sprintf("Unknown getter '%s'", $name));
        }
    }

    /**
     * Check if an attribute exists on the object
     *
     * @param string $name The property name to check.
     * @return bool Whether or not the property exists.
     */
    public function __isset(string $name): bool
    {
        try {
            $this->__get($name);
        } catch (InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

    /**
     * Return properties for debugging.
     *
     * @return array
     */
    public function __debugInfo(): array
    {
        /** @var \DateTimeZone $timezone */
        $timezone = $this->getTimezone();

        $properties = [
            'hasFixedNow' => static::hasTestNow(),
            'time' => $this->format('Y-m-d H:i:s.u'),
            'timezone' => $timezone->getName(),
        ];

        return $properties;
    }
}
