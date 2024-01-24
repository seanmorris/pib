// import PHP from 'php-wasm/php-cgi';

// const input = [];

// const request = (p, {filename, method = 'GET', url = '', get, post, cookie}) => {

// 	const toQueryString = obj => obj ? String(new URLSearchParams(obj)).toString() : '';

// 	const putEnv = (key, value) => p.ccall(
// 		'wasm_sapi_cgi_putenv'
// 		, 'number'
// 		, ['string', 'string']
// 		, [key, String(value)]
// 	);

// 	input.splice(0);

// 	if(method === 'POST')
// 	{
// 		input.push(...(toQueryString(post)).split(''));
// 	}

// 	putEnv('PHP_FCGI_MAX_REQUESTS', 1);

// 	putEnv('SERVER_SOFTWARE', navigator.userAgent);
// 	putEnv('REQUEST_METHOD', method);
// 	putEnv('REQUEST_URI', url);
// 	putEnv('SCRIPT_FILENAME', filename);
// 	putEnv('PATH_TRANSLATED', filename);
// 	putEnv('QUERY_STRING', toQueryString(get));
// 	putEnv('HTTP_COOKIE', toQueryString(cookie));
// 	putEnv('REDIRECT_STATUS', '200');
// 	putEnv('CONTENT_TYPE', 'application/x-www-form-urlencoded');
// 	putEnv('CONTENT_LENGTH', input.length);

// 	return p._main();
// };

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

self.addEventListener('fetch', event => event.respondWith(new Promise(accept => {

	// const php = new PHP({ stdin: () => input ? String(input.shift()).charCodeAt(0) : null });

	// php.then(p => {

	// 	p.ccall('wasm_sapi_cgi_init', 'number', [], []);

	// 	console.log(++c, request(p, {
	// 		filename: '/preload/dump-request.php'
	// 		, method: 'POST'
	// 		, url:    '/index'
	// 		, get:    { hello: 'world' }
	// 		, post:   { field: 'this is post data' }
	// 		, cookie: { cookie: 'chocolate chip' }
	// 	}));
	// });

	const php = new PhpCgi;

	console.log(++c, php.request({
		filename: '/preload/dump-request.php'
		, method: 'POST'
		, url:    '/index'
		, get:    { hello: 'world' }
		, post:   { field: 'this is post data' }
		, cookie: { cookie: 'chocolate chip' }
	}));

	const url      = new URL(event.request.url);
	const pathname = url.pathname.replace(/^\//, '');
	const path     = pathname.split('/');
	const _path    = path.slice(0);

	if(_path[0] === 'php-wasm')
	{
		_path.shift();
	}

	if(!_path[ _path.length-1 ].match(/\.\w+$/) && _path[1] === 'drupal-7.95')
	{
		const getPost = event.request.method !== 'POST'
			? Promise.resolve()
			: event.request.formData();

		return getPost.then(post => {
			accept(new Response(`<script>window.parent.postMessage({
				action: 'respond'
				, method:  '${event.request.method}'
				, path:  '${'/' + path.join('/')}'
				, _GET:  '${url.search}'
				, _POST: '${event.request.method === 'POST'
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
		accept(fetch(event.request));
	}
})));

self.addEventListener('message', event => {
});

self.addEventListener('push', event => {
	console.log(event);
});
