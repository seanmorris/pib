# [![seanmorris/php-wasm](https://github.com/seanmorris/php-wasm/blob/master/docs/sean-icon.png)](https://github.com/seanmorris/php-wasm) php-wasm

[![php-wasm](https://img.shields.io/npm/v/php-wasm?color=4f5d95&label=php-wasm&style=for-the-badge)](https://www.npmjs.com/package/php-wasm)
[![Apache-2.0 Licence Badge](https://img.shields.io/npm/l/cv3-inject?logo=apache&color=427819&style=for-the-badge)](https://github.com/seanmorris/php-wasm/blob/master/LICENSE) [![GitHub Sponsors](https://img.shields.io/github/sponsors/seanmorris?style=for-the-badge&color=f1e05a)](https://github.com/sponsors/seanmorris) ![Size](https://img.shields.io/github/languages/code-size/seanmorris/php-wasm?color=e34c26&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAABQAAAAOCAQAAACFzfR7AAABF0lEQVQoFQXBQWvOAQDA4ef/7o29YWtqKU7ExWE5OIvm4LKcnXwD7aQ0N/kAczO1i1KOO0xJvQojaTm4KbJabnJysLSf5wFAa603CUB322yOAAitVT86BTTQ1+oJDYDQcv+qFRr3vC1ooYPqDkHoYgfVKmnSfhG62t/qBkHn2q8ekjRpryB0v/rZ2eh4r6tpY5pp3Gx7RTONoJfVLnpQfekYtNG0832rRj3tEaT31bOxQ5wc/oATrnnniEMfXfaZDFrAoEk71XajNN9OVVW7HYVeVZ9AF/pd3YPm267qbYs0tF597wygpaquQ7Nt9QLoVlWXCEK3q1oCCF2p6iYBpKGN6kNzATrdr2qVAACa9rgRQKPetAnAf1jX/qSkN8aIAAAAAElFTkSuQmCC&style=for-the-badge) ![GitHub Repo stars](https://img.shields.io/github/stars/seanmorris/php-wasm?style=for-the-badge&label=GitHub%20Stars&link=https%3A%2F%2Fgithub.com%2Fseanmorris%2Fphp-wasm) [![CircleCI](https://img.shields.io/circleci/build/github/seanmorris/php-wasm?logo=circleci&logoColor=white&style=for-the-badge&token=12dae2d9c3cd5ac38bd81752b0751872c556282d)](https://circleci.com/gh/seanmorris/php-wasm/) ![NPM Downloads](https://img.shields.io/npm/dw/php-wasm?style=for-the-badge&color=C80&link=https%3A%2F%2Fwww.npmjs.com%2Fpackage%2Fphp-wasm&label=npm%20installs) ![jsDelivr hits (npm)](https://img.shields.io/jsdelivr/npm/hw/php-wasm?style=for-the-badge&color=09D&link=https%3A%2F%2Fwww.npmjs.com%2Fpackage%2Fphp-wasm&label=jsdelivr%20hits) [![Static Badge](https://img.shields.io/badge/reddit-always%20online-336699?style=for-the-badge&logo=reddit)](https://www.reddit.com/r/phpwasm/) [![Discord](https://img.shields.io/discord/1199824765666463835?style=for-the-badge&logo=discord&link=https%3A%2F%2Fdiscord.gg%2Fj8VZzju7gJ)](https://discord.gg/j8VZzju7gJ)


_PHP in WebAssembly, npm not required._

find php-wasm on [npm](https://npmjs.com/package/php-wasm) | [github](https://github.com/seanmorris/php-wasm) | [unpkg](https://unpkg.com/browse/php-wasm/) | [reddit](https://www.reddit.com/r/phpwasm) | [discord](https://discord.gg/j8VZzju7gJ)

### 🚀 v0.0.8 - Preparing for Lift-off

* Adding ESM & CDN Module support!
* Adding stdin.
* Buffering stdout/stderr in javascript.
* Fixing `<script type = "text/php">` support.
* Adding fetch support for `src` on above.
* Adding support for libzip, iconv, & html-tidy
* Adding support for NodeFS & IDBFS.
* In-place builds.
* Updating PHP to 8.2.11
* Building with Emscripten 3.1.43
* Modularizing dependencies.
* Compressing assets.

[changelog](https://raw.githubusercontent.com/seanmorris/php-wasm/master/CHANGELOG.md)

## ☀️ Examples

<table>
 <tr>
    <td width = "500px" border = "0">
		<ul>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250Aecho%2520%2522Hello%252C%2520World%21%2522%253B%250A&autorun=1&persist=0&single-expression=0&render-as=text">Hello World!</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522html%2522%257D%250Aphpinfo%28%29%253B%250A&autorun=1&persist=0&single-expression=0&render-as=html">phpinfo();</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm?render-as=text&autorun=1&persist=1&single-expression=0&code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Atrue%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%2524setup%2520%253D%2520%2524setup%2520%253F%253F%2520false%253B%250A%2524x%2520%253D%2520%2524x%2520%253F%253F%25200%253B%250A%250Avar_dump%28%2524x%29%253B%250A%250Aif%28%21%2524setup%29%250A%257B%250A%2520%2520%2520%2520%2524window%2520%253D%2520new%2520Vrzno%253B%250A%250A%2520%2520%2520%2520%2524f%2520%253D%2520%2524window-%253EphpFuncA%2520%253D%2520function%28%29%2520use%28%2526%2524x%252C%2520%2524window%29%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2524window-%253Ealert%28%27RAN%2520A%21%2520%27%2520.%2520%2524x%252B%252B%29%253B%250A%2520%2520%2520%2520%257D%253B%250A%2520%2520%2520%2520%250A%2520%2520%2520%2520%2524g%2520%253D%2520%2524window-%253EphpFuncB%2520%253D%2520function%28%29%2520use%28%2526%2524x%252C%2520%2524window%29%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520echo%2520%27%2524x%2520is%2520now%2520%27%2520.%2520%28%252B%252B%2524x%29%2520.%2520PHP_EOL%253B%250A%2520%2520%2520%2520%257D%253B%250A%2520%2520%2520%2520%250A%2520%2520%2520%2520%2524setup%2520%253D%2520true%253B%250A%2520%2520%2520%2520%250A%2520%2520%2520%2520echo%2520%2522Initialized.%255Cn%2522%253B%250A%257D%250A%250A%2524window-%253EphpFuncA%28%29%253B%250A%252F%252F%2520%2524window-%253EphpFuncB%28%29%253B%250A%250A%252F%252F%2520vrzno_eval%28%27window.phpFuncA%28%29%27%29%253B%250Avrzno_eval%28%27window.phpFuncB%28%29%27%29%253B%250A">Javascript Callbacks</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Atrue%252C%2520%2522single-expression%2522%253A%2520true%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%252F%252F%2520run%2520this%2520over%2520and%2520over%2520again%250A%2524c%2520%253D%25201%2520%252B%2520%28%2524c%2520%253F%253F%2520-1%29%253B%250A%250Aprint%2520%2524c%253B%250A&autorun=1&persist=1&single-expression=1&render-as=text">Persistent Memory</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%2524oldTitle%2520%253D%2520NULL%253B%250A%2524newTitle%2520%253D%2520%27Changed%2540%27%2520.%2520date%28%27h%253Ai%253As%27%29%253B%250A%250A%252F%252F%2520Grab%2520the%2520current%2520title%250A%2524oldTitle%2520%253D%2520vrzno_eval%28%27document.title%27%29%253B%250A%250A%252F%252F%2520Change%2520the%2520document%2520title%250A%2524newTitle%2520%253D%2520vrzno_eval%28%27document.title%2520%253D%2520%2522%27%2520.%2520%2524newTitle%2520.%2520%27%2522%27%2520%29%253B%250A%250Aprintf%28%250A%2509%27Title%2520changed%2520from%2520%2522%2525s%2522%2520to%2520%2522%2525s%2522.%27%250A%2509%252C%2520%2524oldTitle%250A%2509%252C%2520%2524newTitle%250A%29%253B%250A%250A%250A%252F%252F%2520Show%2520an%2520alert%250Avrzno_run%28%27alert%27%252C%2520%255B%27Hello%252C%2520World%21%27%255D%29%253B%250A&autorun=1&persist=0&single-expression=0&render-as=text">DOM Access</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%2524x%2520%253D%2520false%253B%250A%250Aa%253A%250A%250Aif%28%21%2524x%29%250A%257B%250A%2509goto%2520b%253B%250A%257D%250A%250Aecho%2520%272.%2520Foo%27%2520.%2520PHP_EOL%253B%250A%250Agoto%2520c%253B%250A%250Ab%253A%250A%250Aecho%2520%271.%2520Bar%27%2520.%2520PHP_EOL%253B%250A%250Aif%28%21%2524x%29%250A%257B%250A%2509%2524x%2520%253D%2520true%253B%250A%2509goto%2520a%253B%250A%257D%250A%250Ac%253A%250Aecho%2520%273.%2520Baz%27%2520.%2520PHP_EOL%253B%250A&autorun=1&persist=0&single-expression=0&render-as=text">goto</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520true%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%252F%252F%2520Only%2520%2522single%2522%2520expressions%2520can%2520return%2520strings%2520directly%250A%252F%252F%2520So%2520wrap%2520the%2520commands%2520in%2520an%2520IFFE.%250A%250A%28function%28%29%2520%257B%250A%2509global%2520%2524persist%253B%250A%250A%2509fwrite%28fopen%28%27php%253A%252F%252Fstdout%27%252C%2520%27w%27%29%252C%2520%2522standard%2520output%21%255Cn%2522%29%253B%250A%2509fwrite%28fopen%28%27php%253A%252F%252Fstdout%27%252C%2520%27w%27%29%252C%2520sprintf%28%250A%2509%2509%2522Ran%2520%2525d%2520times%21%255Cn%2522%252C%2520%252B%252B%2524persist%250A%2509%29%29%253B%250A%2509fwrite%28fopen%28%27php%253A%252F%252Fstderr%27%252C%2520%27w%27%29%252C%2520%27standard%2520error%21%27%29%253B%250A%250A%2509return%2520%27return%2520value%27%253B%250A%257D%29%28%29%253B%250A&autorun=1&persist=1&single-expression=1&render-as=text">StdOut, StdErr & Return</a></li>
		</ul>
	</td>
    <td width = "500px">
		<ul>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%2524db%2520%253D%2520new%2520SQLite3%28%27people.db%27%29%253B%250A%2524db-%253Equery%28%27CREATE%2520TABLE%2520IF%2520NOT%2520EXISTS%2520people%2520%28%250A%2509id%2520INTEGER%2520PRIMARY%2520KEY%252C%250A%2520%2520%2520%2509name%2520TEXT%2520NOT%2520NULL%250A%29%253B%27%29%253B%250A%250Afor%28%2524i%2520%253D%25200%253B%2520%2524i%2520%253C%2520100%253B%2520%2524i%252B%252B%29%2520%257B%250A%250A%2509%2524weirdName%2520%253D%2520str_repeat%28chr%28%2524i%252B64%29%252C%252010%29%253B%250A%2509%2524insert%2520%2520%2520%2520%253D%2520%2524db-%253Eprepare%28%27INSERT%2520INTO%2520people%2520%28name%29%2520VALUES%28%253Aname%29%27%29%253B%250A%250A%2509%2524insert-%253EbindValue%28%27%253Aname%27%252C%2520%2524weirdName%252C%2520SQLITE3_TEXT%29%253B%250A%250A%2509%2524insert-%253Eexecute%28%29%253B%250A%257D%250A%250A%2524results%2520%253D%2520%2524db-%253Equery%28%27SELECT%2520*%2520FROM%2520people%27%29%253B%250A%250A%2524rows%2520%253D%2520%255B%255D%253B%250A%250Awhile%2520%28%2524row%2520%253D%2520%2524results-%253EfetchArray%28%29%29%2520%257B%250A%2520%2520%2520%2520var_dump%28%2524row%29%253B%250A%257D%250A&autorun=1&persist=0&single-expression=0&render-as=text">Sqlite</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%2524db%2520%253D%2520new%2520PDO%28%27sqlite%253Apeople.db%27%29%253B%250A%250A%2524db-%253Equery%28%27CREATE%2520TABLE%2520IF%2520NOT%2520EXISTS%2520people%2520%28%250A%2509id%2520INTEGER%2520PRIMARY%2520KEY%252C%250A%2520%2520%2520%2509name%2520TEXT%2520NOT%2520NULL%250A%29%253B%27%29%253B%250A%250Afor%28%2524i%2520%253D%25200%253B%2520%2524i%2520%253C%252010%253B%2520%2524i%252B%252B%29%2520%257B%250A%2509%2524weirdName%2520%253D%2520str_repeat%28chr%28%2524i%252B64%29%252C%252010%29%253B%250A%2509%2524insert%2520%2520%2520%2520%253D%2520%2524db-%253Eprepare%28%27INSERT%2520INTO%2520people%2520%28name%29%2520VALUES%28%253Aname%29%27%29%253B%250A%250A%2509%2524insert-%253EbindParam%28%27%253Aname%27%252C%2520%2524weirdName%252C%2520SQLITE3_TEXT%29%253B%250A%250A%2509%2524insert-%253Eexecute%28%29%253B%250A%257D%250A%250A%2524results%2520%253D%2520%2524db-%253Equery%28%27SELECT%2520*%2520FROM%2520people%27%29%253B%250A%250A%2524rows%2520%253D%2520%255B%255D%253B%250A%250Awhile%2520%28%2524row%2520%253D%2520%2524results-%253EfetchObject%28%29%29%2520%257B%250A%2520%2520%2520%2520print_r%28%2524row%29%253B%250A%257D%250A&autorun=1&persist=0&single-expression=0&render-as=text">Sqlite w/PDO</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%2524x%2520%253D%2520%255B%250A%2509%2522id%2522%2520%253D%253E%25201%250A%255D%253B%250A%250Avar_dump%28json_decode%28json_encode%28%2524x%29%29%29%253B%250A&autorun=1&persist=0&single-expression=0&render-as=text">JSON</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%2524x%2520%253D%252010%253B%250A%250Afunction%2520run%28callable%2520%2524f%29%2520%257B%250A%2509%2524f%28%29%253B%250A%257D%250A%250Arun%28function%2520%28%29%2520use%2520%28%2526%2524x%29%2520%257B%250A%2509%2524x%2520%253D%25209%253B%250A%257D%29%253B%250A%250Avar_dump%28%2524x%29%253B%250A&autorun=1&persist=0&single-expression=0&render-as=text">Closures</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522html%2522%257D%250A%250A%2524it%2520%253D%2520new%2520RecursiveIteratorIterator%28new%2520RecursiveDirectoryIterator%28%2522.%2522%29%29%253B%250A%250Aforeach%2520%28%2524it%2520as%2520%2524name%2520%253D%253E%2520%2524entry%29%2520%257B%250A%2509echo%2520%2524name%2520.%2520%2522%253Cbr%252F%253E%2522%253B%250A%257D%250A&autorun=1&persist=0&single-expression=0&render-as=html">File access</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250Ainclude%28%2522%252Fpreload%252Fbench.php%2522%29%253B%250A&autorun=1&persist=0&single-expression=0&render-as=text">Zend/bench.php</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?demo=drupal.php&render-as=html&autorun=1&persist=0&single-expression=0&code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Afalse%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522html%2522%257D%250Aini_set%28%27session.save_path%27%252C%2520%27%252Fpersist%27%29%253B%250A%250A%2524stdErr%2520%253D%2520fopen%28%27php%253A%252F%252Fstderr%27%252C%2520%27w%27%29%253B%250A%2524errors%2520%253D%2520%255B%255D%253B%250A%250Aset_error_handler%28function%28...%2524args%29%2520use%28%2524stdErr%252C%2520%2526%2524errors%29%257B%250A%2509fwrite%28%2524stdErr%252C%2520print_r%28%2524args%252C1%29%29%253B%250A%257D%29%253B%250A%250A%2524docroot%2520%253D%2520%27%252Fpersist%252Fdrupal-7.95%27%253B%250A%2524path%2520%2520%2520%2520%253D%2520%27%252Fnode%27%253B%250A%2524script%2520%2520%253D%2520%27index.php%27%253B%250A%250Aif%28%21is_dir%28%2524docroot%29%29%250A%257B%250A%2520%2520%2520%2520%2524it%2520%253D%2520new%2520RecursiveIteratorIterator%28new%2520RecursiveDirectoryIterator%28%2522%252Fpreload%252Fdrupal-7.95%252F%2522%252C%2520FilesystemIterator%253A%253ASKIP_DOTS%29%29%253B%250A%2520%2520%2520%2520foreach%2520%28%2524it%2520as%2520%2524name%2520%253D%253E%2520%2524entry%29%250A%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520if%28is_dir%28%2524name%29%29%2520continue%253B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2524fromDir%2520%253D%2520dirname%28%2524name%29%253B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2524toDir%2520%2520%253D%2520%27%252Fpersist%27%2520.%2520substr%28%2524fromDir%252C%25208%29%253B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2524filename%2520%253D%2520basename%28%2524name%29%253B%250A%2520%2520%2520%2520%2509%2524pDirs%2520%253D%2520%255B%2524pDir%2520%253D%2520%2524toDir%255D%253B%250A%2520%2520%2520%2520%2509while%28%2524pDir%2520%21%253D%253D%2520dirname%28%2524pDir%29%29%2520%2524pDirs%255B%255D%2520%253D%2520%2524pDir%2520%253D%2520dirname%28%2524pDir%29%253B%250A%2520%2520%2520%2520%2509%2524pDirs%2520%253D%2520array_reverse%28%2524pDirs%29%253B%250A%2520%2520%2520%2520%2509foreach%28%2524pDirs%2520as%2520%2524pDir%29%2520if%28%21is_dir%28%2524pDir%29%29%2520mkdir%28%2524pDir%252C%25200777%29%253B%250A%2520%2520%2520%2520%2509file_put_contents%28%2524toDir%2520%2520.%2520%27%252F%27%2520.%2520%2524filename%252C%2520file_get_contents%28%2524fromDir%2520.%2520%27%252F%27%2520.%2520%2524filename%29%29%253B%250A%2520%2520%2520%2520%257D%250A%257D%250A%250A%2524_SERVER%255B%27REQUEST_URI%27%255D%2520%2520%2520%2520%2520%253D%2520%27%252Fphp-wasm%27%2520.%2520%2524docroot%2520.%2520%2524path%253B%250A%2524_SERVER%255B%27REMOTE_ADDR%27%255D%2520%2520%2520%2520%2520%253D%2520%27127.0.0.1%27%253B%250A%2524_SERVER%255B%27SERVER_NAME%27%255D%2520%2520%2520%2520%2520%253D%2520%27localhost%27%253B%250A%2524_SERVER%255B%27SERVER_PORT%27%255D%2520%2520%2520%2520%2520%253D%25203333%253B%250A%2524_SERVER%255B%27REQUEST_METHOD%27%255D%2520%2520%253D%2520%27GET%27%253B%250A%2524_SERVER%255B%27SCRIPT_FILENAME%27%255D%2520%253D%2520%2524docroot%2520.%2520%27%252F%27%2520.%2520%2524script%253B%250A%2524_SERVER%255B%27SCRIPT_NAME%27%255D%2520%2520%2520%2520%2520%253D%2520%2524docroot%2520.%2520%27%252F%27%2520.%2520%2524script%253B%250A%2524_SERVER%255B%27PHP_SELF%27%255D%2520%2520%2520%2520%2520%2520%2520%2520%253D%2520%2524docroot%2520.%2520%27%252F%27%2520.%2520%2524script%253B%250A%250Achdir%28%2524docroot%29%253B%250A%250Aif%28%21defined%28%27DRUPAL_ROOT%27%29%29%2520define%28%27DRUPAL_ROOT%27%252C%2520getcwd%28%29%29%253B%250A%250Arequire_once%2520DRUPAL_ROOT%2520.%2520%27%252Fincludes%252Fbootstrap.inc%27%253B%250Adrupal_bootstrap%28DRUPAL_BOOTSTRAP_FULL%29%253B%250Adrupal_session_start%28%29%253B%250A%250Afwrite%28%2524stdErr%252C%2520json_encode%28%255B%27session_id%27%2520%253D%253E%2520session_id%28%29%255D%29%2520.%2520%2522%255Cn%2522%29%253B%250A%250Aglobal%2520%2524user%253B%250A%250A%2524uid%2520%2520%2520%2520%2520%253D%25201%253B%250A%2524user%2520%2520%2520%2520%253D%2520user_load%28%2524uid%29%253B%250A%2524account%2520%253D%2520array%28%27uid%27%2520%253D%253E%2520%2524user-%253Euid%29%253B%250A%2524session_name%2520%253D%2520session_name%28%29%253B%250A%250Aif%28%21%2524_COOKIE%2520%257C%257C%2520%21%2524_COOKIE%255B%2524%2524session_name%255D%29%250A%257B%250A%2509user_login_submit%28array%28%29%252C%2520%2524account%29%253B%250A%257D%250A%250A%2524itemPath%2520%253D%2520%2524path%253B%250A%2524itemPath%2520%253D%2520preg_replace%28%27%252F%255E%255C%255C%252F%252F%27%252C%2520%27%27%252C%2520%2524path%29%253B%250A%250A%2524GLOBALS%255B%27base_path%27%255D%2520%253D%2520%27%252Fphp-wasm%27%2520.%2520%2524docroot%2520.%2520%27%252F%27%253B%250A%2524base_url%2520%253D%2520%27%252Fphp-wasm%27%2520.%2520%2524docroot%253B%250A%250A%2524_GET%255B%27q%27%255D%2520%253D%2520%2524itemPath%253B%250A%250Amenu_execute_active_handler%28%29%253B%250A%250Afwrite%28%2524stdErr%252C%2520json_encode%28%255B%27HEADERS%27%2520%253D%253Eheaders_list%28%29%255D%29%2520.%2520%2522%255Cn%2522%29%253B%250Afwrite%28%2524stdErr%252C%2520json_encode%28%255B%27COOKIE%27%2520%2520%253D%253E%2520%2524_COOKIE%255D%29%2520.%2520PHP_EOL%29%253B%250Afwrite%28%2524stdErr%252C%2520json_encode%28%255B%27errors%27%2520%2520%253D%253E%2520error_get_last%28%29%255D%29%2520.%2520%2522%255Cn%2522%29%253B%250A">Drupal 7</a></li>
		</ul>
	</td>
	<td width = "500px">
		<ul>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Atrue%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%2524window%2520%253D%2520new%2520Vrzno%253B%250A%2524import%2520%253D%2520vrzno_import%28%27https%253A%252F%252Fcdn.jsdelivr.net%252Fnpm%252F%2540observablehq%252Fplot%25400.6%252F%252Besm%27%29%253B%250A%250A%2524import-%253Ethen%28function%28%2524Plot%29%2520use%28%2524window%29%2520%257B%250A%250A%2509%2524plot%2520%253D%2520%2524Plot-%253ErectY%28%250A%250A%2509%2509%28object%29%255B%27length%27%2520%253D%253E%2520100000%255D%252C%250A%250A%2509%2509%2524Plot-%253EbinX%28%250A%2509%2509%2509%28object%29%255B%27y%27%253D%253E%2520function%28%2524a%252C%2524b%29%257B%2520return%2520-cos%28%2524b-%253Ex1*pi%28%29%29%253B%2520%257D%255D%252C%250A%2509%2509%2509%28object%29%255B%27x%27%253D%253E%2520%2524window-%253EMath-%253Erandom%255D%250A%2509%2509%29%250A%250A%2509%29-%253Eplot%28%29%253B%250A%250A%2509%2524renderTo%2520%253D%2520%2524window-%253Edocument-%253Ebody-%253EquerySelector%28%27%2523example%27%29%253B%250A%2509%2524renderTo-%253EinnerHTML%2520%253D%2520%27%27%253B%250A%250A%2509%2524renderTo-%253Eappend%28%2524plot%29%253B%250A%250A%257D%29-%253Ecatch%28fn%28%2524error%29%2520%253D%253E%2520%2524window-%253Econsole-%253Eerror%28%2524error-%253Emessage%29%29%253B%250A&autorun=1&persist=1&single-expression=0&render-as=text&demo=import.php">Import Javascript Libs</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Atrue%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%250A%2524url%2520%253D%2520%27https%253A%252F%252Fapi.weather.gov%252Fgridpoints%252FTOP%252F40%252C74%252Fforecast%27%253B%250A%250A%2524window%2520%253D%2520new%2520Vrzno%253B%250A%2524window-%253Efetch%28%2524url%29%250A-%253Ethen%28function%28%2524r%29%2520%257B%2520return%2520%2524r-%253Ejson%28%29%253B%2520%257D%29%250A-%253Ethen%28var_dump%28...%29%29%253B%250A%250Aecho%2520%2522Yeah%252C%2520its%2520async.%255Cn%255Cn%2522%253B%250A&autorun=1&persist=1&single-expression=0&render-as=text&demo=fetch.php">Fetch</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Atrue%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%2524window%2520%253D%2520%2524window%2520%253F%253F%2520new%2520Vrzno%253B%250A%250A%2524Promise%2520%253D%2520%2524window-%253EPromise%253B%250A%250A%2524promise%2520%253D%2520vrzno_new%28%2524Promise%252C%2520function%28%2524accept%252C%2520%2524reject%29%2520%257B%250A%250A%2520%2520%2520%2520%2524window%2520%253D%2520new%2520Vrzno%253B%250A%250A%2520%2520%2520%2520if%281%29%250A%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2524accept%28%27Something.%27%29%253B%250A%2520%2520%2520%2520%2520%2520%2520%2520%252F%252F%2520%2524window-%253EsetTimeout%28%250A%2520%2520%2520%2520%2520%2520%2520%2520%252F%252F%2520%2520%2520%2520%2520fn%28%29%2520%253D%253E%2520%2524accept%28%27Something.%27%29%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%252F%252F%2520%2520%2520%2520%25201000%250A%2520%2520%2520%2520%2520%2520%2520%2520%252F%252F%2520%29%253B%250A%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520else%250A%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2524window-%253EsetTimeout%28%250A%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520fn%28%29%2520%253D%253E%2520%2524reject%28%27Error.%27%29%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%25201000%250A%2520%2520%2520%2520%2520%2520%2520%2520%29%253B%250A%2520%2520%2520%2520%257D%250A%250A%257D%29%253B%250A%250A%2524promise-%253Ethen%28var_dump%28...%29%29-%253Ecatch%28var_dump%28...%29%29%253B%250A&autorun=1&persist=1&single-expression=0&render-as=text&demo=promise.php">Promise</a></li>
			<li><a href = "https://seanmorris.github.io/php-wasm/?code=%253C%253Fphp%2520%252F%252F%2520%257B%2522autorun%2522%253Atrue%252C%2520%2522persist%2522%253Atrue%252C%2520%2522single-expression%2522%253A%2520false%252C%2520%2522render-as%2522%253A%2520%2522text%2522%257D%250A%2524window%2520%253D%2520new%2520Vrzno%253B%250A%2524require%2520%253D%2520%2524window-%253Erequire%253B%250A%2524Form%2520%253D%2520%2524require%28%27curvature%252Fform%252FForm%27%29-%253EForm%253B%250A%2524View%2520%253D%2520%2524require%28%27curvature%252Fbase%252FView%27%29-%253EView%253B%250A%250A%2524form%2520%253D%2520new%2520%2524Form%28%28object%29%255B%250A%2520%2520%2520%2520%27id%27%2520%2520%2520%253D%253E%2520%28object%29%255B%27type%27%2520%253D%253E%2520%27number%27%255D%252C%250A%2520%2520%2520%2520%27name%27%2520%253D%253E%2520%28object%29%255B%27type%27%2520%253D%253E%2520%27text%27%255D%252C%250A%255D%29%253B%250A%250A%2524view%2520%253D%2520%2524View-%253Efrom%28%27%253Cdiv%2520style%2520%253D%2520%2522display%253Aflex%253Bflex-direction%253Arow%253Bmargin%253A1rem%253B%2522%253E%250A%2509%253Cdiv%2520style%2520%253D%2520%2522margin-right%253A1rem%2522%253E%250A%2509%2509%253Cp%253ECounter%253C%252Fp%253E%250A%2509%2509%253Cdiv%2520style%2520%253D%2520%2522display%253Aflex%253Bflex-direction%253Arow%253Bmargin%253A1rem%2520auto%253Bmin-width%253A4rem%253B%2522%253E%250A%2509%2509%2509%253Cbutton%2520cv-on%2520%253D%2520%2522click%253Adec%2522%2520style%2520%253D%2520%2522flex%253A1%2522%253E-%253C%252Fbutton%253E%250A%2509%2509%2509%253Cbutton%2520cv-on%2520%253D%2520%2522click%253Ainc%2522%2520style%2520%253D%2520%2522flex%253A1%2522%253E%252B%253C%252Fbutton%253E%250A%2509%2509%253C%252Fdiv%253E%250A%2509%2509%253Cdiv%2520style%2520%253D%2520%2522font-size%253A6rem%253B%2522%253E%255B%255Bcounter%255D%255D%253C%252Fdiv%253E%250A%2509%253C%252Fdiv%253E%250A%2509%253Cdiv%2520style%2520%253D%2520%2522margin-right%253A1rem%2522%253E%250A%2509%2509%253Cp%253EForm%253A%2520%255B%255Bform%255D%255D%253C%252Fp%253E%250A%2509%2509%253Cp%253ESerialized%253A%2520%255B%255Bserialized%255D%255D%253C%252Fp%253E%250A%2509%2509%253Cp%253EJSON%253A%2520%255B%255Bjson%255D%255D%253C%252Fp%253E%250A%2509%253C%252Fdiv%253E%250A%253C%252Fdiv%253E%27%29%253B%250A%250A%2524form-%253EbindTo%28%27json%27%252C%2520function%28%2524json%2520%253D%2520NULL%29%2520use%28%2524view%252C%2520%2524form%29%2520%257B%250A%2520%2520%2520%2520%2524view-%253Eargs-%253Eserialized%2520%253D%2520serialize%28%2524form-%253Eargs-%253Evalue%29%253B%250A%2520%2520%2520%2520%2524view-%253Eargs-%253Ejson%2520%253D%2520%2524json%253B%250A%257D%29%253B%250A%250A%2524view-%253Eargs-%253Ecounter%2520%253D%25200%253B%250A%2524view-%253Eargs-%253Eform%2520%253D%2520%2524form%253B%250A%250A%2524view-%253Einc%2520%253D%2520fn%28%29%2520%253D%253E%2520%2524view-%253Eargs-%253Ecounter%252B%252B%253B%250A%2524view-%253Edec%2520%253D%2520fn%28%29%2520%253D%253E%2520%2524view-%253Eargs-%253Ecounter--%253B%250A%250A%2524renderTo%2520%253D%2520%2524window-%253Edocument-%253Ebody-%253EquerySelector%28%27%2523example%27%29%253B%250A%2524renderTo-%253EinnerHTML%2520%253D%2520%27%27%253B%250A%2524view-%253Erender%28%2524renderTo%29%253B%250A&autorun=1&persist=1&single-expression=0&render-as=text&demo=curvature.php">Curvature</a></li>
			<li><a href = "https://github.com/seanmorris/php-gtk">php-gtk</a></li>
			<li><a href = "https://php-cloud.pages.dev/">php in cloudflare workers</a></li>
			<br />
		</ul>
	</td>
 </tr>
</table>

## 🍎 Quickstart

### Inline PHP

Include the `php-tags.js` script from a CDN:

```html
<script async type = "text/javascript" src = "https://cdn.jsdelivr.net/npm/php-wasm/php-tags.jsdelivr.mjs"></script>
```

And run some PHP right in the page!

```html
<script type = "text/php" data-stdout = "#output">
<?php phpinfo();
</script>
<div id = "output"></div>
```

Inline php can use standard input, output and error with `data-` attributes. Just set the value of the attribute to a selector that will match that tag.

```html
<script async type = "text/javascript" src = "https://cdn.jsdelivr.net/npm/php-wasm/php-tags.jsdelivr.mjs"></script>

<script id = "input" type = "text/plain">Hello, world!</script>

<script type = "text/php" data-stdin = "#input" data-stdout = "#output" data-stderr = "#error">
	<?php echo file_get_contents('php://stdin');
</script>

<div id = "output"></div>
<div id = "error"></div>
```

The `src` attribute can be used on `<script type = "text/php">` tags, as well as their input elements. For example:

```html
<html>
    <head>
        <script async type = "text/javascript" src = "https://cdn.jsdelivr.net/npm/php-wasm/php-tags.jsdelivr.mjs"></script>
        <script id = "input" src = "/test-input.json" type = "text/json"></script>
        <script type = "text/php" src = "/test.php" data-stdin = "#input" data-stdout = "#output" data-stderr = "#error"></script>
    </head>
    <body>
        <div id = "output"></div>
        <div id = "error"></div>
    </body>
</html>
```

#### CDNs

##### JSDelivr

```html
<script async type = "text/javascript" src = "https://cdn.jsdelivr.net/npm/php-wasm/php-tags.jsdelivr.mjs"></script>
```

##### Unpkg

```html
<script async type = "text/javascript" src = "https://www.unpkg.com/php-wasm/php-tags.unpkg.mjs"></script>
```

<!--
##### esm.sh
```html
<script async type = "text/javascript" src = "https://esm.sh/php-wasm/php-wasm/php-tags.jsdelivr.mjs"></script>
``` -->

## 🛠️ Install & Use

Install with npm:

```sh
$ npm install php-wasm
```

Include the module in your preferred format:

### Common JS

```javascript
const { PhpWeb } = require('php-wasm/PhpWeb.js');
const php = new PhpWeb;
```

### ESM

```javascript
import { PhpWeb } from 'php-wasm/PhpWeb.mjs';
const php = new PhpWeb;
```

#### From a CDN:

***Note: This does not require npm.***

##### jsdelivr

```javascript
const { PhpWeb } = await import('https://cdn.jsdelivr.net/npm/php-wasm/PhpWeb.mjs');
const php = new PhpWeb;
```

##### unpkg

```javascript
const { PhpWeb } = await import('https://www.unpkg.com/php-wasm/php-wasm/PhpWeb.mjs');
const php = new PhpWeb;
```

#### Pre-Packaged Static Assets:

***You won't need to use this if you build in-place or use a CDN.***

The php-wasm package comes with pre-built binaries out of the box so you can get started quickly.

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

## 🥤 Running PHP & Taking Output

Create a PHP instance:

```javascript
const { PhpWeb } = await import('https://cdn.jsdelivr.net/npm/php-wasm/PhpWeb.mjs');
const php = new PhpWeb;
```

Add your output listeners:

```javascript
// Listen to STDOUT
php.addEventListener('output', (event) => {
	console.log(event.detail);
});

// Listen to STDERR
php.addEventListener('error', (event) => {
	console.log(event.detail);
});
```

Provide some input data on STDIN if you need to:

```javascript
php.inputString('This is a string of data provided on STDIN.');
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

## 💾 Persistent Storage (IDBFS & NodeFS)

### IDBFS (Web & Worker)

To use IDBFS in PhpWeb, pass a `persist` object with a `mountPath` key.

`mountPath` will be used as the path to the persistent directory within the PHP environment.

```javascript
const { PhpWeb } = await import('https://cdn.jsdelivr.net/npm/php-wasm/PhpWeb.mjs');
const php = new PhpWeb;

let php = new PhpWeb({persist: {mountPath: '/persist'}});
```

### NodeFS (NodeJS Only)

To use NodeFS in PhpWeb, pass a `persist` object with `mountPath` & `localPath` keys.

`localPath` will be used as the path to the HOST directory to expose to PHP.
`mountPath` will be used as the path to the persistent directory within the PHP environment.

```javascript
const { PhpNode } = await import('https://cdn.jsdelivr.net/npm/php-wasm/PhpNode.mjs');
const php = new PhpNode;

let php = new PhpNode({persist: {mountPath: '/persist', localPath: '~/your-files'}});
```

## 🏗️ Building in-place

To use the the in-place builder, first install php-wasm globally:

***Requires docker, docker-compose & make.***

```sh
$ npm install -g php-wasm
```

Create the build environment (can be run from anywhere):

```sh
$ php-wasm image
```

Optionally clean up files from a previous build:

```sh
$ php-wasm clean
```

### Build for web

Then navigate to the directory you want the files to be built in, and run `php-wasm build`

```sh
$ cd ~/my-project
$ php-wasm build
# php-wasm build web
#  "web" is the default here
```

### Build for node

```sh
$ cd ~/my-project
$ php-wasm build node
```

### ESM Modules:

Build ESM modules with:

```sh
$ php-wasm build web mjs
$ php-wasm build node mjs
```

This will build the following files in the current directory (or in `PHP_DIST_DIR`, *see below for more info.*)

```sh
# php-wasm build web
PhpWeb.js          # ⭐ require this module in your javascript if you want to use PHP in JS.
php-web.js         # internal interface between WASM and javscript
php-web.js.wasm    # binary php-wasm

# php-wasm build node
PhpNode.js         # ⭐ require this module in your scripts to use PHP in JS in node.
php-node.js        # internal interface between WASM and javscript
php-node.js.wasm   # binary php-wasm

# php-wasm build web mjs
PhpWeb.mjs         # ⭐ import this module in your javascript if you want to use PHP in JS.
php-tags.local.mjs # ✨ include this with a script tag in your HTML if you want to use inline PHP
php-web.mjs        # internal interface between WASM and javscript
php-web.mjs.wasm   # Binary php-wasm

# php-wasm build node mjs
PhpNode.mjs        # ⭐ import this module in your scripts to use PHP in JS in node.
php-node.mjs       # internal interface between WASM and javscript
php-node.mjs.wasm  # binary php-wasm

PhpBase.js         # All cjs builds depend on this file.
PhpBase.mjs        # All mjs builds depend on this file.
```

### .php-wasm-rc

You can also create a `.php-wasm-rc` file in this directory to customize the build.

```make
# Build to a directory other than the current one (absolute path)
PHP_DIST_DIR=~/my-project/public

# Space separated list of files/directories (absolute paths)
# to be included under the /preload directory in the final build.
PRELOAD_ASSETS=~/my-project/php-scripts ~/other-dir/example.php

# Memory to start the instance with, before growth
INITIAL_MEMORY=2048MB

# Build with assertions enabled
ASSERTIONS=0

# Select the optimization level
OPTIMIZATION=3

# Build with libXML
WITH_LIBXML=1

# Build with Tidy
WITH_TIDY=1

# Build with Iconv
WITH_ICONV=1

# Build with SQLite
WITH_SQLITE=1

# Build with VRZNO
WITH_VRZNO=1
```

## 📦 Packaging files

Use the `PRELOAD_ASSETS` key in your `.php-wasm-rc` file to define a list of files and directories to include by default.

These files will be available under `/preload` in the final package.

### Persistent Memory

So long as `php.refresh()` is not called from Javascript, the instance will maintain its own persistent memory.

```php
<?php
// Run this over and over again...
print ++$x;

```

## 🤝 php-wasm started as a fork of oraoto/PIB...

https://github.com/oraoto/pib

## 🍻 Licensed under the Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

http://www.apache.org/licenses/LICENSE-2.0
