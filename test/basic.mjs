import { test } from 'node:test';
import { strict as assert } from 'node:assert';
import { PhpNode } from '../PhpNode.mjs';

test('Can run PHP', async () => {

	const php = new PhpNode();

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php 2 + 2;`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, '');
	assert.equal(stdErr, '');
});

test('Can print to STDOUT', async () => {

	const php = new PhpNode();

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php echo "Hello, World!";`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, 'Hello, World!');
	assert.equal(stdErr, '');
});

test('Can print to STDERR', async () => {

	const php = new PhpNode();

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php file_put_contents("php://stderr", "Hello, World!");`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, '');
	assert.equal(stdErr, 'Hello, World!');
});

test('Can take input on STDIN', async () => {

	const php = new PhpNode();

	let stdOut = '', stdErr = '', stdin = 'This is a string of data provided on STDIN.';

	php.inputString(stdin);

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(`<?php echo file_get_contents('php://stdin');`);

	assert.equal(exitCode, 0);
	assert.equal(stdOut, stdin);
	assert.equal(stdErr, '');
});

