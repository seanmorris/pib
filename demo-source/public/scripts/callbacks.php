<?php // {"autorun":true, "persist":true, "single-expression": false, "render-as": "text"}

##################################
#                                #
# Open your JS console and run:  #
#                                #
# > phpFuncA()                   #
# > phpFuncB()                   #
#                                #
##################################

$setup = $setup ?? false;

$x = $x ?? 0;
$y = $y ?? 0;

var_dump($x);

if(!$setup)
{
    $window = new Vrzno;

    $f = $window->phpFuncA = function() use(&$x, &$y, $window) {
        printf('RAN phpFuncA! $x: %d, $y: %d' . PHP_EOL, ++$x, $y);
		return $x;
    };

    $g = $window->phpFuncB = function() use(&$x, &$y, $window) {
		$window->alert(sprintf('RAN phpFuncB! $x: %d, $y: %d', $x, ++$y));
		return $y;
    };

    $setup = true;

    echo "Initialized.\n";
}

$window->phpFuncA();
// $window->phpFuncB();

// vrzno_eval('window.phpFuncA()');
vrzno_eval('window.phpFuncB()');
