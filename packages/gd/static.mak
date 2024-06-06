#!/usr/bin/env make

ifeq ($(filter ${WITH_GD},0 1 static dynamic),)
$(error WITH_GD MUST BE 0, 1, static, or dynamic. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_GD}, 1)
WITH_GD=static
endif

ifeq (${WITH_GD}, static)
CONFIGURE_FLAGS+= --enable-gd ${GD_FLAGS}
PHP_CONFIGURE_DEPS+= ${GD_LIBS}
TEST_LIST+= $(shell ls packages/gd/test/*.mjs)
endif

ifeq (${WITH_GD}, dynamic)
PHP_CONFIGURE_DEPS+= ${GD_LIBS}
PHP_ASSET_LIST+= php${PHP_VERSION}-gd.so
TEST_LIST+= $(shell ls packages/gd/test/*.mjs)
endif

GD_FLAGS=
GD_LIBS=

ifeq (${WITH_FREETYPE},shared)
GD_FLAGS+= --with-freetype=/src/lib
GD_LIBS+= packages/freetype/libfreetype.so
ifeq (${WITH_GD}, static)
SHARED_LIBS+= packages/freetype/libfreetype.so
endif
endif

ifeq (${WITH_LIBJPEG},shared)
GD_FLAGS+= --with-jpeg=/src/lib
GD_LIBS+= packages/libjpeg/libjpeg.so
ifeq (${WITH_GD}, static)
SHARED_LIBS+= packages/libjpeg/libjpeg.so
endif
endif

ifeq (${WITH_LIBPNG},shared)
GD_LIBS+= packages/libpng/libpng.so
ifeq (${WITH_GD}, static)
SHARED_LIBS+= packages/libpng/libpng.so
endif
endif

DOCKER_RUN_IN_EXT_GD=${DOCKER_ENV} -w /src/third_party/php${PHP_VERSION}-gd/ emscripten-builder

third_party/php${PHP_VERSION}-gd/config.m4: third_party/php${PHP_VERSION}-src/patched
	${DOCKER_RUN} cp -Lprf /src/third_party/php${PHP_VERSION}-src/ext/gd /src/third_party/php${PHP_VERSION}-gd

packages/gd/php${PHP_VERSION}-gd.so: ${PHPIZE} third_party/php${PHP_VERSION}-gd/config.m4 ${GD_LIBS}
	@ echo -e "\e[33;4mBuilding php-gd\e[0m"
	${DOCKER_RUN_IN_EXT_GD} chmod +x /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_GD} /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_GD} emconfigure ./configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix='/src/lib/php${PHP_VERSION}' --with-php-config=/src/lib/php${PHP_VERSION}/bin/php-config ${GD_FLAGS} --cache-file=/tmp/config-cache;
	${DOCKER_RUN_IN_EXT_GD} sed -i 's#-shared#-static#g' Makefile;
	${DOCKER_RUN_IN_EXT_GD} sed -i 's#-export-dynamic##g' Makefile;
	${DOCKER_RUN_IN_EXT_GD} emmake make -j${CPU_COUNT} EXTRA_INCLUDES='-I/src/third_party/php${PHP_VERSION}-src';
	${DOCKER_RUN_IN_EXT_GD} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive .libs/gd.a $(addprefix /src/,${GD_LIBS})

$(addsuffix /php${PHP_VERSION}-gd.so,$(sort ${SHARED_ASSET_PATHS})): packages/gd/php${PHP_VERSION}-gd.so
	cp -Lp $^ $@
