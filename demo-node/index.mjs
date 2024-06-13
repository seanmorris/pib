#!/usr/bin/env node
import http from 'http';
import { PhpCgiNode } from 'php-cgi-wasm/PhpCgiNode.mjs';

const php = new PhpCgiNode({
	persist: [
		{mountPath: '/persist' , localPath: './persist'}
		, {mountPath: '/config' , localPath: './config'}
	],
	sharedLibs: [
		await import('php-wasm-sqlite')
		, await import('php-wasm-libxml')
	]
});

const server = http.createServer(async (request, response) => {
	const result = await php.request(request);
	const reader = result.body.getReader();

	response.writeHead(result.status, [...result.headers.entries()].flat());

	let done = false;

	while (!done)
	{
		const chunk = await reader.read();
		done = chunk.done;
		chunk.value && response.write(chunk.value);
	}

	response.end();
});

server.listen(3003);
