#!/usr/bin/env make

LIBXML2_TAG?=v2.9.10
DOCKER_RUN_IN_LIBXML =${DOCKER_ENV} -e NOCONFIGURE=1 -e EMCC_CFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}' -w /src/third_party/libxml2/ emscripten-builder
DOCKER_RUN_IN_EXT_DOM =${DOCKER_ENV} -e NOCONFIGURE=1 -e EMCC_CFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}' -w /src/third_party/php${PHP_VERSION}-dom/ emscripten-builder
DOCKER_RUN_IN_EXT_SIMPLEXML =${DOCKER_ENV} -e NOCONFIGURE=1 -e EMCC_CFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}' -w /src/third_party/php${PHP_VERSION}-simplexml/ emscripten-builder
DOCKER_RUN_IN_EXT_XML =${DOCKER_ENV} -e NOCONFIGURE=1 -e EMCC_CFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}' -w /src/third_party/php${PHP_VERSION}-xml/ emscripten-builder

ifeq ($(filter ${WITH_LIBXML},0 1 shared static dynamic),)
$(error WITH_LIBXML MUST BE 0, 1, static, shared, OR dynamic. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_LIBXML},1)
WITH_LIBXML=static
endif

ifeq (${WITH_LIBXML},static)
ARCHIVES+= lib/lib/libxml2.a
CONFIGURE_FLAGS+= --with-libxml --enable-xml --enable-dom --enable-simplexml
TEST_LIST+=$(shell ls packages/libxml/test/*.mjs)
endif

ifeq (${WITH_LIBXML},shared)
SHARED_LIBS+= packages/libxml/libxml2.so
CONFIGURE_FLAGS+= --with-libxml=/src/lib/ --enable-xml --enable-dom --enable-simplexml
PHP_CONFIGURE_DEPS+= packages/libxml/libxml2.so
TEST_LIST+=$(shell ls packages/libxml/test/*.mjs)
PHP_ASSET_LIST+= libxml2.so
SKIP_LIBS+= -lxml2
endif

ifeq (${WITH_LIBXML},dynamic)
SHARED_LIBS+= packages/libxml/libxml2.so
CONFIGURE_FLAGS+= --with-libxml=/src/lib/
PHP_CONFIGURE_DEPS+= packages/libxml/libxml2.so
TEST_LIST+=$(shell ls packages/libxml/test/*.mjs)
PHP_ASSET_LIST+= libxml2.so php${PHP_VERSION}-dom.so php${PHP_VERSION}-simplexml.so php${PHP_VERSION}-xml.so
SKIP_LIBS+= -lxml2
endif

third_party/libxml2/.gitignore:
	@ echo -e "\e[33;4mDownloading LibXML2\e[0m"
	${DOCKER_RUN} git clone https://gitlab.gnome.org/GNOME/libxml2.git third_party/libxml2 \
		--branch ${LIBXML2_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libxml2.a: third_party/libxml2/.gitignore
	@ echo -e "\e[33;4mBuilding LibXML2\e[0m"
	${DOCKER_RUN_IN_LIBXML} ./autogen.sh
	${DOCKER_RUN_IN_LIBXML} emconfigure ./configure --with-http=no --with-ftp=no --with-python=no --with-threads=no --prefix=/src/lib/ --cache-file=/tmp/config-cache
	${DOCKER_RUN_IN_LIBXML} emmake make -j${CPU_COUNT}
	${DOCKER_RUN_IN_LIBXML} emmake make install

lib/lib/libxml2.so: lib/lib/libxml2.a
	${DOCKER_RUN_IN_LIBZIP} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

packages/libxml/libxml2.so: lib/lib/libxml2.so
	cp -L $^ $@

$(addsuffix /libxml2.so,$(sort ${SHARED_ASSET_PATHS})): packages/libxml/libxml2.so
	cp -Lp $^ $@

third_party/php${PHP_VERSION}-dom/config.m4: third_party/php${PHP_VERSION}-src/patched
	${DOCKER_RUN} cp -Lprf /src/third_party/php${PHP_VERSION}-src/ext/dom /src/third_party/php${PHP_VERSION}-dom

third_party/php${PHP_VERSION}-simplexml/config.m4: third_party/php${PHP_VERSION}-src/patched
	${DOCKER_RUN} cp -Lrf /src/third_party/php${PHP_VERSION}-src/ext/simplexml /src/third_party/php${PHP_VERSION}-simplexml

third_party/php${PHP_VERSION}-xml/config.m4: third_party/php${PHP_VERSION}-src/patched
	${DOCKER_RUN} cp -Lprf /src/third_party/php${PHP_VERSION}-src/ext/xml /src/third_party/php${PHP_VERSION}-xml

packages/libxml/php${PHP_VERSION}-dom.so: ${PHPIZE} third_party/php${PHP_VERSION}-dom/config.m4
	${DOCKER_RUN_IN_EXT_DOM} chmod +x /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_DOM} /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_DOM} sed -i 's|#include "php.h"|#include "config.h"\n#include "php.h"\n|g' php_dom.c;
	${DOCKER_RUN_IN_EXT_DOM} emconfigure ./configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix='/src/lib/php${PHP_VERSION}' --with-php-config=/src/lib/php${PHP_VERSION}/bin/php-config;
	${DOCKER_RUN_IN_EXT_DOM} sed -i 's#-shared#-static#g' Makefile;
	${DOCKER_RUN_IN_EXT_DOM} sed -i 's#-export-dynamic##g' Makefile;
	${DOCKER_RUN_IN_EXT_DOM} emmake make -j${CPU_COUNT} EXTRA_INCLUDES='-I/src/third_party/php${PHP_VERSION}-src';
	${DOCKER_RUN_IN_EXT_DOM} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive .libs/dom.a /src/packages/libxml/libxml2.so

$(addsuffix /php${PHP_VERSION}-dom.so,$(sort ${SHARED_ASSET_PATHS})): packages/libxml/php${PHP_VERSION}-dom.so
	cp -Lp $^ $@

packages/libxml/php${PHP_VERSION}-simplexml.so: ${PHPIZE} third_party/php${PHP_VERSION}-simplexml/config.m4
	${DOCKER_RUN_IN_EXT_SIMPLEXML} chmod +x /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_SIMPLEXML} /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_SIMPLEXML} sed -i 's|#include "php.h"|#include "config.h"\n#include "php.h"\n|g' simplexml.c;
	${DOCKER_RUN_IN_EXT_SIMPLEXML} emconfigure ./configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix='/src/lib/php${PHP_VERSION}' --with-php-config=/src/lib/php${PHP_VERSION}/bin/php-config;
	${DOCKER_RUN_IN_EXT_SIMPLEXML} sed -i 's#-shared#-static#g' Makefile;
	${DOCKER_RUN_IN_EXT_SIMPLEXML} sed -i 's#-export-dynamic##g' Makefile;
	${DOCKER_RUN_IN_EXT_SIMPLEXML} emmake make -j${CPU_COUNT} EXTRA_INCLUDES='-I/src/third_party/php${PHP_VERSION}-src';
	${DOCKER_RUN_IN_EXT_SIMPLEXML} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive .libs/simplexml.a /src/packages/libxml/libxml2.so

$(addsuffix /php${PHP_VERSION}-simplexml.so,$(sort ${SHARED_ASSET_PATHS})): packages/libxml/php${PHP_VERSION}-simplexml.so
	cp -Lp $^ $@

packages/libxml/php${PHP_VERSION}-xml.so: ${PHPIZE} third_party/php${PHP_VERSION}-xml/config.m4
	${DOCKER_RUN_IN_EXT_XML} chmod +x /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_XML} /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_XML} sed -i 's|#include "php.h"|#include "config.h"\n#include "php.h"\n|g' xml.c;
	${DOCKER_RUN_IN_EXT_XML} emconfigure ./configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix='/src/lib/php${PHP_VERSION}' --with-php-config=/src/lib/php${PHP_VERSION}/bin/php-config;
	${DOCKER_RUN_IN_EXT_XML} sed -i 's#-shared#-static#g' Makefile;
	${DOCKER_RUN_IN_EXT_XML} sed -i 's#-export-dynamic##g' Makefile;
	${DOCKER_RUN_IN_EXT_XML} emmake make -j${CPU_COUNT} EXTRA_INCLUDES='-I/src/third_party/php${PHP_VERSION}-src';
	${DOCKER_RUN_IN_EXT_XML} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive .libs/xml.a /src/packages/libxml/libxml2.so

$(addsuffix /php${PHP_VERSION}-xml.so,$(sort ${SHARED_ASSET_PATHS})): packages/libxml/php${PHP_VERSION}-xml.so
	cp -Lp $^ $@
