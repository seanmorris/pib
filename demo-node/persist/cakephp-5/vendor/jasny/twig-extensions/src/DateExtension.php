<?php

namespace Jasny\Twig;

use Twig\Error\RuntimeError;
use Twig\Extension\AbstractExtension;
use Twig\TwigFilter;

/**
 * Format a date based on the current locale in Twig
 */
class DateExtension extends AbstractExtension
{
    /**
     * Class constructor
     */
    public function __construct()
    {
        if (!extension_loaded('intl')) {
            throw new \Exception("The Date Twig extension requires the 'intl' PHP extension."); // @codeCoverageIgnore
        }
    }


    /**
     * Return extension name
     *
     * @return string
     */
    public function getName()
    {
        return 'jasny/date';
    }

    /**
     * Callback for Twig to get all the filters.
     *
     * @return \Twig\TwigFilter[]
     */
    public function getFilters()
    {
        return [
            new TwigFilter('localdate', [$this, 'localDate']),
            new TwigFilter('localtime', [$this, 'localTime']),
            new TwigFilter('localdatetime', [$this, 'localDateTime']),
            new TwigFilter('duration', [$this, 'duration']),
            new TwigFilter('age', [$this, 'age']),
        ];
    }

    /**
     * Turn a value into a DateTime object
     *
     * @param string|int|\DateTime $date
     * @return \DateTime
     */
    protected function valueToDateTime($date)
    {
        if (!$date instanceof \DateTime) {
            $date = is_int($date) ? \DateTime::createFromFormat('U', $date) : new \DateTime((string)$date);
        }

        if ($date === false) {
            throw new RuntimeError("Invalid date '$date'");
        }

        return $date;
    }

    /**
     * Get configured intl date formatter.
     *
     * @param string|null $dateFormat
     * @param string|null $timeFormat
     * @param string      $calendar
     * @return \IntlDateFormatter
     */
    protected function getDateFormatter($dateFormat, $timeFormat, $calendar)
    {
        $datetype = isset($dateFormat) ? $this->getFormat($dateFormat) : null;
        $timetype = isset($timeFormat) ? $this->getFormat($timeFormat) : null;

        $calendarConst = $calendar === 'traditional' ? \IntlDateFormatter::TRADITIONAL : \IntlDateFormatter::GREGORIAN;

        $pattern = $this->getDateTimePattern(
            isset($datetype) ? $datetype : $dateFormat,
            isset($timetype) ? $timetype : $timeFormat,
            $calendarConst
        );

        return new \IntlDateFormatter(\Locale::getDefault(), $datetype, $timetype, null, $calendarConst, $pattern);
    }

    /**
     * Format the date/time value as a string based on the current locale
     *
     * @param string|false $format  'short', 'medium', 'long', 'full', 'none' or false
     * @return int|null
     */
    protected function getFormat($format)
    {
        if ($format === false) {
            $format = 'none';
        }

        $types = [
            'none' => \IntlDateFormatter::NONE,
            'short' => \IntlDateFormatter::SHORT,
            'medium' => \IntlDateFormatter::MEDIUM,
            'long' => \IntlDateFormatter::LONG,
            'full' => \IntlDateFormatter::FULL
        ];

        return isset($types[$format]) ? $types[$format] : null;
    }

    /**
     * Get the date/time pattern.
     *
     * @param int|string $datetype
     * @param int|string $timetype
     * @param int        $calendar
     * @return string
     */
    protected function getDateTimePattern($datetype, $timetype, $calendar = \IntlDateFormatter::GREGORIAN)
    {
        if (is_int($datetype) && is_int($timetype)) {
            return null;
        }

        return $this->getDatePattern(
            isset($datetype) ? $datetype : \IntlDateFormatter::SHORT,
            isset($timetype) ? $timetype : \IntlDateFormatter::SHORT,
            $calendar
        );
    }

    /**
     * Get the formatter to create a date and/or time pattern
     *
     * @param int|string $datetype
     * @param int|string $timetype
     * @param int        $calendar
     * @return \IntlDateFormatter
     */
    protected function getDatePatternFormatter($datetype, $timetype, $calendar = \IntlDateFormatter::GREGORIAN)
    {
        return \IntlDateFormatter::create(
            \Locale::getDefault(),
            is_int($datetype) ? $datetype : \IntlDateFormatter::NONE,
            is_int($timetype) ? $timetype : \IntlDateFormatter::NONE,
            \IntlTimeZone::getGMT(),
            $calendar
        );
    }

    /**
     * Get the date and/or time pattern
     * Default date pattern is short date pattern with 4 digit year.
     *
     * @param int|string $datetype
     * @param int|string $timetype
     * @param int        $calendar
     * @return string
     */
    protected function getDatePattern($datetype, $timetype, $calendar = \IntlDateFormatter::GREGORIAN)
    {
        $createPattern =
            (is_int($datetype) && $datetype !== \IntlDateFormatter::NONE) ||
            (is_int($timetype) && $timetype !== \IntlDateFormatter::NONE);

        $pattern = $createPattern ? $this->getDatePatternFormatter($datetype, $timetype, $calendar)->getPattern() : '';

        return trim(
            (is_string($datetype) ? $datetype . ' ' : '') .
            preg_replace('/\byy?\b/', 'yyyy', $pattern) .
            (is_string($timetype) ? ' ' . $timetype : '')
        );
    }

    /**
     * Format the date and/or time value as a string based on the current locale
     *
     * @param \DateTime|int|string $value
     * @param string               $dateFormat  null, 'short', 'medium', 'long', 'full' or pattern
     * @param string               $timeFormat  null, 'short', 'medium', 'long', 'full' or pattern
     * @param string               $calendar    'gregorian' or 'traditional'
     * @return string
     */
    protected function formatLocal($value, $dateFormat, $timeFormat, $calendar = 'gregorian')
    {
        if (!isset($value)) {
            return null;
        }

        $date = $this->valueToDateTime($value);
        $formatter = $this->getDateFormatter($dateFormat, $timeFormat, $calendar);

        return $formatter->format($date->getTimestamp());
    }

    /**
     * Format the date value as a string based on the current locale
     *
     * @param \DateTime|int|string $date
     * @param string               $format    null, 'short', 'medium', 'long', 'full' or pattern
     * @param string               $calendar  'gregorian' or 'traditional'
     * @return string
     */
    public function localDate($date, $format = null, $calendar = 'gregorian')
    {
        return $this->formatLocal($date, $format, false, $calendar);
    }

    /**
     * Format the time value as a string based on the current locale
     *
     * @param \DateTime|int|string $date
     * @param string               $format    'short', 'medium', 'long', 'full' or pattern
     * @param string               $calendar  'gregorian' or 'traditional'
     * @return string
     */
    public function localTime($date, $format = 'short', $calendar = 'gregorian')
    {
        return $this->formatLocal($date, false, $format, $calendar);
    }

    /**
     * Format the date/time value as a string based on the current locale
     *
     * @param \DateTime|int|string $date
     * @param string               $format    date format, pattern or ['date'=>format, 'time'=>format)
     * @param string               $calendar  'gregorian' or 'traditional'
     * @return string
     */
    public function localDateTime($date, $format = null, $calendar = 'gregorian')
    {
        if (is_array($format) || $format instanceof \stdClass || !isset($format)) {
            $formatDate = isset($format['date']) ? $format['date'] : null;
            $formatTime = isset($format['time']) ? $format['time'] : 'short';
        } else {
            $formatDate = $format;
            $formatTime = false;
        }

        return $this->formatLocal($date, $formatDate, $formatTime, $calendar);
    }


    /**
     * Split duration into seconds, minutes, hours, days, weeks and years.
     *
     * @param int $seconds
     * @return array
     */
    protected function splitDuration($seconds, $max)
    {
        if ($max < 1 || $seconds < 60) {
            return [$seconds];
        }

        $minutes = floor($seconds / 60);
        $seconds = $seconds % 60;
        if ($max < 2 || $minutes < 60) {
            return [$seconds, $minutes];
        }

        $hours = floor($minutes / 60);
        $minutes = $minutes % 60;
        if ($max < 3 || $hours < 24) {
            return [$seconds, $minutes, $hours];
        }

        $days = floor($hours / 24);
        $hours = $hours % 24;
        if ($max < 4 || $days < 7) {
            return [$seconds, $minutes, $hours, $days];
        }

        $weeks = floor($days / 7);
        $days = $days % 7;
        if ($max < 5 || $weeks < 52) {
            return [$seconds, $minutes, $hours, $days, $weeks];
        }

        $years = floor($weeks / 52);
        $weeks = $weeks % 52;
        return [$seconds, $minutes, $hours, $days, $weeks, $years];
    }

    /**
     * Calculate duration from seconds.
     * One year is seen as exactly 52 weeks.
     *
     * Use null to skip a unit.
     *
     * @param int    $value     Time in seconds
     * @param array  $units     Time units (seconds, minutes, hours, days, weeks, years)
     * @param string $separator
     * @return string
     */
    public function duration($value, $units = ['s', 'm', 'h', 'd', 'w', 'y'], $separator = ' ')
    {
        if (!isset($value)) {
            return null;
        }

        $parts = $this->splitDuration($value, count($units) - 1) + array_fill(0, 6, null);

        $duration = '';

        for ($i = 5; $i >= 0; $i--) {
            if (isset($parts[$i]) && isset($units[$i])) {
                $duration .= $separator . $parts[$i] . $units[$i];
            }
        }

        return trim($duration, $separator);
    }

    /**
     * Get the age (in years) based on a date.
     *
     * @param \DateTime|string $value
     * @return int
     */
    public function age($value)
    {
        if (!isset($value)) {
            return null;
        }

        $date = $this->valueToDateTime($value);

        return $date->diff(new \DateTime())->format('%y');
    }
}
