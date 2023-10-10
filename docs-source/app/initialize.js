"use strict";

import { PhpWebDrupal as PHP } from 'php-wasm/PhpWebDrupal';

window.PHP = PHP;
const php  = new PHP;

let session_id = '';

const serviceWorker = navigator.serviceWorker;

if(serviceWorker)
{
	serviceWorker.register(`${location.pathname}DrupalWorker.js`);
	// .then(result => console.log('Result, ', result))
	// .catch(error => console.log('Error, ', error));
}

document.addEventListener('DOMContentLoaded', () => {
	const input  = document.querySelector('.input  textarea');
	const stdout = document.querySelector('.stdout > * > div.scroller');
	const stderr = document.querySelector('.stderr > * > div.scroller');
	const stdret = document.querySelector('.stdret > * > div.scroller');
	const run    = document.querySelector('[data-run]');
	const token  = document.querySelector('[data-tokenize]');
	const status = document.querySelector('[data-status]');
	const load   = document.querySelector('[data-load-demo]')
	const demo   = document.querySelector('[data-select-demo]')
	const editor = ace.edit(input);
	const ret    = document.querySelector('#ret');

	const stdoutFrame = document.querySelector('.stdout > * > iframe');
	const stderrFrame = document.querySelector('.stderr > * > iframe');
	const stdretFrame = document.querySelector('.stdret > * > iframe');
	const openFile    = document.getElementById('openFile');
	const exitBox     = document.querySelector('#exit')
	const exitLabel   = exitBox.querySelector('span');
	const persistBox  = document.getElementById('persist');
	const singleBox   = document.getElementById('singleExpression');
	const autorun     = document.querySelector('#autorun');

	const renderAs    = Array.from(document.querySelectorAll('[name=render-as]'));

	openFile.addEventListener('input', event => {

		event.target.files[0].text().then(str => editor.setValue(str));

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

		if(code.length < 1024 * 2)
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
				php.refresh();
			}
		});
	};

	load.addEventListener('click', event => {
		if(!demo.value)
		{
			return;
		}
		fetch(`/php-wasm/scripts/${demo.value}`)
		.then(r => r.text())
		.then(php => {

			const firstLine = String(php.split(/\n/).shift());
			const settings  = JSON.parse(firstLine.split('//').pop());

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

			editor.getSession().setValue(php);

			setTimeout(() => runCode(), 100);
		});
	});

	const query = new URLSearchParams(location.search);

	editor.setTheme('ace/theme/monokai');
	editor.session.setMode("ace/mode/php");

	status.innerText = 'php-wasm loading...';

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
ini_set('session.save_path', '/home/web_user');

$stdErr = fopen('php://stderr', 'w');
$errors = [];

fwrite($stdErr, isset($_SESSION) && json_encode(['session' => $_SESSION]) . "\n");

register_shutdown_function(function() use($stdErr){
	fwrite($stdErr, json_encode(['session_id' => session_id()]) . "\n");
	fwrite($stdErr, json_encode(['headers'=>headers_list()]) . "\n");
	fwrite($stdErr, json_encode(['errors' => error_get_last()]) . "\n");
	fwrite($stdErr, json_encode(['session' => $_SESSION]) . "\n");
});

set_error_handler(function(...$args) use($stdErr, &$errors){
	fwrite($stdErr, json_encode($args, JSON_PRETTY_PRINT) . "\n" );
});

$request = (object) json_decode(
	'${ JSON.stringify({path, method, _GET, _POST}) }'
	, JSON_OBJECT_AS_ARRAY
);

parse_str(substr($request->_GET, 1), $_GET);

$_POST = $request->_POST;

$origin  = 'http://localhost:3333';
$docroot = '/preload/drupal-7.59';
$script  = 'index.php';

$path = $request->path;
$path = preg_replace('/^\\/php-wasm/', '', $path);

$_SERVER['SERVER_SOFTWARE'] = ${JSON.stringify(navigator.userAgent)};
$_SERVER['REQUEST_URI']     = $path;
$_SERVER['REMOTE_ADDR']     = '127.0.0.1';
$_SERVER['SERVER_NAME']     = $origin;
$_SERVER['SERVER_PORT']     = 3333;
$_SERVER['REQUEST_METHOD']  = $request->method;
$_SERVER['SCRIPT_FILENAME'] = $docroot . '/' . $script;
$_SERVER['SCRIPT_NAME']     = $docroot . '/' . $script;
$_SERVER['PHP_SELF']        = $docroot . '/' . $script;
$_SERVER['DOCUMENT_ROOT']   = '/';
$_SERVER['HTTPS']           = '';

chdir($docroot);

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
$itemPath = preg_replace('/^\\//', '', $itemPath);

if($itemPath && (substr($itemPath, 0, 4) !== 'node' || substr($itemPath, -4) === 'edit'))
{
    $router_item = menu_get_item($itemPath);
    $router_item['access_callback'] = true;
    $router_item['access'] = true;

    if ($router_item['include_file']) {
      require_once DRUPAL_ROOT . '/' . $router_item['include_file'];
    }

    $page_callback_result = call_user_func_array(
    	$router_item['page_callback']
    	, is_string($router_item['page_arguments'])
    		? unserialize($router_item['page_arguments'])
    		: $router_item['page_arguments']
    );

    drupal_deliver_page($page_callback_result);
}
else
{
    menu_execute_active_handler();
}`;

		php.run(code).then(exitCode => {
			exitLabel.innerText = exitCode;
			status.innerText = 'php-wasm ready!';
		}).finally(
			() => {
				if(!persistBox.checked)
				{
					php.refresh();
				}
			}
		);
	};

	php.addEventListener('ready', event => {

		if(serviceWorker)
		{
			serviceWorker.addEventListener('message', event => navigate(event.data));
		}

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

		if(query.get('autorun'))
		{
			runCode();
		}
	});

	const outputBuffer = [];

	php.addEventListener('output', (event) => {
		const row = document.createElement('div');
		const content = event.detail.join('');

		outputBuffer.push(content);

		setTimeout(()=>{
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

			while(outputBuffer.pop()){};
		}, 500);

	});

	const errorBuffer = [];

	php.addEventListener('error', (event) => {
		const content = event.detail.join(" ");
		try{
			const headers = JSON.parse(content);

			if(headers.session_id)
			{
				session_id = headers.session_id;
			}

			if(headers.headers)
			{
				for(const header of headers.headers)
				{
					const splitAt = header.indexOf(':')
					const [name, value] = [
						header.substring(0,splitAt)
						, header.substring(splitAt + 2)
					];

					if(name === 'Location')
					{
						console.log(value);

						const redirectUrl = new URL(value);

						setTimeout(()=>navigate({
							method: 'GET'
							, path: redirectUrl.pathname
							, _GET:''
							, _POST:{}
						}), 2000);
					}
				}
			}
		}
		catch(error)
		{
		}

		for(const line of content)
		{
			errorBuffer.push(line);

			setTimeout(()=>{
				const chunk = errorBuffer.join('');

				if(!errorBuffer || !chunk)
				{
					return;
				}

				const node = document.createTextNode(chunk);

				stderr.append(node);
				stderrFrame.srcdoc += chunk;

				while(errorBuffer.pop()){};
			}, 500);
		}

	});

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
