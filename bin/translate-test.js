const fs = require('node:fs');
const readline = require('node:readline');

async function translate()
{
	const input = fs.createReadStream(process.argv[2]);
	const reader = readline.createInterface({input, crlfDelay: Infinity});
	const sections = {};

	let currentSection = null;

	for await (const line of reader)
	{
		if(line.match(/^--\w+--$/))
		{
			currentSection = line.substring(2).substring(0, line.length - 4);
			sections[currentSection] = '';
			continue;
		}

		if(!currentSection)
		{
			continue;
		}

		sections[currentSection] += line + "\n";
	}

	console.log(`import { test } from 'node:test';
import { strict as assert } from 'node:assert';
import { PhpNode } from '../../../packages/php-wasm/PhpNode.mjs';

test(${JSON.stringify(String(sections.TEST).trim())}, async () => {
	const php = new PhpNode( { persist: { mountPath: '/persist', localPath: process.cwd() + '/test/' } } );

	let stdOut = '', stdErr = '';

	php.addEventListener('output', (event) => event.detail.forEach(line => void (stdOut += line)));
	php.addEventListener('error',  (event) => event.detail.forEach(line => void (stdErr += line)));

	await php.binary;

	const exitCode = await php.run(${JSON.stringify(sections.FILE)});

	assert.equal(exitCode, 0);
	assert.equal(stdOut, ${JSON.stringify(sections.EXPECT)});
	assert.equal(stdErr, '');

});
`);
}

translate();
