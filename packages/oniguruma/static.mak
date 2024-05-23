#!/usr/bin/env make

ONIGURUMA_TAG?=v6.9.9
DOCKER_RUN_IN_ONIGURUMA=${DOCKER_ENV} -w /src/third_party/oniguruma/ emscripten-builder

ifeq ($(filter ${WITH_ONIGURUMA},0 1 shared static),)
$(error WITH_ONIGURUMA MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_ONIGURUMA},1)
WITH_ONIGURUMA=static
endif

ifeq (${WITH_ONIGURUMA},static)
ARCHIVES+= lib/lib/libonig.a
CONFIGURE_FLAGS+= --with-onig
endif

ifeq (${WITH_ONIGURUMA},shared)
CONFIGURE_FLAGS+= --with-onig
SHARED_LIBS+= packages/oniguruma/libonig.so
PHP_CONFIGURE_DEPS+= packages/oniguruma/libonig.so
SKIP_LIBS+= -lonig
ifdef PHP_ASSET_PATH
PHP_ASSET_LIST+= ${PHP_ASSET_PATH}/libonig.so
endif
endif

# lib/lib/php/20230831/mbstring.so: ${PHPIZE} lib/lib/libonig.so
# 	${DOCKER_RUN_IN_PHP} bash -euxc 'cd ext/mbstring && { \
# 		../../scripts/phpize; \
# 		emconfigure ./configure --with-php-config=/src/lib/bin/php-config PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix=/src/lib/; \
# 		emmake make EXTRA_INCLUDES='-I/src/third_party/php8.3-src'; \
# 		emmake make install; \
# 	};'

third_party/oniguruma/.gitignore:
	@ echo -e "\e[33;4mDownloading ONIGURUMA\e[0m"
	${DOCKER_RUN} git clone https://github.com/kkos/oniguruma.git third_party/oniguruma \
		--branch ${ONIGURUMA_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libonig.a: third_party/oniguruma/.gitignore
	@ echo -e "\e[33;4mBuilding ONIGURUMA\e[0m"
	${DOCKER_RUN_IN_ONIGURUMA} emconfigure ./autogen.sh
	${DOCKER_RUN_IN_ONIGURUMA} emconfigure ./configure --prefix=/src/lib/ --enable-shared=yes --enable-static=yes --cache-file=/tmp/config-cache
	${DOCKER_RUN_IN_ONIGURUMA} emmake make -j${CPU_COUNT} EMCC_CFLAGS='-fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} '
	${DOCKER_RUN_IN_ONIGURUMA} emmake make install

lib/lib/libonig.so: lib/lib/libonig.a

packages/oniguruma/libonig.so: lib/lib/libonig.so
	cp -Lp $^ $@

ifdef PHP_ASSET_PATH
${PHP_ASSET_PATH}/libonig.so: packages/oniguruma/libonig.so
	cp -Lp $^ $@
endif

# packages/oniguruma/php-mbstring.so: lib/lib/php/20230831/mbstring.so
# 	cp -Lp $^ $@
