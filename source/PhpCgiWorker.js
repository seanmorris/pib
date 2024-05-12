import { PhpCgiBase } from './PhpCgiBase';
import PHP from './php-cgi-worker';
import { commitTransaction, startTransaction } from './webTransactions';

export class PhpCgiWorker extends PhpCgiBase
{
	constructor({docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args} = {})
	{
		super(PHP, {docroot, prefix, rewrite, cookies, types, onRequest, notFound, ...args});
	}

	startTransaction()
	{
		return startTransaction(this);
	}

	commitTransaction()
	{
		return commitTransaction(this);
	}

	async _beforeRequest()
	{
		if(!this.initialized)
		{
			const php = await this.binary;
			await navigator.locks.request('php-wasm-fs-lock', async () => {
				await new Promise((accept,reject) => php.FS.syncfs(true, err => {
					if(err) reject(err);
					else    accept();
				}));
			});

			await this.loadInit();

			this.initialized = true;
		}
	}

	_afterRequest()
	{
		navigator.locks.request('php-wasm-fs-lock', async () => {
			const php = await this.binary;
			await new Promise((accept,reject) => php.FS.syncfs(false, err => {
				if(err) reject(err);
				else    accept();
			}));
		});
	}

	async refresh()
	{
		this.binary = new this.PHP({
			stdin: () =>  this.input
				? String(this.input.shift()).charCodeAt(0)
				: null
			, stdout: x => this.output.push(x)
			, stderr: x => this.error.push(x)
			, persist: [{mountPath:'/persist'}, {mountPath:'/config'}]
			, ...this.phpArgs
		});

		const php = await this.binary;

		php.ccall('pib_storage_init',   'number' , [] , []);
		php.ccall('wasm_sapi_cgi_init', 'number' , [] , []);

		await navigator.locks.request('php-wasm-fs-lock', async () => {
			return new Promise((accept, reject) => {
				php.FS.syncfs(true, error => {
					if(error) reject(error);
					else accept();
				});
			});
		});

		await this.loadInit();
	}

	_enqueue(callback, params = [])
	{
		let accept, reject;

		const coordinator = new Promise((a,r) => [accept, reject] = [a, r]);

		this.queue.push([callback, params, accept, reject]);

		navigator.locks.request('php-wasm-fs-lock', async () => {

			if(!this.queue.length)
			{
				return;
			}

			await (this.autoTransaction ? this.startTransaction() : Promise.resolve());

			do
			{
				const [callback, params, accept, reject] = this.queue.shift();
				callback(...params).then(accept).catch(reject);
				// console.log(params);
				let lockChecks = 8;
				while(!this.queue.length && lockChecks--)
				{
					await new Promise(a => setTimeout(a, 10));
				}
			} while(this.queue.length)

			await (this.autoTransaction ? this.commitTransaction() : Promise.resolve());
		});

		return coordinator;
	}
}
