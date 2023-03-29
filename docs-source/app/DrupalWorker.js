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

	console.log(path);

	if(!path[ path.length-1 ].match(/\.\w+$/)
		&& (path[1] === 'drupal-7.59' || path[2] === 'drupal-7.59')
	){
		const getClient = self.clients.matchAll({
			includeUncontrolled:true
		});

		const getPost = event.request.method !== 'POST'
			? Promise.resolve()
			: event.request.formData().then((formData)=>{
				const post = {};

				for (var key of formData.keys()) {
					post[key] = formData.get(key);
				}

				return post;
			});

		return Promise.all([getClient,getPost]).then(([clients, post]) => {

			clients.forEach(client => {
				client.postMessage({
					method:  event.request.method
					, path:  '/' + pathname
					, _GET:  url.search
					, _POST: post || null
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
