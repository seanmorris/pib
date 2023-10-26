<?php // {"autorun":true, "persist":true, "single-expression": false, "render-as": "text"}
$import = vrzno_import('https://unpkg.com/pad@3.2.0/dist/pad.esm.js');

$import->then(function($imported){

    $pad = $imported->default;

    var_dump( $pad("test", 10) );

});
