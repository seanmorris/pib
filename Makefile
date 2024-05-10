#!/usr/bin/env make

.PHONY: all web js cjs mjs clean php-clean deep-clean show-ports show-versions show-files hooks image push-image pull-image dist demo scripts third_party/preload test

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

ENV_FILE?=.env
-include ${ENV_FILE}

WITH_ICONV   ?=1
WITH_LIBXML  ?=1
WITH_LIBZIP  ?=1
WITH_SQLITE  ?=1
WITH_VRZNO   ?=1
WITH_ZLIB    ?=1

WITH_OPENSSL ?=0
WITH_GD      ?=0
WITH_LIBPNG  ?=0
WITH_LIBJPEG ?=0
WITH_FREETYPE?=0

WITH_ICU   ?=0
WITH_TIDY  ?=0
WITH_EXIF  ?=0

GZIP       ?=0
BROTLI     ?=0

_UID:=$(shell id -u)
_GID:=$(shell id -g)
UID?=${_UID}
GID?=${_GID}

SHELL=bash -euo pipefail

PHP_DIST_DIR?=./

ENVIRONMENT    ?=web
# INITIAL_MEMORY ?=3072MB
INITIAL_MEMORY ?=64MB
MAXIMUM_MEMORY ?=4096MB
ASSERTIONS     ?=0
SYMBOLS        ?=3
OPTIMIZE       ?=2
RELEASE_SUFFIX ?=

PHP_VERSION    ?=8.2
PHP_BRANCH     ?=php-8.2.11
PHP_AR         ?=libphp

PKG_CONFIG_PATH=/src/lib/lib/pkgconfig

INTERACTIVE=
PROGRESS=--progress auto

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

DOCKER_RUN=${DOCKER_ENV} emscripten-builder
DOCKER_RUN_USER   =${DOCKER_ENV} -e UID=${UID} -e GID=${GID} emscripten-builder
DOCKER_RUN_IN_PHP =${DOCKER_ENV} -e CFLAGS="-I /src/lib/include" -w /src/third_party/php${PHP_VERSION}-src/ emscripten-builder

TIMER=(which pv > /dev/null && pv --name '${@}' || cat)

MJS=$(addprefix ${PHP_DIST_DIR}/,php-web.mjs php-webview.mjs php-node.mjs php-shell.mjs php-worker.mjs) \
	$(addprefix ${PHP_DIST_DIR}/,PhpWeb.mjs  PhpWebview.mjs  PhpNode.mjs  PhpShell.mjs  PhpWorker.mjs) \
	$(addprefix ${PHP_DIST_DIR}/,OutputBuffer.mjs webTransactions.mjs _Event.mjs PhpBase.mjs)

CJS=$(addprefix ${PHP_DIST_DIR}/,php-web.js php-webview.js php-node.js php-shell.js php-worker.js) \
	$(addprefix ${PHP_DIST_DIR}/,PhpWeb.js  PhpWebview.js  PhpNode.js  PhpShell.js  PhpWorker.js) \
	$(addprefix ${PHP_DIST_DIR}/,OutputBuffer.js webTransactions.js  _Event.js  PhpBase.js)

TAG_JS=$(addprefix ${PHP_DIST_DIR},php-tags.mjs php-tags.jsdelivr.mjs php-tags.unpkg.mjs php-tags.local.mjs)

all: ${MJS} ${CJS} ${TAG_JS}
cjs: ${CJS}
mjs: ${MJS}

web-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpWeb.mjs OutputBuffer.mjs webTransactions.mjs _Event.mjs php-web.mjs)
web-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpWeb.js  OutputBuffer.js  webTransactions.js  _Event.js php-web.js)

worker-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpWorker.mjs OutputBuffer.mjs webTransactions.mjs _Event.mjs php-worker.mjs)
worker-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpWorker.js  OutputBuffer.js  webTransactions.js  _Event.js php-worker.js)

webview-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpWebview.mjs OutputBuffer.mjs webTransactions.mjs _Event.mjs php-webview.mjs)
webview-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpWebview.js  OutputBuffer.js  webTransactions.js  _Event.js php-webview.js)

node-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpNode.mjs OutputBuffer.mjs _Event.mjs php-node.mjs)
node-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpNode.js  OutputBuffer.js   _Event.js php-node.js)

shell-mjs: $(addprefix ${PHP_DIST_DIR}/,PhpBase.mjs PhpShell.mjs OutputBuffer.mjs _Event.mjs php-shell.mjs)
shell-js:  $(addprefix ${PHP_DIST_DIR}/,PhpBase.js  PhpShell.js  OutputBuffer.js  _Event.js php-shell.js)

WITH_CGI=1

PRELOAD_ASSETS?=
PHP_CONFIGURE_DEPS=
DEPENDENCIES=
ORDER_ONLY=
EXTRA_FILES=
CONFIGURE_FLAGS=
EXTRA_FLAGS=
PHP_ARCHIVE_DEPS=third_party/php${PHP_VERSION}-src/configured third_party/php${PHP_VERSION}-src/patched
ARCHIVES=
EXPORTED_FUNCTIONS="_pib_init", "_pib_storage_init", "_pib_destroy", "_pib_run", "_pib_exec", "_pib_refresh", "_pib_flush", "_main", "_malloc", "_free"
PRE_JS_FILES=source/env.js
EXTRA_PRE_JS_FILES?=

PRE_JS_FILES+= ${EXTRA_PRE_JS_FILES}

TEST_LIST=

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

third_party/preload: third_party/php${PHP_VERSION}-src/patched ${PRELOAD_ASSETS} third_party/php${PHP_VERSION}-src/Zend/bench.php # third_party/drupal-7.95/README.txt
	# ${DOCKER_RUN} rm -rf /src/third_party/preload
ifdef PRELOAD_ASSETS
	@ mkdir -p third_party/preload
	@ cp -prf ${PRELOAD_ASSETS} third_party/preload/
endif

third_party/preload/bench.php: third_party/php${PHP_VERSION}-src/.gitignore
	mkdir -p third_party/preload/
	cp third_party/php${PHP_VERSION}-src/Zend/bench.php third_party/preload/

third_party/preload/dump-request.php: third_party/preload
	mkdir -p third_party/preload/
	cp -p extras/dump-request.php third_party/preload/

third_party/php${PHP_VERSION}-src/.gitignore:
	@ echo -e "\e[33;4mDownloading and patching PHP\e[0m"
	${DOCKER_RUN} git clone https://github.com/php/php-src.git third_party/php${PHP_VERSION}-src \
		--branch ${PHP_BRANCH}   \
		--single-branch          \
		--depth 1

third_party/php${PHP_VERSION}-src/ext/pib/pib.c: source/pib/pib.c
	@ ${DOCKER_RUN} cp -prf source/pib third_party/php${PHP_VERSION}-src/ext/

########### Build the objects. ###########

third_party/php${PHP_VERSION}-src/configured: ${ENV_FILE} ${PHP_CONFIGURE_DEPS} third_party/php${PHP_VERSION}-src/patched third_party/php${PHP_VERSION}-src/ext/pib/pib.c ${ARCHIVES}
	@ echo -e "\e[33;4mConfiguring PHP\e[0m"
	${DOCKER_RUN_IN_PHP} ./buildconf --force
	${DOCKER_RUN_IN_PHP} emconfigure ./configure --cache-file=/src/.cache/config-cache \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		--prefix=/src/lib/ \
		--with-config-file-path=/config \
		--with-layout=GNU  \
		--with-valgrind=no \
		--enable-bcmath    \
		--enable-calendar  \
		--enable-cgi       \
		--enable-cli       \
		--enable-ctype     \
		--enable-embed=static \
		--enable-exif      \
		--enable-filter    \
		--enable-json      \
		--enable-mbstring  \
		--enable-pib       \
		--enable-session   \
		--enable-tokenizer \
		--disable-all      \
		--disable-fiber    \
		--disable-fiber-asm \
		--disable-mbregex  \
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

ifeq (${NODE_RAW_FS}, 1)
NODE_FS_TYPE+= -lnoderawfs.js
endif

PRELOAD_METHOD=--preload-file

SAPI_CLI_PATH=sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE}
SAPI_CGI_PATH=sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE}

EXTRA_CFLAGS=

BUILD_FLAGS=-j`nproc`\
	ZEND_EXTRA_LIBS='-lsqlite3' \
	SAPI_CGI_PATH='${SAPI_CLI_PATH}' \
	SAPI_CLI_PATH='${SAPI_CGI_PATH}'\
	PHP_CLI_OBJS='sapi/embed/php_embed.lo' \
	EXTRA_CFLAGS='-Wno-incompatible-function-pointer-types -Wno-int-conversion ${EXTRA_CFLAGS} -D ENVIRONMENT=${ENVIRONMENT} '\
	EXTRA_LDFLAGS_PROGRAM='-O${OPTIMIZE} -static \
		-Wl,-zcommon-page-size=2097152 -Wl,-zmax-page-size=2097152 -L/src/lib/lib \
		-fPIC ${SYMBOL_FLAGS}                    \
		-s EXPORTED_FUNCTIONS='\''[${EXPORTED_FUNCTIONS}]'\'' \
		-s EXPORTED_RUNTIME_METHODS='\''["ccall", "UTF8ToString", "lengthBytesUTF8", "getValue", "FS"]'\'' \
		-D ENVIRONMENT=${ENVIRONMENT}             \
		-s ENVIRONMENT=${ENVIRONMENT}            \
		-s INITIAL_MEMORY=${INITIAL_MEMORY}      \
		-s MAXIMUM_MEMORY=${MAXIMUM_MEMORY}      \
		-s TOTAL_STACK=32MB                      \
		-s ALLOW_MEMORY_GROWTH=1                 \
		-s ASSERTIONS=${ASSERTIONS}              \
		-s ERROR_ON_UNDEFINED_SYMBOLS=0          \
		-s FORCE_FILESYSTEM                      \
		-s EXPORT_NAME="'PHP'"                   \
		-s MODULARIZE=1                          \
		-s INVOKE_RUN=0                          \
		-s EXIT_RUNTIME=1                        \
		-s USE_ZLIB=1                            \
		-s ASYNCIFY                              \
		-I /src/third_party/php${PHP_VERSION}-src/ \
		-I /src/third_party/php${PHP_VERSION}-src/Zend  \
		-I /src/third_party/php${PHP_VERSION}-src/main  \
		-I /src/third_party/php${PHP_VERSION}-src/TSRM/ \
		-I /src/third_party/libxml2                \
		-I /src/third_party/openssl/crypto/x509    \
		-I /src/third_party/${SQLITE_DIR}          \
		-I /src/third_party/php${PHP_VERSION}-src/ext/json \
		-I /src/third_party/php${PHP_VERSION}-src/sapi/embed \
		${FS_TYPE}                               \
		$(addprefix /src/,${ARCHIVES}) \
		${EXTRA_FILES} \
		${EXTRA_FLAGS} \
	'

DEPENDENCIES+= ${ENV_FILE} ${ARCHIVES} third_party/php${PHP_VERSION}-src/configured
BUILD_TYPE ?=js

ifneq (${PRE_JS_FILES},)
DEPENDENCIES+= .cache/pre.js
endif

build/php-web.js: BUILD_TYPE=js
build/php-web.js: ENVIRONMENT=web
build/php-web.js: FS_TYPE=${WEB_FS_TYPE}
build/php-web.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-web.mjs: BUILD_TYPE=mjs
build/php-web.mjs: ENVIRONMENT=web
build/php-web.mjs: FS_TYPE=${WEB_FS_TYPE}
build/php-web.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-worker.js: BUILD_TYPE=js
build/php-worker.js: ENVIRONMENT=worker
build/php-worker.js: FS_TYPE=${WORKER_FS_TYPE}
build/php-worker.js: PRELOAD_METHOD=--embed-file
build/php-worker.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-worker.mjs: BUILD_TYPE=mjs
build/php-worker.mjs: ENVIRONMENT=worker
build/php-worker.mjs: FS_TYPE=${WORKER_FS_TYPE}
build/php-worker.mjs: PRELOAD_METHOD=--embed-file
build/php-worker.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-node.js: BUILD_TYPE=js
build/php-node.js: ENVIRONMENT=node
build/php-node.js: FS_TYPE=${NODE_FS_TYPE}
build/php-node.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-node.mjs: BUILD_TYPE=mjs
build/php-node.mjs: ENVIRONMENT=node
build/php-node.mjs: FS_TYPE=${NODE_FS_TYPE}
build/php-node.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-shell.js: BUILD_TYPE=js
build/php-shell.js: ENVIRONMENT=shell
build/php-shell.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-shell.mjs: BUILD_TYPE=mjs
build/php-shell.mjs: ENVIRONMENT=shell
build/php-shell.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}/
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-webview.js: BUILD_TYPE=js
build/php-webview.js: ENVIRONMENT=webview
build/php-webview.js: FS_TYPE=${WEB_FS_TYPE}
build/php-webview.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

build/php-webview.mjs: BUILD_TYPE=mjs
build/php-webview.mjs: ENVIRONMENT=webview
build/php-webview.js: FS_TYPE=${WEB_FS_TYPE}
build/php-webview.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cli
	${DOCKER_RUN_IN_PHP} mv -f \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} \
		/src/third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	sed -i 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	cp third_party/php${PHP_VERSION}-src/sapi/cli/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./build/
	sed -i 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@

########## Package files ###########

${PHP_DIST_DIR}/%.js: source/%.js
	npx babel $< --out-dir .

${PHP_DIST_DIR}/%.mjs: source/%.js
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

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
ifeq (${GZIP},1)
	rm -f $@.wasm.gz
	bash -c 'gzip -9 < $@.wasm > $@.wasm.gz'
ifneq (${PRELOAD_ASSETS},)
	rm -f $@.data.gz
	bash -c 'gzip -9 < $@.data > $@.data.gz'
endif
endif
ifeq (${BROTLI},1)
	rm -f $@.wasm.br
	brotli -9 $@.wasm
	rm -f $@.br
	brotli -9 $@
ifneq (${PRELOAD_ASSETS},)
	rm -f $@.data.br
	brotli -9 $@.data
endif
endif

${PHP_DIST_DIR}/%.mjs: build/%.mjs
	cp $^ $@
	cp $^.wasm* $(dir $@)
ifneq (${PRELOAD_ASSETS},)
	cp $^.data $@.data
endif
ifeq (${GZIP},1)
	rm -f $@.gz
	bash -c 'gzip -9 < $@ > $@.gz'
	rm -f $@.wasm.gz
	bash -c 'gzip -9 < $@.wasm > $@.wasm.gz'
ifneq (${PRELOAD_ASSETS},)
	rm -f $@.data.gz
	bash -c 'gzip -9 < $@.data > $@.data.gz'
endif
endif
ifeq (${BROTLI},1)
	rm -f $@.br
	brotli -9 $@
	rm -f $@.wasm.br
	brotli -9 $@.wasm
ifneq (${PRELOAD_ASSETS},)
	rm -f $@.data.br
	brotli -9 $@.data
endif
endif

${PHP_DIST_DIR}/php-worker.js: build/php-worker.js
	cp $^ $@
	cp $^.wasm* $(dir $@)
ifeq (${GZIP},1)
	rm -f $@.gz
	bash -c 'gzip -9 < $@ > $@.gz'
	rm -f $@.wasm.gz
	bash -c 'gzip -9 < $@.wasm > $@.wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $@.br
	brotli -9 $@
	rm -f $@.wasm.br
	brotli -9 $@.wasm
endif

${PHP_DIST_DIR}/php-worker.mjs: build/php-worker.mjs
	cp $^ $@
	cp $^.wasm* $(dir $@)
ifeq (${GZIP},1)
	rm -f $@.gz
	bash -c 'gzip -9 < $@.wasm > $@.gz'
	rm -f $@.wasm.gz
	bash -c 'gzip -9 < $@.wasm > $@.wasm.gz'
endif
ifeq (${BROTLI},1)
	rm -f $@.br
	brotli -9 $@
	rm -f $@.wasm.br
	brotli -9 $@.wasm
endif

############# Demo files ##############

docs-source/app/assets/php-wasm/PhpBase.mjs: source/PhpBase.js
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

docs-source/app/assets/php-wasm/PhpCgiBase.mjs: source/PhpCgiBase.js
	cp $^ $@
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

docs-source/app/assets/php-wasm/_Event.mjs: source/_Event.js
	cp $^ $@
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

docs-source/app/assets/php-wasm/OutputBuffer.mjs: source/OutputBuffer.js
	cp $^ $@
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

docs-source/app/assets/php-wasm/webTransactions.mjs: source/webTransactions.js
	cp $^ $@
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

docs-source/app/assets/php-wasm/parseResponse.mjs: source/parseResponse.js
	cp $^ $@
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

docs-source/app/assets/php-wasm/breakoutRequest.mjs: source/breakoutRequest.js
	cp $^ $@
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

########### Clerical stuff. ###########

${ENV_FILE}:
	touch ${ENV_FILE}

clean:
	${DOCKER_RUN} rm -fv  *.js *.mjs *.wasm *.wasm.map *.data *.br  *.gz
	${DOCKER_RUN} rm -rf lib/lib/${PHP_AR}.* lib/lib/php lib/include/php build/php* \
		packages/php-cgi-wasm/*.js packages/php-cgi-wasm/*.mjs  packages/php-cgi-wasm/*.wasm  packages/php-cgi-wasm/*.data \
		packages/php-cgi-wasm/*.br packages/php-cgi-wasm/*.gz \
		third_party/preload .cache/pre.js
	${DOCKER_RUN_IN_PHP} rm -fv configured
	${DOCKER_RUN_IN_PHP} make clean

php-clean:
	${DOCKER_RUN_IN_PHP} rm -fv configured
	${DOCKER_RUN_IN_PHP} rm -f /src/lib/lib/${PHP_AR}.a
	rm -f third_party/php${PHP_VERSION}-src/sapi/cgi/*.wasm third_party/php${PHP_VERSION}-src/sapi/cgi/*.mjs third_party/php${PHP_VERSION}-src/sapi/cgi/*.js third_party/php${PHP_VERSION}-src/sapi/cgi/*.data
	rm -f third_party/php${PHP_VERSION}-src/sapi/cli/*.wasm third_party/php${PHP_VERSION}-src/sapi/cli/*.mjs third_party/php${PHP_VERSION}-src/sapi/cli/*.js third_party/php${PHP_VERSION}-src/sapi/cli/*.data
	${DOCKER_RUN_IN_PHP} make clean

deep-clean:
	${DOCKER_RUN} rm -fv  *.js *.mjs *.wasm *.wasm.map *.data *.br  *.gz
	${DOCKER_RUN} rm -rfv \
		third_party/php${PHP_VERSION}-src lib/* build/* \
		third_party/libxml2 third_party/tidy-html5 \
		third_party/libicu-src third_party/${SQLITE_DIR} third_party/libiconv-1.17 \
		third_party/freetype-2.10.0 third_party/freetype \
		third_party/gd third_party/jpeg-9f third_party/libicu \
		third_party/libjpeg third_party/libpng third_party/openssl third_party/zlib \
		third_party/vrzno third_party/libzip third_party/preload \
		packages/php-cgi-wasm/*.js packages/php-cgi-wasm/*.mjs  packages/php-cgi-wasm/*.wasm  packages/php-cgi-wasm/*.data \
		packages/php-cgi-wasm/*.br packages/php-cgi-wasm/*.gz \
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

demo: \
	docs-source/app/assets/php-wasm/webTransactions.mjs \
	docs-source/app/assets/php-wasm/OutputBuffer.mjs \
	docs-source/app/assets/php-wasm/_Event.mjs \
	docs-source/app/assets/php-wasm/parseResponse.mjs \
	docs-source/app/assets/php-wasm/breakoutRequest.mjs \
	docs-source/app/assets/php-wasm/PhpCgiBase.mjs \
	docs-source/app/assets/php-wasm/PhpBase.mjs

serve-demo:
	cd docs-source && brunch w -s

build-demo:
	cd docs-source && brunch b -p

NPM_PUBLISH_DRY?=--dry-run

publish:
	npm publish ${NPM_PUBLISH_DRY}

test: node-mjs
	node --test ${TEST_LIST} `ls test/*.mjs`


third_party/vrzno/lib.js: third_party/vrzno/vrzno.c
