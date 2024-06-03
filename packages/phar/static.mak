#!/usr/bin/env make

# ifeq ($(filter ${WITH_PHAR},0 1),)
# $(error WITH_PHAR MUST BE 0 or 1. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
# endif

ifeq (${WITH_PHAR},1)
WITH_PHAR=static
endif

ifeq (${WITH_PHAR},static)
CONFIGURE_FLAGS+= --enable-phar
endif

ifeq (${WITH_PHAR},shared)
PHP_ASSET_LIST+= php${PHP_VERSION}-phar.so
endif

DOCKER_RUN_IN_EXT_PHAR=${DOCKER_ENV} -w /src/third_party/php${PHP_VERSION}-phar/ emscripten-builder

third_party/php${PHP_VERSION}-phar/config.m4: third_party/php${PHP_VERSION}-src/patched
	${DOCKER_RUN} cp -Lprf /src/third_party/php${PHP_VERSION}-src/ext/phar /src/third_party/php${PHP_VERSION}-phar

packages/phar/php${PHP_VERSION}-phar.so: ${PHPIZE} third_party/php${PHP_VERSION}-phar/config.m4
	${DOCKER_RUN_IN_EXT_PHAR} chmod +x /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_PHAR} /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_PHAR} sed -i 's|#define PHAR_MAIN 1|#define PHAR_MAIN 1\n#include "config.h"|g' phar.c;
	${DOCKER_RUN_IN_EXT_PHAR} emconfigure ./configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix='/src/lib/php${PHP_VERSION}' --with-php-config=/src/lib/php${PHP_VERSION}/bin/php-config --cache-file=/tmp/config-cache;
	${DOCKER_RUN_IN_EXT_PHAR} sed -i 's#-shared#-static#g' Makefile;
	${DOCKER_RUN_IN_EXT_PHAR} sed -i 's#-export-dynamic##g' Makefile;
	${DOCKER_RUN_IN_EXT_PHAR} cp ../../packages/phar/phar.mak .
	${DOCKER_RUN_IN_EXT_PHAR} emmake make -f phar.mak -j${CPU_COUNT} EXTRA_INCLUDES='-I/src/third_party/php${PHP_VERSION}-src';
	${DOCKER_RUN_IN_EXT_PHAR} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive .libs/phar.a

$(addsuffix /php${PHP_VERSION}-phar.so,$(sort ${SHARED_ASSET_PATHS})): packages/phar/php${PHP_VERSION}-phar.so
	cp -Lp $^ $@
