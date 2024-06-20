console.error('Deprecated. Use php-tags.mjs');

const importMeta = import.meta;
const moduleRoot = new URL('..', importMeta.url);

import(moduleRoot + '/PhpWeb.mjs').then(({runPhpTags}) => runPhpTags(document));
