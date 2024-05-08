import { PhpBase } from './PhpBase.mjs';
import { commitTransaction, startTransaction } from './webTransactions.mjs';
import PhpBinary from './php-web-drupal.mjs';

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
