#!/usr/bin/env make

.PHONY: all web js cjs mjs clean php-clean deep-clean show-ports show-versions show-files hooks image push-image pull-image dist demo serve-demo scripts third_party/preload test archives assets

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

## Defaults:

ENV_FILE?=.env
-include ${ENV_FILE}

## Default libraries
WITH_BCMATH  ?=1
WITH_CALENDAR?=1
WITH_CTYPE   ?=1
WITH_EXIF    ?=1
WITH_FILTER  ?=1
WITH_MBSTRING?=1
WITH_SESSION ?=1
WITH_TOKENIZER?=1

ifeq ($(filter ${WITH_BCMATH},0 1),)
$(error WITH_BCMATH MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_CALENDAR},0 1),)
$(error WITH_CALENDAR MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_CTYPE},0 1),)
$(error WITH_CTYPE MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_EXIF},0 1),)
$(error WITH_EXIF MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_FILTER},0 1),)
$(error WITH_FILTER MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_MBSTRING},0 1),)
$(error WITH_MBSTRING MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_SESSION},0 1),)
$(error WITH_SESSION MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_TOKENIZER},0 1),)
$(error WITH_TOKENIZER MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

## More libraries
WITH_ICONV   ?=1
WITH_LIBXML  ?=1
WITH_LIBZIP  ?=1
WITH_SQLITE  ?=1
WITH_VRZNO   ?=1
WITH_ZLIB    ?=1

## Even more libraries...
WITH_PHAR    ?=0
WITH_OPENSSL ?=0
WITH_GD      ?=0
WITH_LIBPNG  ?=0
WITH_LIBJPEG ?=0
WITH_FREETYPE?=0

ifeq ($(filter ${WITH_PHAR},0 1),)
$(error WITH_PHAR MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_GD},0 1),)
$(error WITH_GD MUST BE 0, 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

## Extra libraries...
WITH_ONIGURUMA?=0
WITH_ICU   ?=0
WITH_TIDY  ?=0
WITH_EXIF  ?=0
WITH_YAML  ?=0

## Emscripten features...
NODE_RAW_FS ?=0
WITH_NETWORKING?=0

ifeq ($(filter ${NODE_RAW_FS},0 1),)
$(error NODE_RAW_FS MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${WITH_NETWORKING},0 1),)
$(error WITH_NETWORKING MUST BE 0, 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

## Compression
GZIP       ?=0
BROTLI     ?=0

ifeq ($(filter ${GZIP},0 1),)
$(error GZIP MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq ($(filter ${BROTLI},0 1),)
$(error BROTLI MUST BE 0, 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

## PHP Version
PHP_VERSION?=8.3

ifeq ($(filter ${PHP_VERSION},8.3 8.2 8.1 8.0),)
$(error PHP_VERSION MUST BE 8.3, 8.2, 8.1 or 8.0. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

## More Options
PHP_DIST_DIR?=./packages/php-wasm
INITIAL_MEMORY ?=128MB
MAXIMUM_MEMORY ?=4096MB
ASSERTIONS     ?=0
SYMBOLS        ?=0
OPTIMIZE       ?=2
SUB_OPTIMIZE   ?=OPTIMIZE
RELEASE_SUFFIX ?=

## End of defaults

_UID:=$(shell id -u)
_GID:=$(shell id -g)
UID?=${_UID}
GID?=${_GID}

SHELL=bash -euo pipefail

PKG_CONFIG_PATH=/src/lib/lib/pkgconfig

INTERACTIVE=
PROGRESS=--progress auto
CPU_COUNT=`nproc || echo 1`

DOCKER_ENV=PHP_DIST_DIR=${PHP_DIST_DIR} docker-compose ${PROGRESS} -p phpwasm run ${INTERACTIVE} --rm \
	-e PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
	-e PRELOAD_ASSETS='${PRELOAD_ASSETS}' \
	-e INITIAL_MEMORY=${INITIAL_MEMORY}   \
	-e ENVIRONMENT=${ENVIRONMENT}         \
	-e PHP_BRANCH=${PHP_BRANCH}           \
	-e EMCC_CORES=${CPU_COUNT}

DOCKER_RUN=${DOCKER_ENV} emscripten-builder
DOCKER_RUN_IN_PHP =${DOCKER_ENV} -e CFLAGS="-I /src/lib/include" -w /src/third_party/php${PHP_VERSION}-src/ emscripten-builder

TIMER=(which pv > /dev/null && pv --name '${@}' || cat)

MJS=$(addprefix ${PHP_DIST_DIR}/,php-web.mjs php-webview.mjs php-node.mjs php-shell.mjs php-worker.mjs) \
	$(addprefix ${PHP_DIST_DIR}/,PhpWeb.mjs  PhpWebview.mjs  PhpNode.mjs  PhpShell.mjs  PhpWorker.mjs) \
	$(addprefix ${PHP_DIST_DIR}/,OutputBuffer.mjs webTransactions.mjs _Event.mjs PhpBase.mjs fsOps.mjs)

CJS=$(addprefix ${PHP_DIST_DIR}/,php-web.js php-webview.js php-node.js php-shell.js php-worker.js) \
	$(addprefix ${PHP_DIST_DIR}/,PhpWeb.js  PhpWebview.js  PhpNode.js  PhpShell.js  PhpWorker.js) \
	$(addprefix ${PHP_DIST_DIR}/,OutputBuffer.js webTransactions.js  _Event.js  PhpBase.js fsOps.js)

TAG_JS=$(addprefix ${PHP_DIST_DIR}/,php-tags.mjs php-tags.jsdelivr.mjs php-tags.unpkg.mjs php-tags.local.mjs)

ALL=${MJS} ${CJS} ${TAG_JS}

all: ${ALL}
cjs: ${CJS}
mjs: ${MJS}

web-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpWeb.mjs OutputBuffer.mjs fsOps.mjs webTransactions.mjs _Event.mjs php-web.mjs)
web-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpWeb.js  OutputBuffer.js  fsOps.js  webTransactions.js  _Event.js php-web.js)

worker-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpWorker.mjs OutputBuffer.mjs fsOps.mjs webTransactions.mjs _Event.mjs php-worker.mjs)
worker-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpWorker.js  OutputBuffer.js  fsOps.js  webTransactions.js  _Event.js php-worker.js)

webview-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpWebview.mjs OutputBuffer.mjs fsOps.mjs webTransactions.mjs _Event.mjs php-webview.mjs)
webview-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpWebview.js  OutputBuffer.js  fsOps.js  webTransactions.js  _Event.js php-webview.js)

node-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpNode.mjs OutputBuffer.mjs fsOps.mjs _Event.mjs php-node.mjs)
node-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpNode.js  OutputBuffer.js  fsOps.js   _Event.js php-node.js)

shell-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpShell.mjs OutputBuffer.mjs fsOps.mjs _Event.mjs php-shell.mjs)
shell-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpShell.js  OutputBuffer.js  fsOps.js  _Event.js php-shell.js)

WITH_CGI=1

PHP_CONFIGURE_DEPS=
DEPENDENCIES=
ORDER_ONLY=
EXTRA_FILES=
CONFIGURE_FLAGS=
EXTRA_FLAGS=
PHP_ARCHIVE_DEPS=third_party/php${PHP_VERSION}-src/configured third_party/php${PHP_VERSION}-src/patched
ARCHIVES=
SHARED_LIBS=
EXPORTED_FUNCTIONS="_pib_init", "_pib_storage_init", "_pib_destroy", "_pib_run", "_pib_exec", "_pib_refresh", "_pib_flush", "_main", "_malloc", "_free", "_realloc"
PRE_JS_FILES=source/env.js
EXTRA_PRE_JS_FILES?=
PHPIZE=third_party/php${PHP_VERSION}-src/scripts/phpize

PRE_JS_FILES+= ${EXTRA_PRE_JS_FILES}

TEST_LIST=

ifeq (${PHP_VERSION},8.3)
PHP_BRANCH=php-8.3.7
PHP_AR=libphp
endif

ifeq (${PHP_VERSION},8.2)
PHP_BRANCH=php-8.2.11
PHP_AR=libphp
endif

ifeq (${PHP_VERSION},8.1)
PHP_BRANCH=php-8.1.28
PHP_AR=libphp
endif

ifeq (${PHP_VERSION},8.0)
PHP_BRANCH=php-8.0.30
PHP_AR=libphp
endif

ifeq (${PHP_VERSION},7.4)
PHP_BRANCH=php-7.4.28
PHP_AR=libphp7
EXTRA_FLAGS+= -s EMULATE_FUNCTION_POINTER_CASTS=1
endif

EXTRA_CFLAGS=
ZEND_EXTRA_LIBS=
SKIP_LIBS=
PHP_ASSET_LIST=
PHP_ASSET_PATH?=${PHP_DIST_DIR}
SHARED_ASSET_PATHS=${PHP_ASSET_PATH}


ifneq (${PHP_ASSET_PATH},${PHP_DIST_DIR})
PHP_ASSET_LIST+=
endif

-include packages/php-cgi-wasm/static.mak
-include $(addsuffix /static.mak,$(shell npm ls -p))

ifdef PRELOAD_ASSETS
DEPENDENCIES+=
ORDER_ONLY+=third_party/preload
EXTRA_FLAGS+= ${PRELOAD_METHOD} /src/third_party/preload@/preload
endif

########### Collect & patch the source code. ###########

third_party/php${PHP_VERSION}-src/patched: third_party/php${PHP_VERSION}-src/.gitignore
	${DOCKER_RUN} git apply --no-index patch/php${PHP_VERSION}.patch
	${DOCKER_RUN} mkdir -p third_party/php${PHP_VERSION}-src/preload/Zend
	${DOCKER_RUN} touch third_party/php${PHP_VERSION}-src/patched

third_party/preload: third_party/php${PHP_VERSION}-src/patched ${PRELOAD_ASSETS}
	 ${DOCKER_RUN} rm -rf /src/third_party/preload
ifdef PRELOAD_ASSETS
	@ mkdir -p third_party/preload
	@ cp -prfL ${PRELOAD_ASSETS} third_party/preload/
endif

third_party/php${PHP_VERSION}-src/.gitignore:
	@ echo -e "\e[33;4mDownloading and patching PHP\e[0m"
	${DOCKER_RUN} git clone https://github.com/php/php-src.git third_party/php${PHP_VERSION}-src \
		--branch ${PHP_BRANCH}   \
		--single-branch          \
		--depth 1

third_party/php${PHP_VERSION}-src/ext/pib/pib.c: source/pib/pib.c
	@ ${DOCKER_RUN} cp -prf source/pib third_party/php${PHP_VERSION}-src/ext/

########### Build the objects. ###########

ifneq (${WITH_NETWORKING},0)
EXTRA_FLAGS+= -lwebsocket.js
endif

ifneq (${WITH_BCMATH},0)
CONFIGURE_FLAGS+= --enable-bcmath
endif

ifneq (${WITH_CALENDAR},0)
CONFIGURE_FLAGS+= --enable-calendar
endif

ifneq (${WITH_CTYPE},0)
CONFIGURE_FLAGS+= --enable-ctype
endif

ifneq (${WITH_EXIF},0)
CONFIGURE_FLAGS+= --enable-exif
endif

ifneq (${WITH_FILTER},0)
CONFIGURE_FLAGS+= --enable-filter
endif

ifneq (${WITH_MBSTRING},0)
CONFIGURE_FLAGS+= --enable-mbstring
endif

ifneq (${WITH_PHAR},0)
CONFIGURE_FLAGS+= --enable-phar
endif

ifneq (${WITH_SESSION},0)
CONFIGURE_FLAGS+= --enable-session
endif

ifneq (${WITH_TOKENIZER},0)
CONFIGURE_FLAGS+= --enable-tokenizer
endif

ifeq (${WITH_ONIGURUMA},0)
CONFIGURE_FLAGS+= --disable-mbregex
endif

ifeq (${WITH_ONIGURUMA},shared)
PHP_CONFIGURE_DEPS+= lib/lib/libonig.so
CONFIGURE_FLAGS+= --with-onig=/src/lib
endif

ifeq (${WITH_GD}, 1)
TEST_LIST+=$(shell ls packages/gd/test/*.mjs)
CONFIGURE_FLAGS+= --enable-gd
endif

DEPENDENCIES+= ${ENV_FILE} ${ARCHIVES}

third_party/php${PHP_VERSION}-src/configured: ${ENV_FILE} ${ARCHIVES} ${PHP_CONFIGURE_DEPS} third_party/php${PHP_VERSION}-src/patched third_party/php${PHP_VERSION}-src/ext/pib/pib.c
	@ echo -e "\e[33;4mConfiguring PHP\e[0m"
	${DOCKER_RUN_IN_PHP} ./buildconf --force
	${DOCKER_RUN_IN_PHP} emconfigure ./configure --cache-file=/src/.cache/config-cache \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		--prefix=/src/lib/ \
		--with-config-file-path=/preload \
		--with-layout=GNU  \
		--with-valgrind=no \
		--enable-cgi       \
		--enable-cli       \
		--enable-embed=static \
		--enable-pib       \
		--enable-json      \
		--disable-all      \
		--disable-fiber-asm \
		--disable-phpdbg   \
		--disable-rpath    \
		--without-pear     \
		--without-pcre-jit \
		${CONFIGURE_FLAGS}
	${DOCKER_RUN_IN_PHP} touch /src/third_party/php${PHP_VERSION}-src/configured

SYMBOL_FLAGS=
ifdef SYMBOLS
ifneq (${SYMBOLS},0)
SYMBOL_FLAGS=-g${SYMBOLS}
EXTRA_FLAGS+=${SYMBOL_FLAGS}
# EXTRA_FLAGS+= -g${SYMBOLS} -fno-inline
endif
endif

ifdef INLINING_LIMIT
EXTRA_FLAGS+= -sINLINING_LIMIT${INLINING_LIMIT}
endif

ifdef SOURCE_MAP_BASE
EXTRA_FLAGS+= --source-map-base ${SOURCE_MAP_BASE}
endif

ifneq (${PRE_JS_FILES},)
EXTRA_FLAGS+= --pre-js /src/.cache/pre.js
endif

.cache/pre.js: ${PRE_JS_FILES}
ifneq (${PRE_JS_FILES},)
	${DOCKER_RUN} cat ${PRE_JS_FILES} > .cache/pre.js
endif

WEB_FS_TYPE?=-lidbfs.js
NODE_FS_TYPE?=-lnodefs.js
WORKER_FS_TYPE?=${WEB_FS_TYPE}

ifneq (${NODE_RAW_FS},0)
NODE_FS_TYPE+= -lnoderawfs.js
endif

PRELOAD_METHOD=--preload-file

SAPI_CLI_PATH=sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE}
SAPI_CGI_PATH=sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE}

BUILD_FLAGS=-f ../../php.mk -j${CPU_COUNT} \
	SKIP_LIBS='${SKIP_LIBS}' \
	ZEND_EXTRA_LIBS='${ZEND_EXTRA_LIBS}' \
	SAPI_CGI_PATH='${SAPI_CLI_PATH}' \
	SAPI_CLI_PATH='${SAPI_CGI_PATH}'\
	PHP_CLI_OBJS='sapi/embed/php_embed.lo' \
	EXTRA_CFLAGS='-Wno-incompatible-function-pointer-types -Wno-int-conversion -Wimplicit-function-declaration -fPIC -flto ${EXTRA_CFLAGS} ${SYMBOL_FLAGS} '\
	EXTRA_CXXFLAGS='-Wno-incompatible-function-pointer-types -Wno-int-conversion -Wimplicit-function-declaration -fPIC -flto ${EXTRA_CFLAGS} ${SYMBOL_FLAGS} '\
	EXTRA_LDFLAGS_PROGRAM='-O${OPTIMIZE} -static \
		-Wl,-zcommon-page-size=2097152 -Wl,-zmax-page-size=2097152 -L/src/lib/lib \
		-fPIC ${SYMBOL_FLAGS}                    \
		-s EXPORTED_FUNCTIONS='\''[${EXPORTED_FUNCTIONS}]'\'' \
		-s EXPORTED_RUNTIME_METHODS='\''["ccall", "UTF8ToString", "lengthBytesUTF8", "getValue", "FS", "ENV"]'\'' \
		-s ENVIRONMENT=${ENVIRONMENT}            \
		-s INITIAL_MEMORY=${INITIAL_MEMORY}      \
		-s MAXIMUM_MEMORY=${MAXIMUM_MEMORY}      \
		-s ALLOW_MEMORY_GROWTH=1                 \
		-s TOTAL_STACK=32MB                      \
		-s ASSERTIONS=${ASSERTIONS}              \
		-s ERROR_ON_UNDEFINED_SYMBOLS=0          \
		-s EXPORT_NAME="'PHP'"                   \
		-s FORCE_FILESYSTEM                      \
		-s EXIT_RUNTIME=1                        \
		-s INVOKE_RUN=0                          \
		-s MAIN_MODULE=2                         \
		-s MODULARIZE=1                          \
		-s ASYNCIFY                              \
		-s ASYNCIFY_IGNORE_INDIRECT=1            \
		-I /src/third_party/php${PHP_VERSION}-src/ \
		-I /src/third_party/php${PHP_VERSION}-src/Zend  \
		-I /src/third_party/php${PHP_VERSION}-src/main  \
		-I /src/third_party/php${PHP_VERSION}-src/TSRM/ \
		$(addprefix /src/,${ARCHIVES}) \
		${FS_TYPE}                               \
		${EXTRA_FILES} \
		${EXTRA_FLAGS} \
	'

BUILD_TYPE ?=js

ifneq (${PRE_JS_FILES},)
DEPENDENCIES+= .cache/pre.js
endif

DEPENDENCIES+= third_party/php${PHP_VERSION}-src/configured $(addprefix ${PHP_ASSET_PATH}/,${PHP_ASSET_LIST})

READ_ASYNC_OLD=readAsync=\(url,onload,onerror\)=>\{var xhr=new XMLHttpRequest\;xhr.open\("GET",url,true\)\;xhr.responseType="arraybuffer"\;xhr.onload=\(\)=>\{if\(xhr.status==200..xhr.status==0&&xhr.response\)\{onload\(xhr.response\)\;return\}onerror\(\)\}\;xhr.onerror=onerror\;xhr.send\(null\)\}
READ_ASYNC_NEW=readAsync=(url, onload, onerror)  =>  {fetch(url).then(response => response.arrayBuffer()).then(onload).catch(onerror)};

build/php-web.js: BUILD_TYPE=js
build/php-web.js: ENVIRONMENT=web
build/php-web.js: FS_TYPE=${WEB_FS_TYPE}
build/php-web.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-web.mjs: BUILD_TYPE=mjs
build/php-web.mjs: ENVIRONMENT=web
build/php-web.mjs: FS_TYPE=${WEB_FS_TYPE}
build/php-web.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|var _script(Dir\|Name) = import.meta.url;|const importMeta = import.meta;var _script\1 = importMeta.url;|g' $@
	perl -pi -w -e 's|_setTempRet0|setTempRet0|g' $@

build/php-worker.js: BUILD_TYPE=js
build/php-worker.js: ENVIRONMENT=worker
build/php-worker.js: FS_TYPE=${WORKER_FS_TYPE}
build/php-worker.js: PRELOAD_METHOD=--embed-file
build/php-worker.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|${READ_ASYNC_OLD}|${READ_ASYNC_NEW}|' ${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs

build/php-worker.mjs: BUILD_TYPE=mjs
build/php-worker.mjs: ENVIRONMENT=worker
build/php-worker.mjs: FS_TYPE=${WORKER_FS_TYPE}
build/php-worker.mjs: PRELOAD_METHOD=--embed-file
build/php-worker.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|var _script(Dir\|Name) = import.meta.url;|const importMeta = import.meta;var _script\1 = importMeta.url;|g' $@
	perl -pi -w -e 's|${READ_ASYNC_OLD}|${READ_ASYNC_NEW}|' ${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs

build/php-node.js: BUILD_TYPE=js
build/php-node.js: ENVIRONMENT=node
build/php-node.js: FS_TYPE=${NODE_FS_TYPE}
build/php-node.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-node.mjs: BUILD_TYPE=mjs
build/php-node.mjs: ENVIRONMENT=node
build/php-node.mjs: FS_TYPE=${NODE_FS_TYPE}
build/php-node.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|var _script(Dir\|Name) = import.meta.url;|const importMeta = import.meta;var _script\1 = importMeta.url;|g' $@

build/php-shell.js: BUILD_TYPE=js
build/php-shell.js: ENVIRONMENT=shell
build/php-shell.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-shell.mjs: BUILD_TYPE=mjs
build/php-shell.mjs: ENVIRONMENT=shell
build/php-shell.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}/
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|var _script(Dir\|Name) = import.meta.url;|const importMeta = import.meta;var _script\1 = importMeta.url;|g' $@

build/php-webview.js: BUILD_TYPE=js
build/php-webview.js: ENVIRONMENT=webview
build/php-webview.js: FS_TYPE=${WEB_FS_TYPE}
build/php-webview.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-webview.mjs: BUILD_TYPE=mjs
build/php-webview.mjs: ENVIRONMENT=webview
build/php-webview.js: FS_TYPE=${WEB_FS_TYPE}
build/php-webview.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	perl -pi -w -e 's|import\(name\)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require\("fs"\)|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|var _script(Dir\|Name) = import.meta.url;|const importMeta = import.meta;var _script\1 = importMeta.url;|g' $@

########## Package files ###########

${PHP_DIST_DIR}/%.js: source/%.js
	npx babel $< --out-dir ${PHP_DIST_DIR}

${PHP_DIST_DIR}/%.mjs: source/%.js
	cp $< $@;
	perl -pi -w -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

${PHP_DIST_DIR}/php-tags.mjs: source/php-tags.mjs
	cp $< $@;

${PHP_DIST_DIR}/php-tags.jsdelivr.mjs: source/php-tags.jsdelivr.mjs
	cp $< $@;

${PHP_DIST_DIR}/php-tags.unpkg.mjs: source/php-tags.unpkg.mjs
	cp $< $@;

${PHP_DIST_DIR}/php-tags.local.mjs: source/php-tags.local.mjs
	cp $< $@;

${PHP_DIST_DIR}/%.js: build/%.js
	cp $^ $@
	cp $^.wasm* $(dir $@)
ifneq (${PRELOAD_ASSETS},)
	cp $^.data $@.data
endif
ifneq (${GZIP},0)
	rm -f $@.wasm.gz
	bash -c 'gzip -9 < $@.wasm > $@.wasm.gz'
ifneq (${PRELOAD_ASSETS},)
	rm -f $@.data.gz
	bash -c 'gzip -9 < $@.data > $@.data.gz'
endif
endif
ifneq (${BROTLI},0)
	rm -f $@.wasm.br
	brotli -9 $@.wasm
	rm -f $@.br
	brotli -9 $@
ifneq (${PRELOAD_ASSETS},)
	rm -f $@.data.br
	brotli -9 $@.data
endif
endif
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
endif

${PHP_DIST_DIR}/%.mjs: build/%.mjs
	cp $^ $@
	cp $^.wasm* $(dir $@)
ifneq (${PRELOAD_ASSETS},)
	cp $^.data $@.data
endif
ifneq (${GZIP},0)
	rm -f $@.gz
	bash -c 'gzip -9 < $@ > $@.gz'
	rm -f $@.wasm.gz
	bash -c 'gzip -9 < $@.wasm > $@.wasm.gz'
ifneq (${PRELOAD_ASSETS},)
	rm -f $@.data.gz
	bash -c 'gzip -9 < $@.data > $@.data.gz'
endif
endif
ifneq (${BROTLI},0)
	rm -f $@.br
	brotli -9 $@
	rm -f $@.wasm.br
	brotli -9 $@.wasm
ifneq (${PRELOAD_ASSETS},)
	rm -f $@.data.br
	brotli -9 $@.data
endif
endif
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
endif

${PHP_DIST_DIR}/php-worker.js: build/php-worker.js
	cp $^ $@
	cp $^.wasm* $(dir $@)
ifneq (${GZIP},0)
	rm -f $@.gz
	bash -c 'gzip -9 < $@ > $@.gz'
	rm -f $@.wasm.gz
	bash -c 'gzip -9 < $@.wasm > $@.wasm.gz'
endif
ifneq (${BROTLI},0)
	rm -f $@.br
	brotli -9 $@
	rm -f $@.wasm.br
	brotli -9 $@.wasm
endif
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
endif

${PHP_DIST_DIR}/php-worker.mjs: build/php-worker.mjs
	cp $^ $@
	cp $^.wasm* $(dir $@)
ifneq (${GZIP},0)
	rm -f $@.gz
	bash -c 'gzip -9 < $@.wasm > $@.gz'
	rm -f $@.wasm.gz
	bash -c 'gzip -9 < $@.wasm > $@.wasm.gz'
endif
ifneq (${BROTLI},0)
	rm -f $@.br
	brotli -9 $@
	rm -f $@.wasm.br
	brotli -9 $@.wasm
endif
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
endif

########### Clerical stuff. ###########

${ENV_FILE}:
	touch ${ENV_FILE}

archives: ${ARCHIVES}

shared: ${SHARED_LIBS}

lib/lib/libphp.a: BUILD_TYPE=js
lib/lib/libphp.a: ENVIRONMENT=web
lib/lib/libphp.a: FS_TYPE=${WEB_FS_TYPE}
lib/lib/libphp.a: | ${DEPENDENCIES} ${ORDER_ONLY} third_party/preload
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} cli PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} install

${PHPIZE}: | lib/lib/libphp.a
	${DOCKER_RUN_IN_PHP} make ${BUILD_FLAGS} scripts/phpize PHP_BINARIES=cli WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} touch scripts/phpize
	${DOCKER_RUN_IN_PHP} chmod +x scripts/phpize

patch/php8.3.patch:
	bash -c 'cd third_party/php8.3-src/ && git diff > ../../patch/php8.3.patch'
	perl -pi -w -e 's|([ab])/|\1/third_party/php8.3-src/|g' ./patch/php8.3.patch

patch/php8.2.patch:
	bash -c 'cd third_party/php8.2-src/ && git diff > ../../patch/php8.2.patch'
	perl -pi -w -e 's|([ab])/|\1/third_party/php8.2-src/|g' ./patch/php8.2.patch

patch/php8.1.patch:
	bash -c 'cd third_party/php8.1-src/ && git diff > ../../patch/php8.1.patch'
	perl -pi -w -e 's|([ab])/|\1/third_party/php8.1-src/|g' ./patch/php8.1.patch

patch/php8.0.patch:
	bash -c 'cd third_party/php8.0-src/ && git diff > ../../patch/php8.0.patch'
	perl -pi -w -e 's|([ab])/|\1/third_party/php8.0-src/|g' ./patch/php8.0.patch

# patch/libicu.patch:
# 	bash -c 'cd third_party/libicu-72-1 && git diff > ../../patch/libicu.patch'
# 	perl -pi -w -e 's|([ab])/|\1/third_party/libicu-72-1/|g' ./patch/libicu.patch

php-clean:
	${DOCKER_RUN_IN_PHP} make clean

clean deep-clean:
	${DOCKER_RUN} rm -rf \
		lib/* \
		third_party/* \
		packages/*/*.so \
		packages/php-wasm/*.mjs \
		packages/php-cgi-wasm/*.mjs \
		packages/php-wasm/*.mjs* \
		packages/php-cgi-wasm/*.mjs* \

assets: $(addprefix ${PHP_ASSET_PATH}/,${PHP_ASSET_LIST})

show-ports:
	${DOCKER_RUN} emcc --show-ports

show-version:
	${DOCKER_RUN} emcc --show-version

show-files:
	${DOCKER_RUN} emcc --show-files

hooks:
	git config core.hooksPath githooks

image:
	docker-compose build
	# docker-compose --progress quiet build

pull-image:
	docker-compose --progress quiet pull

push-image:
	docker-compose --progress quiet push

demo:
	cd demo-source && npm run build

serve-demo:
	cd demo-source && npm run start

NPM_PUBLISH_DRY?=--dry-run

publish:
	npm publish ${NPM_PUBLISH_DRY}

test: ${TEST_LIST} node-mjs
	node --test ${TEST_LIST} `ls test/*.mjs`
