const moduleRoot = import.meta.url + (String(import.meta.url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = php => [
	{url: new URL(`./php${php.phpVersion}-openssl.so`, moduleRoot), ini: true},
	{url: new URL('./libssl.so', moduleRoot)},
	{url: new URL('./libcrypto.so', moduleRoot)},
];
