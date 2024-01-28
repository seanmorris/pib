import PHP from 'php-cgi-wasm/php-cgi-worker-drupal';
import parseResponse from './parseResponse';

const toQueryString = x => String(new URLSearchParams(x)).toString();

const putEnv = (php, key, value) => php.ccall(
	'wasm_sapi_cgi_putenv'
	, 'number'
	, ['string', 'string']
	, [key, value]
);

export class PhpCgi
{
	rewrite    = path => path;
	processing = null
	docroot    = null;
	php        = null;

	input  = [];
	output = [];
	error  = [];

	cookies = new Map;

	constructor({docroot, rewrite, ...args} = {})
	{
		this.php = new PHP({
			stdin:   () => this.input ? String(this.input.shift()).charCodeAt(0) : null, ...args
			, print: x  => this.output.push(x)
		});

		this.php.then(p => {
			p.ccall('wasm_sapi_cgi_init' , 'number' , [] , [] )
		});

		this.docroot = docroot || '';
		this.rewrite = rewrite || this.rewrite;
	}

	request({filename, method = 'GET', path = '', get, post, cookie})
	{
		// console.log({filename, method, path, get, post, cookie});

		this.input  = ['POST', 'PUT', 'PATCH'].includes(method) ? toQueryString(post).split('') : [];
		this.output = [];
		this.error  = [];

		if(!path && !filename)
		{
			path = '/index.php';
		}

		if(path[0] !== '/')
		{
			path = '/' + path;
		}

		return this.php.then(p => {

			// if(!aboutPath.exists || !p.FS.isFile(aboutPath.object.mode))
			// {
			// 	console.log({path, filename, rewritten, aboutPath});
			// 	const status = '404 - Not Found';
			// 	return new Response(status, {status: 400});
			// }

			filename = filename || this.docroot + path;

			const rewritten = this.rewrite(filename);
			const aboutPath = p.FS.analyzePath(rewritten);

			if(aboutPath.exists && rewritten.substr(-4) !== '.php')
			{
				return new Response(p.FS.readFile(rewritten, { encoding: 'binary' }), {});
			}
			else
			{
				filename = '/preload/drupal-7.95/index.php';
			}

			new URLSearchParams()

			console.log( [...this.cookies.entries()].map(e => `${e[0]}=${e[1]}`).join(';') );

			putEnv(p, 'DOCROOT', this.docroot);
			putEnv(p, 'SERVER_SOFTWARE', navigator.userAgent);
			putEnv(p, 'REQUEST_METHOD', method);
			putEnv(p, 'REQUEST_URI', rewritten);
			putEnv(p, 'REMOTE_ADDR', '127.0.0.1');
			putEnv(p, 'SCRIPT_NAME', filename);
			putEnv(p, 'SCRIPT_FILENAME', filename);
			putEnv(p, 'PATH_TRANSLATED', rewritten);
			putEnv(p, 'QUERY_STRING', toQueryString(get));
			putEnv(p, 'HTTP_COOKIE', [...this.cookies.entries()].map(e => `${e[0]}=${e[1]}`).join(';') );
			putEnv(p, 'REDIRECT_STATUS', '200');
			putEnv(p, 'CONTENT_TYPE', 'application/x-www-form-urlencoded');
			putEnv(p, 'CONTENT_LENGTH', String(this.input.length));

			p._main();

			const parsedResponse = parseResponse(this.output.join('\n') + '\n');

			let status = 200;

			for(const [name, value] of Object.entries(parsedResponse.headers))
			{
				if(name === 'Status')
				{
					status = value.substr(0, 3);
				}
			}

			console.log(parsedResponse.headers);

			if(parsedResponse.headers['Set-Cookie'])
			{
				const raw = parsedResponse.headers['Set-Cookie'];
				const semi  = raw.indexOf(';');
				const equal = raw.indexOf('=');
				const key   = raw.substr(0, equal);
				const value = raw.substr(1 + equal, semi - equal);

				this.cookies.set(key, value);

				console.log({key, value});
			}

			const headers = {
				"Content-Type": parsedResponse.headers["Content-Type"]
			};

			if(parsedResponse.headers.Location)
			{
				headers.Location = parsedResponse.headers.Location;
			}

			// console.log({path, filename, rewritten, headers, aboutPath});

			return new Response(parsedResponse.body, {
				headers, status, url: rewritten
			});
		});
	}
}
