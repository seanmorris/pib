import { PhpCgiBase } from './PhpCgiBase';
import PHP from './php-cgi-node';

export class PhpCgiNode extends PhpCgiBase
{
	constructor({docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args} = {})
	{
		super(PHP, {docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args} = {});
	}
}
