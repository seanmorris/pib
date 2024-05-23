#!/usr/bin/env make

FREETYPE_VERSION?=2.10.0
DOCKER_RUN_IN_FREETYPE=${DOCKER_ENV} -w /src/third_party/freetype-${FREETYPE_VERSION}/build emscripten-builder

ifeq ($(filter ${WITH_FREETYPE},0 1 shared static),)
$(error WITH_FREETYPE MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_FREETYPE},1)
WITH_FREETYPE=static
endif

ifeq (${WITH_FREETYPE},static)
CONFIGURE_FLAGS+= --with-freetype
ARCHIVES+= lib/lib/libfreetype.a
TEST_LIST+=$(shell ls packages/freetype/test/*.mjs)
endif

ifeq (${WITH_FREETYPE},shared)
CONFIGURE_FLAGS+= --with-freetype --with-freetype-dir=/src/lib
SHARED_LIBS+= packages/freetype/libfreetype.so
PHP_CONFIGURE_DEPS+= packages/freetype/libfreetype.so
TEST_LIST+=$(shell ls packages/freetype/test/*.mjs)
SKIP_LIBS+= -lfreetype
ifdef PHP_ASSET_PATH
PHP_ASSET_LIST+= ${PHP_ASSET_PATH}/libfreetype.so
endif
endif

third_party/freetype-${FREETYPE_VERSION}/README:
	@ echo -e "\e[33;4mDownloading FREETYPE\e[0m"
	${DOCKER_RUN} wget -q https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz
	${DOCKER_RUN} tar -xvzf freetype-${FREETYPE_VERSION}.tar.gz -C third_party
	${DOCKER_RUN} rm freetype-${FREETYPE_VERSION}.tar.gz

lib/lib/libfreetype.a: third_party/freetype-${FREETYPE_VERSION}/README
	@ echo -e "\e[33;4mBuilding FREETYPE\e[0m"
	${DOCKER_RUN} rm -rf third_party/freetype-${FREETYPE_VERSION}/build
	${DOCKER_RUN} mkdir third_party/freetype-${FREETYPE_VERSION}/build
	${DOCKER_RUN_IN_FREETYPE} emcmake cmake .. \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_C_FLAGS="-fPIC -O${OPTIMIZE}"
	${DOCKER_RUN_IN_FREETYPE} bash -c 'echo "" > /src/third_party/freetype-${FREETYPE_VERSION}/build/CMakeFiles/freetype.dir/linklibs.rsp'
	${DOCKER_RUN_IN_FREETYPE} emmake make -j${CPU_COUNT}
	${DOCKER_RUN_IN_FREETYPE} emmake make install

lib/lib/libfreetype.so: third_party/freetype-${FREETYPE_VERSION}/README lib/lib/libz.so lib/lib/libpng.so
	@ echo -e "\e[33;4mBuilding FREETYPE\e[0m"
	${DOCKER_RUN} rm -rf third_party/freetype-${FREETYPE_VERSION}/build
	${DOCKER_RUN} mkdir third_party/freetype-${FREETYPE_VERSION}/build
	${DOCKER_RUN_IN_FREETYPE} emcmake cmake \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DBUILD_SHARED_LIBS:BOOL=true \
		-DZLIB_LIBRARY="/src/lib/lib/libz.so" \
		-DPNG_LIBRARY="/src/lib/lib/libpng.so" \
		-DPNG_PNG_INCLUDE_DIR=/src/lib/include \
		-DZLIB_INCLUDE_DIR="/src/lib/include" \
		-DCMAKE_PROJECT_INCLUDE=/src/source/force-shared.cmake \
		-DCMAKE_C_FLAGS="-fPIC -sSIDE_MODULE=1 -O${OPTIMIZE}" \
		..
	${DOCKER_RUN_IN_FREETYPE} emmake make -j${CPU_COUNT}
	${DOCKER_RUN_IN_FREETYPE} emmake make install

packages/freetype/libfreetype.so: lib/lib/libfreetype.so
	cp -Lp $^ $@

ifdef PHP_ASSET_PATH
${PHP_ASSET_PATH}/libfreetype.so: packages/freetype/libfreetype.so
	cp -Lp $^ $@
endif
