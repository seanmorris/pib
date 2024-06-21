# php-wasm-sqlite

sqlite extenstion for php-wasm.

https://github.com/seanmorris/php-wasm

https://www.npmjs.com/package/php-wasm

## Usage

`php-wasm-sqlite` can be loaded via dynamic imports:

```javascript
const php = new PhpWeb({sharedLibs: [
    await import('https://unpkg.com/php-wasm-sqlite')
]});
```

You can rely on the default loading behavior if all `.so` files are served from the same directory as your `.wasm` files.

```javascript
const php = new PhpWeb({sharedLibs: ['php8.3-sqlite.so']});
```

You can provide a callback as the `locateFile` option to map library names to URLs:

```javascript
const locateFile = (libName) => {
    return `https://my-example-server.site/path/to/libs/${libName}`;
};

const php = new PhpWeb({locateFile, sharedLibs: ['php8.3-sqlite.so']});
```

## Build options:

The following options may be set in `.php-wasm-rc` for custom builds of `php-wasm` & `php-cgi-wasm`.

* WITH_SQLITE

### WITH_SQLITE

`0|static|shared|dynamic`

When compiled as a `dynamic` extension, this will produce the extension `php-8.𝑥-sqlite.so`.
