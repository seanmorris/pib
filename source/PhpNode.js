import { PhpBase } from './PhpBase.js';

const PhpBinary = require('./php-node');

export class PhpNode extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}
