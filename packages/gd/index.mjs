const moduleRoot = import.meta.url + (String(import.meta.url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = php => [{url: new URL(`./php${php.phpVersion}-gd.so`, moduleRoot), ini: true},];
