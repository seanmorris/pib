<?php // {"autorun":true, "persist":true, "single-expression": false, "render-as": "text"}
$window = $window ?? new Vrzno;

$promise = new $window->Promise(function($accept, $reject) {
	$window = new Vrzno;
	$window->setTimeout(fn() => $accept('Pass.'), 1000);
	// $window->setTimeout(fn() => $reject('Fail.'), 1000);
});

$promise
	->then(var_dump(...))
	->catch(var_dump(...));
