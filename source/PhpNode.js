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

		const locateFile = name => {
			if(name[0] === '/')
			{
				name = name.substr(1);
			}
			return path.resolve(dir, name);
		};

		super(PhpBinary, {...args, locateFile});
	}
}
