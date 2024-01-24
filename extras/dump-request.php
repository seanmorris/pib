<?php var_export((object)[
	'method' => $_SERVER['REQUEST_METHOD']
	, 'request_uri' => $_SERVER['REQUEST_URI']
	, '_GET' => $_GET
	, '_POST' => $_POST
	, '_COOKIE' => $_COOKIE
	, '_SERVER' => $_SERVER
	, '_REQUEST' => $_REQUEST
]);
