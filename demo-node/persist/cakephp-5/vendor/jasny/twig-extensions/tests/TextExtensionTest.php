<?php

namespace Jasny\Twig;

use Jasny\Twig\TextExtension;
use Jasny\Twig\TestHelper;
use PHPUnit\Framework\TestCase;

/**
 * @covers Jasny\Twig\TextExtension
 */
class TextExtensionTest extends TestCase
{
    use TestHelper;
    
    protected function getExtension()
    {
        return new TextExtension();
    }

    
    public function testParagraph()
    {
        $this->assertRender("<p>foo<br>\nbar</p>\n<p>monkey</p>", "{{ 'foo\nbar\n\nmonkey'|paragraph() }}");
    }
    
    
    public function testLine()
    {
        $this->assertRender("foo", "{{ 'foo\nbar\nbaz'|line() }}");
    }
    
    public function testLineTwo()
    {
        $this->assertRender("bar", "{{ 'foo\nbar\nbaz'|line(2) }}");
    }
    
    public function testLineToHigh()
    {
        $this->assertRender("", "{{ 'foo\nbar\nbaz'|line(100) }}");
    }
    
    
    public function testLess()
    {
        $this->assertRender("foo...", "{{ 'foo<!-- pagebreak -->baz'|less() }}");
    }
    
    public function testLessCustom()
    {
        $this->assertRender("foo..", "{{ 'fooXbarXbaz'|less('..', 'X') }}");
    }
    
    public function testLessNoPageBreak()
    {
        $this->assertRender("foo bar", "{{ 'foo bar'|less }}");
    }
    
    
    public function testTruncate()
    {
        $this->assertRender("foo...", "{{ 'foo bar baz'|truncate(6) }}");
    }
    
    public function testTruncateCustom()
    {
        $this->assertRender("foo ..", "{{ 'foo bar baz'|truncate(6, '..') }}");
    }
    
    public function testTruncateToHigh()
    {
        $this->assertRender("foo bar baz", "{{ 'foo bar baz'|truncate(100) }}");
    }
    
    
    public function testLinkify()
    {
        $this->assertRender(
            '<a href="http://www.example.com">www.example.com</a>, color.bar and '
                . '<a href="mailto:john@example.com">john@example.com</a>',
            '{{ "www.example.com, color.bar and john@example.com"|linkify }}'
        );
    }
    
    public function testLinkifyAll()
    {
        $this->assertRender(
            '<a href="http://www.example.com">www.example.com</a>, <a href="http://color.bar">color.bar</a> and '
                . '<a href="mailto:john@example.com">john@example.com</a>',
            '{{ "www.example.com, color.bar and john@example.com"|linkify(["http", "mail"], [], "all") }}'
        );
    }
    
    public function testLinkifyHttps()
    {
        $this->assertRender(
            '<a href="https://www.example.com">www.example.com</a>',
            '{{ "www.example.com"|linkify("https") }}'
        );
    }
    
    public function testLinkifyMail()
    {
        $this->assertRender(
            '<a href="mailto:john@example.com">john@example.com</a> and '
                . '<a href="mailto:jeff@example.com">jeff@example.com</a>',
            '{{ "john@example.com and jeff@example.com"|linkify }}'
        );
    }
    
    public function testLinkifyFtp()
    {
        $this->assertRender(
            '<a href="ftp://www.example.com">www.example.com</a>',
            '{{ "ftp://www.example.com"|linkify("ftp") }}'
        );
    }
    
    public function testLinkifyFtpAll()
    {
        $this->assertRender(
            '<a href="ftp://www.example.com">www.example.com</a>',
            '{{ "www.example.com"|linkify("ftp", [], "all") }}'
        );
    }
    
    public function testLinkifyOther()
    {
        $this->assertRender(
            '<a href="foo:abc.def.hif">abc.def.hif</a>',
            '{{ "foo:abc.def.hif"|linkify("foo") }}'
        );
    }
    
    public function testLinkifyOtherAll()
    {
        $this->assertRender(
            '<a href="foo:abc.def.hif">abc.def.hif</a>',
            '{{ "abc.def.hif"|linkify("foo", [], "all") }}'
        );
    }
    
    public function testLinkifyWithAttributes()
    {
        $this->assertRender(
            '<a foo="bar" color="blue" href="http://www.example.com">www.example.com</a> and '
                . '<a foo="bar" color="blue" href="mailto:john@example.com">john@example.com</a>',
            '{{ "www.example.com and john@example.com"|linkify(["http", "mail"], {foo: "bar", color: "blue"}) }}'
        );
    }
    
    public function testLinkifyWithExistingLink()
    {
        $this->assertRender(
            '<a href="http://www.example.com">www.example.com</a> and '
                . '<a href="http://www.example.net">www.example.net</a>',
            '{{ "<a href=\\"http://www.example.com\\">www.example.com</a> and www.example.net"|linkify }}'
        );
    }
    
    
    public function filterProvider()
    {
        return [
            ['paragraph'],
            ['line'],
            ['less'],
            ['truncate'],
            ['linkify']
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
