# php-wasm aka PIB

Changes

## 0.0.8 - Preparing for Liftoff

* Adding ESM & CDN Module support!
* Adding stdin
* Buffering stdout/stderr in javascript
* Fixing `<script type = "text/php">` support.
* Adding fetch support for `src` on above.
* Adding support for iconv & html-tidy
* In-place builds.
* Conditional builds.
* Updating PHP to 8.2.11
* Building with Emscripten 3.1.43

## 0.0.7 - Remodermizing

* Updating PHP to 8.2.4
* Updating SQLite to 3.41
* Updating Drupal to 7.95

* Correcting hiccups in the build process

## 0.0.6 - Ease

* Correcting hiccups in the build process

## 0.0.5 - Alignment

* Ensuring npm & github have matching tags
* Ensuring Drupal re-builds correctly with no nested duplicate directory
* Removing some extraneous files from example application
* Separating php-web-drupal from php-web for real this time
* Publishing php-web-drupal to npm

## 0.0.4 - Revisiting

* Separated Drupal from standard php-web to save bandwidth
* Running the build automatically on push in CircleCI
* Getting the automatic build working for Drupal

## 0.0.3 - New Horizons

* php.exec() may be used to evaluate a single php expression & return its result.
* php may now access & traverse the dom and access nodes.
* The querySelector method is available on dom nodes.
* addEventListener/removeEventListener is also available on dom nodes.
* sqlite3 v3.33 is now statically linked to php & the sqlite3 extension is enabled.
* The following extensions are now enabled: sqlite3, pdo, & pdo-sqlite.
* Totally revamped build process that tracks build artifact relationships.
* Builds for web, node, shell, worker & webview.

## 0.0.2 - Gaining Momentum

* php objects now have persistent memory, may be cleared with `php.refresh();`.
* php code may now access Javascript (and thus, the DOM) via the [VRZNO](https://github.com/seanmorris/vrzno) project. The extension is preinstalled with php-wasm.
* `<script type = "text/php">` tags are now supported, both inline and with `src=...`. Both require opening tags as of now.
* Building of object files is now separated from building of binary files so multiple binaries may be built from the same set of objects.
* License changed from MIT to Apache-2.0, which has similar terms, but USERS must have visibility of the attribution, rather that just DEVELOPERS.
* Build dependencies are now expressed in the makefile
* Project can be built in its entirety by running `make`.
* Ensuring newlines in PHP output are respected.


## 0.0.1 - Humble Beginnings

* Event-oriented interface added to php object.
* Buildscript was slightly improved with a makefile
