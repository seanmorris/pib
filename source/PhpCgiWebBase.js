import { PhpCgiBase } from './PhpCgiBase';
import { commitTransaction, startTransaction } from './webTransactions';
import { fsOps } from './fsOps';

const STR = 'string';
const NUM = 'number';

export class PhpCgiWebBase extends PhpCgiBase
{
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
			await navigator.locks.request('php-wasm-fs-lock', async () => {
				const php = await this.binary;
				await this.loadInit(php);
				await new Promise((accept,reject) => php.FS.syncfs(true, err => {
					if(err) reject(err);
					else    accept();
				}));
			});

			this.initialized = true;
		}
	}

	async _afterRequest()
	{
		await navigator.locks.request('php-wasm-fs-lock', async () => {
			const php = await this.binary;
			await new Promise((accept,reject) => php.FS.syncfs(false, err => {
				if(err) reject(err);
				else    accept();
			}));
		});
	}

	refresh()
	{
		const phpArgs = {
			stdin: () =>  this.input
				? String(this.input.shift()).charCodeAt(0)
				: null
			, stdout: x => this.output.push(x)
			, stderr: x => this.error.push(x)
			, persist: [{mountPath:'/persist'}, {mountPath:'/config'}]
			, ...this.phpArgs
		};

		this.binary = navigator.locks.request('php-wasm-fs-lock', async () => {

			const php = await new this.PHP(phpArgs);

			await php.ccall(
				'pib_storage_init'
				, NUM
				, []
				, []
				, {async: true}
			);

			if(this.sharedLibs)
			{
				const iniLines = this.sharedLibs.map(lib => {
					if(typeof lib === 'string')
					{
						return `extension=${lib}`;
					}
				});

				await fsOps.writeFile(php, '/php.ini', iniLines.join("\n") + "\n", {encoding: 'utf8'});
			}

			this.initialized = false;

			await new Promise((accept, reject) => {
				php.FS.syncfs(true, error => {
					if(error) reject(error);
					else accept();
				});
			});

			await php.ccall(
				'wasm_sapi_cgi_init'
				, 'number'
				, []
				, []
				, {async: true}
			);

			await this.loadInit(php);

			return php;

		});
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
				await callback(...params).then(accept).catch(reject);
				let lockChecks = 5;
				while(!this.queue.length && lockChecks--)
				{
					await new Promise(a => setTimeout(a, 5));
				}
			} while(this.queue.length)

			await (this.autoTransaction ? this.commitTransaction() : Promise.resolve());
		});

		return coordinator;
	}
}
