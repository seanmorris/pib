import { test } from 'node:test';
import { strict as assert } from 'node:assert';
import { PhpNode } from '../../../packages/php-wasm/PhpNode.mjs';

test('Intl Extension is enabled.', async () => {
	const php = new PhpNode();

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php var_dump(extension_loaded('intl'));`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, `bool(true)\n`);
	assert.equal(stdErr, '');

});

test('Intl can format numbers.', async () => {
	const php = new PhpNode();

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
