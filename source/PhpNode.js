import { PhpBase } from './PhpBase';
import PhpBinary from './php-node';
import path from 'node:path';
import url from 'node:url';

export class PhpNode extends PhpBase
{
	constructor(args = {})
	{
		const locateFile = (name, dir) => {
			if(name.substr(0, 7) === 'file://')
			{
				name = new URL(name).pathname;
			}

			if(dir === '')
			{
				if(typeof __dirname === 'undefined')
				{
					dir = path.dirname(url.fileURLToPath(import.meta.url));
				}
				else
				{
					dir = __dirname;
				}
			}

			return path.resolve( path.format({dir, name}) );
		};

		super(PhpBinary, {...args, locateFile});
	}
}
