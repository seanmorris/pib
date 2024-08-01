import { test } from 'node:test';
import { strict as assert } from 'node:assert';
import { PhpNode } from '../packages/php-wasm/PhpNode.mjs';

test('Can access JS integers via php.r function.', async () => {

	const php = new PhpNode();

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const scalarInt = 321;

	const exitCode = await php.r`<?php var_dump( ${scalarInt} );`;

	assert.equal(exitCode, 0);
	assert.equal(stdOut, `int(321)\n`);
	assert.equal(stdErr, '');
});

test('Can access JS floats via php.r function.', async () => {

	const php = new PhpNode();

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const scalarInt = 321.123;

	const exitCode = await php.r`<?php var_dump( ${scalarInt} );`;

	assert.equal(exitCode, 0);
	assert.equal(stdOut, `float(321.123)\n`);
	assert.equal(stdErr, '');
});

test('Can access JS strings via php.r function.', async () => {

	const php = new PhpNode();

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const scalarString = "this is a string";

	const exitCode = await php.r`<?php var_dump( ${scalarString} );`;

	assert.equal(exitCode, 0);
	assert.equal(stdOut, `string(16) "this is a string"\n`);
	assert.equal(stdErr, '');
});

if('WITH_VRZNO' in PhpNode.phpExtensions)
{
	test('Can access PHP strings via php.x function.', async () => {
		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		const scalarString = "this is a string";

		const returnValue = await php.x`${scalarString}`;
		const returnValueIFFE = await php.x`(function() { return ${scalarString} ; })()`;

		assert.equal(returnValue, `this is a string`);
		assert.equal(returnValueIFFE, `this is a string`);
		assert.equal(stdErr, '');
	});

	test('Can access PHP integers via php.x function.', async () => {
		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		const scalarInt = 321;

		const returnValue = await php.x`${scalarInt}`;
		const returnValueIFFE = await php.x`(function() { return ${scalarInt} ; })()`;

		assert.equal(returnValue, scalarInt);
		assert.equal(returnValueIFFE, scalarInt);
		assert.equal(stdErr, '');
	});

	test('Can access PHP floats via php.x function.', async () => {
		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		const scalarFloat = 321.123;

		// const returnValue = await php.x`${scalarFloat}`;
		// assert.equal(returnValue, scalarFloat);

		const returnValueIFFE = await php.x`(function() { return ${scalarFloat} ; })()`;
		assert.equal(returnValueIFFE, scalarFloat);

		assert.equal(stdErr, '');
	});

	test('Can access JS callbacks via php.r function.', async () => {

		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		class Thing { getString(){ return "This is a value." } }; // This is a Javascript class

		const exitCode = await php.r`<?php var_dump( (new ${ Thing })->getString() );`;

		assert.equal(exitCode, 0);
		assert.equal(stdOut, `string(16) "This is a value."\n`);
		assert.equal(stdErr, '');
	});

	test('Can access JS classes via php.r function.', async () => {

		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		class Thing { getString(){ return "This is a value." } }; // This is a Javascript class

		const exitCode = await php.r`<?php var_dump( (new ${ Thing })->getString() );`;

		assert.equal(exitCode, 0);
		assert.equal(stdOut, `string(16) "This is a value."\n`);
		assert.equal(stdErr, '');

	});

	test('Can access PHP callbacks that return integers via php.x function.', async () => {
		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		const callback = await php.x`function() { return 321; }`;

		const returnValue = callback();

		assert.equal(returnValue, 321);
		assert.equal(stdErr, '');
	});

	test('Can access PHP callbacks that return floats via php.x function.', async () => {
		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		const callback = await php.x`function() { return 321.123; }`;

		const returnValue = callback();

		assert.equal(returnValue, 321.123);
		assert.equal(stdErr, '');
	});

	test('Can access PHP callbacks that return single-character strings via php.x function.', async () => {
		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		const callback = await php.x`function() { return "a"; }`;

		const returnValue = callback();

		assert.equal(returnValue, "a");
		assert.equal(stdErr, '');
	});

	test('Can access PHP callbacks that return multi-character strings via php.x function.', async () => {
		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		const callback = await php.x`function() { return "abcdefg hijklmn op"; }`;

		const returnValue = callback();

		assert.equal(returnValue, "abcdefg hijklmn op");
		assert.equal(stdOut, '');
		assert.equal(stdErr, '');
	});

	test('Can access PHP callbacks that return objects via php.x function.', async () => {

		const php = new PhpNode();

		let stdOut = '', stdErr = '';

		php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
		php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

		await php.binary;

		const callback = await php.x`function() { return (object)["a" => "abcdefg"]; }`;

		const returnValue = callback();

		assert.equal(returnValue.a, "abcdefg");
		assert.equal(stdOut, '');
		assert.equal(stdErr, '');
	});
}
