<?php // {"autorun":true, "persist":true, "single-expression": false, "render-as": "text"}

$setup = $setup ?? false;
$x = $x ?? 0;

var_dump($x);

if(!$setup)
{
    $window = new Vrzno;

    $f = $window->phpFuncA = function() use(&$x, $window) {
        $window->alert('RAN A! ' . $x++);
    };
    
    $g = $window->phpFuncB = function() use(&$x, $window) {
        echo '$x is now ' . (++$x) . PHP_EOL;
    };
    
    $setup = true;
    
    echo "Initialized.\n";
}

$window->phpFuncA();
// $window->phpFuncB();

// vrzno_eval('window.phpFuncA()');
vrzno_eval('window.phpFuncB()');
