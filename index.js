#!/usr/bin/env node

const child_process = require('node:child_process');
const fs  = require("fs");

const args = process.argv.slice(2);
const cwd  = process.cwd();

const rcFile = cwd + '/.php-wasm-rc';

if(fs.existsSync(cwd + '/.php-wasm-rc'))
{
	const subprocess = child_process.spawn(`make`, ['dist/php-web.js', `ENV_FILE=${rcFile}`, `PHP_DIST_DIR_DEFAULT=${cwd}`], {
		stdio: [ 'inherit', 'inherit', 'inherit' ],
		cwd: __dirname,
	});
}
else
{
	const subprocess = child_process.spawn(`make`, ['dist/php-web.js', `PHP_DIST_DIR_DEFAULT=${cwd}`], {
		stdio: [ 'inherit', 'inherit', 'inherit' ],
		cwd: __dirname,
	});
}
