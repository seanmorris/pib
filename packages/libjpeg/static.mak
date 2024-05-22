#!/usr/bin/env make

ifeq (${WITH_LIBJPEG}, 1)

ARCHIVES+= lib/lib/libjpeg.a
CONFIGURE_FLAGS+= \
	--with-jpeg

DOCKER_RUN_IN_LIBJPEG=${DOCKER_ENV} -w /src/third_party/jpeg-9f/ emscripten-builder
TEST_LIST+=$(shell ls packages/libjpeg/test/*.mjs)

third_party/jpeg-9f/README:
	@ echo -e "\e[33;4mDownloading LIBJPEG\e[0m"
	${DOCKER_RUN} wget -q https://ijg.org/files/jpegsrc.v9f.tar.gz
	${DOCKER_RUN} tar -xvzf jpegsrc.v9f.tar.gz -C third_party
	${DOCKER_RUN} rm jpegsrc.v9f.tar.gz

lib/lib/libjpeg.a: third_party/jpeg-9f/README
	@ echo -e "\e[33;4mBuilding LIBJPEG\e[0m"
	${DOCKER_RUN_IN_LIBJPEG} emconfigure ./configure --prefix=/src/lib/ --cache-file=/tmp/config-cache --disable-shared
	${DOCKER_RUN_IN_LIBJPEG} emmake make -j`nproc` CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_LIBJPEG} emmake make install

endif
