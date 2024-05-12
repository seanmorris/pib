import { PhpBase } from './PhpBase';
import PhpBinary from './php-webview';
import { commitTransaction, startTransaction } from './webTransactions';

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

	async _enqueue(callback, params = [])
	{
		let accept, reject;

		const coordinator = new Promise((a,r) => [accept, reject] = [a, r]);

		this.queue.push([callback, params, accept, reject]);

		await navigator.locks.request('php-wasm-fs-lock', async () => {
			if(!this.queue.length)
			{
				return;
			}

			await (this.autoTransaction ? this.startTransaction() : Promise.resolve());

			while(this.queue.length)
			{
				const [callback, params, accept, reject] = this.queue.shift();
				await callback(...params).then(accept).catch(reject);
			}

			await (this.autoTransaction ? this.commitTransaction() : Promise.resolve());
		});

		return coordinator;
	}
}
