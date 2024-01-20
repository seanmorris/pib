import { PhpBase } from './PhpBase';
import PhpBinary from './php-web-drupal';

export class PhpWebDrupal extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
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
