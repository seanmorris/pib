<?php // {"autorun":true, "persist":false, "single-expression": false, "render-as": "html"}
ini_set('session.save_path', '/home/web_user');

$stdErr = fopen('php://stderr', 'w');
$errors = [];

register_shutdown_function(function() use($stdErr, &$errors){
	fwrite($stdErr, json_encode(['session_id' => session_id()]) . "\n");
	fwrite($stdErr, json_encode(['headers'=>headers_list()]) . "\n");
	fwrite($stdErr, json_encode(['errors' => error_get_last()]) . "\n");
});

set_error_handler(function(...$args) use($stdErr, &$errors){
	fwrite($stdErr, print_r($args,1));
});

$docroot = '/preload/drupal-7.95';
$path    = '/';
$script  = 'index.php';

$_SERVER['REQUEST_URI']     = $docroot . $path;
$_SERVER['REMOTE_ADDR']     = '127.0.0.1';
$_SERVER['SERVER_NAME']     = 'localhost';
$_SERVER['SERVER_PORT']     = 3333;
$_SERVER['REQUEST_METHOD']  = 'GET';
$_SERVER['SCRIPT_FILENAME'] = $docroot . '/' . $script;
$_SERVER['SCRIPT_NAME']     = $docroot . '/' . $script;
$_SERVER['PHP_SELF']        = $docroot . '/' . $script;

chdir($docroot);

ob_start();

define('DRUPAL_ROOT', getcwd());

require_once DRUPAL_ROOT . '/includes/bootstrap.inc';
drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);

$uid     = 1;
$user    = user_load($uid);
$account = array('uid' => $user->uid);
user_login_submit(array(), $account);

$itemPath = $path;
$itemPath = preg_replace('/^\\/preload/', '', $itemPath);
$itemPath = preg_replace('/^\\/drupal-7.59/', '', $itemPath);
$itemPath = preg_replace('/^\//', '', $itemPath);

if($itemPath)
{

	$router_item = menu_get_item($itemPath);
	$router_item['access_callback'] = true;
	$router_item['access'] = true;

	if ($router_item['include_file']) {
	  require_once DRUPAL_ROOT . '/' . $router_item['include_file'];
	}

	$page_callback_result = call_user_func_array($router_item['page_callback'], unserialize($router_item['page_arguments']));

	drupal_deliver_page($page_callback_result);
}
else
{
	menu_execute_active_handler();
}
