import { UniqueIndex } from './UniqueIndex';

const STR = 'string';
const NUM = 'number';

const _Event = globalThis.CustomEvent ?? class extends globalThis.Event
{
	constructor(name, options = {})
	{
		super(name, options)
		this.detail = options.detail;
	}
};

export class PhpBase extends EventTarget
{
	constructor(PhpBinary, args = {})
	{
		super();

		const FLAGS = {};

		this.onerror  = function () {};
		this.onoutput = function () {};
		this.onready  = function () {};

		const callbacks = new UniqueIndex;
		const targets   = new UniqueIndex;
		const zvals     = new Map;

		const defaults  = {

			callbacks, targets,

			postRun:  () => {
				const event = new _Event('ready');
				this.onready(event);
				this.dispatchEvent(event);
			},

			print: (...chunks) =>{
				const event = new CustomEvent('output', {detail: chunks.map(c=>c+"\n")});
				this.onoutput(event);
				this.dispatchEvent(event);
			},

			printErr: (...chunks) => {
				const event = new CustomEvent('error', {detail: chunks.map(c=>c+"\n")});
				this.onerror(event);
				this.dispatchEvent(event);
			}
		};

		const phpSettings = globalThis.phpSettings ?? {};

		this.binary = new PhpBinary(Object.assign({}, defaults, phpSettings, args)).then(php=>{

			const retVal = php.ccall(
				'pib_init'
				, NUM
				, [STR]
				, []
			);

			return php;

		}).catch(error => console.error(error));
	}

	run(phpCode)
	{
		return this.binary.then(php => php.ccall(
			'pib_run'
			, NUM
			, [STR]
			, [`?>${phpCode}`]
		));
	}

	exec(phpCode)
	{
		return this.binary.then(php => php.ccall(
			'pib_exec'
			, STR
			, [STR]
			, [phpCode]
		));
	}

	refresh()
	{
		const call = this.binary.then(php => php.ccall(
			'pib_refresh'
			, NUM
			, []
			, []
		));

		call.catch(error => console.error(error));

		return call;
	}
}
