import { OutputBuffer } from "./OutputBuffer.mjs";
import { _Event } from "./_Event.mjs";

const STR = 'string';
const NUM = 'number';

export class PhpBase extends EventTarget
{
	constructor(PhpBinary, args = {})
	{
		super();

		const FLAGS = {};

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

		}).catch(error => console.error(error));
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

	run(phpCode)
	{
		return this.binary.then(php => {
			const sync = this.autoTransaction
				? this.startTransaction()
				: Promise.resolve();

			const run = sync.then(() => php.ccall(
				'pib_run'
				, NUM
				, [STR]
				, [`?>${phpCode}`]
				, {async: true}
			));

			return this.autoTransaction
				? run.then(() => this.commitTransaction()).then(() => run)
				: run;
		})
		.finally(() => this.flush());
	}

	exec(phpCode)
	{
		return this.binary.then(php => {
			const sync = this.autoTransaction
				? this.startTransaction()
				: Promise.resolve();

			const run = sync.then(() => php.ccall(
				'pib_exec'
				, STR
				, [STR]
				, [phpCode]
				, {async: true}
			));

			return this.autoTransaction
				? run.then(() => this.commitTransaction()).then(() => run)
				: run;
		})
		.finally(() => this.flush());
	}

	startTransaction()
	{
		return Promise.resolve();
	}

	commitTransaction()
	{
		return Promise.resolve();
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

	refresh()
	{
		const call = this.binary.then(php => {

			for(const callback of php.onRefresh)
			{
				callback();
			}

			return php.ccall(
				'pib_refresh'
				, NUM
				, []
				, []
				, {async:true}
			);
		});

		call.catch(error => console.error(error));

		return call;
	}
}
