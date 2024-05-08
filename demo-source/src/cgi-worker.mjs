/* eslint-disable no-restricted-globals */
import { PhpCgiWorkerDrupal } from "./PhpCgiWorkerDrupal.mjs";

// Log requests & send lines to all tabs
const onRequest = (request, response) => {
	const url = new URL(request.url);
	const logLine = `[${(new Date).toISOString()}]`
		+ `#${php.count} 127.0.0.1 - "${request.method}`
		+ ` ${url.pathname}" - HTTP/1.1 ${response.status}`;

	console.log(logLine);

	// self.clients.matchAll({includeUncontrolled: true}).then(clients => {
	// 	clients.forEach(client => client.postMessage({
	// 		action: 'logRequest',
	// 		params: [logLine, {status: response.status}],
	// 	}))
	// });
};

const notFound = request => {
	return new Response(
		`<body><h1>404</h1>${request.url} not found</body>`,
		{status: 404, headers:{'Content-Type': 'text/html'}}
	);
};

// Spawn the PHP-CGI binary
const php = new PhpCgiWorkerDrupal({
	onRequest, notFound
	, prefix: '/php-wasm/'
	, docroot: '/persist/www'
	, types: {
		jpeg: 'image/jpeg'
		, jpg: 'image/jpeg'
		, gif: 'image/gif'
		, png: 'image/png'
		, svg: 'image/svg+xml'
	}
});

// Extras
self.addEventListener('install', event => console.log('Install'));
self.addEventListener('activate', event => console.log('Activate'));

// Set up the event handlers
self.addEventListener('install',  event => php.handleInstallEvent(event));
self.addEventListener('activate', event => php.handleActivateEvent(event));
self.addEventListener('fetch',    event => php.handleFetchEvent(event));
self.addEventListener('message',  event => php.handleMessageEvent(event));
