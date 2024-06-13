<?php // {"autorun":true, "persist":true, "single-expression": true, "render-as": "text"}

// run this over and over again
$c = 1 + ($c ?? -1);

print $c;
