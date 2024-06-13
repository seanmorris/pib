<?php // {"autorun":true, "persist":false, "single-expression": false, "render-as": "text"}

$oldTitle = NULL;
$newTitle = 'Changed@' . date('h:i:s');

// Grab the current title
$oldTitle = vrzno_eval('document.title');

// Change the document title
$newTitle = vrzno_eval('document.title = "' . $newTitle . '"' );

printf(
	'Title changed from "%s" to "%s".'
	, $oldTitle
	, $newTitle
);


// Show an alert
vrzno_run('alert', ['Hello, World!']);
