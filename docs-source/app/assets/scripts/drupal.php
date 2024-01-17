<?php // {"autorun":true, "persist":false, "single-expression": false, "render-as": "html"}
ini_set('session.save_path', '/persist');

$stdErr = fopen('php://stderr', 'w');
$errors = [];

set_error_handler(function(...$args) use($stdErr, &$errors){
	fwrite($stdErr, print_r($args,1));
});

$docroot = '/persist/drupal-7.95';
$path    = '/node';
$script  = 'index.php';

if(!is_dir($docroot))
{
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator("/preload/drupal-7.95/", FilesystemIterator::SKIP_DOTS));
    foreach ($it as $name => $entry)
    {
        if(is_dir($name)) continue;
        $fromDir = dirname($name);
        $toDir  = '/persist' . substr($fromDir, 8);
        $filename = basename($name);
    	$pDirs = [$pDir = $toDir];
    	while($pDir !== dirname($pDir)) $pDirs[] = $pDir = dirname($pDir);
    	$pDirs = array_reverse($pDirs);
    	foreach($pDirs as $pDir) if(!is_dir($pDir)) mkdir($pDir, 0777);
    	file_put_contents($toDir  . '/' . $filename, file_get_contents($fromDir . '/' . $filename));
    }
}

$_SERVER['REQUEST_URI']     = $path;
$_SERVER['REMOTE_ADDR']     = '127.0.0.1';
$_SERVER['SERVER_NAME']     = 'localhost';
$_SERVER['SERVER_PORT']     = 3333;
$_SERVER['REQUEST_METHOD']  = 'GET';
$_SERVER['SCRIPT_FILENAME'] = $docroot . '/' . $script;
$_SERVER['SCRIPT_NAME']     = $docroot . '/' . $script;
$_SERVER['PHP_SELF']        = $docroot . '/' . $script;

chdir($docroot);

if(!defined('DRUPAL_ROOT')) define('DRUPAL_ROOT', getcwd());

require_once DRUPAL_ROOT . '/includes/bootstrap.inc';
drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
drupal_session_start();

fwrite($stdErr, json_encode(['session_id' => session_id()]) . "\n");

global $user;

$uid     = 1;
$user    = user_load($uid);
$account = array('uid' => $user->uid);
$session_name = session_name();

if(!$_COOKIE || !$_COOKIE[$$session_name])
{
	user_login_submit(array(), $account);
}

$itemPath = $path;
$itemPath = preg_replace('/^\\/persist/', '', $itemPath);
$itemPath = preg_replace('/^\\/drupal-7.95/', '', $itemPath);
$itemPath = preg_replace('/^\//', '', $itemPath);

$GLOBALS['base_path'] = '/php-wasm' . $docroot . '/';
$base_url = '/php-wasm' . $docroot;;

$_GET['q'] = $itemPath;

menu_execute_active_handler();

fwrite($stdErr, json_encode(['HEADERS' =>headers_list()]) . "\n");
fwrite($stdErr, json_encode(['COOKIE'  => $_COOKIE]) . PHP_EOL);
fwrite($stdErr, json_encode(['errors'  => error_get_last()]) . "\n");
