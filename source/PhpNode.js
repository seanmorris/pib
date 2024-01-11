import { PhpBase } from './PhpBase';
import PhpBinary from './php-node';
import path from 'node:path';
import url from 'node:url';

export class PhpNode extends PhpBase
{
	constructor(args = {})
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

		const locateFile = wasmBinary => path.resolve(dir, wasmBinary);


		super(PhpBinary, {...args, locateFile});
	}
}
