import PHP from 'php-wasm/php-cgi';

const toQueryString = str => String(new URLSearchParams(str)).toString();

const putEnv = (php, key, value) => php.ccall(
	'wasm_sapi_cgi_putenv'
	, 'number'
	, ['string', 'string']
	, [key, value]
);

export class PhpCgi
{
	input = [];
	php = new PHP({ stdin: () => this.input ? String(this.input.shift()).charCodeAt(0) : null });
	docroot = '/';
	rewrite = path => path;
	processing = null
	queue = [];

	constructor({docroot, rewrite} = {})
	{
		this.php.then(p => {
			p.ccall('wasm_sapi_cgi_init' , 'number' , [] , [] )
		});
		this.docroot = docroot;
		this.rewrite = rewrite || this.rewrite;
	}

	request({filename, method = 'GET', path = '', get, post, cookie})
	{
		this.input = ['POST', 'PUT', 'PATCH'].includes(method)
			? toQueryString(post).split('')
			: [];

		if(path[0] !== '/')
		{
			path = '/' + path;
		}

		filename = filename || this.docroot + path;

		const rewritten = this.rewrite(filename);

		return this.php.then(p => {
			putEnv(p, 'DOCROOT', this.docroot);
			putEnv(p, 'SERVER_SOFTWARE', navigator.userAgent);
			putEnv(p, 'REQUEST_METHOD', method);
			putEnv(p, 'REQUEST_URI', path);
			putEnv(p, 'SCRIPT_FILENAME', filename);
			putEnv(p, 'PATH_TRANSLATED', rewritten);
			putEnv(p, 'QUERY_STRING', toQueryString(get));
			putEnv(p, 'HTTP_COOKIE', toQueryString(cookie));
			putEnv(p, 'REDIRECT_STATUS', '200');
			putEnv(p, 'CONTENT_TYPE', 'application/x-www-form-urlencoded');
			putEnv(p, 'CONTENT_LENGTH', String(this.input.length));

			p._main();
		});
	}
}
