"use strict";

// import { process } from 'process/browser';

self.addEventListener('install', event => {
	console.log('Install');
	self.skipWaiting();
});

self.addEventListener('activate', event => {
	console.log('Activate');
	event.waitUntil(clients.claim());
});

self.addEventListener('fetch', event => event.respondWith(new Promise(accept => {
	const url      = new URL(event.request.url);
	const pathname = url.pathname.replace(/^\//, '');
	const path     = pathname.split('/');
	const _path    = path.slice(0);

	if(_path[0] === 'php-wasm')
	{
		_path.shift();
	}

	// while(_path[ _path.length-1 ] === '')
	// {
	// 	_path.pop();
	// }

	if(!_path[ _path.length-1 ].match(/\.\w+$/) && _path[1] === 'drupal-7.95')
	{
		const getClient = self.clients.matchAll({
			includeUncontrolled:true
		});

		const getPost = event.request.method !== 'POST'
			? Promise.resolve()
			: event.request.formData();

		return Promise.all([getClient,getPost]).then(([clients, post]) => {
			clients.forEach(client => {
				client.postMessage({
					method:  event.request.method
					, path:  '/' + path.join('/')
					, _GET:  url.search
					, _POST: event.request.method === 'POST' ? ('?' + String(new URLSearchParams(post))) : ''
				});
			});

			accept(new Response('Loopback Request...'));
		});
	}
	else
	{
		accept(fetch(event.request));
	}
})));

self.addEventListener('message', event => {
});


self.addEventListener('push', event => {
	console.log(event);
});
