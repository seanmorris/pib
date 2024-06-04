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

	const tags = {stdin: null, stdout: null, stderr: null};

	if(element.hasAttribute('data-stdout'))
	{
		tags.stdout = document.querySelector(element.getAttribute('data-stdout'));
	}

	if(element.hasAttribute('data-stderr'))
	{
		tags.stderr = document.querySelector(element.getAttribute('data-stderr'));
	}

	if(element.hasAttribute('data-stdin'))
	{
		tags.stdin = document.querySelector(element.getAttribute('data-stdin'));
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

	if(tags.stdin)
	{
		getInput = Promise.resolve(tags.stdin.innerText);

		if(tags.stdin.hasAttribute('src'))
		{
			getInput = fetch(tags.stdin.getAttribute('src')).then(response => response.text());
		}
	}

	const getAll = Promise.all([getCode, getInput]);

	getAll.then(([code, input,]) => {
		const php = new PhpWeb;

		php.inputString(input);

		const outListener = event => {

			stdout += event.detail;

			if(ran && tags.stdout)
			{
				tags.stdout.innerHTML = stdout;
			}
		};

		const errListener = event => {

			stderr += event.detail;

			if(ran && tags.stderr)
			{
				tags.stderr.innerHTML = stderr;
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
				tags.stdout && (tags.stdout.innerHTML = stdout);
				tags.stderr && (tags.stderr.innerHTML = stderr);
			});
		});
	});
}

const phpSelector = 'script[type="text/php"]';

export const runPhpTags = (doc) => {

	const phpNodes = doc.querySelectorAll(phpSelector);

	for(const phpNode of phpNodes)
	{
		const code = phpNode.innerText.trim();

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
