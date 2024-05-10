<?php

$window = new Vrzno;

$window->a = 0;
$a =& $window->a;
$n = PHP_EOL;

function clog($m) {
    clog('' . $m . '');
}

// Now to test some manipulation
$a++;

printf("a: %d" . $n, $window->a); // 0
printf("a: %d" . $n, $a); // 1
clog('"a", window.a'); // 0
clog('"a", '.$a);   // 1

$window->a++;

printf("a: %d" . $n, $window->a); // 1
printf("a: %d" . $n, $a); // 1
clog('"a", window.a'); // 1
clog('"a", '.$a);   // 1

$window->b = 0;
$b = $window->b;

// Without reference
$b++;

printf("b: %d" . $n, $window->b); // 0
printf("b: %d" . $n, $b); // 1
clog('"b", window.b'); // 0
clog('"b", '.$b);   // 1

$window->b++;

printf("b: %d" . $n, $window->b); // 1
printf("b: %d" . $n, $b); // 1
clog('"b", window.b'); // 1
clog('"b", '.$b);   // 1

// Object reference
$ob = new StdClass();

$window->c = $ob;
$ob->a = 0;
$c =& $ob->a;

$c++;

printf("c: %d" . $n, $ob->a); // 1
printf("c: %d" . $n, $c); // 1
clog('"c", window.c'); // ?? Proxy
clog('"c", window.c.a'); // ?? undefined
clog('"c", '.$c);   // 1

$ob->a++;

printf("c: %d" . $n, $ob->a); // 2
printf("c: %d" . $n, $c); // 2
clog('"c", window.c'); // ?? Proxy
clog('"c", window.c.a'); // ?? undefined
clog('"c", '.$c);   // 2

// Other way around
$obd = new StdClass();
$d = 0;

$window->d = $obd;
$obd->a = &$d;

$d++;

printf("d: %d" . $n, $obd->a); // 1
printf("d: %d" . $n, $d); // 1
clog('"d", window.d'); // ?? Proxy
clog('"d", window.d.a'); // ?? undefined
clog('"d", '.$d);   // 1

$obd->a++;

printf("d: %d" . $n, $obd->a); // 2
printf("d: %d" . $n, $d); // 2
clog('"d", window.d'); // ?? Proxy
clog('"d", window.d.a'); // ?? undefined
clog('"d", '.$d);   // 2

// Passing by ref to window does not work.
$e = 0;
$window->e =& $e; // "Cannot assign by reference to overloaded object in php-wasm"
