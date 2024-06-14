const importMeta = import.meta;
const url = new URL(importMeta.url);
const ini = !!(Number(  url.searchParams.get('ini') ?? true  ));
const moduleRoot = url + (String(url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = php => [
	{url: new URL(`./php${php.phpVersion}-intl.so`, moduleRoot), ini},
	{url: new URL('./libicuuc.so',   moduleRoot)},
	{url: new URL('./libicutu.so',   moduleRoot)},
	{url: new URL('./libicutest.so', moduleRoot)},
	{url: new URL('./libicuio.so',   moduleRoot)},
	{url: new URL('./libicui18n.so', moduleRoot)},
	{url: new URL('./libicudata.so', moduleRoot)},
];

export const getFiles = () => [
	{
		path:  '/preload/icudt72l.dat'
		, url: new URL('./icudt72l.dat', moduleRoot)
	},
];
