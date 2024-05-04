import { PhpCgiBase } from './PhpCgiBase';
import PHP from './php-cgi-web';

export class PhpCgiWeb extends PhpCgiBase
{
	constructor({docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args} = {})
	{
		super(PHP, {docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args} = {});
	}

	async _enqueue(method, params = [])
	{
		let accept, reject;

		const coordinator = new Promise((a,r) => [accept, reject] = [a, r]);

		this.queue.push([method, params, accept, reject]);

		await navigator.locks.request('php-wasm-fs-lock', async () => {
			if(!this.queue.length)
			{
				return;
			}

			while(this.queue.length)
			{
				const [method, params, accept, reject] = this.queue.shift();
				await this[method](...params).then(accept).catch(reject);
			}
		});

		return coordinator;
	}
}
