const importMeta = import.meta;
import(new URL('./PhpWeb.mjs', importMeta.url) + '').then(({runPhpTags}) => runPhpTags(document));
