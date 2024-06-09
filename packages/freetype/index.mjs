const moduleRoot = import.meta.url + (String(import.meta.url).substr(-10) !== '/index.mjs' ? '/' : '');

export const getLibs = () => [{url: new URL('./libfreetype.so', moduleRoot)}];
