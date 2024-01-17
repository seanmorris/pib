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
			stdout: new EventBuffer(this, 'output', -1),
			stderr: new EventBuffer(this, 'error',  -1),
		} });

		Object.freeze(this.buffers);

		const defaults  = {
			stdin:  () => this.buffers.stdin.shift() ?? null,
			stdout: byte => this.buffers.stdout.push(byte),
			stderr: byte => this.buffers.stderr.push(byte),

			postRun:  () => {
				const event = new _Event('ready');
				this.onready(event);
				this.dispatchEvent(event);
			},
		};

		const phpSettings = globalThis.phpSettings ?? {};

		this.binary = new PhpBinary(Object.assign({}, defaults, phpSettings, args)).then(php => {
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
		return this.binary.then(php =>  {
			const sync = new Promise(accept => {
				php.FS.syncfs(true, err => {
					err && console.error(err);
					accept(err);
				});
			});

			const run = sync.then(() => php.ccall(
				'pib_run'
				, NUM
				, [STR]
				, [`?>${phpCode}`]
				, {async:true}
			));

			return run.then(() => {
				return new Promise(accept => {
					php.FS.syncfs(false, err => {
						err && console.error(err);
						accept(run)
					});
				});
			});
		})
		.finally(() => this.flush());
	}

	exec(phpCode)
	{
		return this.binary.then(php => {
			const sync = new Promise(accept => {
				php.FS.syncfs(true, err => {
					err && console.error(err);
					accept(err);
				});
			});

			const run = sync.then(() => php.ccall(
				'pib_exec'
				, STR
				, [STR]
				, [phpCode]
				, {async:true}
			));

			return run.then(() => {
				return new Promise(accept => {
					return php.FS.syncfs(false, err => {
						err && console.error(err);
						accept(run)
					});
				});
			});
		})
		.finally(() => this.flush());
	}

	refresh()
	{
		const call = this.binary.then(php => php.ccall(
			'pib_refresh'
			, NUM
			, []
			, []
			, {async:true}
		));

		call.catch(error => console.error(error));

		return call;
	}
}

const _Event = globalThis.CustomEvent ?? class extends globalThis.Event
{
	constructor(name, options = {})
	{
		super(name, options)
		this.detail = options.detail;
	}
};

class EventBuffer
{
	constructor(target, eventType, maxLength)
	{
		Object.defineProperty(this, 'target',    {value: target});
		Object.defineProperty(this, 'buffer',    {value: []});
		Object.defineProperty(this, 'eventType', {value: eventType});
		Object.defineProperty(this, 'maxLength', {value: maxLength});
		Object.defineProperty(this, 'decoder',   {value: new TextDecoder()});
	}

	push(...items)
	{
		this.buffer.push(...items);

		const end = this.buffer.length - 1;

		if(this.maxLength === -1 && this.buffer[end] === 10)
		{
			this.flush();
		}

		if(this.maxLength >= 0 && this.buffer.length >= this.maxLength)
		{
			this.flush();
		}
	}

	flush()
	{
		if(!this.buffer.length)
		{
			return;
		}

		const event = new _Event(this.eventType, {
			detail: [this.decoder.decode(new Uint8Array(this.buffer))]
		});

		if(this.target['on' + this.eventType])
		{
			if(this.target['on' + this.eventType](event) === false)
			{
				return;
			}
		}

		if(!this.target.dispatchEvent(event))
		{
			return;
		}

		this.buffer.splice(0);
	}
}
