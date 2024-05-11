#!/usr/bin/env make

ifeq (${WITH_LIBPNG}, 1)

LIBPNG_TAG?=v1.6.41
ARCHIVES+= lib/lib/libpng.a
CONFIGURE_FLAGS+= \
	--enable-png

DOCKER_RUN_IN_LIBPNG=${DOCKER_ENV} -w /src/third_party/libpng/ emscripten-builder
TEST_LIST+=$(shell ls packages/libpng/test/*.mjs)

third_party/libpng/.gitignore:
	@ echo -e "\e[33;4mDownloading LIBPNG\e[0m"
	${DOCKER_RUN} git clone https://github.com/pnggroup/libpng.git third_party/libpng \
		--branch ${LIBPNG_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libpng.a: third_party/libpng/.gitignore lib/lib/libz.a
	@ echo -e "\e[33;4mBuilding LIBPNG\e[0m"
	${DOCKER_RUN_IN_LIBPNG} emconfigure ./configure --prefix=/src/lib/ --with-zlib-prefix=/src/lib/ --cache-file=/tmp/config-cache --disable-shared
	${DOCKER_RUN_IN_LIBPNG} emmake make -j`nproc` EXTRA_CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_LIBPNG} emmake make install;

endif
