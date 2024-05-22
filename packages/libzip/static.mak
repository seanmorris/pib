#!/usr/bin/env make

LIBZIP_TAG?=v1.10.1

ifeq ($(filter ${WITH_LIBZIP},0 1 shared static),)
$(error WITH_LIBZIP MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR .env FILE.)
endif

ifeq (${WITH_LIBZIP},1)
WITH_LIBZIP=static
endif

ifeq (${WITH_LIBZIP},static)
ARCHIVES+= lib/lib/libzip.a
CONFIGURE_FLAGS+= --with-zip
TEST_LIST+=$(shell ls packages/libzip/test/*.mjs)
DOCKER_RUN_IN_LIBZIP =${DOCKER_ENV} -e C_FLAGS="-fPIC -O${OPTIMIZE}" -w /src/third_party/libzip/ emscripten-builder
endif

ifeq (${WITH_LIBZIP},shared)
SHARED_LIBS+= lib/lib/libzip.so
CONFIGURE_FLAGS+= --with-zip
PHP_CONFIGURE_DEPS+= packages/libzip/libzip.so
TEST_LIST+=$(shell ls packages/libzip/test/*.mjs)
DOCKER_RUN_IN_LIBZIP =${DOCKER_ENV} -e C_FLAGS="-fPIC -sSIDE_MODULE=1 -O${OPTIMIZE}" -w /src/third_party/libzip/ emscripten-builder
endif

third_party/libzip/.gitignore:
	@ echo -e "\e[33;4mDownloading LibZip\e[0m"
	${DOCKER_RUN} git clone https://github.com/nih-at/libzip.git third_party/libzip \
		--branch ${LIBZIP_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libzip.a: third_party/libzip/.gitignore lib/lib/libz.a
	@ echo -e "\e[33;4mBuilding LibZip\e[0m"
	${DOCKER_RUN_IN_LIBZIP} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DZLIB_LIBRARY=/src/lib/lib/libz.a \
		-DZLIB_INCLUDE_DIR=/src/lib/include/ \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="-fPIC"
	${DOCKER_RUN_IN_LIBZIP} emmake make -ej${CPU_COUNT}
	${DOCKER_RUN_IN_LIBZIP} emmake make install;

lib/lib/libzip.so: third_party/libzip/.gitignore lib/lib/libz.so
	@ echo -e "\e[33;4mBuilding LibZip\e[0m"
	${DOCKER_RUN_IN_LIBZIP} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DZLIB_LIBRARY=/src/lib/lib/libz.so \
		-DZLIB_INCLUDE_DIR=/src/lib/include/ \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_SHARED_LIBS:BOOL=true \
		-DBUILD_TOOLS:BOOL=false \
		-DBUILD_EXAMPLES:BOOL=false \
		-DBUILD_DOC:BOOL=false \
		-DCMAKE_PROJECT_INCLUDE=/src/source/force-shared.cmake
	${DOCKER_RUN_IN_LIBZIP} emmake make -ej${CPU_COUNT} zip
	${DOCKER_RUN_IN_LIBZIP} emmake make install;

packages/libzip/libzip.so: lib/lib/libzip.so
	cp $^ $@
