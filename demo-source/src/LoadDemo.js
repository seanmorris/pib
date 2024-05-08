import './Common.css';
import './LoadDemo.css';

import loader from './tail-spin.svg';

import initPhp from './init.php';

import { PhpWebDrupal } from './PhpWebDrupal'
import { useEffect, useState } from 'react';
import { onMessage, sendMessage } from './msg-bus';

const packages = {
	'drupal-7': {
		name:  'Drupal 7',
		file:  '/backups/drupal-7.95.zip',
		path:  'drupal-7.95',
		vHost: 'drupal',
		dir:   'drupal-7.95',
		entry: 'index.php',
	},
	'cakephp-5': {
		name:  'CakePHP 5',
		file:  '/backups/cakephp-5.zip',
		path:  'cakephp-5',
		vHost: 'cakephp-5',
		dir:   'cakephp-5/webroot',
		entry: 'index.php',
	},
	'codeigniter-4': {
		name:  'CodeIgniter 4',
		file:  '/backups/codeigniter-4.zip',
		path:  'codeigniter-4',
		vHost: 'codeigniter-4',
		dir:   'codeigniter-4/public',
		entry: 'index.php',
	},
	'laminas-3': {
		name:  'Laminas 3',
		file:  '/backups/laminas-3.zip',
		path:  'laminas-3',
		vHost: 'laminas-3',
		dir:   'laminas-3/public',
		entry: 'index.php',
	},
	'laravel-11': {
		name:  'Laravel 11',
		file:  '/backups/laravel-11.zip',
		path:  'laravel-11',
		vHost: 'laravel-11',
		dir:   'laravel-11/public',
		entry: 'index.php',
	},
};

const installDemo = async () => {

	const query = new URLSearchParams(window.location.search);

	console.log('!!!');

	if(!query.has('framework'))
	{
		window.dispatchEvent(
			new CustomEvent('install-status', {detail: 'No framework selected.'})
		);
		return;
	}

	console.log('!!!');

	const selectedFrameworkName = query.get('framework');

	if(!(selectedFrameworkName in packages))
	{
		window.dispatchEvent(
			new CustomEvent('install-status', {detail: 'Invalid framework selected.'})
		);
		return;
	}

	const selectedFramework = packages[selectedFrameworkName];

	const php = new PhpWebDrupal({persist: [{mountPath:'/persist'}, {mountPath:'/config'}]});

	php.addEventListener('output', event => console.log(event.detail));
	php.addEventListener('error', event => console.log(event.detail));

	await navigator.serviceWorker.register(`/cgi-worker.js`);

	await navigator.serviceWorker.getRegistration(`${window.location.origin}/cgo-worker.mjs`);
	const initPhpCode = await (await fetch(initPhp)).text();

	window.dispatchEvent(new CustomEvent('install-status', {detail: 'Downloading package...'}));
	const download = await fetch(selectedFramework.file);
	const zipContents = await download.arrayBuffer();

	const settings = await sendMessage('getSettings');
	const vHostPrefix = '/php-wasm/' + selectedFramework.vHost;
	const existingvHost = settings.vHosts.find(vHost => vHost.pathPrefix === vHostPrefix);

	if(!existingvHost)
	{
		settings.vHosts.push({
			pathPrefix: vHostPrefix,
			directory:  '/persist/' + selectedFramework.dir,
			entrypoint: selectedFramework.entry
		});
	}
	else
	{
		existingvHost.directory = '/persist/' + selectedFramework.dir;
		existingvHost.entrypoint = selectedFramework.entry;
	}

	console.log(settings);

	await sendMessage('setSettings', [settings]);
	await sendMessage('storeInit');

	window.dispatchEvent(new CustomEvent('install-status', {detail: 'Unpacking files...'}));

	await sendMessage('writeFile', ['/persist/restore.zip', new Uint8Array(zipContents)]);
	await sendMessage('writeFile', ['/config/restore-path.tmp', '/persist/' + selectedFramework.path]);
	console.log(await php.run(initPhpCode));

	window.dispatchEvent(new CustomEvent('install-status', {detail: 'Refreshing PHP...'}));
	await sendMessage('refresh', []);

	window.dispatchEvent(new CustomEvent('install-status', {detail: 'Done!'}));

	// window.demoInstalling = null;
};

const openDemo = () => {
	const query = new URLSearchParams(window.location.search);

	console.log('!!!');

	if(!query.has('framework'))
	{
		window.dispatchEvent(
			new CustomEvent('install-status', {detail: 'No framework selected.'})
		);
		return;
	}

	console.log('!!!');

	const selectedFrameworkName = query.get('framework');

	if(!(selectedFrameworkName in packages))
	{
		window.dispatchEvent(
			new CustomEvent('install-status', {detail: 'Invalid framework selected.'})
		);
		return;
	}

	const selectedFramework = packages[selectedFrameworkName];

	window.open('/php-wasm/' + selectedFramework.vHost)
}

function LoadDemo() {
	const [message, setMessage] = useState('Initializing installer...');

	const onStatus = event => setMessage(event.detail);

	useEffect(() => {
		navigator.serviceWorker.addEventListener('message', onMessage);
		window.addEventListener('install-status', onStatus);
		return () => {
			navigator.serviceWorker.removeEventListener('message', onMessage);
			window.removeEventListener('install-status', onStatus);
		}
	}, []);

	window.demoInstalling = window.demoInstalling || installDemo();

	return (
		<div className = "load-demo">
			<div className = "center">
				{ message !== 'Done!'
					? <img className = "loader-icon" src = {loader} />
					: ''
				}
				<div className = "bevel">
				<div className = "inset">{message}</div>
				{ message === 'Done!'
					? <div>
						<button className = "padded margined" onClick = {() => openDemo()}>Open Site</button>
						<button className = "padded margined" onClick = {() => window.location = '/code-editor'}>Edit Files</button>
					</div>
					: ''
				}
				</div>
			</div>
		</div>
	);
}

export default LoadDemo;
