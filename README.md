# WASM PHP

Project based on https://github.com/seanmorris/php-wasm which was forked from https://github.com/oraoto/pib

I fixed some inconsistencies in the Makefile and removed non-essential things. This fork:
  - does build sqlite3
  - does build libxml
  - has no javascript abstraction
  - does not build https://github.com/seanmorris/vrzno which allows javascript access from PHP (TODO add this back opt-in cause it's really cool)
  - does not add preloaded data, having this separatly from php-wasm builds allows for more flexibility (see [preload data section](#preload-data))
  - exposes FS and builds with [IDBFS](https://emscripten.org/docs/api_reference/Filesystem-API.html#FS.syncfs)
  - reduces memory to 256mb

## Usage

Some build

## Build

```
docker build . -t php-wasm
docker create --name=php-wasm php-wasm
docker cp php-wasm:/build/php-web.wasm ./build
docker cp php-wasm:/build/php-web.mjs ./build/php-web.mjs
```

Builded files will be located in `build/php-web.js` and `build/php-web.wasm`.

## Usage

To execute some php, call `pib_exec` using [`ccall`](https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html#interacting-with-code-ccall-cwrap), for example:

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
    'pib_exec'
    , 'string'
    , ['string']
    , [`phpversion();`]
  );
})
```

The builded PHP WASM version exposes these functions that will help you execute PHP: `_pib_init`, `_pib_destroy`, `_pib_run`, `_pib_exec`, `_pib_refresh`. The source code behind them is located under `source/pib_eval.c` and the exported function are declared in the final build command (see `Makefile`).

Thanks to [@seanmorris](https://github.com/seanmorris/php-wasm) you can also use persistent calls to keep things in memory by using:

```javascript
let retVal = ccall(
  'pib_init'
  , NUM
  , [STR]
  , []
);

console.log('PHP initialized', retVal)

function runCode(phpCode) {
  ccall(
    'pib_run'
    , NUM
    , [STR]
    , [`?>${phpCode}`]
  )
}

// Remove things kept in-memory
function refresh() {
  ccall(
    'pib_refresh'
    , NUM
    , []
    , []
  );
}
```

More examples on the code usage are available on [@seanmorris's repository](https://github.com/seanmorris/php-wasm/tree/master/docs-source) or on [APIPlatform By Examples]().

## Preload data

You can build preloaded assets (`PRELOAD_ASSETS=/data`) using `make preload-data`. Then you'll need to add the `php-web.data.js` to the actual `php-web.js` file.

This step on API Platform By Examples is done with the following Makefile using the original file as `php-web.ori.js`:

```make
UID=1000
API_PLATFORM_DIR=examples
DOCKER_RUN=docker run --rm -e ENVIRONMENT=web -v $(CURDIR):/src -v $(CURDIR)/../${API_PLATFORM_DIR}:/src/${API_PLATFORM_DIR} -w /src soyuka/php-emscripten-builder:latest

preload:
	${DOCKER_RUN} python3 /emsdk/upstream/emscripten/tools/file_packager.py ./public/php-web.data --preload "/src/${API_PLATFORM_DIR}" --js-output=./php-wasm/php-web.data.js
	${DOCKER_RUN} chown ${UID} ./php-wasm/php-web.data.js
	sed -e '/function(Module) {/r./php-wasm/php-web.data.js' php-wasm/php-web.ori.js > php-wasm/php-web.js
	rmdir ${API_PLATFORM_DIR}
```

## TODO

- cache libxml and sqlite to speed up builds
- add opt-in / opt-out sqlite libxml vrzno and mb more
