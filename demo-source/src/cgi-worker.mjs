/* eslint-disable no-restricted-globals */
import { PhpCgiWorker } from "php-cgi-wasm/PhpCgiWorker.mjs";

// import zlib from 'https://cdn.jsdelivr.net/npm/php-wasm-zlib@0.0.9-d';
// import libzip from 'https://cdn.jsdelivr.net/npm/php-wasm-libzip@0.0.9-c';
// import iconv from 'https://cdn.jsdelivr.net/npm/php-wasm-iconv@0.0.9-f';
// import libicu from 'https://cdn.jsdelivr.net/npm/php-wasm-libicu@0.0.9-r';
// import sqlite from 'https://cdn.jsdelivr.net/npm/php-wasm-sqlite@0.0.9-s';
// import freetype from 'https://cdn.jsdelivr.net/npm/php-wasm-freetype@0.0.9-c';
// import libpng from 'https://cdn.jsdelivr.net/npm/php-wasm-libpng@0.0.9-h';
// import libjpeg from 'https://cdn.jsdelivr.net/npm/php-wasm-libjpeg@0.0.9-c';
// import libxml from 'https://cdn.jsdelivr.net/npm/php-wasm-libxml@0.0.9-h';
// import gd from 'https://cdn.jsdelivr.net/npm/php-wasm-gd@0.0.9-c';
// import openssl from 'https://cdn.jsdelivr.net/npm/php-wasm-openssl@0.0.9-e';
// import phar from 'https://cdn.jsdelivr.net/npm/php-wasm-phar@0.0.9-b';
// import tidy from 'https://cdn.jsdelivr.net/npm/php-wasm-tidy@0.0.9-d';
// import yaml from 'https://cdn.jsdelivr.net/npm/php-wasm-yaml@0.0.9-f';

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
	`php${PhpCgiWorker.phpVersion}-openssl.so`,
	`php${PhpCgiWorker.phpVersion}-dom.so`,
	`php${PhpCgiWorker.phpVersion}-mbstring.so`,
	`php${PhpCgiWorker.phpVersion}-sqlite.so`,
	`php${PhpCgiWorker.phpVersion}-pdo-sqlite.so`,
	// zlib
	// , libzip
	// , iconv
	// , libicu
	// , sqlite
	// , freetype
	// , libpng
	// , libjpeg
	// , libxml
	// , gd
	// , openssl
	// , phar
	// , tidy
	// , yaml
];

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
