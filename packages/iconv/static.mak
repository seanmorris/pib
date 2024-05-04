#!/usr/bin/env make

ifeq (${WITH_ICONV}, 1)

ICONV_TAG?=v1.17
ARCHIVES+= lib/lib/libiconv.a
CONFIGURE_FLAGS+= \
	--with-iconv=/src/lib

DOCKER_RUN_IN_ICONV=${DOCKER_ENV} -w /src/third_party/libiconv-1.17/ emscripten-builder
TEST_LIST+=$(shell ls packages/iconv/test/*.mjs)

third_party/libiconv-1.17/README:
	@ echo -e "\e[33;4mDownloading Iconv\e[0m"
	${DOCKER_RUN} wget -q https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
	${DOCKER_RUN} tar -xvzf libiconv-1.17.tar.gz -C third_party
	${DOCKER_RUN} rm libiconv-1.17.tar.gz

lib/lib/libiconv.a: third_party/libiconv-1.17/README
	@ echo -e "\e[33;4mBuilding Iconv\e[0m"
	${DOCKER_RUN_IN_ICONV} autoconf
	${DOCKER_RUN_IN_ICONV} emconfigure ./configure --prefix=/src/lib/ --enable-shared=no --enable-static=yes --cache-file=/tmp/config-cache
	${DOCKER_RUN_IN_ICONV} emmake make -j`nproc` EMCC_CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_ICONV} emmake make install
	${DOCKER_RUN_IN_ICONV} chown -R $(or ${UID},1000):$(or ${GID},1000) ./

endif
