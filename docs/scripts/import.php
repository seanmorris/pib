<?php // {"autorun":true, "persist":true, "single-expression": false, "render-as": "text"}

$window = new Vrzno;
$import = vrzno_import('https://cdn.jsdelivr.net/npm/@observablehq/plot@0.6/+esm');
$Plot = vrzno_await($import);

$brands = [
	["name" => "Apple", "value" => 214480],
	["name" => "Google", "value" => 155506],
	["name" => "Amazon", "value" => 100764],
	["name" => "Microsoft", "value" => 92715],
	["name" => "Coca-Cola", "value" => 66341],
	["name" => "Samsung", "value" => 59890],
	["name" => "Toyota", "value" => 53404],
	["name" => "Mercedes-Benz", "value" => 48601],
	["name" => "Facebook", "value" => 45168],
	["name" => "McDonald's", "value" => 43417],
	["name" => "Intel", "value" => 43293],
];

$plot = $Plot->barY($brands, (object)[
	'x' => 'name',
	'y' => 'value',
	'sort' => (object)['x' => 'y', 'reverse' => true, 'limit' => 10],
	'fill' => 'steelblue',
])->plot();

$renderTo = $window->document->body->querySelector('#example');
$renderTo->innerHTML = '';

$renderTo->append($plot);
