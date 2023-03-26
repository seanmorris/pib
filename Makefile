-include .env

SHELL=bash -euxo pipefail

ENVIRONMENT    ?=web
INITIAL_MEMORY ?=1024MB
PRELOAD_ASSETS ?=preload/
ASSERTIONS     ?=0
OPTIMIZE       ?=-O3
RELEASE_SUFFIX ?=

PHP_BRANCH     ?=php-7.4.20
VRZNO_BRANCH   ?=DomAccess
ICU_TAG        ?=release-67-1
LIBXML2_TAG    ?=v2.9.10
TIDYHTML_TAG   ?=5.6.0

PKG_CONFIG_PATH ?=/src/lib/lib/pkgconfig

DOCKER_ENV=USERID=${UID} docker-compose -p phpwasm run --rm \
	-e PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
	-e PRELOAD_ASSETS='${PRELOAD_ASSETS}' \
	-e INITIAL_MEMORY=${INITIAL_MEMORY}   \
	-e ENVIRONMENT=${ENVIRONMENT}         \
	-e EMCC_ALLOW_FASTCOMP=1

DOCKER_RUN           =${DOCKER_ENV} emscripten-builder
DOCKER_RUN_IN_PHP    =${DOCKER_ENV} -w /src/third_party/php7.4-src/ emscripten-builder
DOCKER_RUN_IN_ICU4C  =${DOCKER_ENV} -w /src/third_party/libicu-src/icu4c/source/ emscripten-builder
DOCKER_RUN_IN_LIBXML =${DOCKER_ENV} -w /src/third_party/libxml2/ emscripten-builder

TIMER=(which pv > /dev/null && pv --name '${@}' || cat)
.PHONY: web all clean show-ports image js hooks push-image pull-image

all: php-web.wasm php-web-drupal.wasm php-webview.wasm php-node.wasm php-shell.wasm php-worker.wasm js
web: lib/pib_eval.o php-web.wasm
	@ echo "Done!"

########### Collect & patch the source code. ###########

third_party/sqlite3.33-src/sqlite3.c:
	@ echo -e "\e[33mDownloading and patching SQLite"
	@ wget https://sqlite.org/2020/sqlite-amalgamation-3330000.zip
	@ ${DOCKER_RUN} unzip sqlite-amalgamation-3330000.zip
	@ ${DOCKER_RUN} rm -r sqlite-amalgamation-3330000.zip
	@ ${DOCKER_RUN} mv sqlite-amalgamation-3330000 third_party/sqlite3.33-src
	@ ${DOCKER_RUN} git apply --no-index patch/sqlite3-wasm.patch

third_party/php7.4-src/patched: third_party/sqlite3.33-src/sqlite3.c
	@ echo -e "\e[33mDownloading and patching PHP"
	@ ${DOCKER_RUN} git clone https://github.com/php/php-src.git third_party/php7.4-src \
		--branch ${PHP_BRANCH}   \
		--single-branch          \
		--depth 1
	@ ${DOCKER_RUN} git apply --no-index patch/php7.4.patch
	@ ${DOCKER_RUN} mkdir -p third_party/php7.4-src/preload/Zend
	@ ${DOCKER_RUN} cp third_party/php7.4-src/Zend/bench.php third_party/php7.4-src/preload/Zend
	@ ${DOCKER_RUN} touch third_party/php7.4-src/patched

source/sqlite3.c: third_party/sqlite3.33-src/sqlite3.c third_party/php7.4-src/patched
	@ echo -e "\e[33mImporting SQLite"
	@ ${DOCKER_RUN} cp -v third_party/sqlite3.33-src/sqlite3.c source/sqlite3.c
	@ ${DOCKER_RUN} cp -v third_party/sqlite3.33-src/sqlite3.h source/sqlite3.h
	@ ${DOCKER_RUN} cp -v third_party/sqlite3.33-src/sqlite3.h third_party/php7.4-src/main/sqlite3.h
	@ ${DOCKER_RUN} cp -v third_party/sqlite3.33-src/sqlite3.c third_party/php7.4-src/main/sqlite3.c

third_party/php7.4-src/ext/vrzno/vrzno.c: third_party/php7.4-src/patched
	@ echo -e "\e[33mDownloading and importing VRZNO"
	@ ${DOCKER_RUN} git clone https://github.com/seanmorris/vrzno.git third_party/php7.4-src/ext/vrzno \
		--branch ${VRZNO_BRANCH} \
		--single-branch          \
		--depth 1

third_party/drupal-7.59/README.txt:
	@ echo -e "\e[33mDownloading and patching Drupal"
	@ wget https://ftp.drupal.org/files/projects/drupal-7.59.zip
	@ ${DOCKER_RUN} unzip drupal-7.59.zip
	@ ${DOCKER_RUN} rm -v drupal-7.59.zip
	@ ${DOCKER_RUN} mv drupal-7.59 third_party/drupal-7.59
	@ ${DOCKER_RUN} git apply --no-index patch/drupal-7.59.patch
	@ ${DOCKER_RUN} cp -r extras/drupal-7-settings.php third_party/drupal-7.59/sites/default/settings.php
	@ ${DOCKER_RUN} cp -r extras/drowser-files/.ht.sqlite third_party/drupal-7.59/sites/default/files/.ht.sqlite
	@ ${DOCKER_RUN} cp -r extras/drowser-files/* third_party/drupal-7.59/sites/default/files
	@ ${DOCKER_RUN} cp -r extras/drowser-logo.png third_party/drupal-7.59/sites/default/logo.png
	@ ${DOCKER_RUN} rm -rf third_party/php7.4-src/preload/drupal-7.59
	@ ${DOCKER_RUN} mkdir -p third_party/php7.4-src/preload
	@ ${DOCKER_RUN} cp -r third_party/drupal-7.59 third_party/php7.4-src/preload/

# third_party/libicu-src:
# 	@ ${DOCKER_RUN} git clone https://github.com/unicode-org/icu.git third_party/libicu-src \
# 		--branch ${ICU_TAG} \
# 		--single-branch     \
# 		--depth 1;

third_party/libxml2/.gitignore:
	@ echo -e "\e[33mDownloading LibXML2"
	@ ${DOCKER_RUN} env GIT_SSL_NO_VERIFY=true git clone https://gitlab.gnome.org/GNOME/libxml2.git third_party/libxml2 \
		--branch ${LIBXML2_TAG} \
		--single-branch     \
		--depth 1;

# third_party/tidy-html5:
# 	@ ${DOCKER_RUN} git clone https://github.com/htacg/tidy-html5.git third_party/tidy-html5 \
# 		--branch ${TIDYHTML_TAG} \
# 		--single-branch     \
# 		--depth 1;

########### Build the objects. ###########

third_party/php7.4-src/configure: third_party/php7.4-src/ext/vrzno/vrzno.c source/sqlite3.c lib/lib/libxml2.la
	@ echo -e "\e[33mBuilding PHP object files"
	${DOCKER_RUN_IN_PHP} ./buildconf --force
	${DOCKER_RUN_IN_PHP} bash -c "emconfigure ./configure \
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
	"

lib/libphp7.a: third_party/php7.4-src/configure third_party/php7.4-src/patched third_party/php7.4-src/**.c source/sqlite3.c
	@ echo -e "\e[33mBuilding PHP symbol files"
	@ ${DOCKER_RUN_IN_PHP} emmake make -j8
	@ ${DOCKER_RUN} cp -v third_party/php7.4-src/.libs/libphp7.la third_party/php7.4-src/.libs/libphp7.a lib/

lib/pib_eval.o: lib/libphp7.a source/pib_eval.c
	@ echo -e "\e[33mRun pkgconfig"
	${DOCKER_RUN_IN_PHP} emcc ${OPTIMIZE} \
		-I .     \
		-I Zend  \
		-I main  \
		-I TSRM/ \
		-I /src/third_party/libxml2 \
		/src/source/pib_eval.c \
		-o /src/lib/pib_eval.o \

lib/lib/libxml2.la: third_party/libxml2/.gitignore
	@ echo -e "\e[33mBuilding LibXML2"
	${DOCKER_RUN_IN_LIBXML} ./autogen.sh
	${DOCKER_RUN_IN_LIBXML} emconfigure ./configure --with-http=no --with-ftp=no --with-python=no --with-threads=no --enable-shared=no --prefix=/src/lib/ | ${TIMER}
	${DOCKER_RUN_IN_LIBXML} emmake make | ${TIMER}
	${DOCKER_RUN_IN_LIBXML} emmake make install | ${TIMER}

########### Build the final files. ###########

FINAL_BUILD=${DOCKER_RUN_IN_PHP} emcc ${OPTIMIZE} \
	-o ../../build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.js \
	--llvm-lto 2                     \
	-s EXPORTED_FUNCTIONS='["_pib_init", "_pib_destroy", "_pib_run", "_pib_exec" "_pib_refresh", "_main", "_php_embed_init", "_php_embed_shutdown", "_php_embed_shutdown", "_zend_eval_string", "_exec_callback", "_del_callback"]' \
	-s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "UTF8ToString", "lengthBytesUTF8"]' \
	-s ENVIRONMENT=${ENVIRONMENT}    \
	-s MAXIMUM_MEMORY=-1             \
	-s INITIAL_MEMORY=${INITIAL_MEMORY} \
	-s ALLOW_MEMORY_GROWTH=1         \
	-s ASSERTIONS=${ASSERTIONS}      \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0  \
	-s EXPORT_NAME="'PHP'"           \
	-s MODULARIZE=1                  \
	-s INVOKE_RUN=0                  \
	-s USE_ZLIB=1                    \
		/src/lib/pib_eval.o /src/lib/libphp7.a /src/lib/lib/libxml2.a

php-web-drupal.wasm: ENVIRONMENT=web-drupal
php-web-drupal.wasm: lib/libphp7.a lib/pib_eval.o source/**.c source/**.h third_party/drupal-7.59/README.txt
	@ echo -e "\e[33mBuilding PHP for web (drupal)"
	@ ${FINAL_BUILD} --preload-file ${PRELOAD_ASSETS} -s ENVIRONMENT=web
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-web.wasm: ENVIRONMENT=web
php-web.wasm: lib/libphp7.a lib/pib_eval.o source/**.c source/**.h
	@ echo -e "\e[33mBuilding PHP for web"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-worker.wasm: ENVIRONMENT=worker
php-worker.wasm: lib/libphp7.a lib/pib_eval.o source/**.c source/**.h
	@ echo -e "\e[33mBuilding PHP for workers"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-node.wasm: ENVIRONMENT=node
php-node.wasm: lib/libphp7.a lib/pib_eval.o source/**.c source/**.h
	@ echo -e "\e[33mBuilding PHP for node"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-shell.wasm: ENVIRONMENT=shell
php-shell.wasm: lib/libphp7.a lib/pib_eval.o source/**.c source/**.h
	@ echo -e "\e[33mBuilding PHP for shell"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

php-webview.wasm: ENVIRONMENT=webview
php-webview.wasm: lib/libphp7.a lib/pib_eval.o source/pib_eval.c
	@ echo -e "\e[33mBuilding PHP for webview"
	@ ${FINAL_BUILD}
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/app/assets
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./docs-source/public
	@ ${DOCKER_RUN} cp -v build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.* ./dist

########### Clerical stuff. ###########

clean:
	@ ${DOCKER_RUN} rm -fv  *.js *.wasm *.data
	@ ${DOCKER_RUN} rm -rfv build/*
	@ ${DOCKER_RUN} rm -rfv lib/*
	@ ${DOCKER_RUN} rm -rfv third_party/php7.4-src
	@ ${DOCKER_RUN} rm -rfv third_party/drupal-7.59
	@ ${DOCKER_RUN} rm -rfv third_party/libxml2
	@ ${DOCKER_RUN} rm -rfv third_party/libicu-src
	@ ${DOCKER_RUN} rm -rfv third_party/sqlite3.33-src
	@ ${DOCKER_RUN} rm -rfv dist/*
	@ ${DOCKER_RUN} rm -rfv docs/php-*.js docs/php-*.wasm

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

########### NOPS ###########
third_party/php7.4-src/**.c:
third_party/php7.4-src/**.h:
source/**.c:
source/**.h:
