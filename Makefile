-include .env

SHELL=bash -euxo pipefail

USERID?=1000

ENVIRONMENT    ?=web
INITIAL_MEMORY ?=1024MB
PRELOAD_ASSETS ?=preload/
ASSERTIONS     ?=0
OPTIMIZE       ?=3
RELEASE_SUFFIX ?=

PHP_VERSION    ?=8.2
PHP_BRANCH     ?=php-8.2.11
PHP_AR         ?=libphp

# PHP_VERSION    ?=7.4
# PHP_BRANCH     ?=php-7.4.20
# PHP_AR         ?=libphp7

VRZNO_BRANCH   ?=DomAccess8.2
ICU_TAG        ?=release-74-rc
LIBXML2_TAG    ?=v2.9.10
TIDYHTML_TAG   ?=5.6.0
ICONV_TAG      ?=v1.17
SQLITE_VERSION ?=3410200
SQLITE_DIR     ?=sqlite3.41-src
TIMELIB_BRANCH ?=2018.01

# VRZNO_DEV_PATH=third_party/vrzno

PKG_CONFIG_PATH ?=/src/lib/lib/pkgconfig

DOCKER_ENV=USERID=${UID} docker-compose -p phpwasm run --rm \
	-e PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
	-e PRELOAD_ASSETS='${PRELOAD_ASSETS}' \
	-e INITIAL_MEMORY=${INITIAL_MEMORY}   \
	-e ENVIRONMENT=${ENVIRONMENT}         \
	-e PHP_BRANCH=${PHP_BRANCH}           \
	-e EMCC_CORES=`nproc`

DOCKER_ENV_SIDE=USERID=${UID} docker-compose -p phpwasm run --rm \
	-e PRELOAD_ASSETS='${PRELOAD_ASSETS}' \
	-e INITIAL_MEMORY=${INITIAL_MEMORY}   \
	-e ENVIRONMENT=${ENVIRONMENT}         \
	-e PHP_BRANCH=${PHP_BRANCH}           \
	-e EMCC_CORES=`nproc`                 \
	-e CFLAGS=" -I/root/lib/include " \
	-e EMCC_FLAGS=" -sSIDE_MODULE=1 -sERROR_ON_UNDEFINED_SYMBOLS=0 "

DOCKER_RUN           =${DOCKER_ENV} emscripten-builder
DOCKER_RUN_IN_PHP    =${DOCKER_ENV} -w /src/third_party/php${PHP_VERSION}-src/ emscripten-builder
DOCKER_RUN_IN_PHPSIDE=${DOCKER_ENV_SIDE} -w /src/third_party/php${PHP_VERSION}-src/ emscripten-builder
DOCKER_RUN_IN_ICU4C  =${DOCKER_ENV} -w /src/third_party/libicu-src/icu4c/source/ emscripten-builder
DOCKER_RUN_IN_LIBXML =${DOCKER_ENV} -w /src/third_party/libxml2/ emscripten-builder
DOCKER_RUN_IN_SQLITE =${DOCKER_ENV_SIDE} -w /src/third_party/${SQLITE_DIR}/ emscripten-builder
DOCKER_RUN_IN_TIDY   =${DOCKER_ENV_SIDE} -w /src/third_party/tidy-html5/ emscripten-builder
DOCKER_RUN_IN_ICU    =${DOCKER_ENV_SIDE} -w /src/third_party/libicu-src/icu4c/source emscripten-builder
DOCKER_RUN_IN_ICONV  =${DOCKER_ENV_SIDE} -w /src/third_party/libiconv-1.17/ emscripten-builder
DOCKER_RUN_IN_TIMELIB=${DOCKER_ENV_SIDE} -w /src/third_party/timelib/ emscripten-builder

TIMER=(which pv > /dev/null && pv --name '${@}' || cat)
.PHONY: web all clean show-ports image js hooks push-image pull-image

all: cjs mjs js
cjs: php-web-drupal.js php-web.js php-webview.js php-node.js php-shell.js php-worker.js
mjs: php-web-drupal.mjs php-web.mjs php-webview.mjs php-node.mjs php-shell.mjs php-worker.mjs
web-drupal: lib/pib_eval.o php-web-drupal.wasm
web: lib/pib_eval.o php-web.wasm
	@ echo "Done!"

########### Collect & patch the source code. ###########

third_party/${SQLITE_DIR}/sqlite3.c:
	@ echo -e "\e[33mDownloading and patching SQLite"
	@ wget -q https://sqlite.org/2023/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	@ ${DOCKER_RUN} tar -xzf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	@ ${DOCKER_RUN} rm -r sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	@ ${DOCKER_RUN} rm -rf third_party/${SQLITE_DIR}
	@ ${DOCKER_RUN} mv sqlite-autoconf-${SQLITE_VERSION} third_party/${SQLITE_DIR}
	
third_party/php${PHP_VERSION}-src/.gitignore: third_party/${SQLITE_DIR}/sqlite3.c
	@ echo -e "\e[33mDownloading and patching PHP"
	@ ${DOCKER_RUN} git clone https://github.com/php/php-src.git third_party/php${PHP_VERSION}-src \
		--branch ${PHP_BRANCH}   \
		--single-branch          \
		--depth 1

third_party/php${PHP_VERSION}-src/patched: third_party/php${PHP_VERSION}-src/.gitignore
	@ ${DOCKER_RUN} git apply --no-index patch/php${PHP_VERSION}.patch
	@ ${DOCKER_RUN} mkdir -p third_party/php${PHP_VERSION}-src/preload/Zend
	@ ${DOCKER_RUN} cp third_party/php${PHP_VERSION}-src/Zend/bench.php third_party/php${PHP_VERSION}-src/preload/Zend
	@ ${DOCKER_RUN} touch third_party/php${PHP_VERSION}-src/patched

third_party/php${PHP_VERSION}-src/ext/vrzno/vrzno.c: third_party/php${PHP_VERSION}-src/patched
	@ echo -e "\e[33mDownloading and importing VRZNO"
ifdef VRZNO_DEV_PATH
	@ echo -e "\e[33mLinking dev VRZNO"
	@ ${DOCKER_RUN} rm -rfv third_party/php${PHP_VERSION}-src/ext/vrzno
	@ ${DOCKER_RUN} cp -rfv third_party/vrzno third_party/php${PHP_VERSION}-src/ext/vrzno
else
	@ ${DOCKER_RUN} git clone https://github.com/seanmorris/vrzno.git third_party/php${PHP_VERSION}-src/ext/vrzno \
		--branch ${VRZNO_BRANCH} \
		--single-branch          \
		--depth 1
endif

third_party/drupal-7.95/README.txt:
	@ echo -e "\e[33mDownloading and patching Drupal"
	@ wget -q https://ftp.drupal.org/files/projects/drupal-7.95.zip
	@ ${DOCKER_RUN} unzip drupal-7.95.zip
	@ ${DOCKER_RUN} rm -v drupal-7.95.zip
	@ ${DOCKER_RUN} mv drupal-7.95 third_party/drupal-7.95
	@ ${DOCKER_RUN} git apply --no-index patch/drupal-7.95.patch
	@ ${DOCKER_RUN} cp -r extras/drupal-7-settings.php third_party/drupal-7.95/sites/default/settings.php
	@ ${DOCKER_RUN} cp -r extras/drowser-files/.ht.sqlite third_party/drupal-7.95/sites/default/files/.ht.sqlite
	@ ${DOCKER_RUN} cp -r extras/drowser-files/* third_party/drupal-7.95/sites/default/files
	@ ${DOCKER_RUN} cp -r extras/drowser-logo.png third_party/drupal-7.95/sites/default/logo.png
	@ ${DOCKER_RUN} rm -rf third_party/php${PHP_VERSION}-src/preload/drupal-7.95
	@ ${DOCKER_RUN} mkdir -p third_party/php${PHP_VERSION}-src/preload
	@ ${DOCKER_RUN} cp -r third_party/drupal-7.95 third_party/php${PHP_VERSION}-src/preload/

third_party/libxml2/.gitignore:
	@ echo -e "\e[33mDownloading LibXML2"
	@ ${DOCKER_RUN} env GIT_SSL_NO_VERIFY=true git clone https://gitlab.gnome.org/GNOME/libxml2.git third_party/libxml2 \
		--branch ${LIBXML2_TAG} \
		--single-branch     \
		--depth 1;

third_party/tidy-html5/.gitignore:
	@ ${DOCKER_RUN} git clone https://github.com/htacg/tidy-html5.git third_party/tidy-html5 \
		--branch ${TIDYHTML_TAG} \
		--single-branch     \
		--depth 1;
	@ ${DOCKER_RUN_IN_TIDY} git apply --no-index ../../patch/tidy-html.patch

# third_party/libicu-src/.gitignore:
# 	@ ${DOCKER_RUN} git clone https://github.com/unicode-org/icu.git third_party/libicu-src \
# 		--branch ${ICU_TAG} \
# 		--single-branch     \
# 		--depth 1;

third_party/libiconv-1.17/README:
	@ ${DOCKER_RUN} wget -q https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
	@ ${DOCKER_RUN} tar -xvzf libiconv-1.17.tar.gz -C third_party
	@ ${DOCKER_RUN} rm libiconv-1.17.tar.gz

########### Build the objects. ###########

lib/lib/libxml2.a: third_party/libxml2/.gitignore
	@ echo -e "\e[33mBuilding LibXML2"
	@ ${DOCKER_RUN_IN_LIBXML} ./autogen.sh
	@ ${DOCKER_RUN_IN_LIBXML} emconfigure ./configure --with-http=no --with-ftp=no --with-python=no --with-threads=no --enable-shared=no --prefix=/src/lib/
	@ ${DOCKER_RUN_IN_LIBXML} emmake make -j`nproc` EXTRA_CFLAGS='-fPIC -O${OPTIMIZE}' | ${TIMER}
	@ ${DOCKER_RUN_IN_LIBXML} emmake make install | ${TIMER}

lib/lib/libsqlite3.a: third_party/${SQLITE_DIR}/sqlite3.c
	@ echo -e "\e[33mBuilding LibSqlite3"
	@ ${DOCKER_RUN_IN_SQLITE} emconfigure ./configure --with-http=no --with-ftp=no --with-python=no --with-threads=no --enable-shared=no --prefix=/src/lib/ | ${TIMER}
	@ ${DOCKER_RUN_IN_SQLITE} emmake make -j`nproc` EXTRA_CFLAGS='-fPIC -O${OPTIMIZE}' | ${TIMER}
	@ ${DOCKER_RUN_IN_SQLITE} emmake make install | ${TIMER}

lib/lib/libtidy.a: third_party/tidy-html5/.gitignore
	@ echo -e "\e[33mBuilding LibTidy"
	${DOCKER_RUN_IN_TIDY} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="-I/emsdk/upstream/emscripten/system/lib/libc/musl/include/ -fpic"
	${DOCKER_RUN_IN_TIDY} emmake make;
	${DOCKER_RUN_IN_TIDY} emmake make install;

# lib/lib/libicudata.a: third_party/libicu-src/.gitignore
# 	@ echo -e "\e[33mBuilding LibIcu"
# 	@ ${DOCKER_RUN_IN_ICU} emconfigure ./configure --prefix=/src/lib/ --enable-icu-config --enable-extras=no --enable-tools=no --enable-samples=no --enable-tests=no --enable-shared=no --enable-static=yes
# 	@ ${DOCKER_RUN_IN_ICU} emmake make clean install

lib/lib/libiconv.a: third_party/libiconv-1.17/README
	@ echo -e "\e[33mBuilding LibIconv"
	@ ${DOCKER_RUN_IN_ICONV} autoconf
	@ ${DOCKER_RUN_IN_ICONV} emconfigure ./configure --prefix=/src/lib/ --enable-shared=no --enable-static=yes
	@ ${DOCKER_RUN_IN_ICONV} emmake make EMCC_CFLAGS='-fPIC -O${OPTIMIZE}'
	@ ${DOCKER_RUN_IN_ICONV} emmake make install

third_party/php${PHP_VERSION}-src/configured: \
	third_party/php${PHP_VERSION}-src/patched third_party/php${PHP_VERSION}-src/ext/vrzno/vrzno.c lib/lib/libxml2.a lib/lib/libtidy.a lib/lib/libiconv.a lib/lib/libsqlite3.a lib/lib/ # libicudata.a
	@ echo -e "\e[33mConfiguring PHP"
	@ ${DOCKER_RUN_IN_PHPSIDE} ./buildconf --force
	@ ${DOCKER_RUN_IN_PHPSIDE} emconfigure ./configure \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		--enable-embed=static \
		--prefix=/src/lib/ \
		--with-layout=GNU  \
		--with-libxml      \
		--disable-cgi      \
		--disable-cli      \
		--disable-all      \
		--enable-session   \
		--enable-filter    \
		--enable-calendar  \
		--enable-dom       \
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
		--enable-vrzno     \
		--enable-xml       \
		--enable-simplexml \
		--with-gd          \
		--with-sqlite3     \
		--enable-pdo       \
		--with-pdo-sqlite=/src/lib \
		--with-iconv=/src/lib \
		--with-tidy=/src/lib \
		--disable-fiber-asm
	@ ${DOCKER_RUN_IN_PHPSIDE} touch /src/third_party/php${PHP_VERSION}-src/configured

lib/lib/${PHP_AR}.a: third_party/php${PHP_VERSION}-src/configured third_party/php${PHP_VERSION}-src/patched
	@ echo -e "\e[33mBuilding PHP"
	@ ${DOCKER_RUN_IN_PHPSIDE} emmake make -j`nproc` EXTRA_CFLAGS='-Wno-int-conversion -Wno-incompatible-function-pointer-types'
	@ ${DOCKER_RUN_IN_PHPSIDE} emmake make install

########### Build the final files. ###########

FINAL_BUILD=${DOCKER_RUN_IN_PHP} emcc -O${OPTIMIZE} \
	-Wno-int-conversion -Wno-incompatible-function-pointer-types \
	-s EXPORTED_FUNCTIONS='["_pib_init", "_pib_destroy", "_pib_run", "_pib_exec", "_pib_refresh", "_main", "_php_embed_init", "_php_embed_shutdown", "_php_embed_shutdown", "_zend_eval_string", "_exec_callback", "_del_callback"]' \
	-s EXPORTED_RUNTIME_METHODS='["ccall", "UTF8ToString", "lengthBytesUTF8"]' \
	-s ENVIRONMENT=${ENVIRONMENT}    \
	-s MAXIMUM_MEMORY=2048mb         \
	-s INITIAL_MEMORY=${INITIAL_MEMORY} \
	-s ALLOW_MEMORY_GROWTH=1         \
	-s ASSERTIONS=${ASSERTIONS}      \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0  \
	-s EXPORT_NAME="'PHP'"           \
	-s MODULARIZE=1                  \
	-s INVOKE_RUN=0                  \
	-s USE_ZLIB=1                    \
	-I .     \
    -I Zend  \
    -I main  \
    -I TSRM/ \
	-I /src/third_party/libxml2 \
	-I /src/third_party/${SQLITE_DIR} \
	-I ext/pdo_sqlite \
	-I ext/json \
	-I ext/vrzno \
	-o ../../build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE} \
	--llvm-lto 2                     \
	/src/lib/lib/${PHP_AR}.a \
	/src/lib/lib/libxml2.a   \
	/src/lib/lib/libtidy.a   \
	/src/lib/lib/libiconv.a  \
	/src/lib/lib/libsqlite3.a ext/pdo_sqlite/pdo_sqlite.c ext/pdo_sqlite/sqlite_driver.c ext/pdo_sqlite/sqlite_statement.c \
	/src/source/pib_eval.c

# /src/lib/lib/libicudata.a /src/lib/lib/libicui18n.a /src/lib/lib/libicuio.a /src/lib/lib/libicuuc.a

DEPENDENCIES=lib/lib/libxml2.a lib/lib/libiconv.a lib/lib/libtidy.a lib/lib/${PHP_AR}.a source/pib_eval.c lib/lib/libxml2.a lib/lib/libsqlite3.a
BUILD_TYPE ?=js

php-web-drupal.js: ENVIRONMENT=web-drupal
php-web-drupal.js: ${DEPENDENCIES} third_party/drupal-7.95/README.txt
	@ echo -e "\e[33mBuilding PHP for web (drupal)"
	@ ${FINAL_BUILD} --preload-file ${PRELOAD_ASSETS} -s ENVIRONMENT=web
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-web-drupal.mjs: BUILD_TYPE=mjs
php-web-drupal.mjs: ENVIRONMENT=web-drupal
php-web-drupal.mjs: ${DEPENDENCIES} third_party/drupal-7.95/README.txt
	@ ${FINAL_BUILD} --preload-file ${PRELOAD_ASSETS} -s ENVIRONMENT=web
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./

php-web.js: ENVIRONMENT=web
php-web.js: ${DEPENDENCIES}
	@ echo -e "\e[33mBuilding PHP for web"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-web.mjs: BUILD_TYPE=mjs
php-web.mjs: ENVIRONMENT=web
php-web.mjs: ${DEPENDENCIES}
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-worker.js: ENVIRONMENT=worker
php-worker.js: ${DEPENDENCIES}
	@ echo -e "\e[33mBuilding PHP for workers"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-worker.mjs: BUILD_TYPE=mjs
php-worker.mjs: ENVIRONMENT=worker
php-worker.mjs: ${DEPENDENCIES}
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-node.js: ENVIRONMENT=node
php-node.js: ${DEPENDENCIES}
	@ echo -e "\e[33mBuilding PHP for node"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-node.mjs: BUILD_TYPE=mjs
php-node.mjs: ENVIRONMENT=node
php-node.mjs: ${DEPENDENCIES}
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist


php-shell.js: ENVIRONMENT=shell
php-shell.js: ${DEPENDENCIES}
	@ echo -e "\e[33mBuilding PHP for shell"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-shell.mjs: BUILD_TYPE=mjs
php-shell.mjs: ENVIRONMENT=shell
php-shell.mjs: ${DEPENDENCIES}
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-webview.js: ENVIRONMENT=webview
php-webview.js: ${DEPENDENCIES}
	@ echo -e "\e[33mBuilding PHP for webview"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-webview.mjs: BUILD_TYPE=mjs
php-webview.mjs: ENVIRONMENT=webview
php-webview.mjs: ${DEPENDENCIES}
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

########### Clerical stuff. ###########

clean:
	@ ${DOCKER_RUN} rm -fv  *.js *.mjs *.wasm *.data
	@ ${DOCKER_RUN} rm -rfv build/* lib/* docs/php-*.js docs/php-*.wasm \
		/src/lib/pib_eval.o /src/lib/${PHP_AR}.a
	@ ${DOCKER_RUN_IN_PHP} make clean

php-clean:
	@ ${DOCKER_RUN} rm -fv third_party/php${PHP_VERSION}-src/configured
	@ ${DOCKER_RUN_IN_PHP} make clean

deep-clean:
	@ ${DOCKER_RUN} rm -fv  *.js *.mjs *.wasm *.data
	@ ${DOCKER_RUN} rm -rfv build/* lib/* third_party/php${PHP_VERSION}-src \
		third_party/drupal-7.95 third_party/libxml2 third_party/tidy-html5 \
		third_party/libicu-src third_party/${SQLITE_DIR} third_party/libiconv-1.17 \
		dist/* docs/php-*.js docs/php-*.wasm \
		sqlite-*.* \

show-ports:
	@ ${DOCKER_RUN} emcc --show-ports

show-version:
	@ ${DOCKER_RUN}  emcc --version

show-files:
	@ ${DOCKER_RUN} cat /root/.bashrc

hooks:
	@ git config core.hooksPath githooks

js:
	@ echo -e "\e[33mBuilding JS"
	@ npx babel source --out-dir .
	@ find source -name "*.js" | while read JS; \
		do cp $${JS} $$(basename $${JS%.js}.mjs); \
		sed -i -E "s~\\b(import.+ from )(['\"])([^'\"]+)\2~\1\2\3.mjs\2~g" $$(basename $${JS%.js}.mjs); \
		sed -i -E "s~\\brequire(\()(['\"])([^'\"]+)\2(\))~(await import\1\2\3.mjs\2\4).default~g" $$(basename $${JS%.js}.mjs); \
	done;

image:
	@ docker-compose build

pull-image:
	@ docker-compose pull

push-image:
	@ docker-compose push

demo: php-web-drupal.js
	@ make js
	@ cd docs-source && brunch b -p

NPM_PUBLISH_DRY?=--dry-run

publish:
	@ npm publish ${NPM_PUBLISH_DRY}

########### NOPS ###########
third_party/php${PHP_VERSION}-src/**.c:
third_party/php${PHP_VERSION}-src/**.h:
source/**.c:
source/**.h:
