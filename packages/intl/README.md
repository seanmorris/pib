# php-wasm-intl

intl extenstion for php-wasm, includes libicu.

https://github.com/seanmorris/php-wasm

https://www.npmjs.com/package/php-wasm

## Usage

`php-wasm-intl` can be loaded via dynamic imports:

```javascript
const php = new PhpWeb({sharedLibs: [
    await import('https://unpkg.com/php-wasm-intl')
]});
```

The following supporting libraries will automatically be pulled from the package:

* libicuuc.so
* libicutu.so
* libicutest.so
* libicuio.so
* libicui18n.so
* libicudata.so

You can rely on the default loading behavior if all `.so` files are served from the same directory as your `.wasm` files.

```javascript
const php = new PhpWeb({sharedLibs: ['php8.3-intl.so']});
```

## Data files

If you're loading the library manually, you'll need to load `icudt72l.dat` into the  `/preload` directory:

```javascript
const sharedLibs = [`https://unpkg.com/php-wasm-intl/php\${PHP_VERSION}-intl.so`];

const files = [
    {
        name: 'icudt72l.dat',
        parent: '/preload/',
        url: 'https://unpkg.com/php-wasm-intl/icudt72l.dat'
    }
];

const php = new PhpWeb({sharedLibs, files});
```

You can provide a callback as the `locateFile` option to map library names to URLs:

```javascript
const locateFile = (libName) => {
    return `https://my-example-server.site/path/to/libs/${libName}`;
};

const php = new PhpWeb({locateFile, sharedLibs: ['php8.3-intl.so']});
```

## Build options:

The following options may be set in `.php-wasm-rc` for custom builds of `php-wasm` & `php-cgi-wasm`.

* WITH_INTL

### WITH_INTL

`0|static|shared|dynamic`

When compiled as a `dynamic`, or `shared` extension, this will produce the extension `php-8.𝑥-intl.so` & the following libraries:

* libicuuc.so
* libicutu.so
* libicutest.so
* libicuio.so
* libicui18n.so
* libicudata.so

The following data file will also be produced, and should be loaded to the `/preload` directory:

* icudt72l.dat
