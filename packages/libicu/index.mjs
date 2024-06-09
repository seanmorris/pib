const moduleRoot = import.meta.url + (String(import.meta.url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = php => [
	{url: new URL(`./php${php.phpVersion}-intl.so`, moduleRoot), ini: true},
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
