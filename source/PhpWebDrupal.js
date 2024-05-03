import { PhpBase } from './PhpBase';
import PhpBinary from './php-web-drupal';

export class PhpWebDrupal extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}
