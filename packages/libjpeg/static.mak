#!/usr/bin/env make

JPEG_VERSION=v9f
DOCKER_RUN_IN_LIBJPEG=${DOCKER_ENV} -w /src/third_party/jpeg-9f/ emscripten-builder

ifeq ($(filter ${WITH_LIBJPEG},0 1 shared static),)
$(error WITH_LIBJPEG MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_LIBJPEG},1)
WITH_LIBJPEG=static
endif

ifeq (${WITH_LIBJPEG},static)
ARCHIVES+= lib/lib/libjpeg.a
CONFIGURE_FLAGS+= --with-jpeg
TEST_LIST+=$(shell ls packages/libjpeg/test/*.mjs)
endif

ifeq (${WITH_LIBJPEG},shared)
SHARED_LIBS+= packages/libjpeg/libjpeg.so
PHP_CONFIGURE_DEPS+= packages/libjpeg/libjpeg.so
TEST_LIST+=$(shell ls packages/libjpeg/test/*.mjs)
SKIP_LIBS+= -ljpeg
ifdef PHP_ASSET_PATH
PHP_ASSET_LIST+= ${PHP_ASSET_PATH}/libjpeg.so
endif
endif

third_party/jpeg-9f/README:
	@ echo -e "\e[33;4mDownloading LIBJPEG\e[0m"
	${DOCKER_RUN} wget -q https://ijg.org/files/jpegsrc.${JPEG_VERSION}.tar.gz
	${DOCKER_RUN} tar -xvzf jpegsrc.${JPEG_VERSION}.tar.gz -C third_party
	${DOCKER_RUN} rm jpegsrc.${JPEG_VERSION}.tar.gz

lib/lib/libjpeg.a: third_party/jpeg-9f/README
	@ echo -e "\e[33;4mBuilding LIBJPEG\e[0m"
	${DOCKER_RUN_IN_LIBJPEG} emconfigure ./configure --prefix=/src/lib/ --cache-file=/tmp/config-cache
	${DOCKER_RUN_IN_LIBJPEG} emmake make -j${CPU_COUNT} EMCC_CFLAGS='-fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} '
	${DOCKER_RUN_IN_LIBJPEG} emmake make install

lib/lib/libjpeg.so: lib/lib/libjpeg.a

packages/libjpeg/libjpeg.so: lib/lib/libjpeg.so
	cp -rL $^ $@

ifdef PHP_ASSET_PATH
${PHP_ASSET_PATH}/libjpeg.so: packages/libjpeg/libjpeg.so
	cp -Lp $^ $@
endif
