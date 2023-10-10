import { PhpBase } from './PhpBase.js';

const PhpBinary = require('./php-webview');

export class PhpWebview extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}
