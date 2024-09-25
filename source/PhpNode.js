import { PhpBase } from './PhpBase';
import PhpBinary from './php-node';
import path from 'node:path';
import url from 'node:url';

export class PhpNode extends PhpBase
{
	constructor(args = {})
	{
		const locateFile = (name, dir) => {
			console.log({dir, name});
			if(name.substr(0, 7) === 'file://')
			{
				name = new URL(name).pathname;
			}

			return path.isAbsolute(name) ? name : path.resolve(dir, name);
		};

		super(PhpBinary, {...args, locateFile});
	}
}
