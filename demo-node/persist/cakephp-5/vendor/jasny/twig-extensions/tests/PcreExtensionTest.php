<?php

namespace Jasny\Twig;

use Jasny\Twig\PcreExtension;
use Jasny\Twig\TestHelper;
use PHPUnit\Framework\TestCase;
use Twig\Error\RuntimeError as TwigRuntimeError;

/**
 * @covers Jasny\Twig\PcreExtension
 */
class PcreExtensionTest extends TestCase
{
    use TestHelper;

    protected function getExtension()
    {
        return new PcreExtension();
    }


    public function testGetName()
    {
        $this->assertEquals('jasny/pcre', $this->getExtension()->getName());
    }


    public function testQuote()
    {
        $this->assertRender('foo\(\)', '{{ "foo()"|preg_quote }}');
    }

    public function testQuoteDelimiter()
    {
        $this->assertRender('foo\@bar', '{{ "foo@bar"|preg_quote("@") }}');
    }

    public function testPregMatch()
    {
        $this->assertRender('YES', '{% if "foo"|preg_match("/oo/") %}YES{% else %}NO{% endif %}');
    }

    public function testPregMatchNo()
    {
        $this->assertRender('NO', '{% if "fod"|preg_match("/oo/") %}YES{% else %}NO{% endif %}');
    }

    public function testPregMatchError()
    {
        $this->expectException(TwigRuntimeError::class);
        $this->render('{% if "fod"|preg_match("/o//o/") %}YES{% else %}NO{% endif %}');
    }


    public function testPregGet()
    {
        $this->assertRender('d', '{{ "food"|preg_get("/oo(.)/", 1) }}');
    }

    public function testPregGetDefault()
    {
        $this->assertRender('ood', '{{ "food"|preg_get("/oo(.)/") }}');
    }


    public function testPregGetAll()
    {
        $this->assertRender('d|t|m', '{{ "food woot should doom"|preg_get_all("/oo(.)/", 1)|join("|") }}');
    }

    public function testPregGetAllDefault()
    {
        $this->assertRender('ood|oot|oom', '{{ "food woot doom"|preg_get_all("/oo(.)/")|join("|") }}');
    }


    public function testPregGrep()
    {
        $this->assertRender(
            'world|how|you',
            '{{ ["hello", "sweet", "world", "how", "are", "you"]|preg_grep("/o./")|join("|") }}'
        );
    }

    public function testPregGrepInvert()
    {
        $this->assertRender(
            'hello|sweet|are',
            '{{ ["hello", "sweet", "world", "how", "are", "you"]|preg_grep("/o./", "invert")|join("|") }}'
        );
    }


    public function testReplace()
    {
        $this->assertRender(
            'the quick brawen faxe jumped aveer the lazy dage',
            '{{ "the quick brown fox jumped over the lazy dog"|preg_replace("/o(\\\\w)/", "a$1e") }}'
        );
    }

    public function testReplaceLimit()
    {
        $this->assertRender(
            'the quick brawen faxe jumped over the lazy dog',
            '{{ "the quick brown fox jumped over the lazy dog"|preg_replace("/o(\\\\w)/", "a$1e", 2) }}'
        );
    }

    public function testReplaceWithArray()
    {
        $this->assertRender(
            'hello|sweet|wareld|hawe|are|yaue',
            '{{ ["hello", "sweet", "world", "how", "are", "you"]|preg_replace("/o(.)/", "a$1e")|join("|") }}'
        );
    }

    public function testReplaceAssertNoEval()
    {
        $this->expectException(TwigRuntimeError::class);
        $this->render('{{ "foo"|preg_replace("/o/ei", "strtoupper") }}');
    }


    public function testFilter()
    {
        $this->assertRender(
            'wareld|hawe|yaue',
            '{{ ["hello", "sweet", "world", "how", "are", "you"]|preg_filter("/o(.)/", "a$1e")|join("|") }}'
        );
    }

    public function testFilterAssertNoEval()
    {
        $this->expectException(TwigRuntimeError::class);
        $this->render('{{ "foo"|preg_filter("/o/ei", "strtoupper") }}');
    }


    public function testSplit()
    {
        $this->assertRender(
            'the quick br|n f| jumped |er the lazy d|',
            '{{ "the quick brown fox jumped over the lazy dog"|preg_split("/o(\\\\w)/", "a$1e")|join("|") }}'
        );
    }


    public function filterProvider()
    {
        return [
            ['preg_quote'],
            ['preg_match'],
            ['preg_get'],
            ['preg_get_all'],
            ['preg_grep'],
            ['preg_replace'],
            ['preg_filter'],
            ['preg_split']
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
