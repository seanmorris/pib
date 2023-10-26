import { PhpBase } from './PhpBase';

const PhpBinary = require('./php-web-drupal');

export class PhpWebDrupal extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}
