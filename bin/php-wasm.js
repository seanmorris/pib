#!/usr/bin/env node
const child_process = require('node:child_process');
const fs  = require("fs");
var tty = require('tty');

const args = process.argv.slice(2);
const cwd  = process.cwd();
const rcFile = cwd + '/.php-wasm-rc';

const commands = {};

{ // build
	const build = (flags, envName = 'web', buildType = 'js') => {

		const envNameCap = String(envName[0]).toUpperCase() + envName.substr(1);
		const buildTypeLower = String(buildType).toLowerCase();

		const options = [
			`dist/Php${envNameCap}.${buildTypeLower}`,
			`PHP_DIST_DIR_DEFAULT=${cwd}`,
			`BUILD_TYPE=${buildTypeLower}`,
			`IS_TTY=${tty.isatty(process.stdout.fd) ? 1 : 0}`
		];

		if(fs.existsSync(cwd + '/.php-wasm-rc'))
		{
			options.push(`ENV_FILE=${rcFile}`,);
			child_process.spawn(`touch`, [rcFile], {
				stdio: [ 'inherit', 'inherit', 'inherit' ],
				cwd: __dirname + '/..',
			});
		}

		child_process.spawn(`make`, options, {
			stdio: [ 'inherit', 'inherit', 'inherit' ],
			cwd: __dirname + '/..',
		});
	};

	build.info = `Build php-wasm.`;
	build.help = `Usage: php-wasm build ENV_NAME MODULE_TYPE

	ENV_NAME: [web, node]
	  web: build the web version (default)
	  node: build the nodejs version

	MODULE_TYPE: [js, mjs]
	  mjs: build an es6 module (default)
	  js: build a common js module`;

	commands.build = build;
}

{ //run
	// const run = (flags, file) => {
	// 	const php = new PhpNode;

	// 	php.addEventListener('output', (event) => event.detail.forEach(l => process.stdout.write(l)));
	// 	php.addEventListener('error',  (event) => event.detail.forEach(l => process.stderr.write(l)));
	// 	php.addEventListener('ready', () => php.run(fs.readFileSync(file)));
	// };

	// run.info = 'Run a script in php-wasm.';
	// run.help = `Usage: php-wasm run FILE

	// FILE - File containing the script to run.`

	// commands.run = run;
}

{ // image
	const image = (flags,) => {
		const options = ['image'];
		const subprocess = child_process.spawn(`make`, options, {
			stdio: [ 'inherit', 'inherit', 'inherit' ],
			cwd: __dirname + '/..',
		});
	};

	image.info = 'Create the build environment docker image';
	image.help = `Usage: php-wasm image`

	commands.image = image;
}

{ // clean
	const clean = () => {
		const subprocess = child_process.spawn(`make`, ['deep-clean'], {
			stdio: [ 'inherit', 'inherit', 'inherit' ],
			cwd: __dirname + '/..',
		});
	};

	clean.info = `Clear cached build resources`;
	clean.help = `Usage: php-wasm clean`;

	commands.clean = clean;
}

{ // help
	const help = (flags, command = null) => {
		if(command)
		{
			if(!commands[command])
			{
				console.error(`Error: Cannot print help for "${command}". No such command exists.`);
				return;
			}

			console.error(commands[command].help);
			return;
		}

		console.error('Usage:');
		console.error('php-wasm [COMMAND] [ARG, ...]');
		console.error('');
		console.error('Available commands');
		console.error('');

		for(const [commandName, command] of Object.entries(commands))
		{
			console.error(`  ${commandName}`);
			console.error(`  ${command.info}`);
			console.error('');
		}
	};

	help.info = 'Display helptext for a given command.';
	help.help = `Usage: php-wasm help COMMAND

	COMMAND - Command to print helptext for.`

	commands.help = help;
}

const command = args.shift() || 'help';

const argsToFlags = args => {
	const filterdArgs = [];
	const flags = {};

	args.forEach((arg => {

		if(arg[0] !== '-')
		{
			filterdArgs.push(arg);
			return;
		}

		let offset = 1;

		if(arg[1] === '-')
		{
			offset = 2;
		}

		const index = arg.indexOf('=');

		if(index < 0)
		{
			flags[arg] = true;
			return;
		}

		flags[arg.substr(offset, index - offset)] = arg.substr(1 + index);

		return
	}))

	return [flags, ...filterdArgs];
};

if(!commands[command])
{
	console.error(`Error: No such command: ${command}`);
}
else
{
	commands[command](...argsToFlags(args));
}
