const moduleRoot = import.meta.url + (String(import.meta.url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = php => [
	{url: new URL(`./php${php.phpVersion}-mbstring.so`, moduleRoot), ini: true},
	{url: new URL('./libonig.so', moduleRoot)},
];
