import { OutputBuffer } from "./OutputBuffer";
import { _Event } from "./_Event";
import { fsOps } from './fsOps';

const STR = 'string';
const NUM = 'number';

export class PhpBase extends EventTarget
{
	constructor(PhpBinary, args = {})
	{
		super();

		this.queue  = [];

		this.onerror  = function () {};
		this.onoutput = function () {};
		this.onready  = function () {};

		Object.defineProperty(this, 'encoder', {value: new TextEncoder()});
		Object.defineProperty(this, 'buffers', {value: {
			stdin: [],
			stdout: new OutputBuffer(this, 'output', -1),
			stderr: new OutputBuffer(this, 'error',  -1),
		} });

		Object.freeze(this.buffers);

		this.autoTransaction = ('autoTransaction' in args) ? args.autoTransaction : true;
		this.transactionStarted = false;

		const defaults = {
			stdin:  () => this.buffers.stdin.shift() ?? null,
			stdout: byte => this.buffers.stdout.push(byte),
			stderr: byte => this.buffers.stderr.push(byte),

			postRun:  () => {
				const event = new _Event('ready');
				this.onready(event);
				this.dispatchEvent(event);
			},
		};

		const fixed = { onRefresh: new Set };

		const phpSettings = globalThis.phpSettings ?? {};

		this.binary = new PhpBinary(Object.assign({}, defaults, phpSettings, args, fixed)).then(php => {
			const retVal = php.ccall(
				'pib_init'
				, NUM
				, [STR]
				, []
			);

			return php;
		});
	}

	inputString(byteString)
	{
		this.input(this.encoder.encode(byteString));
	}

	input(items)
	{
		this.buffers.stdin.push(...items);
	}

	flush()
	{
		this.buffers.stdout.flush();
		this.buffers.stderr.flush();
	}

	tokenize(phpCode)
	{
		return this.binary
		.then(php => php.ccall(
			'pib_tokenize'
			, STR
			, [STR]
			, [phpCode]
			, {async: true}
		));
	}

	startTransaction()
	{
		return Promise.resolve();
	}

	commitTransaction()
	{
		return Promise.resolve();
	}

	async _enqueue(callback, params = [])
	{
		let accept, reject;

		const coordinator = new Promise((a,r) => [accept, reject] = [a, r]);

		this.queue.push([callback, params, accept, reject]);

		if(!this.queue.length)
		{
			return;
		}

		await this.autoTransaction ? this.startTransaction() : Promise.resolve();

		while(this.queue.length)
		{
			const [callback, params, accept, reject] = this.queue.shift();
			await callback(...params).then(accept).catch(reject);
		}

		await this.autoTransaction ? this.commitTransaction() : Promise.resolve();

		return coordinator;
	}

	run(phpCode)
	{
		return this._enqueue(phpCode => this._run(phpCode), [phpCode]);
	}

	async _run(phpCode)
	{
		return await (await this.binary).ccall(
				'pib_run'
				, NUM
				, [STR]
				, [`?>${phpCode}`]
				, {async: true}
		)
		.finally(() => this.flush());
	}

	exec(phpCode)
	{
		return this._enqueue(phpCode => this._exec(phpCode), [phpCode]);
	}

	async _exec(phpCode)
	{
		return (await this.binary).ccall(
				'pib_exec'
				, STR
				, [STR]
				, [phpCode]
				, {async: true}
		)
		.finally(() => this.flush());
	}

	async refresh()
	{
		const php = await this.binary;

		for(const callback of php.onRefresh)
		{
			callback();
		}

		await php.ccall(
			'pib_refresh'
			, NUM
			, []
			, []
			, {async:true}
		);
	}

	analyzePath(path)
	{
		return this._enqueue(fsOps.analyzePath, [this.binary, path]);
	}

	readdir(path)
	{
		return this._enqueue(fsOps.readdir, [this.binary, path]);
	}

	readFile(path)
	{
		return this._enqueue(fsOps.readFile, [this.binary, path]);
	}

	stat(path)
	{
		return this._enqueue(fsOps.stat, [this.binary, path]);
	}

	mkdir(path)
	{
		return this._enqueue(fsOps.mkdir, [this.binary, path]);
	}

	rmdir(path)
	{
		return this._enqueue(fsOps.rmdir, [this.binary, path]);
	}

	rename(path, newPath)
	{
		return this._enqueue(fsOps.rename, [this.binary, path, newPath]);
	}

	writeFile(path, data, options)
	{
		return this._enqueue(fsOps.writeFile, [this.binary, path, data, options]);
	}

	unlink(path)
	{
		return this._enqueue(fsOps.unlink, [this.binary, path]);
	}

	// analyzePath(path)
	// {
	// 	return this._enqueue(path => this._analyzePath(path), [path]);
	// }

	// _analyzePath(path)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.analyzePath(this.binary, path);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }

	// readdir(path)
	// {
	// 	return this._enqueue(path => this._readdir(path), [path]);
	// }

	// _readdir(path)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.readdir(this.binary, path);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }

	// readFile(path)
	// {
	// 	return this._enqueue(path => this._readFile(path), [path]);
	// }

	// _readFile(path)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.readFile(this.binary, path);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }

	// stat(path)
	// {
	// 	return this._enqueue(path => this._stat(path), [path]);
	// }

	// _stat(path)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.stat(this.binary, path);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }

	// mkdir(path)
	// {
	// 	return this._enqueue(path => this._mkdir(path), [path]);
	// }

	// _mkdir(path)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.mkdir(this.binary, path);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }

	// rmdir(path)
	// {
	// 	return this._enqueue(path => this._rmdir(path), [path]);
	// }

	// _rmdir(path)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.rmdir(this.binary, path);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }

	// rename(path, newPath)
	// {
	// 	return this._enqueue((path, newPath) => this._rename(path, newPath), [path, newPath]);
	// }

	// _rename(path, newPath)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.rename(this.binary, path, newPath);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }

	// writeFile(path, data, options)
	// {
	// 	return this._enqueue((path, data, options) => this._writeFile(path, data, options), [path, data, options]);
	// }

	// _writeFile(path, data, options)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.writeFile(this.binary, path, data, options);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }

	// unlink(path)
	// {
	// 	return this._enqueue(path => this._unlink(path), [path]);
	// }

	// _unlink(path)
	// {
	// 	return this.binary.then(php => {
	// 		const sync = this.autoTransaction
	// 			? this.startTransaction()
	// 			: Promise.resolve();

	// 		const run = fsOps.unlink(this.binary, path);

	// 		return this.autoTransaction
	// 			? run.then(() => this.commitTransaction()).then(() => run)
	// 			: run;
	// 	})
	// 	.finally(() => this.flush());
	// }
}
