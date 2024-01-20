import { PhpBase } from './PhpBase';
import PhpBinary from './php-node';
import path from 'node:path';
import url from 'node:url';
import fs from 'node:fs';

export class PhpNode extends PhpBase
{
	constructor(args = {})
	{
		let dir;

		if(typeof __dirname === 'undefined')
		{
			dir = path.dirname(url.fileURLToPath(import.meta.url));
		}
		else
		{
			dir = __dirname;
		}

		const locateFile = wasmBinary => path.resolve(dir, wasmBinary);

		super(PhpBinary, {...args, locateFile});
	}

	run(phpCode)
	{
		return this.binary.then(php => {

			const sync = !php.persist
				? Promise.resolve()
				: new Promise(accept => php.FS.syncfs(true, err => {
					if(err) console.warn(err);
					accept();
				}));

			const run = sync.then(() => super.run(phpCode));

			if(!php.persist)
			{
				return run;
			}

			return run.then(() => new Promise(accept => php.FS.syncfs(false, err => {
				if(err) console.warn(err);
				accept(run);
			})));
		})
		.finally(() => this.flush());
	}

	exec(phpCode)
	{
		return this.binary.then(php => {
			const sync = new Promise(accept => php.FS.syncfs(true, err => {
				if(err) console.warn(err);
				accept();
			}));

			const run = sync.then(() =>super.exec(phpCode));

			return run.then(() => new Promise(accept => php.FS.syncfs(false, err => {
				if(err) console.warn(err);
				accept(run);
			})));
		})
		.finally(() => this.flush());
	}
}
