#!/usr/bin/env make

ICONV_TAG?=v1.17
DOCKER_RUN_IN_ICONV=${DOCKER_ENV} -e EMCC_CFLAGS='-fPIC -O${OPTIMIZE}' -w /src/third_party/libiconv-1.17/ emscripten-builder

ifeq ($(filter ${WITH_ICONV},0 1 shared static),)
$(error WITH_ICONV MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_ICONV},1)
WITH_ICONV=static
endif

ifeq (${WITH_ICONV},static)
ARCHIVES+= lib/lib/libiconv.a
CONFIGURE_FLAGS+= --with-iconv=/src/lib
TEST_LIST+=$(shell ls packages/iconv/test/*.mjs)
DOCKER_RUN_IN_ICONV=${DOCKER_ENV} -w /src/third_party/libiconv-1.17/ emscripten-builder
endif

ifeq (${WITH_ICONV},shared)
SHARED_LIBS+= packages/iconv/libiconv.so
PHP_CONFIGURE_DEPS+= packages/iconv/libiconv.so
TEST_LIST+=$(shell ls packages/iconv/test/*.mjs)
SKIP_LIBS+= -libiconv
endif

# lib/lib/php/20230831/iconv.so: ${PHPIZE} lib/lib/libiconv.so
# 	${DOCKER_RUN_IN_PHP} bash -euxc 'cd ext/iconv && { \
# 		../../scripts/phpize; \
# 		emconfigure ./configure --with-php-config=/src/lib/bin/php-config PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix=/src/lib/ --with-iconv=/src/lib; \
# 		emmake make EXTRA_INCLUDES="-I/src/third_party/php8.3-src" EXTRA_CFLAGS="-fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} "; \
# 		emmake make install; \
# 	};'

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

lib/lib/libiconv.so: lib/lib/libiconv.a
	${DOCKER_RUN_IN_ICONV} emcc -shared -o /src/$@ -fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} -Wl,--whole-archive /src/$^

packages/iconv/libiconv.so: lib/lib/libiconv.so
	cp $^ $@
