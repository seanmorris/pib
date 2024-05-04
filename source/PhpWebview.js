import { PhpBase } from './PhpBase';
import { commitTransaction, startTransaction } from './webTransactions';
import PhpBinary from './php-webview';

export class PhpWebview extends PhpBase
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
