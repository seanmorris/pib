#!/usr/bin/env make

ifeq (${WITH_LIBZIP}, 1)

LIBZIP_TAG?=v1.10.1

ARCHIVES+= lib/lib/libzip.a
CONFIGURE_FLAGS+= --with-zip

DOCKER_RUN_IN_LIBZIP =${DOCKER_ENV} -w /src/third_party/libzip/ emscripten-builder
TEST_LIST+=$(shell ls packages/libzip/test/*.mjs)

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
		-DCMAKE_C_FLAGS=" -fPIC"
	${DOCKER_RUN_IN_LIBZIP} emmake make -j`nproc`;
	${DOCKER_RUN_IN_LIBZIP} emmake make install;

endif

