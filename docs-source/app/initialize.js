"use strict";

import { PhpWebDrupal as PHP } from 'php-wasm/PhpWebDrupal';

let php = new PHP;

let session_id = '';

const serviceWorker = navigator.serviceWorker;

if(serviceWorker && !serviceWorker.controller)
{
	serviceWorker.register(`${location.pathname}DrupalWorker.js`);
	// .catch(error => console.log('Error, ', error));
}

document.addEventListener('DOMContentLoaded', () => {
	const input   = document.querySelector('.input  textarea');
	const stdout  = document.querySelector('.stdout > * > div.scroller');
	const stderr  = document.querySelector('.stderr > * > div.scroller');
	const stdret  = document.querySelector('.stdret > * > div.scroller');
	const run     = document.querySelector('[data-run]');
	const reset   = document.querySelector('[data-reset-storage]');
	const refresh = document.querySelector('[data-refresh]');
	const token   = document.querySelector('[data-tokenize]');
	const status  = document.querySelector('[data-status]');
	const load    = document.querySelector('[data-load-demo]');
	const demo    = document.querySelector('[data-select-demo]');
	const editor  = ace.edit(input);
	const ret     = document.querySelector('#ret');

	const stdoutFrame = document.querySelector('.stdout > * > iframe');
	const stderrFrame = document.querySelector('.stderr > * > iframe');
	const stdretFrame = document.querySelector('.stdret > * > iframe');
	const openFile    = document.getElementById('openFile');
	const exitBox     = document.querySelector('#exit');
	const exitLabel   = exitBox.querySelector('span');
	const persistBox  = document.getElementById('persist');
	const singleBox   = document.getElementById('singleExpression');
	const autorun     = document.querySelector('#autorun');

	const renderAs    = Array.from(document.querySelectorAll('[name=render-as]'));

	const outputBuffer = [];
	const errorBuffer = [];
	let outputTimer;
	let errorTimer;

	reset.addEventListener('click', event => {

		const openDb = indexedDB.open("/persist", 21);


		openDb.onsuccess = event => {
			const db = openDb.result;
			const transaction = db.transaction(["FILE_DATA"], "readwrite");
			const objectStore = transaction.objectStore("FILE_DATA");
			const objectStoreRequest = objectStore.clear();

			objectStoreRequest.onsuccess = (event) => {
				location.reload();
			};
		};
	});

	openFile.addEventListener('input', event =>{

		const reader = new FileReader();

		reader.onload = (event) => {
			editor.setValue(event.target.result);
		};

		reader.readAsText(event.target.files[0]);

	});

	const runCode = () => {

		exitLabel.innerText = '_';

		status.innerText = 'Executing...';

		stdoutFrame.srcdoc = ' ';
		stderrFrame.srcdoc = ' ';
		stdretFrame.srcdoc = ' ';

		while(stdout.firstChild)
		{
			stdout.firstChild.remove();
		}

		while(stderr.firstChild)
		{
			stderr.firstChild.remove();
		}

		while(stdret.firstChild)
		{
			stdret.firstChild.remove();
		}

		let code = editor.session.getValue();

		if(1 || code.length < 1024 * 2)
		{
			query.set('autorun', autorun.checked ? 1 : 0);
			query.set('persist', persistBox.checked ? 1 : 0);
			query.set('single-expression', singleBox.checked ? 1 : 0);
			query.set('code', encodeURIComponent(code));
			history.replaceState({}, document.title, "?" + query.toString());
		}

		const func = singleBox.checked
			? 'exec'
			: 'run';

		if(singleBox.checked)
		{
			code = code.replace(/^\s*<\?php/, '');
			code = code.replace(/\?>\s*/, '');
		}

		php[func](code).then(ret=>{

			status.innerText = 'php-wasm ready!';

			const content = String(ret);

			stdret.innerText = content;
			stdretFrame.srcdoc = content;

			exitLabel.innerText = '_';

			if(!singleBox.checked)
			{
				setTimeout(() => exitLabel.innerText = ret, 100);
			}
		}).finally(() => {
			if(!persistBox.checked)
			{
				refreshPhp();
				// php.refresh();
			}
		});
	};

	demo.addEventListener('change', event => {
		if(!demo.value)
		{
			return;
		}

		if(demo.value === 'drupal.php')
		{
			reset.style.display = '';
		}
		else
		{
			reset.style.display = 'none';
		}
	});

	load.addEventListener('click', event => {
		document.querySelector('#example').innerHTML = '';
		refreshPhp().then(() => {
			if(!demo.value)
			{
				return;
			}

			let scriptPath = '/php-wasm/scripts';

			if(window.location.hostname === 'localhost' || window.location.hostname.substr(0,4) === '192.')
			{
				scriptPath = '/scripts';
			}

			fetch(`${scriptPath}/${demo.value}`)
			.then(r => r.text())
			.then(phpCode => {

				const firstLine = String(phpCode.split(/\n/).shift());
				const settings  = JSON.parse(firstLine.split('//').pop());

				query.set('demo', demo.value);

				if('autorun' in settings)
				{
					autorun.checked = !!settings.autorun;
				}

				if('single-expression' in settings)
				{
					singleBox.checked = !!settings['single-expression'];
				}

				if('persist' in settings)
				{
					persistBox.checked = !!settings.persist;
				}

				if('render-as' in settings)
				{
					if(settings['render-as'] === 'text')
					{
						renderAs[0].checked = true;

						renderAs[0].dispatchEvent(new Event('change'));

						query.set('render-as', 'text');
					}
					else if(settings['render-as'] === 'html')
					{
						renderAs[1].checked = true;

						renderAs[1].dispatchEvent(new Event('change'));

						query.set('render-as', 'html');
					}
				}

				persistBox.dispatchEvent(new Event('change'));
				singleBox.dispatchEvent(new Event('input'));
				autorun.dispatchEvent(new Event('change'));

				history.replaceState({}, document.title, "?" + query.toString());

				editor.getSession().setValue(phpCode);

				refreshPhp(2).then(() => runCode());
			});
		});
	});

	const query = new URLSearchParams(location.search);

	editor.setTheme('ace/theme/monokai');
	editor.session.setMode("ace/mode/php");

	status.innerText = 'php-wasm loading...';

	const cookieJar = new Map;

	const navigate = ({path, method, _GET, _POST}) => {

		// console.trace({path, method, _GET, _POST});

		exitLabel.innerText = '_';

		status.innerText = 'Executing...';

		stdoutFrame.srcdoc = ' ';
		stderrFrame.srcdoc = ' ';
		stdretFrame.srcdoc = ' ';

		while(stdout.firstChild)
		{
			stdout.firstChild.remove();
		}

		while(stderr.firstChild)
		{
			stderr.firstChild.remove();
		}

		while(stdret.firstChild)
		{
			stdret.firstChild.remove();
		}

		const code = `<?php
ini_set('session.save_path', '/persist');
ini_set('display_errors', 0);

$stdErr = fopen('php://stderr', 'w');
$errors = [];

$request = (object) json_decode(
	'${ JSON.stringify({path, method, _GET, _POST, _COOKIE: Object.fromEntries(cookieJar.entries())}) }'
	, JSON_OBJECT_AS_ARRAY
);

parse_str(substr($request->_GET, 1), $_GET);
parse_str(substr($request->_POST, 1), $_POST);

$_COOKIE = $request->_COOKIE;

fwrite($stdErr, json_encode(['_GET' => $_GET]) . PHP_EOL);
fwrite($stdErr, json_encode(['_POST' => $_POST]) . PHP_EOL);

$docroot = '/persist/drupal-7.95/';
$script  = 'index.php';

$path = $request->path;
$path = preg_replace('/^\\/php-wasm/', '', $path);
$path = preg_replace('/^\\/persist/', '', $path);
$path = preg_replace('/^\\/drupal-7.95/', '', $path);
$path = preg_replace('/^\\//', '', $path);
$path = $path ?: "node";

$_SERVER['SERVER_SOFTWARE'] = ${JSON.stringify(navigator.userAgent)};
$_SERVER['REQUEST_URI']     = $docroot . $path;
$_SERVER['QUERY_STRING']    = $request->_GET;
$_SERVER['REMOTE_ADDR']     = '127.0.0.1';
$_SERVER['SERVER_NAME']     = 'localhost';
$_SERVER['SERVER_PORT']     = 3333;
$_SERVER['REQUEST_METHOD']  = $request->method;
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
if(!$_COOKIE || !$_COOKIE[$session_name])
{
	user_login_submit(array(), $account);
}

fwrite($stdErr, json_encode(['PATH' => $path, "ORIGINAL" => $request->path]) . PHP_EOL);

$GLOBALS['base_path'] = '/php-wasm' . $docroot . '/';

$_GET['q'] = $itemPath;

menu_execute_active_handler();

fwrite($stdErr, json_encode(['HEADERS' =>headers_list()]) . "\n");
fwrite($stdErr, json_encode(['COOKIE'  => $_COOKIE]) . PHP_EOL);
fwrite($stdErr, json_encode(['errors'  => error_get_last()]) . "\n");
`;

		refreshPhp()
		.then(() => php.run(code))
		.then(exitCode => {
			exitLabel.innerText = exitCode;
			status.innerText = 'php-wasm ready!';
		})
		.catch(error => console.error(error))
		.finally(() => refreshPhp());
	};

	let _init = true;

	const ready = event => {

		status.innerText = 'php-wasm ready!';

		run.removeAttribute('disabled');

		token && token.addEventListener('click', () => {

			const url     = '/drupal-7.59/install.php';
			const options = {method: 'GET'};

			fetch(url, options).then(r=> r.text()).then(r => {
				console.log('Done');
			});

		});

		run.addEventListener('click', runCode);

		// refresh.addEventListener('click', () => void php.refresh());

		if(_init && _init !== 2 && query.get('autorun'))
		{
			runCode();
		}
	};

	const output = event => {
		const content = event.detail.join('');

		outputBuffer.push(content);

		if(outputTimer)
		{
			clearTimeout(outputTimer);
			outputTimer = null;
		}

		outputTimer = setTimeout(()=>{
			let chunk = outputBuffer.join('');

			if(!outputBuffer || !chunk)
			{
				return;
			}

			if(location.hostname.match(/github.io$/))
			{
				chunk = chunk.replace(/\/preload/g, '/php-wasm/preload');
			}

			const node = document.createTextNode(chunk);

			stdout.append(node);
			stdoutFrame.srcdoc += chunk;

			outputBuffer.splice(0);
		}, 50);

	};

	const error = event => {
		const content = event.detail.join('');

		try{
			const packet = JSON.parse(content);

			if(packet.HEADERS)
			{
				const raw = packet.HEADERS;
				const headers = {};

				for(let line of raw)
				{
					line = String(line);
					const colon = line.indexOf(':');

					if(colon >= 0)
					{
						headers[ line.substr(0, colon) ] = line.substr(2 + colon);
					}
					else
					{
						headers[ line ] = true;
					}
				}

				if((headers[302] || headers[303]) && headers.Location)
				{
					const redirectUrl = headers.Location;
					const _GET = redirectUrl.search;

					navigate({
						method: 'GET'
						, path: redirectUrl.pathname
						, _GET: ''
						, _POST:''
					});
				}

				if(headers['Set-Cookie'])
				{
					const raw = headers['Set-Cookie'];
					const semi  = raw.indexOf(';');
					const equal = raw.indexOf('=');
					const key   = raw.substr(0, equal);
					const value = raw.substr(equal, semi - equal);

					cookieJar.set(key, value);
				}

				// if(headers.headers)
				// {
				// 	for(const header of headers.headers)
				// 	{
				// 		const splitAt = header.indexOf(':')
				// 		const [name, value] = [
				// 			header.substring(0,splitAt)
				// 			, header.substring(splitAt + 2)
				// 		];
				// 	}
				// }
			}

		}
		catch(error)
		{
			console.error(error);
		}

		errorBuffer.push(content);

		if(errorTimer)
		{
			clearTimeout(errorTimer);
			errorTimer = null;
		}

		errorTimer = setTimeout(()=>{
			errorTimer = null;
			const chunk = errorBuffer.join('');

			if(!errorBuffer || !chunk)
			{
				return;
			}

			const node = document.createTextNode(chunk);

			stderr.append(node);
			stderrFrame.srcdoc += chunk;

			errorBuffer.splice(0);
		}, 50);

	};

	const onNavigate = event => navigate(event.data);

	const refreshPhp = (init = false) => {

		_init = init;

		if(init)
		{
			if(php)
			{
				php.removeEventListener('ready', ready);
				php.removeEventListener('output', output);
				php.removeEventListener('error', error);

				if(serviceWorker)
				{
					serviceWorker.removeEventListener('message', onNavigate);
				}
			}

			php = new PHP;

			php.addEventListener('ready', ready);
			php.addEventListener('output', output);
			php.addEventListener('error', error);

			if(serviceWorker)
			{
				serviceWorker.addEventListener('message', onNavigate);
			}
		}
		else
		{
			return php.refresh();
		}

		return php.binary;
	};

	refreshPhp(true);

	ret.style.display = 'none';

	singleBox.addEventListener('input', event=>{
		if(event.target.checked)
		{
			exitBox.style.display = 'none';
			ret.style.display = 'flex';
		}
		else
		{
			exitBox.style.display = 'flex';
			ret.style.display = 'none';
		}
	});

	exitLabel.innerText = '_';

	if(query.has('code'))
	{
		editor.setValue(decodeURIComponent(query.get('code')));
	}

	if(query.has('render-as'))
	{
		document.querySelector(`[name=render-as][value=${query.get('render-as')}]`).checked = true;
	}

	autorun.checked    = Number(query.get('autorun'));
	persistBox.checked = Number(query.get('persist'));
	singleBox.checked  = Number(query.get('single-expression'));
	demo.value = String(query.get('demo'));

	if(demo.value !== 'drupal.php')
	{
		reset.style.display = 'none';
	}

	if(singleBox.checked)
	{
		exitBox.style.display = 'none';
		ret.style.display = 'flex';
	}
	else
	{
		exitBox.style.display = 'flex';
		ret.style.display = 'none';
	}

	setTimeout(() => editor.selection.moveCursorFileStart(), 150);

	renderAs.map(radio => {

		if(query.get('render-as') === 'html')
		{

			stdout.style.display = 'none';
			stdoutFrame.style.display = 'flex';

			stderr.style.display = 'none';
			stderrFrame.style.display = 'flex';

			stdret.style.display = 'none';
			stdretFrame.style.display = 'flex';
		}
		else
		{
			stdout.style.display = 'flex';
			stdoutFrame.style.display = 'none';

			stderr.style.display = 'flex';
			stderrFrame.style.display = 'none';

			stdret.style.display = 'flex';
			stdretFrame.style.display = 'none';
		}

		radio.addEventListener('change', event => {

			const type = event.target.value;

			query.set('render-as', type);
			history.replaceState({}, document.title, "?" + query.toString());

			if(type === 'html')
			{

				stdout.style.display = 'none';
				stdoutFrame.style.display = 'flex';

				stderr.style.display = 'none';
				stderrFrame.style.display = 'flex';

				stdret.style.display = 'none';
				stdretFrame.style.display = 'flex';
			}
			else
			{
				stdout.style.display = 'flex';
				stdoutFrame.style.display = 'none';

				stderr.style.display = 'flex';
				stderrFrame.style.display = 'none';

				stdret.style.display = 'flex';
				stdretFrame.style.display = 'none';
			}

		});
	});

});

