import { PhpBase } from './PhpBase';
import PhpBinary from './php-node';

export class PhpNode extends PhpBase
{
	constructor(args = {})
	{
		if(typeof __dirname === undefined)
		{
			dir = path.dirname(fileURLToPath(import.meta.url));
		}
		else
		{
			dir = __dirname;
		}

		const locateFile = wasmBinary => path.resolve(dir, wasmBinary);


		super(PhpBinary, {...args, locateFile});
	}
}
