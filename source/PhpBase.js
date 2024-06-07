import { phpVersion } from "./config";
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

		this.sharedLibs = args.sharedLibs || [];
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

		const userLocateFile = args.locateFile || (() => undefined);

		const urlLibs = {};

		if(args.sharedLibs)
		{
			args.sharedLibs.forEach(libDef => {
				if(typeof libDef === 'string') {
					if(libDef.substr(0, 1) == '/'
						|| libDef.substr(0, 2) == './'
						|| libDef.substr(0, 8) == 'https://'
						|| libDef.substr(0, 7) == 'http://'
					){
						urlLibs[ libDef.split('/').pop() ] = libDef;
					}
				}
				else if(typeof libDef === 'object') {
					const name = libDef.name ?? libDef.url.split('/').pop();
					urlLibs[ name ] = libDef.url;
				}
			});

			console.log(urlLibs);
		}

		args.locateFile = path => {
			let located = userLocateFile(path);
			if(located !== undefined)
			{
				return located;
			}
			if(urlLibs[path])
			{
				return urlLibs[path];
			}
		};

		this.binary = new PhpBinary(Object.assign({}, defaults, phpSettings, args, fixed)).then(async php => {

			await php.ccall(
				'pib_storage_init'
				, NUM
				, []
				, []
				, {async: true}
			);

			if(this.sharedLibs.length)
			{
				const iniLines = this.sharedLibs.map(lib => {
					if(typeof lib === 'string')
					{
						return `extension=${lib}`;
					}
					else if(typeof lib === 'object' && lib.ini)
					{
						return `extension=${lib.url.split('/').pop()}`;
					}
				}).filter(x=>x);

				args.ini && iniLines.push(args.ini.replace(/\n\s+/g, '\n'));

				await fsOps.writeFile(php, '/php.ini', iniLines.join("\n") + "\n", {encoding: 'utf8'});
			}

			await php.ccall(
				'pib_init'
				, NUM
				, []
				, []
				, {async: true}
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

		const _accept = result => accept(result);
		const _reject = reason => reject(reason);

		this.queue.push([callback, params, _accept, _reject]);

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

	readFile(path, options)
	{
		return this._enqueue(fsOps.readFile, [this.binary, path, options]);
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
}

PhpBase.phpVersion = phpVersion;
