const importMeta = import.meta;
const url = new URL(importMeta.url);
const ini = !!(Number(  url.searchParams.get('ini') ?? true  ));
const moduleRoot = url + (String(url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = php => [
	{url: new URL(`./php${php.phpVersion}-simplexml.so`, moduleRoot), ini},
	{url: new URL(`./php${php.phpVersion}-xml.so`,       moduleRoot), ini},
	{url: new URL(`./php${php.phpVersion}-dom.so`,       moduleRoot), ini},
	{url: new URL('./libxml2.so', moduleRoot)},
];
