const moduleRoot = import.meta.url + (String(import.meta.url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = php => [
	{url: new URL(`./php${php.phpVersion}-simplexml.so`, moduleRoot), ini: true},
	{url: new URL(`./php${php.phpVersion}-xml.so`, moduleRoot), ini: true},
	{url: new URL(`./php${php.phpVersion}-dom.so`, moduleRoot), ini: true},
	{url: new URL('./libxml2.so', moduleRoot)},
];
