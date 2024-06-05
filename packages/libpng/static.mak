#!/usr/bin/env make

LIBPNG_TAG?=v1.6.41
DOCKER_RUN_IN_LIBPNG=${DOCKER_ENV} -w /src/third_party/libpng/ emscripten-builder

ifeq ($(filter ${WITH_LIBPNG},0 1 shared static),)
$(error WITH_LIBPNG MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_LIBPNG},1)
WITH_LIBPNG=static
endif

ifeq (${WITH_LIBPNG},static)
ARCHIVES+= lib/lib/libpng.a
CONFIGURE_FLAGS+= --enable-png
TEST_LIST+=$(shell ls packages/libpng/test/*.mjs)
SKIP_LIBS+= -lpng16
endif

ifeq (${WITH_LIBPNG},shared)
# CONFIGURE_FLAGS+= --enable-png --with-png-dir=/src/lib
# SHARED_LIBS+= packages/libpng/libpng.so
# PHP_CONFIGURE_DEPS+= packages/libpng/libpng.so
TEST_LIST+=$(shell ls packages/libpng/test/*.mjs)
PHP_ASSET_LIST+= libpng.so
SKIP_LIBS+= -lpng16
endif

third_party/libpng/.gitignore:
	@ echo -e "\e[33;4mDownloading LIBPNG\e[0m"
	${DOCKER_RUN} git clone https://github.com/pnggroup/libpng.git third_party/libpng \
		--branch ${LIBPNG_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libpng.a: third_party/libpng/.gitignore lib/lib/libz.a
	@ echo -e "\e[33;4mBuilding LIBPNG\e[0m"
	${DOCKER_RUN_IN_LIBPNG} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="-fPIC -flto -O${SUB_OPTIMIZE} " \
		-DZLIB_LIBRARY="/src/lib/lib/libz.a" \
		-DZLIB_INCLUDE_DIR="/src/lib/include/" \
		-DPNG_SHARED="ON"
	${DOCKER_RUN_IN_LIBPNG} emmake make -j1;
	${DOCKER_RUN_IN_LIBPNG} emmake make install;

lib/lib/libpng.so: third_party/libpng/.gitignore lib/lib/libz.so
	@ echo -e "\e[33;4mBuilding LIBPNG\e[0m"
	${DOCKER_RUN_IN_LIBPNG} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_PROJECT_INCLUDE=/src/source/force-shared.cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="-fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE}" \
		-DZLIB_LIBRARY="/src/lib/lib/libz.so" \
		-DZLIB_INCLUDE_DIR="/src/lib/include/" \
		-DPNG_SHARED="ON"
	${DOCKER_RUN_IN_LIBPNG} emmake make -j1;
	${DOCKER_RUN_IN_LIBPNG} emmake make install;

packages/libpng/libpng.so: lib/lib/libpng.so
	cp -rL $^ $@

$(addsuffix /libpng.so,$(sort ${SHARED_ASSET_PATHS})): packages/libpng/libpng.so
	cp -Lp $^ $@
