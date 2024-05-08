<?php // {"autorun":true, "persist":false, "single-expression": false, "render-as": "text"}

$x = 10;

function run(callable $f) {
	$f();
}

run(function () use (&$x) {
	$x = 9;
});

var_dump($x);
