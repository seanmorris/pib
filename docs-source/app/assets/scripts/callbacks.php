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

    $f = $window->phpFuncA = function() use(&$x, $window) {
        echo '$x is now ' . (++$x) . PHP_EOL;
    };

    $g = $window->phpFuncB = function() use(&$y, $window) {
		$window->alert('RAN phpFuncB! $y:' . ++$y);
    };

    $setup = true;

    echo "Initialized.\n";
}

$window->phpFuncA();
// $window->phpFuncB();

// vrzno_eval('window.phpFuncA()');
vrzno_eval('window.phpFuncB()');
