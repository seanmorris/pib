-include .env

SHELL=bash -euxo pipefail

USERID?=1000

ENVIRONMENT    ?=web
INITIAL_MEMORY ?=1024MB
PRELOAD_ASSETS ?=preload/
ASSERTIONS     ?=0
OPTIMIZE       ?=-O3
RELEASE_SUFFIX ?=

PHP_VERSION    ?=8.2
PHP_BRANCH     ?=php-8.2.11
PHP_AR         ?=libphp

# PHP_VERSION    ?=7.4
# PHP_BRANCH     ?=php-7.4.20
# PHP_AR         ?=libphp7

VRZNO_BRANCH   ?=DomAccess8.2
ICU_TAG        ?=release-67-1
LIBXML2_TAG    ?=v2.9.10
TIDYHTML_TAG   ?=5.6.0
ICONV_TAG      ?=v1.17
SQLITE_VERSION ?=3410200
SQLITE_DIR     ?=sqlite3.41-src

PKG_CONFIG_PATH ?=/src/lib/lib/pkgconfig

DOCKER_ENV=USERID=${UID} docker-compose -p phpwasm run --rm \
	-e PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
	-e PRELOAD_ASSETS='${PRELOAD_ASSETS}' \
	-e INITIAL_MEMORY=${INITIAL_MEMORY}   \
	-e ENVIRONMENT=${ENVIRONMENT}         \
	-e PHP_BRANCH=${PHP_BRANCH}           \
	-e EMCC_CORES=`nproc`                 \
	-e EMCC_ALLOW_FASTCOMP=1

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
DOCKER_RUN_IN_ICU4C  =${DOCKER_ENV} -w /src/third_party/libicu-src/icu4c/source/ emscripten-builder
DOCKER_RUN_IN_LIBXML =${DOCKER_ENV} -w /src/third_party/libxml2/ emscripten-builder
DOCKER_RUN_IN_TIDY   =${DOCKER_ENV_SIDE} -w /src/third_party/tidy-html5/ emscripten-builder
DOCKER_RUN_IN_ICU    =${DOCKER_ENV_SIDE} -w /src/third_party/libicu-src/icu4c/source emscripten-builder
DOCKER_RUN_IN_ICONV  =${DOCKER_ENV_SIDE} -w /src/third_party/libiconv-1.17/ emscripten-builder

TIMER=(which pv > /dev/null && pv --name '${@}' || cat)
.PHONY: web all clean show-ports image js hooks push-image pull-image

all: php-web-drupal.wasm php-web.wasm php-webview.wasm php-node.wasm php-shell.wasm php-worker.wasm js
web-drupal: lib/pib_eval.o php-web-drupal.wasm
web: lib/pib_eval.o php-web.wasm
	@ echo "Done!"

########### Collect & patch the source code. ###########

third_party/${SQLITE_DIR}/sqlite3.c: patch/sqlite3-wasm.patch
	@ echo -e "\e[33mDownloading and patching SQLite"
	@ wget https://sqlite.org/2023/sqlite-amalgamation-${SQLITE_VERSION}.zip
	@ ${DOCKER_RUN} unzip sqlite-amalgamation-${SQLITE_VERSION}.zip
	@ ${DOCKER_RUN} rm -r sqlite-amalgamation-${SQLITE_VERSION}.zip
	@ ${DOCKER_RUN} mv sqlite-amalgamation-${SQLITE_VERSION} third_party/${SQLITE_DIR}
	@ ${DOCKER_RUN} git apply --no-index patch/sqlite3.41-wasm.patch

third_party/php${PHP_VERSION}-src/patched: third_party/${SQLITE_DIR}/sqlite3.c
	@ echo -e "\e[33mDownloading and patching PHP"
	@ ${DOCKER_RUN} git clone https://github.com/php/php-src.git third_party/php${PHP_VERSION}-src \
		--branch ${PHP_BRANCH}   \
		--single-branch          \
		--depth 1
	@ ${DOCKER_RUN} git apply --no-index patch/php${PHP_VERSION}.patch
	@ ${DOCKER_RUN} mkdir -p third_party/php${PHP_VERSION}-src/preload/Zend
	@ ${DOCKER_RUN} cp third_party/php${PHP_VERSION}-src/Zend/bench.php third_party/php${PHP_VERSION}-src/preload/Zend
	@ ${DOCKER_RUN} touch third_party/php${PHP_VERSION}-src/patched

source/sqlite3.c: third_party/${SQLITE_DIR}/sqlite3.c third_party/php${PHP_VERSION}-src/patched
	@ echo -e "\e[33mImporting SQLite"
	@ ${DOCKER_RUN} cp -v third_party/${SQLITE_DIR}/sqlite3.c source/sqlite3.c
	@ ${DOCKER_RUN} cp -v third_party/${SQLITE_DIR}/sqlite3.h source/sqlite3.h
	@ ${DOCKER_RUN} cp -v third_party/${SQLITE_DIR}/sqlite3.h third_party/php${PHP_VERSION}-src/main/sqlite3.h
	@ ${DOCKER_RUN} cp -v third_party/${SQLITE_DIR}/sqlite3.c third_party/php${PHP_VERSION}-src/main/sqlite3.c

third_party/php${PHP_VERSION}-src/ext/vrzno/vrzno.c: third_party/php${PHP_VERSION}-src/patched
	@ echo -e "\e[33mDownloading and importing VRZNO"
	@ ${DOCKER_RUN} git clone https://github.com/seanmorris/vrzno.git third_party/php${PHP_VERSION}-src/ext/vrzno \
		--branch ${VRZNO_BRANCH} \
		--single-branch          \
		--depth 1

third_party/drupal-7.95/README.txt:
	@ echo -e "\e[33mDownloading and patching Drupal"
	@ wget https://ftp.drupal.org/files/projects/drupal-7.95.zip
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
	git clone https://github.com/htacg/tidy-html5.git third_party/tidy-html5 \
		--branch ${TIDYHTML_TAG} \
		--single-branch     \
		--depth 1;
	cd third_party/tidy-html5 && \
	git apply --no-index ../../patch/tidy-html.patch

third_party/libicu-src/.gitignore:
	@ ${DOCKER_RUN} git clone https://github.com/unicode-org/icu.git third_party/libicu-src \
		--branch ${ICU_TAG} \
		--single-branch     \
		--depth 1;

third_party/libiconv-1.17/README:
	wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
	mkdir third_party/libiconv
	tar -xvzf libiconv-1.17.tar.gz -C third_party
	rm libiconv-1.17.tar.gz

	# @ ${DOCKER_RUN} git clone https://github.com/roboticslibrary/libiconv.git third_party \
	# 	--branch ${ICONV_TAG} \
	# 	--single-branch     \
	# 	--depth 1;

########### Build the objects. ###########

third_party/php${PHP_VERSION}-src/configured: third_party/php${PHP_VERSION}-src/ext/vrzno/vrzno.c source/sqlite3.c lib/lib/libxml2.la lib/lib/libtidy.a lib/lib/libicudata.a
	@ echo -e "\e[33mBuilding PHP object files"
	${DOCKER_RUN_IN_PHP} ./buildconf --force
	${DOCKER_RUN_IN_PHP} emconfigure pkg-config --list-all
	${DOCKER_RUN_IN_PHP} emconfigure ./configure \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		--enable-embed=static \
		--with-layout=GNU  \
		--with-libxml      \
		--disable-cgi      \
		--disable-cli      \
		--disable-all      \
		--with-sqlite3     \
		--enable-session   \
		--enable-filter    \
		--enable-calendar  \
		--enable-dom       \
		--enable-pdo       \
		--with-pdo-sqlite  \
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
		--with-iconv=/src/lib \
		--with-tidy=/src/lib \
		--enable-intl      \
		--disable-fiber-asm
	touch third_party/php${PHP_VERSION}-src/configured

lib/${PHP_AR}.a: third_party/php${PHP_VERSION}-src/configured third_party/php${PHP_VERSION}-src/patched third_party/php${PHP_VERSION}-src/**.c source/sqlite3.c
	@ echo -e "\e[33mBuilding PHP symbol files"
	@ ${DOCKER_RUN_IN_PHP} emmake make -j`nproc` EXTRA_CFLAGS='-Wno-int-conversion -Wno-incompatible-function-pointer-types'
	@ ${DOCKER_RUN} cp -v \
		third_party/php${PHP_VERSION}-src/.libs/${PHP_AR}.la \
		third_party/php${PHP_VERSION}-src/.libs/${PHP_AR}.a lib/

lib/pib_eval.o: lib/${PHP_AR}.a source/pib_eval.c lib/lib/libxml2.la
	${DOCKER_RUN_IN_PHP} emcc -c ${OPTIMIZE} \
		-I .     \
		-I Zend  \
		-I main  \
		-I TSRM/ \
		-I /src/third_party/libxml2 \
		-o /src/lib/pib_eval.o \
		/src/source/pib_eval.c

lib/lib/libxml2.la: third_party/libxml2/.gitignore
	@ echo -e "\e[33mBuilding LibXML2"
	${DOCKER_RUN_IN_LIBXML} ./autogen.sh
	${DOCKER_RUN_IN_LIBXML} emconfigure ./configure --with-http=no --with-ftp=no --with-python=no --with-threads=no --enable-shared=no --prefix=/src/lib/ | ${TIMER}
	${DOCKER_RUN_IN_LIBXML} emmake make -j`nproc` | ${TIMER}
	${DOCKER_RUN_IN_LIBXML} emmake make install | ${TIMER}

lib/lib/libtidy.a: third_party/tidy-html5/.gitignore
	@ echo -e "\e[33mBuilding LibTidy"
	${DOCKER_RUN_IN_TIDY} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="-I/emsdk/upstream/emscripten/system/lib/libc/musl/include/"; \
	${DOCKER_RUN_IN_TIDY} emmake make
	${DOCKER_RUN_IN_TIDY} emmake make install

lib/lib/libicudata.a: third_party/libicu-src/.gitignore
	@ echo -e "\e[33mBuilding LibIcu"
	${DOCKER_RUN_IN_ICU} emconfigure ./configure --prefix=/src/lib/ --target=wasm32-unknown-emscripten --enable-icu-config --enable-extras=no --enable-tools=no --enable-samples=no --enable-tests=no --enable-shared=no --enable-static=yes
	${DOCKER_RUN_IN_ICU} emmake make clean install

lib/lib/libiconv.a: third_party/libiconv-1.17/README
	@ echo -e "\e[33mBuilding LibIconv"
	${DOCKER_RUN_IN_ICONV} autoconf
	${DOCKER_RUN_IN_ICONV} emconfigure ./configure --prefix=/src/lib/ --target=wasm32-unknown-emscripten --enable-shared=no --enable-static=yes
	${DOCKER_RUN_IN_ICONV} emmake make
	${DOCKER_RUN_IN_ICONV} emmake make install

########### Build the final files. ###########

FINAL_BUILD=${DOCKER_RUN_IN_PHP} emcc ${OPTIMIZE} \
	-o ../../build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.js \
	--llvm-lto 2                     \
	-s EXPORTED_FUNCTIONS='["_pib_init", "_pib_destroy", "_pib_run", "_pib_exec" "_pib_refresh", "_main", "_php_embed_init", "_php_embed_shutdown", "_php_embed_shutdown", "_zend_eval_string", "_exec_callback", "_del_callback"]' \
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
	-s MAIN_MODULE                   \
	-s USE_ZLIB=1                    \
	-s USE_LIBPNG=1                  \
	/src/lib/pib_eval.o /src/lib/${PHP_AR}.a /src/lib/lib/libxml2.a /src/lib/lib/libtidy.a /src/lib/lib/libicudata.a /src/lib/lib/libicui18n.a /src/lib/lib/libicuio.a /src/lib/lib/libicuuc.a /src/lib/lib/libiconv.a

DEPENDENCIES=lib/${PHP_AR}.a lib/pib_eval.o lib/lib/libicudata.a lib/lib/libiconv.a source/**.c source/**.h

php-web-drupal.wasm: ENVIRONMENT=web-drupal
php-web-drupal.wasm: ${DEPENDENCIES} third_party/drupal-7.95/README.txt
	@ echo -e "\e[33mBuilding PHP for web (drupal)"
	@ ${FINAL_BUILD} --preload-file ${PRELOAD_ASSETS} -s ENVIRONMENT=web
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-web.wasm: ENVIRONMENT=web
php-web.wasm: ${DEPENDENCIES}
	@ echo -e "\e[33mBuilding PHP for web"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-worker.wasm: ENVIRONMENT=worker
php-worker.wasm: lib/${PHP_AR}.a lib/pib_eval.o source/**.c source/**.h
	@ echo -e "\e[33mBuilding PHP for workers"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-node.wasm: ENVIRONMENT=node
php-node.wasm: lib/${PHP_AR}.a lib/pib_eval.o source/**.c source/**.h
	@ echo -e "\e[33mBuilding PHP for node"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-shell.wasm: ENVIRONMENT=shell
php-shell.wasm: lib/${PHP_AR}.a lib/pib_eval.o source/**.c source/**.h
	@ echo -e "\e[33mBuilding PHP for shell"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-webview.wasm: ENVIRONMENT=webview
php-webview.wasm: lib/${PHP_AR}.a lib/pib_eval.o source/pib_eval.c
	@ echo -e "\e[33mBuilding PHP for webview"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

########### Clerical stuff. ###########

clean:
	@ ${DOCKER_RUN} rm -fv  *.js *.wasm *.data
	@ ${DOCKER_RUN} rm -rfv build/* lib/* docs/php-*.js docs/php-*.wasm \
		/src/lib/pib_eval.o /src/lib/${PHP_AR}.a \
		# /src/lib/lib/libxml2.a
php-clean:
	@ ${DOCKER_RUN} rm -fv third_party/php${PHP_VERSION}-src/configure

deep-clean:
	@ ${DOCKER_RUN} rm -fv  *.js *.wasm *.data
	@ ${DOCKER_RUN} rm -rfv build/* lib/* third_party/php${PHP_VERSION}-src \
		third_party/drupal-7.95 third_party/libxml2 third_party/tidy-html5 \
		third_party/libicu-src third_party/${SQLITE_DIR} \
		dist/* docs/php-*.js docs/php-*.wasm \
		sqlite-*.* \

show-ports:
	@ ${DOCKER_RUN} emcc --show-ports

hooks:
	@ git config core.hooksPath githooks

js:
	@ echo -e "\e[33mBuilding JS"
	@ npm install | ${TIMER}
	@ npx babel source --out-dir . | ${TIMER}

image:
	@ docker-compose build

pull-image:
	@ docker-compose pull

push-image:
	@ docker-compose push

demo:php-web-drupal.wasm
	cd docs-source && brunch b -p
	make js

########### NOPS ###########
third_party/php${PHP_VERSION}-src/**.c:
third_party/php${PHP_VERSION}-src/**.h:
source/**.c:
source/**.h:
