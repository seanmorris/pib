import { PhpCgi } from "./PhpCgi";
import { Request } from "./PhpCgi";

const php = new PhpCgi({ docroot: '/persist/drupal-7.95', rewrite: path => {
	const _path = path.split('/');

	_path.shift();

	if(_path[0] === 'php-wasm')
	{
		_path.shift();
	}

	if(_path[0] === 'drupal')
	{
		_path.shift();
	}

	if(_path[0] === 'drupal-7.95')
	{
		_path.shift();
	}

	return _path.join('/');
} });

self.addEventListener('install', event => {
	console.log('Install');
	self.skipWaiting();
});

self.addEventListener('activate', event => {
	console.log('Activate');
	event.waitUntil(clients.claim());
});

self.addEventListener('fetch', event => event.respondWith(new Promise(accept => {
	const request  = event.request;
	const url      = new URL(request.url);
	const pathname = url.pathname.replace(/^\//, '');
	const path     = pathname.split('/');
	const _path    = path.slice(0);

	if(self.location.hostname === url.hostname && ((_path[0] === 'php-wasm' && _path[1] === 'drupal') || _path[0] === 'persist'))
	{
		let getPost = Promise.resolve();

		if(request.body)
		{
			getPost = new Promise(accept => {
				const reader = request.body.getReader();
				const postBody = [];

				const processBody = ({done, value}) => {

					if(value)
					{
						postBody.push([...value].map(x => String.fromCharCode(x)).join(''));
					}

					if(!done)
					{
						return reader.read().then(processBody);
					}

					accept(postBody.join(''));
				};

				return reader.read().then(processBody);
			});
		}

		return getPost.then(post => php.enqueue({
			url
			, method: request.method
			, path: pathname
			, get: url.search ? url.search.substr(1) : ''
			, post: request.method === 'POST' ? post : null
			, contentType: request.method === 'POST'
				? (request.headers.get('Content-Type') ?? 'application/x-www-form-urlencoded')
				: null
		}))
		.then(accept);
	}

	if(_path[0] === 'php-wasm')
	{
		_path.shift();
	}

	if(_path.length && !_path[ _path.length-1 ].match(/\.\w+$/) && _path[1] === 'drupal-7.95')
	{
		const getPost = request.method !== 'POST' ? Promise.resolve() : request.formData();

		return getPost.then(post => {
			accept(new Response(`<script>window.parent.postMessage({
				action: 'respond'
				, method:  '${request.method}'
				, path:  '${'/' + path.join('/')}'
				, _GET:  '${url.search}'
				, _POST: '${request.method === 'POST'
					? ('?' + String(new URLSearchParams(post)))
					: ''
				}'
			});</script>`, {
				headers: {'Content-Type': 'text/html'}
			}));
		});
	}
	else
	{
		accept(fetch(request));
	}
})));

self.addEventListener('message', async event => {
	const { data, source } = event;
	const { action, token, params = [] } = data;

	switch(action)
	{
		case 'readdir':
			source.postMessage({re: token, result: await php.readdir(...params)});
		break;

		case 'mkdir':
			source.postMessage({re: token, result: await php.mkdir(...params)});
		break;

		case 'readFile':
			source.postMessage({re: token, result: await php.readFile(...params)});
		break;

		case 'writeFile':
			source.postMessage({re: token, result: await php.writeFile(...params)});
		break;
	}
});

self.addEventListener('push', event => {
	console.log(event);
});
