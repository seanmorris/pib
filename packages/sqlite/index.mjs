const moduleRoot = import.meta.url + (String(import.meta.url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = php => [
	{url: new URL('./libsqlite3.so', moduleRoot)},
	{url: new URL(`./php${php.phpVersion}-sqlite.so`, moduleRoot), ini: true},
	{url: new URL(`./php${php.phpVersion}-pdo-sqlite.so`, moduleRoot), ini: true},
];
