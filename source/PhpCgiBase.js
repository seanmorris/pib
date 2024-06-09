import { phpVersion } from "./config";
import { parseResponse } from './parseResponse';
import { breakoutRequest } from './breakoutRequest';
import { fsOps } from './fsOps';
import { resolveDependencies } from './resolveDependencies';

const STR = 'string';
const NUM = 'number';

const putEnv = (php, key, value) => php.ccall(
	'wasm_sapi_cgi_putenv'
	, 'number'
	, ['string', 'string']
	, [key, value]
);

const requestTimes = new WeakMap;

export class PhpCgiBase
{
	docroot    = null;
	prefix     = '/php-wasm';
	rewrite    = path => path;
	cookies    = null;
	types      = {};
	onRequest  = () => {};
	phpArgs    = {};

	maxRequestAge    = 0;
	staticCacheTime  = 60_000;
	dynamicCacheTime = 0;
	vHosts = [];

	php        = null;
	input      = [];
	output     = [];
	error      = [];
	count      = 0;

	queue = [];

	constructor(PHP, {docroot, prefix, rewrite, entrypoint, cookies, types, onRequest, notFound, sharedLibs, ...args} = {})
	{
		this.PHP        = PHP;
		this.docroot    = docroot    || this.docroot;
		this.prefix     = prefix     || this.prefix;
		this.rewrite    = rewrite    || this.rewrite;
		this.entrypoint = entrypoint || this.entrypoint;
		this.cookies    = cookies    || new Map;
		this.types      = types      || this.types;
		this.onRequest  = onRequest  || this.onRequest;
		this.notFound   = notFound   || this.notFound;
		this.sharedLibs = sharedLibs || this.sharedLibs;

		this.phpArgs   = args;

		this.autoTransaction = ('autoTransaction' in args) ? args.autoTransaction : true;
		this.transactionStarted = false;

		this.maxRequestAge    = args.maxRequestAge    || this.maxRequestAge;
		this.staticCacheTime  = args.staticCacheTime  || this.staticCacheTime;
		this.dynamicCacheTime = args.dynamicCacheTime || this.dynamicCacheTime;
		this.vHosts = args.vHosts || [];

		this.env = {};

		Object.assign(this.env, args.env || {});

		this.refresh();
	}

	handleInstallEvent(event)
	{
		return event.waitUntil(self.skipWaiting());
	}

	handleActivateEvent(event)
	{
		return event.waitUntil(self.clients.claim());
	}

	async handleMessageEvent(event)
	{
		const { data, source } = event;
		const { action, token, params = [] } = data;

		switch(action)
		{
			case 'analyzePath':
			case 'readdir':
			case 'readFile':
			case 'stat':
			case 'mkdir':
			case 'rmdir':
			case 'writeFile':
			case 'rename':
			case 'unlink':
			case 'putEnv':

			case 'refresh':
			case 'getSettings':
			case 'setSettings':
			case 'getEnvs':
			case 'setEnvs':
			case 'storeInit':
				let result, error;
				try
				{
					result = await this[action](...params);
				}
				catch(_error)
				{
					error = JSON.parse(JSON.stringify(_error));
					console.warn(_error);
				}
				finally
				{
					source.postMessage({re: token, result, error});
				}

			break;
		}
	}

	handleFetchEvent(event)
	{
		const url     = new URL(event.request.url);
		const prefix  = this.prefix;

		if(url.pathname.substr(0, prefix.length) === prefix && url.hostname === self.location.hostname)
		{
			requestTimes.set(event.request, Date.now());
			const response = this.request(event.request);
			return event.respondWith(response);
		}
		else
		{
			return fetch(event.request);
		}
	}

	async _enqueue(callback, params = [])
	{
		let accept, reject;

		const coordinator = new Promise((a,r) => [accept, reject] = [a, r]);

		this.queue.push([callback, params, accept, reject]);

		if(!this.queue.length)
		{
			return;
		}

		while(this.queue.length)
		{
			const [callback, params, accept, reject] = this.queue.shift();
			await callback(...params).then(accept).catch(reject);
		}

		return coordinator;
	}

	refresh()
	{
		const {files, libs, urlLibs} = resolveDependencies(this.sharedLibs, this);

		console.log(files, libs, urlLibs);

		const userLocateFile = this.phpArgs.locateFile || (() => undefined);

		const locateFile = path => {
			let located = userLocateFile(path);
			if(located !== undefined)
			{
				return located;
			}
			if(urlLibs[path])
			{
				return urlLibs[path];
			}
		};

		const phpArgs = {
			persist: [{mountPath:'/persist'}, {mountPath:'/config'}]
			, ...this.phpArgs
			, stdin: () =>  this.input
				? String(this.input.shift()).charCodeAt(0)
				: null
			, stdout: x => this.output.push(x)
			, stderr: x => this.error.push(x)
			, locateFile
		};

		this.binary = new this.PHP(phpArgs).then(async php => {

			await php.ccall(
				'pib_storage_init'
				, NUM
				, []
				, []
				, {async: true}
			);

			files.forEach(fileDef => php.FS.createPreloadedFile(
				fileDef.parent, fileDef.name, fileDef.url, true, false
			));

			const iniLines = libs.map(lib => {
				if(typeof lib === 'string')
				{
					return `extension=${lib}`;
				}
			});

			args.ini && iniLines.push(args.ini.replace(/\n\s+/g, '\n'));

			php.FS.writeFile('/php.ini', iniLines.join("\n") + "\n", {encoding: 'utf8'});

			await php.ccall(
				'wasm_sapi_cgi_init'
				, 'number'
				, []
				, []
				, {async: true}
			);

			await this.loadInit(php);

			return php;
		});
	}

	async _beforeRequest()
	{}

	async _afterRequest()
	{}

	async request(request)
	{
		const {
			url
			, method = 'GET'
			, get
			, post
			, contentType
		} = await breakoutRequest(request);

		const cache  = await caches.open('static-v1');
		const cached = await cache.match(url);

		// this.maxRequestAge

		if(cached)
		{
			const cacheTime = Number(cached.headers.get('x-php-wasm-cache-time'));

			if(this.staticCacheTime > 0 && this.staticCacheTime > Date.now() - cacheTime)
			{
				this.onRequest(request, cached);
				return cached;
			}
		}

		const php = await this.binary;

		await this._beforeRequest();

		let docroot = this.docroot;
		let vHostEntrypoint, vHostPrefix;

		for(const {pathPrefix, directory, entrypoint} of this.vHosts)
		{
			if(pathPrefix === url.pathname.substr(0, pathPrefix.length))
			{
				docroot = directory;
				vHostEntrypoint = entrypoint;
				vHostPrefix = pathPrefix;
				break;
			}
		}

		const rewrite = this.rewrite(url.pathname);

		let scriptName, path;

		if(typeof rewrite === 'object')
		{
			scriptName = rewrite.scriptName;
			path = docroot + rewrite.path;
		}
		else
		{

			path = docroot + rewrite.substr((vHostPrefix || this.prefix).length);
			scriptName = path;
		}

		if(vHostEntrypoint)
		{
			scriptName = vHostPrefix + '/' + vHostEntrypoint;
		}

		let originalPath = url.pathname;

		const extension = path.split('.').pop();

		if(extension !== 'php')
		{
			const aboutPath = php.FS.analyzePath(path);

			// Return static file
			if(aboutPath.exists && php.FS.isFile(aboutPath.object.mode))
			{
				const response = new Response(php.FS.readFile(path, { encoding: 'binary', url }), {});
				response.headers.append('x-php-wasm-cache-time', new Date().getTime());
				if(extension in this.types)
				{
					response.headers.append('Content-type', this.types[extension]);
				}
				cache.put(url, response.clone());
				this.onRequest(request, response);
				return response;
			}
			else if(aboutPath.exists && php.FS.isDir(aboutPath.object.mode) && '/' !== originalPath[ -1 + originalPath.length  ])
			{
				originalPath += '/'
			}

			// Rewrite to index
			path = docroot + '/index.php';
		}

		if(this.maxRequestAge > 0 && Date.now() - requestTimes.get(request) > this.maxRequestAge)
		{
			const response = new Response('408: Request Timed Out.', { status: 408 });
			this.onRequest(request, response);
			return response;
		}

		const aboutPath = php.FS.analyzePath(path);

		if(!aboutPath.exists)
		{
			const rawResponse = this.notFound
				? this.notFound(request)
				: '404 - Not Found.';

			if(rawResponse)
			{
				return rawResponse instanceof Response
					? rawResponse
					: new Response(rawResponse, {status: 404});
			}
		}

		this.input  = ['POST', 'PUT', 'PATCH'].includes(method) ? post.split('') : [];
		this.output = [];
		this.error  = [];

		const selfUrl = new URL(globalThis.location);

		putEnv(php, 'PHP_INI_SCAN_DIR', `/config:/preload:${docroot}`);
		putEnv(php, 'PHPRC', '/php.ini');

		for(const [name, value] of Object.entries(this.env))
		{
			putEnv(php, name, value);
		}

		putEnv(php, 'SERVER_SOFTWARE', navigator.userAgent);
		putEnv(php, 'REQUEST_METHOD', method);
		putEnv(php, 'REMOTE_ADDR', '127.0.0.1');
		putEnv(php, 'HTTP_HOST', selfUrl.host);
		putEnv(php, 'REQUEST_SCHEME', selfUrl.protocol.substr(0, selfUrl.protocol.length - 0));

		putEnv(php, 'DOCUMENT_ROOT', docroot);
		putEnv(php, 'REQUEST_URI', originalPath);
		putEnv(php, 'SCRIPT_NAME', scriptName);
		putEnv(php, 'SCRIPT_FILENAME', path);
		putEnv(php, 'PATH_TRANSLATED', path);

		putEnv(php, 'QUERY_STRING', get);
		putEnv(php, 'HTTP_COOKIE', [...this.cookies.entries()].map(e => `${e[0]}=${e[1]}`).join(';') );
		putEnv(php, 'REDIRECT_STATUS', '200');
		putEnv(php, 'CONTENT_TYPE', contentType);
		putEnv(php, 'CONTENT_LENGTH', String(this.input.length));

		try
		{
			const exitCode = await php.ccall(
				'main'
				, 'number'
				, ['number', 'string']
				, []
				, {async: true}
			);

			if(exitCode === 0)
			{
				this._afterRequest();
			}
			else
			{
				console.warn(new TextDecoder().decode(new Uint8Array(this.output).buffer));
				console.error(new TextDecoder().decode(new Uint8Array(this.error).buffer));
			}
		}
		catch (error)
		{
			console.error(error);

			this.refresh();

			const response = new Response(
				`500: Internal Server Error.\n`
					+ `=`.repeat(80) + `\n\n`
					+ `Stacktrace:\n${error.stack}\n`
					+ `=`.repeat(80) + `\n\n`
					+ `STDERR:\n${new TextDecoder().decode(new Uint8Array(this.error).buffer)}\n`
					+ `=`.repeat(80) + `\n\n`
					+ `STDOUT:\n${new TextDecoder().decode(new Uint8Array(this.output).buffer)}\n`
					+ `=`.repeat(80) + `\n\n`
				, { status: 500 }
			);
			this.onRequest(request, response);

			return response;
		}

		++this.count;

		const parsedResponse = parseResponse(this.output);

		let status = 200;

		for(const [name, value] of Object.entries(parsedResponse.headers))
		{
			if(name === 'Status')
			{
				status = value.substr(0, 3);
			}
		}

		if(parsedResponse.headers['Set-Cookie'])
		{
			const raw = parsedResponse.headers['Set-Cookie'];
			const semi  = raw.indexOf(';');
			const equal = raw.indexOf('=');
			const key   = raw.substr(0, equal);
			const value = raw.substr(1 + equal, -1 + semi - equal);

			this.cookies.set(key, value,);
		}

		const headers = {
			'Content-Type': parsedResponse.headers["Content-Type"] ?? 'text/html; charset=utf-8'
		};

		if(parsedResponse.headers.Location)
		{
			headers.Location = parsedResponse.headers.Location;
		}

		const response = new Response(parsedResponse.body || '', { headers, status, url });

		this.onRequest(request, response);

		return response;
	}

	analyzePath(path)
	{
		return this._enqueue(fsOps.analyzePath, [this.binary, path]);
	}

	readdir(path)
	{
		return this._enqueue(fsOps.readdir, [this.binary, path]);
	}

	readFile(path, options)
	{
		return this._enqueue(fsOps.readFile, [this.binary, path, options]);
	}

	stat(path)
	{
		return this._enqueue(fsOps.stat, [this.binary, path]);
	}

	mkdir(path)
	{
		return this._enqueue(fsOps.mkdir, [this.binary, path]);
	}

	rmdir(path)
	{
		return this._enqueue(fsOps.rmdir, [this.binary, path]);
	}

	rename(path, newPath)
	{
		return this._enqueue(fsOps.rename, [this.binary, path, newPath]);
	}

	writeFile(path, data, options)
	{
		return this._enqueue(fsOps.writeFile, [this.binary, path, data, options]);
	}

	unlink(path)
	{
		return this._enqueue(fsOps.unlink, [this.binary, path]);
	}

	async putEnv(name, value)
	{
		return (await this.binary).ccall('wasm_sapi_cgi_putenv', 'number', ['string', 'string'], [name, value]);
	}

	async getSettings()
	{
		return {
			docroot: this.docroot
			, maxRequestAge: this.maxRequestAge
			, staticCacheTime: this.staticCacheTime
			, dynamicCacheTime: this.dynamicCacheTime
			, vHosts: this.vHosts
		};
	}

	async setSettings({docroot, maxRequestAge, staticCacheTime, dynamicCacheTime, vHosts})
	{
		this.docroot = docroot ?? this.docroot;
		this.maxRequestAge = maxRequestAge ?? this.maxRequestAge;
		this.staticCacheTime = staticCacheTime ?? this.staticCacheTime;
		this.dynamicCacheTime = dynamicCacheTime ?? this.dynamicCacheTime;
		this.vHosts = vHosts ?? this.vHosts;
	}

	async getEnvs()
	{
		return {...this.env};
	}

	async setEnvs(env)
	{
		for(const key of Object.keys(this.env))
		{
			this.env[key] = undefined;
		}

		Object.assign(this.env, env);
	}

	async storeInit()
	{
		const settings = await this.getSettings();
		const env = await this.getEnvs();
		await this.writeFile(
			'/config/init.json'
			, JSON.stringify({settings, env}, null, 4)
			, {encoding: 'utf8'}
		);
	}

	async loadInit(binary)
	{
		const initPath = '/config/init.json';
		const check = await fsOps.analyzePath(binary, initPath);

		if(!check.exists)
		{
			return;
		}

		const initJson = await fsOps.readFile(binary, initPath, {encoding: 'utf8'});
		const init = JSON.parse(initJson || '{}');
		const {settings, env} = init;

		this.setSettings(settings);
		this.setEnvs(env);
	}
}

PhpCgiBase.phpVersion = phpVersion;
