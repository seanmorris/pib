<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
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
use Stringable;

/**
 * An immutable date object.
 *
 * This class is useful when you want to represent a calendar date and ignore times.
 * This means that timezone changes take no effect as a calendar date exists in all timezones
 * in each respective date.
 *
 * @property-read int $year
 * @property-read int $yearIso
 * @property-read int<1, 12> $month
 * @property-read int<1, 31> $day
 * @property-read int<1, 7> $dayOfWeek 1 (for Monday) through 7 (for Sunday)
 * @property-read int<0, 365> $dayOfYear 0 through 365
 * @property-read int<1, 5> $weekOfMonth 1 through 5
 * @property-read int<1, 53> $weekOfYear ISO-8601 week number of year, weeks starting on Monday
 * @property-read int<1, 31> $daysInMonth number of days in the given month
 * @property-read int $age does a diffInYears() with default parameters
 * @property-read int<1, 4> $quarter the quarter of this instance, 1 - 4
 * @property-read int<1, 2> $half the half of the year, with 1 for months Jan...Jun and 2 for Jul...Dec.
 * @psalm-immutable
 * @psalm-consistent-constructor
 */
class ChronosDate implements Stringable
{
    use FormattingTrait;

    /**
     * Default format to use for __toString method when type juggling occurs.
     *
     * @var string
     */
    public const DEFAULT_TO_STRING_FORMAT = 'Y-m-d';

    /**
     * Format to use for __toString method when type juggling occurs.
     *
     * @var string
     */
    protected static string $toStringFormat = self::DEFAULT_TO_STRING_FORMAT;

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
     * Instance of the diff formatting object.
     *
     * @var \Cake\Chronos\DifferenceFormatterInterface|null
     */
    protected static ?DifferenceFormatterInterface $diffFormatter = null;

    /**
     * Errors from last time createFromFormat() was called.
     *
     * @var array|false
     */
    protected static array|false $lastErrors = false;

    /**
     * @var \DateTimeImmutable
     */
    protected DateTimeImmutable $native;

    /**
     * Create a new Immutable Date instance.
     *
     * Dates do not have time or timezone components exposed. Internally
     * ChronosDate wraps a PHP DateTimeImmutable but limits modifications
     * to only those that operate on day values.
     *
     * By default dates will be calculated from the server's default timezone.
     * You can use the `timezone` parameter to use a different timezone. Timezones
     * are used when parsing relative date expressions like `today` and `yesterday`
     * but do not participate in parsing values like `2022-01-01`.
     *
     * @param \Cake\Chronos\ChronosDate|\DateTimeInterface|string $time Fixed or relative time
     * @param \DateTimeZone|string|null $timezone The time zone used for 'now'
     */
    public function __construct(
        ChronosDate|DateTimeInterface|string $time = 'now',
        DateTimeZone|string|null $timezone = null
    ) {
        $this->native = $this->createNative($time, $timezone);
    }

    /**
     * Initializes the PHP DateTimeImmutable object.
     *
     * @param \Cake\Chronos\ChronosDate|\DateTimeInterface|string $time Fixed or relative time
     * @param \DateTimeZone|string|null $timezone The time zone used for 'now'
     * @return \DateTimeImmutable
     */
    protected function createNative(
        ChronosDate|DateTimeInterface|string $time,
        DateTimeZone|string|null $timezone
    ): DateTimeImmutable {
        if (!is_string($time)) {
            return new DateTimeImmutable($time->format('Y-m-d 00:00:00'));
        }

        $timezone ??= date_default_timezone_get();
        $timezone = $timezone instanceof DateTimeZone ? $timezone : new DateTimeZone($timezone);

        $testNow = Chronos::getTestNow();
        if ($testNow === null) {
            $time = new DateTimeImmutable($time, $timezone);

            return new DateTimeImmutable($time->format('Y-m-d 00:00:00'));
        }

        $testNow = $testNow->setTimezone($timezone);
        if ($time !== 'now') {
            $testNow = $testNow->modify($time);
        }

        return new DateTimeImmutable($testNow->format('Y-m-d 00:00:00'));
    }

    /**
     * Get today's date.
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return static
     */
    public static function now(DateTimeZone|string|null $timezone = null): static
    {
        return new static('now', $timezone);
    }

    /**
     * Get today's date.
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for today.
     * @return static
     */
    public static function today(DateTimeZone|string|null $timezone = null): static
    {
        return static::now($timezone);
    }

    /**
     * Get tomorrow's date.
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for tomorrow.
     * @return static
     */
    public static function tomorrow(DateTimeZone|string|null $timezone = null): static
    {
        return new static('tomorrow', $timezone);
    }

    /**
     * Get yesterday's date.
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for yesterday.
     * @return static
     */
    public static function yesterday(DateTimeZone|string|null $timezone = null): static
    {
        return new static('yesterday', $timezone);
    }

    /**
     * Create an instance from a string.  This is an alias for the
     * constructor that allows better fluent syntax as it allows you to do
     * Chronos::parse('Monday next week')->fn() rather than
     * (new Chronos('Monday next week'))->fn()
     *
     * @param \Cake\Chronos\ChronosDate|\DateTimeInterface|string $time The strtotime compatible string to parse
     * @return static
     */
    public static function parse(ChronosDate|DateTimeInterface|string $time): static
    {
        return new static($time);
    }

    /**
     * Create an instance from a specific date.
     *
     * @param int $year The year to create an instance with.
     * @param int $month The month to create an instance with.
     * @param int $day The day to create an instance with.
     * @return static
     */
    public static function create(int $year, int $month, int $day): static
    {
        $instance = static::createFromFormat(
            'Y-m-d',
            sprintf('%s-%s-%s', 0, $month, $day),
        );

        return $instance->addYears($year);
    }

    /**
     * Create an instance from a specific format
     *
     * @param string $format The date() compatible format string.
     * @param string $time The formatted date string to interpret.
     * @return static
     * @throws \InvalidArgumentException
     */
    public static function createFromFormat(
        string $format,
        string $time,
    ): static {
        $dateTime = DateTimeImmutable::createFromFormat($format, $time);

        static::$lastErrors = DateTimeImmutable::getLastErrors();
        if (!$dateTime) {
            $message = static::$lastErrors ? implode(PHP_EOL, static::$lastErrors['errors']) : 'Unknown error';

            throw new InvalidArgumentException($message);
        }

        return new static($dateTime);
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
     * Creates an instance from an array of date values.
     *
     * Allowed values:
     *  - year
     *  - month
     *  - day
     *
     * @param array<int|string> $values Array of date and time values.
     * @return static
     */
    public static function createFromArray(array $values): static
    {
        $formatted = sprintf('%04d-%02d-%02d ', $values['year'], $values['month'], $values['day']);

        return static::parse($formatted);
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
     * Add an Interval to a Date
     *
     * Any changes to the time will be ignored and reset to 00:00:00
     *
     * @param \DateInterval $interval The interval to modify this date by.
     * @return static A modified Date instance
     */
    public function add(DateInterval $interval): static
    {
        if ($interval->f > 0 || $interval->s > 0 || $interval->i > 0 || $interval->h > 0) {
            throw new InvalidArgumentException('Cannot add intervals with time components');
        }
        $new = clone $this;
        $new->native = $new->native->add($interval)->setTime(0, 0, 0);

        return $new;
    }

    /**
     * Subtract an Interval from a Date.
     *
     * Any changes to the time will be ignored and reset to 00:00:00
     *
     * @param \DateInterval $interval The interval to modify this date by.
     * @return static A modified Date instance
     */
    public function sub(DateInterval $interval): static
    {
        if ($interval->f > 0 || $interval->s > 0 || $interval->i > 0 || $interval->h > 0) {
            throw new InvalidArgumentException('Cannot subtract intervals with time components');
        }
        $new = clone $this;
        $new->native = $new->native->sub($interval)->setTime(0, 0, 0);

        return $new;
    }

    /**
     * Creates a new instance with date modified according to DateTimeImmutable::modifier().
     *
     * Attempting to change a time component will raise an exception
     *
     * @param string $modifier Date modifier
     * @return static
     */
    public function modify(string $modifier): static
    {
        if (preg_match('/hour|minute|second/', $modifier)) {
            throw new InvalidArgumentException('Cannot modify date objects by time values');
        }

        $new = clone $this;
        $new->native = $new->native->modify($modifier);
        if ($new->native === false) {
            throw new InvalidArgumentException('Unable to modify date using: ' . $modifier);
        }

        if ($new->format('H:i:s') !== '00:00:00') {
            $new->native = $new->native->setTime(0, 0, 0);
        }

        return $new;
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
        $new = clone $this;
        $new->native = $new->native->setDate($year, $month, $day);

        return $new;
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
        $new = clone $this;
        $new->native = $new->native->setISODate($year, $week, $dayOfWeek);

        return $new;
    }

    /**
     * Returns the difference between this instance and target.
     *
     * @param \Cake\Chronos\ChronosDate $target Target instance
     * @param bool $absolute Whether the interval is forced to be positive
     * @return \DateInterval
     */
    public function diff(ChronosDate $target, bool $absolute = false): DateInterval
    {
        return $this->native->diff($target->native, $absolute);
    }

    /**
     * Returns formatted date string according to DateTimeImmutable::format().
     *
     * @param string $format String format
     * @return string
     */
    public function format(string $format): string
    {
        return $this->native->format($format);
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
     * Resets the date to the first day of the month
     *
     * @return static
     */
    public function startOfMonth(): static
    {
        return $this->modify('first day of this month');
    }

    /**
     * Resets the date to end of the month
     *
     * @return static
     */
    public function endOfMonth(): static
    {
        return $this->modify('last day of this month');
    }

    /**
     * Resets the date to the first day of the year
     *
     * @return static
     */
    public function startOfYear(): static
    {
        return $this->modify('first day of january');
    }

    /**
     * Resets the date to end of the year
     *
     * @return static
     */
    public function endOfYear(): static
    {
        return $this->modify('last day of december');
    }

    /**
     * Resets the date to the first day of the decade
     *
     * @return static
     */
    public function startOfDecade(): static
    {
        $year = $this->year - $this->year % Chronos::YEARS_PER_DECADE;

        return $this->modify("first day of january $year");
    }

    /**
     * Resets the date to end of the decade
     *
     * @return static
     */
    public function endOfDecade(): static
    {
        $year = $this->year - $this->year % Chronos::YEARS_PER_DECADE + Chronos::YEARS_PER_DECADE - 1;

        return $this->modify("last day of december $year");
    }

    /**
     * Resets the date to the first day of the century
     *
     * @return static
     */
    public function startOfCentury(): static
    {
        $year = $this->startOfYear()
            ->year($this->year - 1 - ($this->year - 1) % Chronos::YEARS_PER_CENTURY + 1)
            ->year;

        return $this->modify("first day of january $year");
    }

    /**
     * Resets the date to end of the century and time to 23:59:59
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

        return $this->modify("last day of december $year");
    }

    /**
     * Resets the date to the first day of week (defined in $weekStartsAt)
     *
     * @return static
     */
    public function startOfWeek(): static
    {
        $dateTime = $this;
        if ($dateTime->dayOfWeek !== Chronos::getWeekStartsAt()) {
            $dateTime = $dateTime->previous(Chronos::getWeekStartsAt());
        }

        return $dateTime;
    }

    /**
     * Resets the date to end of week (defined in $weekEndsAt) and time to 23:59:59
     *
     * @return static
     */
    public function endOfWeek(): static
    {
        $dateTime = $this;
        if ($dateTime->dayOfWeek !== Chronos::getWeekEndsAt()) {
            $dateTime = $dateTime->next(Chronos::getWeekEndsAt());
        }

        return $dateTime;
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

        return $this->modify("next $day");
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

        return $this->modify("last $day");
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

        return $this->modify("first $day of this month");
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

        return $this->modify("last $day of this month");
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

        return $this->modify("first $day of january");
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

        return $this->modify("last $day of december");
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
     * @param \Cake\Chronos\ChronosDate $other The instance to compare with.
     * @return bool
     */
    public function equals(ChronosDate $other): bool
    {
        return $this->native == $other->native;
    }

    /**
     * Determines if the instance is not equal to another
     *
     * @param \Cake\Chronos\ChronosDate $other The instance to compare with.
     * @return bool
     */
    public function notEquals(ChronosDate $other): bool
    {
        return !$this->equals($other);
    }

    /**
     * Determines if the instance is greater (after) than another
     *
     * @param \Cake\Chronos\ChronosDate $other The instance to compare with.
     * @return bool
     */
    public function greaterThan(ChronosDate $other): bool
    {
        return $this->native > $other->native;
    }

    /**
     * Determines if the instance is greater (after) than or equal to another
     *
     * @param \Cake\Chronos\ChronosDate $other The instance to compare with.
     * @return bool
     */
    public function greaterThanOrEquals(ChronosDate $other): bool
    {
        return $this->native >= $other->native;
    }

    /**
     * Determines if the instance is less (before) than another
     *
     * @param \Cake\Chronos\ChronosDate $other The instance to compare with.
     * @return bool
     */
    public function lessThan(ChronosDate $other): bool
    {
        return $this->native < $other->native;
    }

    /**
     * Determines if the instance is less (before) or equal to another
     *
     * @param \Cake\Chronos\ChronosDate $other The instance to compare with.
     * @return bool
     */
    public function lessThanOrEquals(ChronosDate $other): bool
    {
        return $this->native <= $other->native;
    }

    /**
     * Determines if the instance is between two others
     *
     * @param \Cake\Chronos\ChronosDate $start Start of target range
     * @param \Cake\Chronos\ChronosDate $end End of target range
     * @param bool $equals Whether to include the beginning and end of range
     * @return bool
     */
    public function between(ChronosDate $start, ChronosDate $end, bool $equals = true): bool
    {
        if ($start->greaterThan($end)) {
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
     * @param \Cake\Chronos\ChronosDate $first The instance to compare with.
     * @param \Cake\Chronos\ChronosDate $second The instance to compare with.
     * @param \Cake\Chronos\ChronosDate ...$others Others instance to compare with.
     * @return self
     */
    public function closest(ChronosDate $first, ChronosDate $second, ChronosDate ...$others): ChronosDate
    {
        $closest = $first;
        $closestDiffInDays = $this->diffInDays($first);
        foreach ([$second, ...$others] as $other) {
            $otherDiffInDays = $this->diffInDays($other);
            if ($otherDiffInDays < $closestDiffInDays) {
                $closest = $other;
                $closestDiffInDays = $otherDiffInDays;
            }
        }

        return $closest;
    }

    /**
     * Get the farthest date from the instance.
     *
     * @param \Cake\Chronos\ChronosDate $first The instance to compare with.
     * @param \Cake\Chronos\ChronosDate $second The instance to compare with.
     * @param \Cake\Chronos\ChronosDate ...$others Others instance to compare with.
     * @return self
     */
    public function farthest(ChronosDate $first, ChronosDate $second, ChronosDate ...$others): ChronosDate
    {
        $farthest = $first;
        $farthestDiffInDays = $this->diffInDays($first);
        foreach ([$second, ...$others] as $other) {
            $otherDiffInDays = $this->diffInDays($other);
            if ($otherDiffInDays > $farthestDiffInDays) {
                $farthest = $other;
                $farthestDiffInDays = $otherDiffInDays;
            }
        }

        return $farthest;
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
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isYesterday(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->equals(static::yesterday($timezone));
    }

    /**
     * Determines if the instance is today
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isToday(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->equals(static::now($timezone));
    }

    /**
     * Determines if the instance is tomorrow
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isTomorrow(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->equals(static::tomorrow($timezone));
    }

    /**
     * Determines if the instance is within the next week
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isNextWeek(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->format('W o') === static::now($timezone)->addWeeks(1)->format('W o');
    }

    /**
     * Determines if the instance is within the last week
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isLastWeek(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->format('W o') === static::now($timezone)->subWeeks(1)->format('W o');
    }

    /**
     * Determines if the instance is within the next month
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isNextMonth(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->format('m Y') === static::now($timezone)->addMonths(1)->format('m Y');
    }

    /**
     * Determines if the instance is within the last month
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isLastMonth(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->format('m Y') === static::now($timezone)->subMonths(1)->format('m Y');
    }

    /**
     * Determines if the instance is within the next year
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isNextYear(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->year === static::now($timezone)->addYears(1)->year;
    }

    /**
     * Determines if the instance is within the last year
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isLastYear(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->year === static::now($timezone)->subYears(1)->year;
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
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isFuture(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->greaterThan(static::now($timezone));
    }

    /**
     * Determines if the instance is in the past, ie. less (before) than now
     *
     * @param \DateTimeZone|string|null $timezone Time zone to use for now.
     * @return bool
     */
    public function isPast(DateTimeZone|string|null $timezone = null): bool
    {
        return $this->lessThan(static::now($timezone));
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
     * Returns true this instance happened within the specified interval
     *
     * @param string|int $timeInterval the numeric value with space then time type.
     *    Example of valid types: 6 hours, 2 days, 1 minute.
     * @return bool
     */
    public function wasWithinLast(string|int $timeInterval): bool
    {
        $now = new static(new Chronos());
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
        $now = new static(new Chronos());
        $interval = $now->modify('+' . $timeInterval);
        $thisTime = $this->format('U');

        return $thisTime <= $interval->format('U') && $thisTime >= $now->format('U');
    }

    /**
     * Get the difference by the given interval using a filter callable
     *
     * @param \DateInterval $interval An interval to traverse by
     * @param callable $callback The callback to use for filtering.
     * @param \Cake\Chronos\ChronosDate|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffFiltered(
        DateInterval $interval,
        callable $callback,
        ?ChronosDate $other = null,
        bool $absolute = true,
        int $options = 0
    ): int {
        $start = $this;
        $end = $other ?? new ChronosDate(Chronos::now());
        $inverse = false;

        if ($end < $start) {
            $start = $end;
            $end = $this;
            $inverse = true;
        }
        // Hack around PHP's DatePeriod not counting equal dates at midnight as
        // within the range. Sadly INCLUDE_END_DATE doesn't land until 8.2
        $endTime = $end->native->modify('+1 second');

        $period = new DatePeriod($start->native, $interval, $endTime, $options);
        $vals = array_filter(iterator_to_array($period), function (DateTimeInterface $date) use ($callback) {
            return $callback(static::parse($date));
        });

        $diff = count($vals);

        return $inverse && !$absolute ? -$diff : $diff;
    }

    /**
     * Get the difference in years
     *
     * @param \Cake\Chronos\ChronosDate|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInYears(?ChronosDate $other = null, bool $absolute = true): int
    {
        $diff = $this->diff($other ?? new static(new Chronos()), $absolute);

        return $diff->invert ? -$diff->y : $diff->y;
    }

    /**
     * Get the difference in months
     *
     * @param \Cake\Chronos\ChronosDate|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInMonths(?ChronosDate $other = null, bool $absolute = true): int
    {
        $diff = $this->diff($other ?? new static(Chronos::now()), $absolute);
        $months = $diff->y * Chronos::MONTHS_PER_YEAR + $diff->m;

        return $diff->invert ? -$months : $months;
    }

    /**
     * Get the difference in weeks
     *
     * @param \Cake\Chronos\ChronosDate|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInWeeks(?ChronosDate $other = null, bool $absolute = true): int
    {
        return (int)($this->diffInDays($other, $absolute) / Chronos::DAYS_PER_WEEK);
    }

    /**
     * Get the difference in days
     *
     * @param \Cake\Chronos\ChronosDate|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @return int
     */
    public function diffInDays(?ChronosDate $other = null, bool $absolute = true): int
    {
        $diff = $this->diff($other ?? new static(Chronos::now()), $absolute);

        return $diff->invert ? -(int)$diff->days : (int)$diff->days;
    }

    /**
     * Get the difference in days using a filter callable
     *
     * @param callable $callback The callback to use for filtering.
     * @param \Cake\Chronos\ChronosDate|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffInDaysFiltered(
        callable $callback,
        ?ChronosDate $other = null,
        bool $absolute = true,
        int $options = 0
    ): int {
        return $this->diffFiltered(new DateInterval('P1D'), $callback, $other, $absolute, $options);
    }

    /**
     * Get the difference in weekdays
     *
     * @param \Cake\Chronos\ChronosDate|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffInWeekdays(?ChronosDate $other = null, bool $absolute = true, int $options = 0): int
    {
        return $this->diffInDaysFiltered(function (ChronosDate $date) {
            return $date->isWeekday();
        }, $other, $absolute, $options);
    }

    /**
     * Get the difference in weekend days using a filter
     *
     * @param \Cake\Chronos\ChronosDate|null $other The instance to difference from.
     * @param bool $absolute Get the absolute of the difference
     * @param int $options DatePeriod options, {@see https://www.php.net/manual/en/class.dateperiod.php}
     * @return int
     */
    public function diffInWeekendDays(?ChronosDate $other = null, bool $absolute = true, int $options = 0): int
    {
        return $this->diffInDaysFiltered(function (ChronosDate $date) {
            return $date->isWeekend();
        }, $other, $absolute, $options);
    }

    /**
     * Get the difference in a human readable format.
     *
     * When comparing a value in the past to default now:
     * 5 months ago
     *
     * When comparing a value in the future to default now:
     * 5 months from now
     *
     * When comparing a value in the past to another value:
     * 5 months before
     *
     * When comparing a value in the future to another value:
     * 5 months after
     *
     * @param \Cake\Chronos\ChronosDate|null $other The datetime to compare with.
     * @param bool $absolute removes difference modifiers ago, after, etc
     * @return string
     */
    public function diffForHumans(?ChronosDate $other = null, bool $absolute = false): string
    {
        return static::diffFormatter()->diffForHumans($this, $other, $absolute);
    }

    /**
     * Returns the date as a `DateTimeImmutable` instance at midnight.
     *
     * @param \DateTimeZone|string|null $timezone Time zone the DateTimeImmutable instance will be in
     * @return \DateTimeImmutable
     */
    public function toDateTimeImmutable(DateTimeZone|string|null $timezone = null): DateTimeImmutable
    {
        if ($timezone === null) {
            return $this->native;
        }

        $timezone = is_string($timezone) ? new DateTimeZone($timezone) : $timezone;

        return new DateTimeImmutable($this->native->format('Y-m-d H:i:s.u'), $timezone);
    }

    /**
     * Returns the date as a `DateTimeImmutable` instance at midnight.
     *
     * Alias of `toDateTimeImmutable()`.
     *
     * @param \DateTimeZone|string|null $timezone Time zone the DateTimeImmutable instance will be in
     * @return \DateTimeImmutable
     */
    public function toNative(DateTimeZone|string|null $timezone = null): DateTimeImmutable
    {
        return $this->toDateTimeImmutable($timezone);
    }

    /**
     * Get a part of the object
     *
     * @param string $name The property name to read.
     * @return string|float|int|bool The property value.
     * @throws \InvalidArgumentException
     */
    public function __get(string $name): string|float|int|bool
    {
        static $formats = [
            'year' => 'Y',
            'yearIso' => 'o',
            'month' => 'n',
            'day' => 'j',
            'dayOfWeek' => 'N',
            'dayOfYear' => 'z',
            'weekOfYear' => 'W',
            'daysInMonth' => 't',
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
        $properties = [
            'hasFixedNow' => Chronos::hasTestNow(),
            'date' => $this->format('Y-m-d'),
        ];

        return $properties;
    }
}
