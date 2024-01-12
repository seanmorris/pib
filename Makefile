#!/usr/bin/env make

ENV_FILE?=.env
-include ${ENV_FILE}

WITH_LIBXML?=1
WITH_TIDY  ?=1
WITH_ICONV ?=1
WITH_ICU   ?=0
WITH_SQLITE?=1
WITH_VRZNO ?=1

GZIP       ?=0
BROTLI     ?=0

BUILD_WEB?=1
BUILD_NODE?=1
BUILD_SHELL?=1
BUILD_WORKER?=1
BUILD_WEBVIEW?=1

_UID:=$(shell echo $$UID)
_GID:=$(shell echo $$UID)
UID?=${_UID}
GID?=${_GID}

SHELL=bash -euo pipefail

PHP_DIST_DIR_DEFAULT ?=./dist
PHP_DIST_DIR ?=${PHP_DIST_DIR_DEFAULT}

ENVIRONMENT    ?=web
# INITIAL_MEMORY ?=3072MB
INITIAL_MEMORY ?=64MB
MAXIMUM_MEMORY ?=4096MB
ASSERTIONS     ?=1
# SYMBOLS        ?=3
OPTIMIZE       ?=2
RELEASE_SUFFIX ?=

PHP_VERSION    ?=8.2
PHP_BRANCH     ?=php-8.2.11
PHP_AR         ?=libphp

PKG_CONFIG_PATH=/src/lib/lib/pkgconfig

INTERACTIVE=
PROGRESS=--progress quiet

# ifeq (${IS_TTY},1)
# INTERACTIVE=
# PROGRESS=--progress tty
# endif

DOCKER_ENV=PHP_DIST_DIR=${PHP_DIST_DIR} docker-compose ${PROGRESS} -p phpwasm run ${INTERACTIVE} --rm \
	-e PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
	-e PRELOAD_ASSETS='${PRELOAD_ASSETS}' \
	-e INITIAL_MEMORY=${INITIAL_MEMORY}   \
	-e ENVIRONMENT=${ENVIRONMENT}         \
	-e PHP_BRANCH=${PHP_BRANCH}           \
	-e EMCC_CORES=`nproc`

DOCKER_ENV_SIDE=docker-compose ${PROGRESS} -p phpwasm run ${INTERACTIVE} --rm \
	-e PRELOAD_ASSETS='${PRELOAD_ASSETS}' \
	-e INITIAL_MEMORY=${INITIAL_MEMORY}   \
	-e ENVIRONMENT=${ENVIRONMENT}         \
	-e PHP_BRANCH=${PHP_BRANCH}           \
	-e EMCC_CORES=`nproc`                 \
	-e CFLAGS=" -I/root/lib/include " \
	-e EMCC_FLAGS=" -sSIDE_MODULE=1 -sERROR_ON_UNDEFINED_SYMBOLS=0 "

DOCKER_RUN           =${DOCKER_ENV} emscripten-builder
DOCKER_RUN_USER      =${DOCKER_ENV} -e UID=${UID} -e GID=${GID} emscripten-builder
DOCKER_RUN_IN_PHP    =${DOCKER_ENV} -w /src/third_party/php${PHP_VERSION}-src/ emscripten-builder
DOCKER_RUN_IN_PHPSIDE=${DOCKER_ENV_SIDE} -w /src/third_party/php${PHP_VERSION}-src/ emscripten-builder
DOCKER_RUN_IN_ICU4C  =${DOCKER_ENV} -w /src/third_party/libicu-src/icu4c/source/ emscripten-builder
DOCKER_RUN_IN_LIBXML =${DOCKER_ENV} -w /src/third_party/libxml2/ emscripten-builder
DOCKER_RUN_IN_LIBZIP =${DOCKER_ENV} -w /src/third_party/libzip/ emscripten-builder
DOCKER_RUN_IN_SQLITE =${DOCKER_ENV_SIDE} -w /src/third_party/${SQLITE_DIR}/ emscripten-builder
DOCKER_RUN_IN_TIDY   =${DOCKER_ENV_SIDE} -w /src/third_party/tidy-html5/ emscripten-builder
DOCKER_RUN_IN_ICU    =${DOCKER_ENV_SIDE} -w /src/third_party/libicu-src/icu4c/source emscripten-builder
DOCKER_RUN_IN_ICONV  =${DOCKER_ENV_SIDE} -w /src/third_party/libiconv-1.17/ emscripten-builder
DOCKER_RUN_IN_TIMELIB=${DOCKER_ENV_SIDE} -w /src/third_party/timelib/ emscripten-builder

TIMER=(which pv > /dev/null && pv --name '${@}' || cat)
.PHONY: all web js cjs mjs clean php-clean deep-clean show-ports show-versions show-files hooks image push-image pull-image dist demo scripts third_party/preload php-tags.mjs test

MJS=php-web.mjs php-webview.mjs php-node.mjs php-shell.mjs php-worker.mjs \
	PhpWeb.mjs  PhpWebview.mjs  PhpNode.mjs  PhpShell.mjs  PhpWorker.mjs

CJS=php-web.js php-webview.js php-node.js php-shell.js php-worker.js \
	PhpWeb.js  PhpWebview.js  PhpNode.js  PhpShell.js  PhpWorker.js

all: ${MJS} ${CJS} php-tags.mjs php-tags.jsdelivr.mjs php-tags.unpkg.mjs php-tags.local.mjs
cjs: ${CJS}
mjs: ${MJS}

dist: dist/php-web-drupal.mjs dist/php-web.mjs dist/php-webview.mjs dist/php-node.mjs dist/php-shell.mjs dist/php-worker.mjs \
      dist/php-web-drupal.js  dist/php-web.js  dist/php-webview.js  dist/php-node.js  dist/php-shell.js  dist/php-worker.js \
	  dist/php-tags.mjs

web-drupal: php-web-drupal.wasm
web: lib/pib_eval.o php-web.wasm
	echo "Done!"

PRELOAD_ASSETS?=
PHP_CONFIGURE_DEPS=
DEPENDENCIES=
ORDER_ONLY=
EXTRA_FILES=/src/source/pib_eval.c
CONFIGURE_FLAGS=
EXTRA_FLAGS=
PHP_ARCHIVE_DEPS=third_party/php${PHP_VERSION}-src/configured third_party/php${PHP_VERSION}-src/patched
ARCHIVES=
EXPORTED_FUNCTIONS="_pib_init", "_pib_destroy", "_pib_run", "_pib_exec", "_pib_refresh", "_main", "_php_embed_init", "_php_embed_shutdown", "_php_embed_shutdown", "_zend_eval_string"

# include make/iconv.mak make/icu.mak make/libxml.mak make/sqlite.mak make/tidy.mak make/vrzno.mak

# SUBSOFILES?=
# SUBSOFILES+=$(addsuffix /*.so,$(shell npm ls -p))
-include $(addsuffix /static.mak,$(shell npm ls -p))

ifdef PRELOAD_ASSETS
DEPENDENCIES+=third_party/preload
ORDER_ONLY+=
EXTRA_FLAGS+= --preload-file /src/third_party/preload@/preload
endif

########### Collect & patch the source code. ###########

third_party/php${PHP_VERSION}-src/patched: third_party/php${PHP_VERSION}-src/.gitignore
	${DOCKER_RUN} git apply --no-index patch/php${PHP_VERSION}.patch
	${DOCKER_RUN} mkdir -p third_party/php${PHP_VERSION}-src/preload/Zend
	${DOCKER_RUN} touch third_party/php${PHP_VERSION}-src/patched

third_party/preload: third_party/php${PHP_VERSION}-src/patched ${PRELOAD_ASSETS} third_party/php${PHP_VERSION}-src/Zend/bench.php
	${DOCKER_RUN} rm -rf /src/third_party/preload
ifdef PRELOAD_ASSETS
	@ mkdir -p third_party/preload
	@ cp -prf ${PRELOAD_ASSETS} third_party/preload/
endif

third_party/drupal-7.95: third_party/drupal-7.95/README.txt

third_party/drupal-7.95/README.txt:
	@ echo -e "\e[33;4mDownloading and patching Drupal\e[0m"
	wget -q https://ftp.drupal.org/files/projects/drupal-7.95.zip
	${DOCKER_RUN} unzip drupal-7.95.zip
	${DOCKER_RUN} rm -v drupal-7.95.zip
	${DOCKER_RUN} mv drupal-7.95 third_party/drupal-7.95
	${DOCKER_RUN} git apply --no-index patch/drupal-7.95.patch
	${DOCKER_RUN} cp -r extras/drupal-7-settings.php third_party/drupal-7.95/sites/default/settings.php
	${DOCKER_RUN} cp -r extras/drowser-files/.ht.sqlite third_party/drupal-7.95/sites/default/files/.ht.sqlite
	${DOCKER_RUN} cp -r extras/drowser-files/* third_party/drupal-7.95/sites/default/files
	${DOCKER_RUN} cp -r extras/drowser-logo.png third_party/drupal-7.95/sites/default/logo.png
	cp -prf third_party/drupal-7.95 third_party/preload/

third_party/preload/bench.php: third_party/php${PHP_VERSION}-src/.gitignore
	mkdir -p third_party/preload/
	cp -p third_party/php${PHP_VERSION}-src/Zend/bench.php third_party/preload/

third_party/php${PHP_VERSION}-src/.gitignore:
	@ echo -e "\e[33;4mDownloading and patching PHP\e[0m"
	${DOCKER_RUN} git clone https://github.com/php/php-src.git third_party/php${PHP_VERSION}-src \
		--branch ${PHP_BRANCH}   \
		--single-branch          \
		--depth 1

########### Build the objects. ###########

third_party/php${PHP_VERSION}-src/configured: ${ENV_FILE} ${PHP_CONFIGURE_DEPS} third_party/php${PHP_VERSION}-src/patched ${ARCHIVES}
	@ echo -e "\e[33;4mConfiguring PHP\e[0m"
	${DOCKER_RUN_IN_PHPSIDE} ./buildconf --force
	${DOCKER_RUN_IN_PHPSIDE} emconfigure ./configure --config-cache \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		--enable-embed=static \
		--disable-fiber-asm \
		--prefix=/src/lib/ \
		--with-layout=GNU  \
		--disable-cgi      \
		--disable-cli      \
		--disable-all      \
		--enable-session   \
		--enable-filter    \
		--enable-calendar  \
		--disable-rpath    \
		--disable-phpdbg   \
		--without-pear     \
		--with-valgrind=no \
		--without-pcre-jit \
		--enable-bcmath    \
		--enable-json      \
		--enable-ctype     \
		--enable-mbstring  \
		--disable-mbregex  \
		--enable-tokenizer \
		--with-gd          \
		${CONFIGURE_FLAGS}
	${DOCKER_RUN_IN_PHPSIDE} touch /src/third_party/php${PHP_VERSION}-src/configured

lib/lib/${PHP_AR}.a: ${PHP_ARCHIVE_DEPS}
	@ echo -e "\e[33;4mBuilding PHP\e[0m"
	${DOCKER_RUN_IN_PHPSIDE} emmake make -j`nproc` EXTRA_CFLAGS='-Wno-int-conversion -Wno-incompatible-function-pointer-types -fPIC'
	${DOCKER_RUN_IN_PHPSIDE} emmake make install

########### Build the final files. ###########

ifdef INLINING_LIMIT
EXTRA_FLAGS+= -sINLINING_LIMIT${INLINING_LIMIT}
endif

ifdef SYMBOLS
ifneq (${SYMBOLS},0)
EXTRA_FLAGS+= -g${SYMBOLS}
endif
endif

ifdef SOURCE_MAP_BASE
EXTRA_FLAGS+= --source-map-base ${SOURCE_MAP_BASE}
endif

FINAL_BUILD=${DOCKER_RUN_IN_PHP} emcc -O${OPTIMIZE} \
	-Wno-int-conversion -Wno-incompatible-function-pointer-types \
	-s EXPORTED_FUNCTIONS='[${EXPORTED_FUNCTIONS}]' \
	-s EXPORTED_RUNTIME_METHODS='["ccall", "UTF8ToString", "lengthBytesUTF8", "getValue"]' \
	-s ENVIRONMENT=${ENVIRONMENT}    \
	-s INITIAL_MEMORY=${INITIAL_MEMORY} \
	-s MAXIMUM_MEMORY=${MAXIMUM_MEMORY} \
	-s ALLOW_MEMORY_GROWTH=1         \
	-s ASSERTIONS=${ASSERTIONS}      \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0  \
	-s FORCE_FILESYSTEM              \
	-s EXPORT_NAME="'PHP'"           \
	-s MODULARIZE=1                  \
	-s INVOKE_RUN=0                  \
	-s USE_ZLIB=1                    \
	-s ASYNCIFY                      \
	-I .     \
    -I Zend  \
    -I main  \
    -I TSRM/ \
	-I /src/third_party/libxml2 \
	-I /src/third_party/${SQLITE_DIR} \
	-I ext/pdo_sqlite \
	-I ext/json \
	-I ext/vrzno \
	${EXTRA_FLAGS} \
	-o ../../build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE} \
	$(addprefix /src/,${ARCHIVES}) \
	/src/lib/lib/${PHP_AR}.a \
	${EXTRA_FILES}

# /src/lib/lib/libicudata.a /src/lib/lib/libicui18n.a /src/lib/lib/libicuio.a /src/lib/lib/libicuuc.a

DEPENDENCIES+= ${ENV_FILE} ${ARCHIVES} lib/lib/${PHP_AR}.a source/pib_eval.c third_party/preload/bench.php
BUILD_TYPE ?=js

build/php-web-drupal.js: BUILD_TYPE=js
build/php-web-drupal.js: PRELOAD_ASSETS=third_party/drupal-7.95 third_party/php${PHP_VERSION}-src/Zend/bench.php
build/php-web-drupal.js: EXTRA_FLAGS+= --preload-file /src/third_party/preload@/preload
build/php-web-drupal.js: ENVIRONMENT=web-drupal
build/php-web-drupal.js: ${DEPENDENCIES} third_party/drupal-7.95/README.txt third_party/php${PHP_VERSION}-src/Zend/bench.php third_party/preload | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for web (drupal)\e[0m"
	${DOCKER_RUN} mkdir -p /src/third_party/preload/
	${DOCKER_RUN} cp -prf ${PRELOAD_ASSETS} /src/third_party/preload/
	${FINAL_BUILD} -s ENVIRONMENT=web
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-web-drupal.mjs: BUILD_TYPE=mjs
build/php-web-drupal.mjs: PRELOAD_ASSETS=third_party/drupal-7.95 third_party/php${PHP_VERSION}-src/Zend/bench.php
build/php-web-drupal.mjs: EXTRA_FLAGS+= --preload-file /src/third_party/preload@/preload
build/php-web-drupal.mjs: ENVIRONMENT=web-drupal
build/php-web-drupal.mjs: ${DEPENDENCIES} third_party/drupal-7.95/README.txt third_party/preload | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for web (drupal)\e[0m"
	${DOCKER_RUN} mkdir -p /src/third_party/preload/
	${DOCKER_RUN} cp -prf ${PRELOAD_ASSETS} /src/third_party/preload/
	${FINAL_BUILD} -s ENVIRONMENT=web
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-web.js: BUILD_TYPE=js
build/php-web.js: ENVIRONMENT=web
build/php-web.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for web\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-web.mjs: BUILD_TYPE=mjs
build/php-web.mjs: ENVIRONMENT=web
build/php-web.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for web\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-worker.js: BUILD_TYPE=js
build/php-worker.js: ENVIRONMENT=worker
build/php-worker.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for workers\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-worker.mjs: BUILD_TYPE=mjs
build/php-worker.mjs: ENVIRONMENT=worker
build/php-worker.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for workers\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-node.js: BUILD_TYPE=js
build/php-node.js: ENVIRONMENT=node
build/php-node.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for node\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-node.mjs: BUILD_TYPE=mjs
build/php-node.mjs: ENVIRONMENT=node
build/php-node.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for node\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-shell.js: BUILD_TYPE=js
build/php-shell.js: ENVIRONMENT=shell
build/php-shell.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for shell\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-shell.mjs: BUILD_TYPE=mjs
build/php-shell.mjs: ENVIRONMENT=shell
build/php-shell.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for shell\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-webview.js: BUILD_TYPE=js
build/php-webview.js: ENVIRONMENT=webview
build/php-webview.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for shell\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

build/php-webview.mjs: BUILD_TYPE=mjs
build/php-webview.mjs: ENVIRONMENT=webview
build/php-webview.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for webview\e[0m"
	${FINAL_BUILD}
	${DOCKER_RUN} chown ${UID}:${GID} $(basename $@)*

########## Package files ###########

php-web-drupal.js: build/php-web-drupal.js
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
	cp $(basename $^).data $(basename $@).data
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-web-drupal.mjs: build/php-web-drupal.mjs
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
	cp $(basename $^).data $(basename $@).data
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-web.js: build/php-web.js
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-web.mjs: build/php-web.mjs
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-worker.js: build/php-worker.js
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-worker.mjs: build/php-worker.mjs
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-node.js: build/php-node.js
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-node.mjs: build/php-node.mjs
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-shell.js: build/php-shell.js
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-shell.mjs: build/php-shell.mjs
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-webview.js: build/php-webview.js
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

php-webview.mjs: build/php-webview.mjs
	cp $^ $@
	cp $(basename $^).wasm* $(dir $(basename $@))
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $(basename $@).wasm.br
	brotli -9 $(basename $@).wasm
endif

PhpBase.js: source/PhpBase.js
	npx babel $< --out-dir .

PhpWebDrupal.js: source/PhpWebDrupal.js PhpBase.js
	npx babel $< --out-dir .

PhpWeb.js: source/PhpWeb.js PhpBase.js
	npx babel $< --out-dir .

PhpNode.js: source/PhpNode.js PhpBase.js
	npx babel $< --out-dir .

PhpShell.js: source/PhpShell.js PhpBase.js
	npx babel $< --out-dir .

PhpWorker.js: source/PhpWorker.js PhpBase.js
	npx babel $< --out-dir .

PhpWebview.js: source/PhpWebview.js PhpBase.js
	npx babel $< --out-dir .


PhpBase.mjs: source/PhpBase.js
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

PhpWebDrupal.mjs: source/PhpWebDrupal.js PhpBase.mjs
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

PhpWeb.mjs: source/PhpWeb.js PhpBase.mjs
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

PhpNode.mjs: source/PhpNode.js PhpBase.mjs
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

PhpShell.mjs: source/PhpShell.js PhpBase.mjs
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

PhpWorker.mjs: source/PhpWorker.js PhpBase.mjs
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

PhpWebview.mjs: source/PhpWebview.js PhpBase.mjs
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

php-tags.mjs: source/php-tags.mjs
	cp $< $@;

php-tags.jsdelivr.mjs: source/php-tags.jsdelivr.mjs
	cp $< $@;

php-tags.unpkg.mjs: source/php-tags.unpkg.mjs
	cp $< $@;

php-tags.local.mjs: source/php-tags.local.mjs
	cp $< $@;

########## Dist files ###########

dist/PhpBase.js: PhpBase.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/PhpBase.mjs: PhpBase.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/php-tags.mjs: source/php-tags.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/php-tags.local.mjs: source/php-tags.local.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/php-web-drupal.js: build/php-web-drupal.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@ $(basename $@).wasm
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@ $(basename $@).data
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@ $(basename $@).data || true
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif

dist/php-web-drupal.mjs: build/php-web-drupal.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	rm -f $(basename $@).wasm.gz
	gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif

dist/PhpWebDrupal.js: PhpWebDrupal.js dist/php-web-drupal.js dist/PhpBase.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/PhpWebDrupal.mjs: PhpWebDrupal.mjs dist/php-web-drupal.mjs dist/PhpBase.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@


dist/php-web.js: build/php-web.js dist/php-tags.mjs dist/php-tags.local.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/php-web.mjs: build/php-web.mjs dist/php-tags.mjs dist/php-tags.local.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'


dist/PhpWeb.js: PhpWeb.js dist/php-web.js dist/php-web.js dist/PhpBase.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/PhpWeb.mjs: PhpWeb.mjs dist/php-web.mjs dist/php-web.mjs dist/PhpBase.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@


dist/php-worker.js: build/php-worker.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/php-worker.mjs: build/php-worker.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/PhpWorker.js: PhpWorker.js dist/php-worker.js dist/PhpBase.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/PhpWorker.mjs: PhpWorker.mjs dist/php-worker.mjs dist/PhpBase.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@


dist/php-node.js: build/php-node.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/php-node.mjs: build/php-node.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/PhpNode.js: PhpNode.js dist/php-node.js dist/PhpBase.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/PhpNode.mjs: PhpNode.mjs dist/php-node.mjs dist/PhpBase.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@


dist/php-shell.js: build/php-shell.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/php-shell.mjs: build/php-shell.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/PhpShell.js: PhpShell.js dist/php-shell.js dist/PhpBase.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/PhpShell.mjs: PhpShell.mjs dist/php-shell.mjs dist/PhpBase.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@


dist/php-webview.js: build/php-webview.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/php-webview.mjs: build/php-webview.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN_USER} cp $(basename $<).wasm $(basename $@).wasm
	${DOCKER_RUN_USER} cp $(basename $<).data $(basename $@).data || true
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@
ifeq (${GZIP},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.gz
	${DOCKER_RUN_USER} bash -c 'gzip -9 < $(basename $@).wasm > $(basename $@).wasm.gz'
endif
ifeq (${BROTLI},1)
	${DOCKER_RUN_USER} rm -f $(basename $@).wasm.br
	${DOCKER_RUN_USER} brotli -9 $(basename $@).wasm
endif
	${DOCKER_RUN} bash -c 'chown $(or ${UID},1000):$(or ${GID},1000) $(basename $@).*'

dist/PhpWebview.js: PhpWebview.js dist/php-webview.js dist/PhpBase.js
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@

dist/PhpWebview.mjs: PhpWebview.js dist/php-webview.mjs dist/PhpBase.mjs
	${DOCKER_RUN_USER} cp $< $@
	${DOCKER_RUN} chown $(or ${UID},1000):$(or ${GID},1000) $@


############# Demo files ##############

docs-source/app/assets/php-web-drupal.wasm: ENVIRONMENT=web-drupal
docs-source/app/assets/php-web-drupal.wasm: php-web-drupal.js
	${DOCKER_RUN} cp -rv \
		build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.wasm* \
		build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.data \
		./docs-source/app/assets;

	${DOCKER_RUN} cp -rv \
		build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.wasm* \
		build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.data \
		./docs-source/public;

	${DOCKER_RUN} chown $(or $(UID),1000):$(or $(GID),1000) \
		./docs-source/app/assets/php-${ENVIRONMENT}${RELEASE_SUFFIX}.wasm* \
		./docs-source/app/assets/php-${ENVIRONMENT}${RELEASE_SUFFIX}.data \
		./docs-source/public/php-${ENVIRONMENT}${RELEASE_SUFFIX}.wasm* \
		./docs-source/public/php-${ENVIRONMENT}${RELEASE_SUFFIX}.data;

########### Clerical stuff. ###########

.env:
	touch .env

clean:
	${DOCKER_RUN} rm -fv  *.js *.mjs *.wasm *.wasm.br *.wasm.gz *.data
	${DOCKER_RUN} rm -rf /src/lib/lib/${PHP_AR}.* /src/lib/lib/php /src/lib/include/php
	${DOCKER_RUN_IN_PHP} make clean

php-clean:
	${DOCKER_RUN_IN_PHP} rm -fv configured
	${DOCKER_RUN_IN_PHP} make clean

deep-clean:
	${DOCKER_RUN} rm -fv  *.js *.mjs *.wasm *.wasm.br *.wasm.gz *.data
	${DOCKER_RUN} rm -rfv \
		third_party/php${PHP_VERSION}-src lib/* build/* \
		third_party/drupal-7.95 third_party/libxml2 third_party/tidy-html5 \
		third_party/libicu-src third_party/${SQLITE_DIR} third_party/libiconv-1.17 \
		third_party/vrzno third_party/libzip third_party/preload \
		dist/* sqlite-*

show-ports:
	${DOCKER_RUN} emcc --show-ports

show-version:
	${DOCKER_RUN} emcc --show-version

show-files:
	${DOCKER_RUN} emcc --show-files

hooks:
	git config core.hooksPath githooks

image:
	docker-compose --progress quiet build

pull-image:
	docker-compose --progress quiet pull

push-image:
	docker-compose --progress quiet push

demo: PhpWebDrupal.js php-web-drupal.js docs-source/app/assets/php-web-drupal.wasm

NPM_PUBLISH_DRY?=--dry-run

publish:
	npm publish ${NPM_PUBLISH_DRY}

test:
	node --test test/*.mjs
