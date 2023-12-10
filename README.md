# WASM PHP

Project based on https://github.com/seanmorris/php-wasm which was forked from https://github.com/oraoto/pib

I fixed some inconsistencies in the Makefile and removed non-essential things. This fork:
  - builds sqlite3
  - builds libxml
  - no javascript abstraction
  - exposes FS and builds with [IDBFS](https://emscripten.org/docs/api_reference/Filesystem-API.html#FS.syncfs)
  - does not build https://github.com/seanmorris/vrzno which allows javascript access from PHP (TODO add this back opt-in cause it's really cool)
  - does not add preloaded data, having this separatly from php-wasm builds allows for more flexibility (see [preload data section](#preload-data))

## Build

```
docker buildx bake
```

Builded files will be located in `build/php-web.js` and `build/php-web.wasm`.
The module we export in this image is called `createPhpModule`.

### Build arguments

Use this as template to build PHP with emscripten. At build these arguments are available:

```console
LIBXML2_TAG=v2.9.10
PHP_BRANCH=PHP-8.3.0
```

The next args are used for [emcc options](https://github.com/soyuka/php-wasm/blob/513f284e1ba8f26d66e08a97291f484b3dd7de1b/Dockerfile#L108) `-sOPTION`
see [settings.js](https://github.com/emscripten-core/emscripten/blob/9bdb310b89472a0f4d64f36e4a79273d8dc7fa98/src/settings.js#L633).
In fact it's even easier for you to set them directly in [the Dockerfile](https://github.com/soyuka/php-wasm/blob/513f284e1ba8f26d66e08a97291f484b3dd7de1b/Dockerfile#L108).

```console
WASM_ENVIRONMENT=web
ASSERTIONS=0
OPTIMIZE=-O2
INITIAL_MEMORY=256mb
JAVASCRIPT_EXTENSION=mjs # change by js if needed
MODULARIZE=1
EXPORT_ES6=1
EXPORT_NAME=createPhpModule
```

### Preload data

My prefered option is to use the [`file_packager`](https://github.com/emscripten-core/emscripten/blob/9bdb310b89472a0f4d64f36e4a79273d8dc7fa98/tools/file_packager) tool to build the preloaded data in a `php-web.data.js` (and `php-web.data` file). These are preloaded into IDBFS. That can be changed changing the `-lidbfs.js` argument to `emcc`.

This will preload `SOME_DIR` into the `/src` directory inside the WASM filesystem:

```
mkdir -p php-wasm
docker run -v SOME_DIR:/src -v $(pwd)/php-wasm:/dist -w /dist soyuka/php-wasm:8.2.9 python3 /emsdk/upstream/emscripten/tools/file_packager.py php-web.data --use-preload-cache --lz4 --preload "/src" --js-output=php-web.data.js --no-node --exclude '*/.*' --export-name=createPhpModule
ls php-wasm/
```

Note that the `php-web.data.js` must be either used as `PRE_JS` argument to emcc or it needs to be included inside the `php-web.js`:

```
sed '/--pre-js/r php-wasm/php-web.data.js' php-wasm/php-web.mjs > this-has-preloaded-data-php-web.mjs
```

We match the `export-name` with the emcc `EXPORT_NAME` option. Use excludes to downsize the preloaded data weight.

## Usage

To execute some php, call `phpw_exec` using [`ccall`](https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html#interacting-with-code-ccall-cwrap), for example:

```javascript
const phpBinary = require('build/php-web');

return phpBinary({
    onAbort: function(reason) {
      console.error('WASM aborted: ' + reason)
    },
    print: function (...args) {
      console.log('stdout: ', args)
    },
    printErr: function (...args) {
      console.log('stderr: ', args)
    }
})
.then(({ccall, FS}) => {
  const phpVersion = ccall(
    'phpw_exec'
    , 'string'
    , ['string']
    , [`phpversion();`]
  );
})
```

### API

```javascript
phpw_exec(string code): string
phpw_run(string code): void
phpw(string filePath): void
```

### Example calls:


```javascript
const STR = 'string';
ccall("phpw", null, [STR], ["public/index.php"]);
console.log(ccall("phpw_exec", STR, [STR], ["phpversion();"]));
```

[More about how to call exposed functions](https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html?highlight=call#interacting-with-code-ccall-cwrap)

## TODO

- add opt-in / opt-out sqlite libxml vrzno and mb more
