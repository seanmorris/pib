<?php // {"autorun":true, "persist":true, "single-expression": false, "render-as": "text"}
$window = $window ?? new Vrzno;

$Promise = $window->Promise;

$promise = vrzno_new($Promise, function($accept, $reject) {

    $window = new Vrzno;

    if(1)
    {
        $accept('Something.');
        // $window->setTimeout(
        //     fn() => $accept('Something.'),
        //     1000
        // );
    }
    else
    {
        $window->setTimeout(
            fn() => $reject('Error.'),
            1000
        );
    }

});

$promise->then(var_dump(...))->catch(var_dump(...));
