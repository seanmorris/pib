#!/usr/bin/env make

DOCKER_RUN_IN_EXT_GD=${DOCKER_ENV} -w /src/third_party/php-gd/ emscripten-builder

third_party/php-gd/config.m4: third_party/php${PHP_VERSION}-src/patched
	${DOCKER_RUN} cp -Lprf /src/third_party/php${PHP_VERSION}-src/ext/gd /src/third_party/php-gd

packages/gd/php-gd.so: ${PHPIZE} third_party/php-gd/config.m4 packages/freetype/libfreetype.so packages/libpng/libpng.so packages/libjpeg/libjpeg.so
	${DOCKER_RUN_IN_EXT_GD} chmod +x /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_GD} /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_GD} emconfigure ./configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix=/src/lib/ --with-php-config=/src/lib/bin/php-config;
	${DOCKER_RUN_IN_EXT_GD} sed -i 's#-shared#-static#g' Makefile;
	${DOCKER_RUN_IN_EXT_GD} sed -i 's#-export-dynamic##g' Makefile;
	${DOCKER_RUN_IN_EXT_GD} emmake make -j${CPU_COUNT} EXTRA_INCLUDES='-I/src/third_party/php8.3-src';
	${DOCKER_RUN_IN_EXT_GD} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive .libs/gd.a /src/packages/freetype/libfreetype.so /src/packages/libpng/libpng.so /src/packages/libjpeg/libjpeg.so

$(addsuffix /php-gd.so,$(sort ${SHARED_ASSET_PATHS})): packages/tidy/php-gd.so
	cp -Lp $^ $@
