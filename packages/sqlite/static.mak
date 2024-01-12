#!/usr/bin/env make

SQLITE_VERSION?=3410200
SQLITE_DIR?=sqlite3.41-src

ifeq (${WITH_SQLITE}, 1)

ARCHIVES+= lib/lib/libsqlite3.a
CONFIGURE_FLAGS+=  \
	--with-sqlite3 \
	--enable-pdo   \
	--with-pdo-sqlite=/src/lib
EXTRA_FILES+= ext/pdo_sqlite/pdo_sqlite.c ext/pdo_sqlite/sqlite_driver.c ext/pdo_sqlite/sqlite_statement.c

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
	${DOCKER_RUN_IN_SQLITE} emmake make -j`nproc` EXTRA_CFLAGS='-fPIC'
	${DOCKER_RUN_IN_SQLITE} emmake make install

endif
