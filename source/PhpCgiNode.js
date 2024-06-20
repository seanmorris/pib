import { PhpCgiBase } from './PhpCgiBase';
import PHP from './php-cgi-node';
import path from 'node:path';
import url from 'node:url';

export class PhpCgiNode extends PhpCgiBase
{
	constructor({docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args} = {})
	{
		let dir;

		if(typeof __dirname === 'undefined')
		{
			dir = path.dirname(url.fileURLToPath(import.meta.url));
		}
		else
		{
			dir = __dirname;
		}

		const locateFile = name => path.resolve(dir, name);

		super(PHP, {docroot, prefix, rewrite, cookies, types, onRequest, notFound, locateFile, ...args});
	}

	async request(request)
	{
		const protocol = request.connection.encrypted ? 'https://' : 'http://';

		request.url = new URL(protocol + request.headers.host + request.url);

		request.headers = new Map(Object.entries(request.headers));

		const response = await super.request(request);

		console.error(`[${new Date().toLocaleString()}] [HTTP ${response.status}] ${String(request.method).padStart(5,' ')} ${request.url}`);

		return response;
	}
}
