<?php // {"autorun":true, "persist":false, "single-expression": false, "render-as": "text"}

$x = false;

a:

if(!$x)
{
	goto b;
}

echo 'Foo';

goto c;

b:

echo 'Bar';

if(!$x)
{
	$x = true;
	goto a;
}

c:
echo 'Baz';
