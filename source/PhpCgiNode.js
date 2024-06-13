import { PhpCgiBase } from './PhpCgiBase';
import PHP from './php-cgi-node';

export class PhpCgiNode extends PhpCgiBase
{
	constructor({docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args} = {})
	{
		super(PHP, {docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args});
	}

	request(request)
	{
		const protocol = request.connection.encrypted ? 'https://' : 'http://';

		request.url = new URL(protocol + request.headers.host + request.url);

		request.headers = new Map(Object.entries(request.headers));

		return super.request(request);
	}
}
