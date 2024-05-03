# [![seanmorris/php-cgi-wasm](https://github.com/seanmorris/php-wasm/blob/master/docs/sean-icon.png)](https://github.com/seanmorris/php-wasm) php-cgi-wasm

find php-cgi-wasm on [npm](https://npmjs.com/package/php-cgi-wasm)

_The CGI Counterpart to [php-wasm](https://npmjs.com/package/php-wasm)._

This package encompasses the CGI-specific build artifacts of php-wasm. The goal of this part of the project is to provide a version of PHP that more closely resembles the environment facilitated by PHP when running under web servers like Apache and nginx. This is achieved by building a binary artifact of PHP-CGI, rather than PHP-CLI to Web Assembly. The resulting WASM binary can then be run under nodejs with express, in a webpage, or inside a service worker.

