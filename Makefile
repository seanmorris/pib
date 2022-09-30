-include .env
# Please note that this file is under Apache2 License https://github.com/seanmorris/php-wasm)

ENVIRONMENT    ?=web
INITIAL_MEMORY ?=256mb
PRELOAD_ASSETS ?=/src/preload/
ASSERTIONS     ?=0
OPTIMIZE       ?=-O2
RELEASE_SUFFIX ?=

DOCKER_IMAGE   ?=soyuka/php-emscripten-builder:latest
PHP_BRANCH     ?=PHP-8.1.10
LIBXML2_TAG    ?=v2.9.10

DOCKER_ENV=docker run --rm \
	-v $(CURDIR):/src \
	-e INITIAL_MEMORY=${INITIAL_MEMORY}   \
	-e LIBXML_LIBS="-L/src/lib/lib" \
	-e LIBXML_CFLAGS="-I/src/lib/include/libxml2" \
	-e SQLITE_CFLAGS="-I/src/lib/include/sqlite3" \
	-e SQLITE_LIBS="-L/src/lib/lib" \
  -e PRELOAD_ASSETS='${PRELOAD_ASSETS}' \
	-e ENVIRONMENT=${ENVIRONMENT}         

DOCKER_RUN           =${DOCKER_ENV} ${DOCKER_IMAGE}
DOCKER_RUN_IN_PHP    =${DOCKER_ENV} -w /src/third_party/php-src/ ${DOCKER_IMAGE}
DOCKER_RUN_IN_SQLITE =${DOCKER_ENV} -w /src/third_party/sqlite-src/ ${DOCKER_IMAGE}
DOCKER_RUN_IN_LIBXML =${DOCKER_ENV} -w /src/third_party/libxml2/ ${DOCKER_IMAGE}

.PHONY: clean build pull

all: lib/pib_eval.o php-web.wasm

########### Collect & patch the source code. ###########

third_party/sqlite-src:
	mkdir -p third_party
	wget https://sqlite.org/2020/sqlite-amalgamation-3330000.zip
	${DOCKER_RUN} unzip sqlite-amalgamation-3330000.zip
	${DOCKER_RUN} rm sqlite-amalgamation-3330000.zip
	${DOCKER_RUN} mv sqlite-amalgamation-3330000 third_party/sqlite-src

third_party/sqlite-src/sqlite3.o: third_party/sqlite-src
	${DOCKER_RUN_IN_SQLITE} emcc -Oz -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_DISABLE_LFS -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_THREADSAFE=0 -DSQLITE_ENABLE_NORMALIZE -c sqlite3.c -o sqlite3.o
	${DOCKER_RUN} mkdir -p /src/lib/include/sqlite3
	${DOCKER_RUN} cp -v third_party/sqlite-src/sqlite3.h /src/lib/include/sqlite3/sqlite3.h
	${DOCKER_RUN} cp -v third_party/sqlite-src/sqlite3.o /src/lib/lib/sqlite3.o

third_party/php-src/patched:
	${DOCKER_RUN} git clone https://github.com/php/php-src.git third_party/php-src \
		--branch ${PHP_BRANCH}   \
		--single-branch          \
		--depth 1
	${DOCKER_RUN_IN_PHP} sed -i -s 's/headers_sent) = 1/headers_sent) = 0/' sapi/embed/php_embed.c
	${DOCKER_RUN_IN_PHP} sed -i -s 's/no_headers = 1/no_headers = 0/' sapi/embed/php_embed.c
	${DOCKER_RUN} touch third_party/php-src/patched

third_party/libxml2/README:
	${DOCKER_RUN} git clone https://gitlab.gnome.org/GNOME/libxml2.git third_party/libxml2 \
		--branch ${LIBXML2_TAG} \
		--single-branch     \
		--depth 1

third_party/libxml2/configure: third_party/libxml2/README
	${DOCKER_RUN_IN_LIBXML} ./autogen.sh
	${DOCKER_RUN_IN_LIBXML} emconfigure ./configure --prefix=/src/lib/ --enable-static --disable-shared \
		--with-python=no --with-threads=no
	${DOCKER_RUN_IN_LIBXML} emmake make -j8
	${DOCKER_RUN_IN_LIBXML} emmake make install

########### Build the objects. ###########

third_party/php-src/configure: third_party/php-src/patched third_party/libxml2/configure third_party/sqlite-src/sqlite3.o
	mkdir -p build
	${DOCKER_RUN_IN_PHP} bash -c "./buildconf --force && emconfigure ./configure \
		--enable-embed=static \
		--with-layout=GNU  \
		--with-libxml      \
		--enable-xml       \
		--disable-cgi      \
		--disable-cli      \
		--disable-fiber-asm \
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
		--enable-simplexml   \
		--enable-pdo       \
		--with-pdo-sqlite  \
		--with-sqlite3    \
	"

lib/libphp.a: third_party/php-src/configure third_party/php-src/patched
	${DOCKER_RUN_IN_PHP} emmake make -j8
	# PHP7 outputs a libphp7 whereas php8 a libphp
	${DOCKER_RUN_IN_PHP} bash -c '[[ -f .libs/libphp7.la  ]] && mv .libs/libphp7.la .libs/libphp.la && mv .libs/libphp7.a .libs/libphp.a && mv .libs/libphp7.lai .libs/libphp.lai || exit 0'
	${DOCKER_RUN} cp -v third_party/php-src/.libs/libphp.la third_party/php-src/.libs/libphp.a lib/

lib/pib_eval.o: lib/libphp.a source/pib_eval.c
	${DOCKER_RUN_IN_PHP} emcc ${OPTIMIZE} \
		-I .     \
		-I Zend  \
		-I main  \
		-I TSRM/ \
		-c \
		/src/source/pib_eval.c \
		-o /src/lib/pib_eval.o \
		-s ERROR_ON_UNDEFINED_SYMBOLS=0

########### Build the final files. ###########

FINAL_BUILD=${DOCKER_RUN_IN_PHP} emcc ${OPTIMIZE} \
	-o ../../build/php-${ENVIRONMENT}${RELEASE_SUFFIX}.js \
	--llvm-lto 2                     \
	-s EXPORTED_FUNCTIONS='["_pib_init", "_pib_destroy", "_pib_run", "_pib_exec", "_pib_refresh", "_main", "_php_embed_init", "_php_embed_shutdown", "_php_embed_shutdown", "_zend_eval_string"]' \
	-s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "UTF8ToString", "lengthBytesUTF8", "FS"]' \
	-s ENVIRONMENT=${ENVIRONMENT}    \
	-s FORCE_FILESYSTEM=1            \
	-s MAXIMUM_MEMORY=2gb             \
	-s INITIAL_MEMORY=${INITIAL_MEMORY} \
	-s ALLOW_MEMORY_GROWTH=1         \
	-s ASSERTIONS=${ASSERTIONS}      \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0  \
	-s MODULARIZE=1                  \
	-s INVOKE_RUN=0                  \
	-lidbfs.js                       \
		/src/lib/pib_eval.o /src/lib/lib/sqlite3.o /src/lib/libphp.a /src/lib/lib/libxml2.a

php-web.wasm: ENVIRONMENT=web
php-web.wasm: lib/libphp.a lib/pib_eval.o 
	${FINAL_BUILD}

php-worker.wasm: ENVIRONMENT=worker
php-worker.wasm: lib/libphp.a lib/pib_eval.o
	${FINAL_BUILD}

php-node.wasm: ENVIRONMENT=node
php-node.wasm: lib/libphp.a lib/pib_eval.o
	${FINAL_BUILD}

php-shell.wasm: ENVIRONMENT=shell
php-shell.wasm: lib/libphp.a lib/pib_eval.o
	${FINAL_BUILD}

php-webview.wasm: ENVIRONMENT=webview
php-webview.wasm: lib/libphp.a lib/pib_eval.o
	${FINAL_BUILD}

########### Clerical stuff. ###########

clean:
	${DOCKER_RUN} rm -fv  *.js *.wasm *.data
	${DOCKER_RUN} rm -rfv  build/* lib/*
	${DOCKER_RUN} rm -rfv third_party/php-src
	${DOCKER_RUN} rm -rfv third_party/libxml2
	${DOCKER_RUN} rm -rfv third_party/sqlite-src

build:
	docker build . -t ${DOCKER_IMAGE}

pull:
	docker pull ${DOCKER_IMAGE}

preload-data:
	${DOCKER_RUN_IN_PHP} python3 /emsdk/upstream/emscripten/tools/file_packager.py ../../build/php-web.data \
		--preload ${PRELOAD_ASSETS} \
		--js-output=../../build/php-web.data.js

