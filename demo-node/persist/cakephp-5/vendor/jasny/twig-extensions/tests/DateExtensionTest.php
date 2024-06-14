<?php

namespace Jasny\Twig;

use Jasny\Twig\DateExtension;
use Jasny\Twig\TestHelper;
use PHPUnit\Framework\TestCase;

/**
 * @covers Jasny\Twig\DateExtension
 */
class DateExtensionTest extends TestCase
{
    use TestHelper;

    public function setUp(): void
    {
        date_default_timezone_set('UTC');
        \Locale::setDefault("en_EN");
    }

    protected function getExtension()
    {
        return new DateExtension();
    }


    public function localDateTimeProvider()
    {
        return [
            ['9/20/2015', '20-09-2015', "{{ '20-09-2015'|localdate }}"],
            ['September 20, 2015', '20 september 2015', "{{ '20-09-2015'|localdate('long') }}"],
            ['9/20/15', "20-09-15", "{{ '20-09-2015'|localdate('short') }}"],
            ['Sunday, September 20, 2015', "zondag 20 september 2015", "{{ '20-09-2015'|localdate('full') }}"],
            ['20|09|2015', "20|09|2015", "{{ '20-09-2015'|localdate('dd|MM|yyyy') }}"],

            ['11:14 PM', "23:14", "{{ '23:14:12'|localtime }}"],
            ['11:14 PM', "23:14", "{{ '23:14:12'|localtime('short') }}"],
            ['23|14|12', "23|14|12", "{{ '23:14:12'|localtime('HH|mm|ss') }}"],

            // NOTE: a `replace` is used to remove the comma, which seems to be inconsistant accross environments.
            ['9/20/2015 11:14 PM', '20-09-2015 23:14', "{{ '20-09-2015 23:14:12'|localdatetime|replace({',': ''}) }}"],
            ['20|23', '20|23', "{{ '20-09-2015 23:14:12'|localdatetime('dd|HH') }}"],
        ];
    }

    /**
     * @dataProvider localDateTimeProvider
     *
     * @param string $en
     * @param string $nl
     * @param string $template
     */
    public function testLocalDateTimeEn($en, $nl, $template)
    {
        if (!\Locale::setDefault("en_EN")) {
            return $this->markAsSkipped("Unable to set locale to 'en_EN'");
        }

        $this->assertRender($en, $template);
    }

    /**
     * @dataProvider localDateTimeProvider
     *
     * @param string $en
     * @param string $nl
     * @param string $template
     */
    public function testLocalDateTimeNL($en, $nl, $template)
    {
        if (!\Locale::setDefault("nl_NL")) {
            return $this->markAsSkipped("Unable to set locale to 'nl_NL'");
        }

        $this->assertRender($nl, $template);

    }


    public function durationProvider()
    {
        return [
            ['31s', "{{ 31|duration }}"],
            ['17m 31s', "{{ 1051|duration }}"],
            ['3h 17m 31s', "{{ 11851|duration }}"],
            ['2d 3h 17m 31s', "{{ 184651|duration }}"],
            ['3w 2d 3h 17m 31s', "{{ 1999051|duration }}"],
            ['1y 3w 2d 3h 17m 31s', "{{ 33448651|duration }}"],

            ['17 minute(s)', "{{ 1051|duration([null, ' minute(s)', ' hour(s)', ' day(s)']) }}"],
            ['3 hour(s)', "{{ 11851|duration([null, null, ' hour(s)']) }}"],
            ['2 day(s)', "{{ 184651|duration([null, null, null, ' day(s)']) }}"],
            ['3 week(s)', "{{ 1999051|duration([null, null, null, null, ' week(s)']) }}"],
            ['1 year(s)', "{{ 33448651|duration([null, null, null, null, null, ' year(s)']) }}"],

            ['3u:17m', "{{ 11851|duration([null, 'm', 'u'], ':') }}"],
            ['3:17h', "{{ 11851|duration([null, '', ''], ':') }}h"],
        ];
    }

    /**
     * @dataProvider durationProvider
     *
     * @param string $expect
     * @param string $template
     */
    public function testDuration($expect, $template)
    {
        $this->assertRender($expect, $template);
    }


    public function ageProvider()
    {
        $time = time() - (((32 * 365) + 100) * 24 * 3600);
        $date = date('Y-m-d', $time);

        return [
            ['32', "{{ $time|age }}"],
            ['32', "{{ '$date'|age }}"]
        ];
    }

    /**
     * @dataProvider ageProvider
     *
     * @param string $expect
     * @param string $template
     */
    public function testAge($expect, $template)
    {
        $this->assertRender($expect, $template);
    }


    public function filterProvider()
    {
        return [
            ['localdate'],
            ['localtime'],
            ['localdatetime'],
            ['duration'],
            ['age']
        ];
    }

    /**
     * @dataProvider filterProvider
     *
     * @param string $filter
     */
    public function testWithNull($filter)
    {
        $this->assertRender('-', '{{ null|' . $filter . '("//")|default("-") }}');
    }
}
