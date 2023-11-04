import { PhpBase } from './PhpBase';
import PhpBinary from './php-webview';

export class PhpWebview extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}
