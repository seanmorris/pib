import { PhpBase } from './PhpBase';
import PhpBinary from './php-web';
import { commitTransaction, startTransaction } from './webTransactions';

export class PhpWeb extends PhpBase
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

	async refresh()
	{
		super.refresh();
		const php = await this.binary;
		await navigator.locks.request('php-wasm-fs-lock', async () => {
			return new Promise((accept, reject) => {
				php.FS.syncfs(true, error => {
					if(error) reject(error);
					else accept();
				});
			});
		});
	}

	async _enqueue(callback, params = [])
	{
		let accept, reject;

		const coordinator = new Promise((a,r) => [accept, reject] = [a, r]);

		const _accept = result => accept(result);
		const _reject = reason => reject(reason);

		this.queue.push([callback, params, _accept, _reject]);

		navigator.locks.request('php-wasm-fs-lock', async () => {
			if(!this.queue.length)
			{
				return;
			}

			await (this.autoTransaction ? this.startTransaction() : Promise.resolve());

			do
			{
				const [callback, params, accept, reject] = this.queue.shift();
				const run = callback(...params);
				run.then(accept).catch(reject);
				await run;
			} while(this.queue.length)

			await (this.autoTransaction ? this.commitTransaction() : Promise.resolve());
		});

		return coordinator;
	}
}

const runPhpScriptTag = element => {

	const scope = {stdin: null, stdout: null, stderr: null, ini: '', libs: []};

	if(element.hasAttribute('data-stdout'))
	{
		scope.stdout = document.querySelector(element.getAttribute('data-stdout'));
	}

	if(element.hasAttribute('data-stderr'))
	{
		scope.stderr = document.querySelector(element.getAttribute('data-stderr'));
	}

	if(element.hasAttribute('data-stdin'))
	{
		scope.stdin = document.querySelector(element.getAttribute('data-stdin'));
	}

	if(element.hasAttribute('data-ini'))
	{
		scope.ini = element.getAttribute('data-ini');
	}

	if(element.hasAttribute('data-libs'))
	{
		try
		{
			scope.libs = JSON.parse(element.getAttribute('data-libs'));
		}
		catch(error)
		{
			console.error(error);
		}
	}

	let stdout = '';
	let stderr = '';
	let ran = false;

	let getCode = Promise.resolve(element.innerText);

	if(element.hasAttribute('src'))
	{
		getCode = fetch(element.getAttribute('src')).then(response => response.text());
	}

	let getInput = Promise.resolve('');

	if(scope.stdin)
	{
		getInput = Promise.resolve(scope.stdin.innerText);

		if(scope.stdin.hasAttribute('src'))
		{
			getInput = fetch(scope.stdin.getAttribute('src')).then(response => response.text());
		}
	}

	const getAll = Promise.all([getCode, getInput]);

	getAll.then(([code, input,]) => {
		const php = new PhpWeb({sharedLibs: scope.libs, ini: scope.ini});

		php.inputString(input);

		const outListener = event => {

			stdout += event.detail;

			if(ran && scope.stdout)
			{
				scope.stdout.innerHTML = stdout;
			}
		};

		const errListener = event => {

			stderr += event.detail;

			if(ran && scope.stderr)
			{
				scope.stderr.innerHTML = stderr;
			}
		};

		php.addEventListener('output', outListener);
		php.addEventListener('error',  errListener);

		php.addEventListener('ready', () => {
			php.run(code)
			.then(exitCode => console.log(exitCode))
			.catch(error => console.warn(error))
			.finally(() => {
				ran = true;
				php.flush();
				scope.stdout && (scope.stdout.innerHTML = stdout);
				scope.stderr && (scope.stderr.innerHTML = stderr);
			});
		});
	});
}

const phpSelector = 'script[type="text/php"]';

export const runPhpTags = (doc) => {

	const phpNodes = doc.querySelectorAll(phpSelector);

	for(const phpNode of phpNodes)
	{
		runPhpScriptTag(phpNode);
	}

	const observer = new MutationObserver((mutations, observer) => {
		for(const mutation of mutations)
		{
			for(const addedNode of mutation.addedNodes)
			{
				if(!addedNode.matches || !addedNode.matches(phpSelector))
				{
					continue;
				}

				runPhpScriptTag(addedNode);
			}
		}
	});

	observer.observe(document.body.parentElement, {childList: true, subtree: true});
}
