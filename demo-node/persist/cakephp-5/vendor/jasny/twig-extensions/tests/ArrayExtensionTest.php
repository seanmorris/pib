<?php

namespace Jasny\Twig;

use Jasny\Twig\ArrayExtension;
use Jasny\Twig\TestHelper;
use PHPUnit\Framework\TestCase;

/**
 * @covers Jasny\Twig\ArrayExtension
 */
class ArrayExtensionTest extends TestCase
{
    use TestHelper;
    
    protected function getExtension()
    {
        return new ArrayExtension();
    }


    public function testSum()
    {
        $data = [1, 2, 3, 4];
        
        $this->assertRender('10', '{{ data|sum }}', compact('data'));
    }

    public function testProduct()
    {
        $data = [1, 2, 3, 4];
        
        $this->assertRender('24', '{{ data|product }}', compact('data'));
    }

    public function testValues()
    {
        $data = (object)['foo' => 1, 'bar' => 2, 'zoo' => 3];
        
        $this->assertRender('1-2-3', '{{ data|values|join("-") }}', compact('data'));
    }

    
    public function testAsArrayWithObject()
    {
        $data = (object)['foo' => 1, 'bar' => 2, 'zoo' => 3];
        
        $this->assertRender('foo-bar-zoo', '{{ data|as_array|keys|join("-") }}', compact('data'));
    }
    
    public function testAsArrayWithString()
    {
        $data = 'foo';
        
        $this->assertRender('foo', '{{ data|as_array|join("-") }}', compact('data'));
    }
    
    public function testHtmlAttr()
    {
        $data = ['href' => 'foo.html', 'class' => 'big small', 'checked' => true, 'disabled' => false];
        
        $this->assertRender(
            'href="foo.html" class="big small" checked="checked"',
            '{{ data|html_attr|raw }}',
            compact('data')
        );
    }
    
    
    public function filterProvider()
    {
        return [
            ['sum'],
            ['product'],
            ['values'],
            ['as_array'],
            ['html_attr']
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
