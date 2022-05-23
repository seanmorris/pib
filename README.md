# PIB: PHP in Browser (and Node.js) aka php-wasm


![php-wasm](https://img.shields.io/npm/v/php-wasm?color=609&label=PIB%2Fphp-wasm&style=for-the-badge)
[![Apache-2.0 Licence Badge](https://img.shields.io/npm/l/cv3-inject?logo=apache&color=338800&style=for-the-badge)](https://github.com/seanmorris/php-wasm/blob/master/LICENSE)

[![CircleCI](https://img.shields.io/circleci/build/github/seanmorris/php-wasm?logo=circleci&logoColor=white&style=for-the-badge&token=b52ac489d3c2d170963021c81ecd422b7536f41c)](https://circleci.com/gh/seanmorris/php-wasm/) ![Size](https://img.shields.io/github/languages/code-size/seanmorris/php-wasm?logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAABQAAAAOCAQAAACFzfR7AAABF0lEQVQoFQXBQWvOAQDA4ef/7o29YWtqKU7ExWE5OIvm4LKcnXwD7aQ0N/kAczO1i1KOO0xJvQojaTm4KbJabnJysLSf5wFAa603CUB322yOAAitVT86BTTQ1+oJDYDQcv+qFRr3vC1ooYPqDkHoYgfVKmnSfhG62t/qBkHn2q8ekjRpryB0v/rZ2eh4r6tpY5pp3Gx7RTONoJfVLnpQfekYtNG0832rRj3tEaT31bOxQ5wc/oATrnnniEMfXfaZDFrAoEk71XajNN9OVVW7HYVeVZ9AF/pd3YPm267qbYs0tF597wygpaquQ7Nt9QLoVlWXCEK3q1oCCF2p6iYBpKGN6kNzATrdr2qVAACa9rgRQKPetAnAf1jX/qSkN8aIAAAAAElFTkSuQmCC&style=for-the-badge)

### v0.0.5 - Alignment.


[changelog](https://raw.githubusercontent.com/seanmorris/php-wasm/master/CHANGELOG.md)

## Examples

+ [Hello, World](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250Aecho%2520%2522Hello%252C%2520World%21%2522%253B)
+ [phpinfo()](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520phpinfo%28%29%253B&persist=0&render-as=html&single-expression=0)
+ [Persistent Memory](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%2524c%252B%252B%253B%2520%252F%252F%2520run%2520this%2520over%2520and%2520over%2520again&persist=1&single-expression=1)
+ [Access The DOM](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%2524oldTitle%2520%253D%2520NULL%253B%250A%2524newTitle%2520%253D%2520%27Changed%2540%27%2520.%2520date%28%27h%253Ai%253As%27%29%253B%250A%250A%252F%252F%2520Grab%2520the%2520current%2520title%250A%2524oldTitle%2520%253D%2520vrzno_eval%28%27document.title%27%29%253B%250A%250A%252F%252F%2520Change%2520the%2520document%2520title%250A%2524newTitle%2520%253D%2520vrzno_eval%28%27document.title%2520%253D%2520%2522%27%2520.%2520%2524newTitle%2520.%2520%27%2522%27%2520%29%253B%250A%250Aprintf%28%250A%2520%2520%2520%2520%27Title%2520changed%2520from%2520%2522%2525s%2522%2520to%2520%2522%2525s%2522.%27%250A%2520%2520%2520%2520%252C%2520%2524oldTitle%250A%2520%2520%2520%2520%252C%2520%2524newTitle%250A%29%253B%250A%250A%250A%252F%252F%2520Show%2520an%2520alert%250Avrzno_run%28%27alert%27%252C%2520%255B%27Hello%252C%2520World%21%27%255D%29%253B)
+ [goto](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%2524x%2520%253D%2520false%253B%250A%250Aa%253A%250A%250Aif%28%21%2524x%29%250A%257B%250A%2520%2520%2520%2520goto%2520b%253B%250A%257D%250A%250Aecho%2520%27Foo%27%253B%250A%250Agoto%2520c%253B%250A%2520%250Ab%253A%250A%250Aecho%2520%27Bar%27%253B%250A%250Aif%28%21%2524x%29%250A%257B%250A%2520%2520%2520%2520%2524x%2520%253D%2520true%253B%250A%2520%2520%2520%2520goto%2520a%253B%250A%257D%250A%250Ac%253A%250Aecho%2520%27Bar%27%253B&persist=0&single-expression=0&render-as=html)
+ [Standard Output, Standard Error, & Return](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%252F%252F%2520Only%2520%2522single%2522%2520expressions%2520can%2520return%2520strings%2520directly%250A%252F%252F%2520So%2520wrap%2520the%2520commands%2520in%2520an%2520IFFE.%250A%250A%28function%28%29%2520%257B%250A%2520%2520%2520%2520global%2520%2524persist%253B%250A%250A%2520%2520%2520%2520fwrite%28fopen%28%27php%253A%252F%252Fstdout%27%252C%2520%27w%27%29%252C%2520%2522output%255Cn%2522%29%253B%250A%2520%2520%2520%2520fwrite%28fopen%28%27php%253A%252F%252Fstdout%27%252C%2520%27w%27%29%252C%2520sprintf%28%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Ran%2520%2525d%2520times%21%255Cn%2522%252C%2520%2524persist%252B%252B%250A%2520%2520%2520%2520%29%29%253B%250A%2520%2520%2520%2520fwrite%28fopen%28%27php%253A%252F%252Fstderr%27%252C%2520%27w%27%29%252C%2520%27error%27%29%253B%250A%2520%2520%2520%2520%250A%2520%2520%2520%2520return%2520%27return%2520value%27%253B%250A%257D%29%28%29%253B&persist=1&single-expression=1)
+ [Sqlite](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%2524db%2520%253D%2520new%2520SQLite3%28%27people.db%27%29%253B%250A%2524db-%253Equery%28%27CREATE%2520TABLE%2520IF%2520NOT%2520EXISTS%2520people%2520%28%250A%2509id%2520INTEGER%2520PRIMARY%2520KEY%252C%250A%2520%2520%2520%2509name%2520TEXT%2520NOT%2520NULL%250A%29%253B%27%29%253B%250A%250Afor%28%2524i%2520%253D%25200%253B%2520%2524i%2520%253C%2520100%253B%2520%2524i%252B%252B%29%2520%257B%250A%2509%2524insert%2520%253D%2520%2524db-%253Eprepare%28%27INSERT%2520INTO%2520people%2520%28name%29%2520VALUES%28%253Aname%29%27%29%253B%250A%2509%2524insert-%253EbindValue%28%27%253Aname%27%252C%2520str_repeat%28chr%28%2524i%252B64%29%252C%252010%29%252C%2520SQLITE3_TEXT%29%253B%250A%250A%2509%2524insert-%253Eexecute%28%29%253B%250A%257D%250A%250A%2524results%2520%253D%2520%2524db-%253Equery%28%27SELECT%2520*%2520FROM%2520people%27%29%253B%250A%250A%2524rows%2520%253D%2520%255B%255D%253B%250A%250Awhile%2520%28%2524row%2520%253D%2520%2524results-%253EfetchArray%28%29%29%2520%257B%250A%2520%2520%2520%2520var_dump%28%2524row%29%253B%250A%257D%250A&persist=1)
+ [Sqlite w/PDO](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%2524db%2520%253D%2520new%2520PDO%28%27sqlite%253Apeople.db%27%29%253B%250A%250A%2524db-%253Equery%28%27CREATE%2520TABLE%2520IF%2520NOT%2520EXISTS%2520people%2520%28%250A%2509id%2520INTEGER%2520PRIMARY%2520KEY%252C%250A%2520%2520%2520%2509name%2520TEXT%2520NOT%2520NULL%250A%29%253B%27%29%253B%250A%250Afor%28%2524i%2520%253D%25200%253B%2520%2524i%2520%253C%252010%253B%2520%2524i%252B%252B%29%2520%257B%250A%2509%2524insert%2520%253D%2520%2524db-%253Eprepare%28%27INSERT%2520INTO%2520people%2520%28name%29%2520VALUES%28%253Aname%29%27%29%253B%250A%2509%2524insert-%253EbindParam%28%27%253Aname%27%252C%2520str_repeat%28chr%28%2524i%252B64%29%252C%252010%29%252C%2520SQLITE3_TEXT%29%253B%250A%250A%2509%2524insert-%253Eexecute%28%29%253B%250A%257D%250A%250A%2524results%2520%253D%2520%2524db-%253Equery%28%27SELECT%2520*%2520FROM%2520people%27%29%253B%250A%250A%2524rows%2520%253D%2520%255B%255D%253B%250A%250Awhile%2520%28%2524row%2520%253D%2520%2524results-%253EfetchObject%28%29%29%2520%257B%250A%2520%2520%2520%2520print_r%28%2524row%29%253B%250A%257D%250A&persist=0&single-expression=0)
+ [JSON](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%2524x%2520%253D%2520%255B%250A%2520%2520%2520%2522id%2522%2520%253D%253E%25201%2520%2520%250A%255D%253B%250A%250Avar_dump%28json_decode%28json_encode%28%2524x%29%29%29%253B%250A)
+ [Closures](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%2524x%2520%253D%252010%253B%250A%250Afunction%2520run%28callable%2520%2524f%29%2520%257B%250A%2520%2520%2520%2520%2524f%28%29%253B%250A%257D%250A%250Arun%28function%2520%28%29%2520use%2520%28%2526%2524x%29%2520%257B%250A%2520%2520%2520%2520%2524x%2520%253D%25209%253B%250A%257D%29%253B%250A%250Avar_dump%28%2524x%29%253B%250A)
+ [File access](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%2524it%2520%253D%2520new%2520RecursiveIteratorIterator%28new%2520RecursiveDirectoryIterator%28%2522.%2522%29%29%253B%250A%250Aforeach%2520%28%2524it%2520as%2520%2524name%2520%253D%253E%2520%2524entry%29%2520%257B%250A%2520%2520%2520%2520echo%2520%2524name%2520.%2520%2522%253Cbr%252F%253E%2522%253B%250A%257D%250A)
+ [Zend/bench.php](https://seanmorris.github.io/php-wasm?autorun=0&persist=0&single-expression=0&code=%253C%253Fphp%250A%250Ainclude%28%2522%252Fpreload%252FZend%252Fbench.php%2522%29%253B%250A&render-as=text)
+ [Drupal 7](https://seanmorris.github.io/php-wasm/?autorun=0&persist=0&single-expression=0&code=%253C%253Fphp%250Aini_set%28%27session.save_path%27%252C%2520%27%252Fhome%252Fweb_user%27%29%253B%250A%250A%2524stdErr%2520%253D%2520fopen%28%27php%253A%252F%252Fstderr%27%252C%2520%27w%27%29%253B%250A%2524errors%2520%253D%2520%255B%255D%253B%250A%250Aregister_shutdown_function%28function%28%29%2520use%28%2524stdErr%252C%2520%2526%2524errors%29%257B%250A%2520%2520%2520%2520fwrite%28%2524stdErr%252C%2520json_encode%28%255B%27session_id%27%2520%253D%253E%2520session_id%28%29%255D%29%2520.%2520%2522%255Cn%2522%29%253B%250A%2520%2520%2520%2520fwrite%28%2524stdErr%252C%2520json_encode%28%255B%27headers%27%253D%253Eheaders_list%28%29%255D%29%2520.%2520%2522%255Cn%2522%29%253B%250A%2520%2520%2520%2520fwrite%28%2524stdErr%252C%2520json_encode%28%255B%27errors%27%2520%253D%253E%2520error_get_last%28%29%255D%29%2520.%2520%2522%255Cn%2522%29%253B%250A%257D%29%253B%250A%250Aset_error_handler%28function%28...%2524args%29%2520use%28%2524stdErr%252C%2520%2526%2524errors%29%257B%250A%2509fwrite%28%2524stdErr%252C%2520print_r%28%2524args%252C1%29%29%253B%250A%257D%29%253B%250A%250A%2524docroot%2520%253D%2520%27%252Fpreload%252Fdrupal-7.59%27%253B%250A%2524path%2520%2520%2520%2520%253D%2520%27%252F%27%253B%250A%2524script%2520%2520%253D%2520%27index.php%27%253B%250A%250A%2524_SERVER%255B%27REQUEST_URI%27%255D%2520%2520%2520%2520%2520%253D%2520%2524docroot%2520.%2520%2524path%253B%250A%2524_SERVER%255B%27REMOTE_ADDR%27%255D%2520%2520%2520%2520%2520%253D%2520%27127.0.0.1%27%253B%250A%2524_SERVER%255B%27SERVER_NAME%27%255D%2520%2520%2520%2520%2520%253D%2520%27localhost%27%253B%250A%2524_SERVER%255B%27SERVER_PORT%27%255D%2520%2520%2520%2520%2520%253D%25203333%253B%250A%2524_SERVER%255B%27REQUEST_METHOD%27%255D%2520%2520%253D%2520%27GET%27%253B%250A%2524_SERVER%255B%27SCRIPT_FILENAME%27%255D%2520%253D%2520%2524docroot%2520.%2520%27%252F%27%2520.%2520%2524script%253B%250A%2524_SERVER%255B%27SCRIPT_NAME%27%255D%2520%2520%2520%2520%2520%253D%2520%2524docroot%2520.%2520%27%252F%27%2520.%2520%2524script%253B%250A%2524_SERVER%255B%27PHP_SELF%27%255D%2520%2520%2520%2520%2520%2520%2520%2520%253D%2520%2524docroot%2520.%2520%27%252F%27%2520.%2520%2524script%253B%250A%250Achdir%28%2524docroot%29%253B%250A%250Aob_start%28%29%253B%250A%250Adefine%28%27DRUPAL_ROOT%27%252C%2520getcwd%28%29%29%253B%250A%250Arequire_once%2520DRUPAL_ROOT%2520.%2520%27%252Fincludes%252Fbootstrap.inc%27%253B%250Adrupal_bootstrap%28DRUPAL_BOOTSTRAP_FULL%29%253B%250A%250A%2524uid%2520%2520%2520%2520%2520%253D%25201%253B%250A%2524user%2520%2520%2520%2520%253D%2520user_load%28%2524uid%29%253B%250A%2524account%2520%253D%2520array%28%27uid%27%2520%253D%253E%2520%2524user-%253Euid%29%253B%250Auser_login_submit%28array%28%29%252C%2520%2524account%29%253B%250A%250A%2524itemPath%2520%253D%2520%2524path%253B%250A%2524itemPath%2520%253D%2520preg_replace%28%27%252F%255E%255C%255C%252Fpreload%252F%27%252C%2520%27%27%252C%2520%2524itemPath%29%253B%250A%2524itemPath%2520%253D%2520preg_replace%28%27%252F%255E%255C%255C%252Fdrupal-7.59%252F%27%252C%2520%27%27%252C%2520%2524itemPath%29%253B%250A%2524itemPath%2520%253D%2520preg_replace%28%27%252F%255E%255C%252F%252F%27%252C%2520%27%27%252C%2520%2524itemPath%29%253B%250A%250Aif%28%2524itemPath%29%250A%257B%250A%2520%2520%2520%2520%250A%2520%2520%2520%2520%2524router_item%2520%253D%2520menu_get_item%28%2524itemPath%29%253B%250A%2520%2520%2520%2520%2524router_item%255B%27access_callback%27%255D%2520%253D%2520true%253B%250A%2520%2520%2520%2520%2524router_item%255B%27access%27%255D%2520%253D%2520true%253B%250A%2520%2520%2520%2520%250A%2520%2520%2520%2520if%2520%28%2524router_item%255B%27include_file%27%255D%29%2520%257B%250A%2520%2520%2520%2520%2520%2520require_once%2520DRUPAL_ROOT%2520.%2520%27%252F%27%2520.%2520%2524router_item%255B%27include_file%27%255D%253B%250A%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520%250A%2520%2520%2520%2520%2524page_callback_result%2520%253D%2520call_user_func_array%28%2524router_item%255B%27page_callback%27%255D%252C%2520unserialize%28%2524router_item%255B%27page_arguments%27%255D%29%29%253B%250A%2520%2520%2520%2520%250A%2520%2520%2520%2520drupal_deliver_page%28%2524page_callback_result%29%253B%250A%257D%250Aelse%250A%257B%250A%2520%2520%2520%2520menu_execute_active_handler%28%29%253B%250A%257D&render-as=html)


## Getting Started

Install with npm:

```sh
$ npm install php-wasm
```

## Static Assets:

You'll need to add the following `postinstall` script entry to your package.json to ensure the static assets are available to your web application. Make sure to replace `public/` with the path to your public document root if necessary.

```json
{
  "scripts": {
    "postinstall": [
      "cp node_modules/php-wasm/php-web.* public/"
    ]
  },
}
```

If you're using a more advanced bundler, use the vendor's documentation to learn how to move the files matching the following pattern to your public directory:

```
./node_modules/php-wasm/php-web.*
```

## Usage

Using php-wasm is easy.

### Automatic

Once the library is included in the page, you can run PHP right from a script tag! The src attribute is also supported for non-inline scripts.

```html
<script type = "text/php">
	<?php vrzno_run('alert', ['Hello, world!']);
</script>
```

### Manual

First, grab an instance of the object:

```javascript
const PHP = require('php-wasm/PhpWeb').PhpWeb;
const php = new PHP;
```

or, in es6:

```javascript
import { PhpWeb as PHP } from 'php-wasm/PhpWeb';
const php = new PHP;
```
Then, add an output listener:

```javascript
php.addEventListener('output', (event) => {
	console.log(event.detail);
});
```

Be sure to wait until your WASM is fully loaded, then run some PHP:

```javascript
php.addEventListener('ready', () => {
	php.run('<?php echo "Hello, world!";');
});
```
Get the result code of your script with `then()`:

```javascript
php.addEventListener('ready', () => {
	php.run('<?php echo "Hello, world!";').then(retVal => {
		// retVal contains the return code.
	});
});

```
### Persistent Memory

So long as `php.refresh()` is not called from Javascript, the instance will maintain its own persistent memory.

```php
<?php
// Run this over and over again...
print ++$x;

```

See the example in action [here](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%252F%252F%2520Run%2520this%2520over%2520and%2520over%2520again...%250Aprint%2520%252B%252B%2524x%253B&persist=1)

### Accessing the DOM

The DOM may be accessed via the [VRZNO](https://github.com/seanmorris/vrzno) php extension. This is specially  for the browser allowing PHP to access Javascript via a C api. It comes preinstalled with php-wasm.

See the example in action [here](https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%250A%250A%2524oldTitle%2520%253D%2520NULL%253B%250A%2524newTitle%2520%253D%2520%27Changed%2540%27%2520.%2520date%28%27h%253Ai%253As%27%29%253B%250A%250A%252F%252F%2520Grab%2520the%2520current%2520title%250A%2524oldTitle%2520%253D%2520vrzno_eval%28%27document.title%27%29%253B%250A%250A%252F%252F%2520Change%2520the%2520document%2520title%250A%2524newTitle%2520%253D%2520vrzno_eval%28%27document.title%2520%253D%2520%2522%27%2520.%2520%2524newTitle%2520.%2520%27%2522%27%2520%29%253B%250A%250Aprintf%28%250A%2520%2520%2520%2520%27Title%2520changed%2520from%2520%2522%2525s%2522%2520to%2520%2522%2525s%2522.%27%250A%2520%2520%2520%2520%252C%2520%2524oldTitle%250A%2520%2520%2520%2520%252C%2520%2524newTitle%250A%29%253B%250A%250A%250A%252F%252F%2520Show%2520an%2520alert%250Avrzno_run%28%27alert%27%252C%2520%255B%27Hello%252C%2520World%21%27%255D%29%253B)

```php

// Show an alert with vrzno_run. Note the second param is an array of args.
vrzno_run('alert', ['Hello, World!']);

$oldTitle = NULL;
$newTitle = 'Changed@' . date('h:i:s');

// Grab the current title.
$oldTitle = vrzno_eval('document.title');

// Change the document title.
vrzno_eval('document.title = "' . $newTitle . '"' );

```

# php-wasm is a fork of oraoto/PIB...

**[Run PIB](https://seanmorris.github.io/php-wasm/)**

Firefox is recommended for better user experience.

## Building From Source

### Using Docker

The quickest way to build PIB is by using Make & Docker. Simply issue the `make` command after checking out the repo, and it will build.

```
make
```

### Using Emscripten SDK (emsdk) manually

Steps:

+ Setup emsdk (>= 1.38.11), see [Installation Instructions](https://emscripten.org/docs/getting_started/downloads.html#installation-instructions)
+ Run `bash configure.sh`
+ Run `bash build-objects.sh`
+ Run `bash build.sh` to build the web binary

# Acknowledgements

- php-wasm and makefile contributed by @seanmorris
- The Web UI is based on [Rust Playground](https://play.rust-lang.org/).
