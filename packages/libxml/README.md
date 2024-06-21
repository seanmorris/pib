# php-wasm-libxml

libxml extension for php-wasm

https://github.com/seanmorris/php-wasm

https://www.npmjs.com/package/php-wasm

## Usage

The library `libxml.so` is included by default with `php-wasm`, and will be loaded automatically.

You can rely on the default loading behavior if all `.so` files are served from the same directory as your `.wasm` files.

You can provide a callback as the `locateFile` option to map library names to URLs:

```javascript
const locateFile = (libName) => {
    return `https://my-example-server.site/path/to/libs/${libName}`;
};

const php = new PhpWeb({locateFile});
```

## Build options:

The following options may be set in `.php-wasm-rc` for custom builds of `php-wasm` & `php-cgi-wasm`.

* WITH_LIBXML

### WITH_LIBXML

`0|static|shared`

When compiled as a `shared` libary, this will produce the libary file `libxml.so`.
