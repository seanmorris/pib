import { PhpCgi } from "./PhpCgi";

self.addEventListener('install', event => {
	console.log('Install');
	self.skipWaiting();
});

self.addEventListener('activate', event => {
	console.log('Activate');
	event.waitUntil(clients.claim());
});

let c = 0;

const php = new PhpCgi({ docroot: '/preload/drupal-7.95' });

self.addEventListener('fetch', event => event.respondWith(new Promise(accept => {

	const request  = event.request;
	const url      = new URL(request.url);
	const pathname = url.pathname.replace(/^\//, '');
	const path     = pathname.split('/');
	const _path    = path.slice(0);

	// if(self.location.hostname === url.hostname)
	if(self.location.hostname === url.hostname && (_path[0] === 'php-wasm' || _path[0] === 'preload'))
	{
		if(_path[0] === 'php-wasm')
		{
		}

		_path.shift();

		if(_path[0] === 'drupal-7.95')
		{
			_path.shift();
		}

		if(_path[0] === 'persist')
		{
			_path.shift();
			if(_path[0] === 'drupal-7.95')
			{
				_path.shift();
			}
		}

		let getPost = Promise.resolve();

		if(request.body)
		{
			getPost = new Promise(accept => {
				const reader = request.body.getReader();
				const postBody = [];

				const processBody = ({done, value}) => {

					console.log({done,value});

					if(value)
					{
						postBody.push([...value].map(x => String.fromCharCode(x)).join(''));
					}

					if(!done)
					{
						return reader.read().then(processBody);
					}

					console.log(postBody.join(''));
					accept(postBody.join(''));
				};

				return reader.read().then(processBody);
			});
		}

		return getPost.then(post => {
			return php.request({
				method: request.method
				, path: _path.join('/')
				, get: url.search ? url.search.substr(1) : ''
				, post: request.method === 'POST'
					? String(new URLSearchParams(post))
					: null
			});
		})
		.then((r) => accept(r));
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

self.addEventListener('message', event => {
});

self.addEventListener('push', event => {
	console.log(event);
});
