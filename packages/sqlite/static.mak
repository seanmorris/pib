#!/usr/bin/env make

SQLITE_VERSION?=3410200
SQLITE_DIR?=sqlite3.41-src
DOCKER_RUN_IN_SQLITE=${DOCKER_ENV} -w /src/third_party/${SQLITE_DIR}/ emscripten-builder

ifeq ($(filter ${WITH_SQLITE},0 1 shared static),)
$(error WITH_SQLITE MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_SQLITE},1)
WITH_SQLITE=static
endif

ifeq (${WITH_SQLITE},static)
ARCHIVES+= lib/lib/libsqlite3.a
CONFIGURE_FLAGS+= --with-sqlite3 --enable-pdo --with-pdo-sqlite=/src/lib
TEST_LIST+=$(shell ls packages/sqlite/test/*.mjs)
endif

ifeq (${WITH_SQLITE},shared)
CONFIGURE_FLAGS+= --with-sqlite3 --enable-pdo --with-pdo-sqlite=/src/lib
SHARED_LIBS+= packages/sqlite/libsqlite3.so
PHP_CONFIGURE_DEPS+= packages/sqlite/libsqlite3.so
TEST_LIST+=$(shell ls packages/sqlite/test/*.mjs)
SKIP_LIBS+= -lsqlite3
endif

third_party/${SQLITE_DIR}/sqlite3.c:
	@ echo -e "\e[33;4mDownloading SQLite\e[0m"
	wget -q https://sqlite.org/2023/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	${DOCKER_RUN} tar -xzf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	${DOCKER_RUN} rm -r sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	${DOCKER_RUN} rm -rf third_party/${SQLITE_DIR}
	${DOCKER_RUN} mv sqlite-autoconf-${SQLITE_VERSION} third_party/${SQLITE_DIR}

lib/lib/libsqlite3.a: third_party/${SQLITE_DIR}/sqlite3.c
	@ echo -e "\e[33;4mBuilding LibSqlite3\e[0m"
	${DOCKER_RUN_IN_SQLITE} emconfigure ./configure --with-http=no --with-ftp=no --with-python=no --with-threads=no --enable-shared=no --prefix=/src/lib/ --cache-file=/tmp/config-cache
	${DOCKER_RUN_IN_SQLITE} emmake make -j`nproc` CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_SQLITE} emmake make install

lib/lib/libsqlite3.so: lib/lib/libsqlite3.a
	${DOCKER_RUN_IN_LIBZIP} emcc -shared -o /src/$@ -fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} -Wl,--whole-archive /src/$^

packages/sqlite/libsqlite3.so: lib/lib/libsqlite3.so
	cp $^ $@
