<?php // {"autorun":true, "persist":false, "single-expression": false, "render-as": "html"}

chdir('/');

$it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator("."));

foreach ($it as $name => $entry) {
	echo $name . "<br/>";
}
