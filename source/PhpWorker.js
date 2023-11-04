import { PhpBase } from './PhpBase';
import PhpBinary from './php-worker';

export class PhpWorker extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}
