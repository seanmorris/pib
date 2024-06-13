<?php // {"autorun":true, "persist":false, "single-expression": false, "render-as": "text"}

$x = [
	"id" => 1
];

var_dump(json_decode(json_encode($x)));
