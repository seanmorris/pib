/* eslint-disable no-restricted-globals */
import { PhpCgiWorker } from "php-cgi-wasm/PhpCgiWorker.mjs";

// Log requests
const onRequest = (request, response) => {
	const url = new URL(request.url);
	const logLine = `[${(new Date).toISOString()}]`
		+ `#${php.count} 127.0.0.1 - "${request.method}`
		+ ` ${url.pathname}" - HTTP/1.1 ${response.status}`;

	console.log(logLine);
};

const notFound = request => {
	return new Response(
		`<body><h1>404</h1>${request.url} not found</body>`,
		{status: 404, headers:{'Content-Type': 'text/html'}}
	);
};

const sharedLibs = [
	`php${PhpCgiWorker.phpVersion}-zlib.so`,
	`php${PhpCgiWorker.phpVersion}-zip.so`,
	`php${PhpCgiWorker.phpVersion}-iconv.so`,
	`php${PhpCgiWorker.phpVersion}-intl.so`,
	`php${PhpCgiWorker.phpVersion}-ssl.so`,
	`php${PhpCgiWorker.phpVersion}-dom.so`,
	`php${PhpCgiWorker.phpVersion}-mbstring.so`,
	`php${PhpCgiWorker.phpVersion}-sqlite.so`,
	`php${PhpCgiWorker.phpVersion}-pdo.so`,
	`php${PhpCgiWorker.phpVersion}-pdo-sqlite.so`,
];

console.log(sharedLibs);

// Spawn the PHP-CGI binary
const php = new PhpCgiWorker({
	onRequest, notFound, sharedLibs
	, prefix: '/php-wasm/cgi-bin/'
	, docroot: '/persist/www'
	, types: {
		jpeg: 'image/jpeg'
		, jpg: 'image/jpeg'
		, gif: 'image/gif'
		, png: 'image/png'
		, svg: 'image/svg+xml'
	}
});

// Set up the event handlers
self.addEventListener('install',  event => php.handleInstallEvent(event));
self.addEventListener('activate', event => php.handleActivateEvent(event));
self.addEventListener('fetch',    event => php.handleFetchEvent(event));
self.addEventListener('message',  event => php.handleMessageEvent(event));

// Extras
self.addEventListener('install',  event => console.log('Install'));
self.addEventListener('activate', event => console.log('Activate'));
