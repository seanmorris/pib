import { test } from 'node:test';
import { strict as assert } from 'node:assert';
import { PhpNode } from '../../../packages/php-wasm/PhpNode.mjs';

test('Intl Extension is enabled. (explicit)', async () => {
	const php = process.env.WITH_ICU === 'dynamic'
		? new PhpNode({
			sharedLibs:[`php${PhpNode.phpVersion}-intl.so`]
			, files: [{parent: '/preload/', name: 'icudt72l.dat', url: './node_modules/php-wasm-libicu/icudt72l.dat'}]
		})
		: new PhpNode;

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php var_dump(extension_loaded('intl'));`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, `bool(true)\n`);
	assert.equal(stdErr, '');
});

test('Intl can format numbers. (explicit)', async () => {
	const php = process.env.WITH_ICU === 'dynamic'
		? new PhpNode({
			sharedLibs:[`php${PhpNode.phpVersion}-intl.so`]
			, files: [{parent: '/preload/', name: 'icudt72l.dat', url: './node_modules/php-wasm-libicu/icudt72l.dat'}]
		})
		: new PhpNode;

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php
		$formatter = new \NumberFormatter("en-US", \NumberFormatter::CURRENCY);
		var_dump($formatter->format(100.00));
	`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, `string(7) "$100.00"\n`);
	assert.equal(stdErr, '');

});

test('Intl Extension is enabled. (module loader)', async () => {
	const php = process.env.WITH_ICU === 'dynamic'
		? new PhpNode({sharedLibs:[ await import('php-wasm-libicu') ]})
		: new PhpNode;

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php var_dump(extension_loaded('intl'));`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, `bool(true)\n`);
	assert.equal(stdErr, '');
});

test('Intl can format numbers. (module loader)', async () => {
	const php = process.env.WITH_ICU === 'dynamic'
		? new PhpNode({sharedLibs:[ await import('php-wasm-libicu') ]})
		: new PhpNode;

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php
		$formatter = new \NumberFormatter("en-US", \NumberFormatter::CURRENCY);
		var_dump($formatter->format(100.00));
	`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, `string(7) "$100.00"\n`);
	assert.equal(stdErr, '');

});
