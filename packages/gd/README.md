# php-wasm-gd

gd for php-wasm

https://github.com/seanmorris/php-wasm

https://www.npmjs.com/package/php-wasm

## Usage

`php-wasm-gd` can be loaded via dynamic imports:

```javascript
const php = new PhpWeb({sharedLibs: [
    await import('https://unpkg.com/php-wasm-gd')
]});
```

The supporting libraries `libfreetype.so`, `libjpeg.so`, and `libpng.so` will automatically be pulled from the package.

You can rely on the default loading behavior if all `.so` files are served from the same directory as your `.wasm` files.

```javascript
const php = new PhpWeb({sharedLibs: ['php8.3-gd.so']});
```

You can provide a callback as the `locateFile` option to map library names to URLs:

```javascript
const locateFile = (libName) => {
    return `https://my-example-server.site/path/to/libs/${libName}`;
};

const php = new PhpWeb({locateFile, sharedLibs: ['php8.3-gd.so']});
```

## Build options:

The following options may be set in `.php-wasm-rc` for custom builds of `php-wasm` & `php-cgi-wasm`.

* WITH_GD
* WITH_FREETYPE
* WITH_LIBJPEG
* WITH_LIBPNG (requires WITH_ZLIB)

### WITH_GD

`0|static|dynamic`

When compiled as a `dynamic` extension, this will produce the extension `php-8.x-gd.so`.

### WITH_LIBPNG

`0|static|shared`

When compiled as a `shared` library, this will produce the library `libpng.so`.

If WITH_GD is dynamic, then loading will be deferred until after gd is loaded.

### WITH_FREETYPE

`0|static|shared`

When compiled as a `shared` library, this will produce the library `libfreetype.so`.

If WITH_GD is dynamic, then loading will be deferred until after gd is loaded.

### WITH_LIBJPEG

`0|static|shared`

When compiled as a `shared` library, this will produce the library `libjpeg.so`.

If WITH_GD is dynamic, then loading will be deferred until after gd is loaded.
