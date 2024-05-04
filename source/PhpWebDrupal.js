import { PhpBase } from './PhpBase';
import { commitTransaction, startTransaction } from './webTransactions';
import PhpBinary from './php-web-drupal';

export class PhpWebDrupal extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}

	startTransaction()
	{
		return startTransaction(this);
	}

	commitTransaction()
	{
		return commitTransaction(this);
	}
}
