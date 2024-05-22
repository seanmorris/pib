#!/usr/bin/env make

TIDYHTML_TAG?=5.6.0
DOCKER_RUN_IN_TIDY=${DOCKER_ENV} -w /src/third_party/tidy-html5/ emscripten-builder

ifeq ($(filter ${WITH_TIDY},0 1 shared static),)
$(error WITH_TIDY MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR .env FILE.)
endif

ifeq (${WITH_TIDY},1)
WITH_TIDY=static
endif

ifneq ($(filter ${WITH_TIDY},1 shared static),)
ifeq ($(filter ${WITH_LIBXML},1 shared static),)
$(error TIDY REQUIRES WITH_LIBXML=[1|share|static]. PLEASE CHECK YOUR .env FILE.)
endif
endif

ifeq (${WITH_TIDY},static)
ARCHIVES+= lib/lib/libtidy.a
CONFIGURE_FLAGS+= --with-tidy=/src/lib
TEST_LIST+=$(shell ls packages/tidy/test/*.mjs)
endif

ifeq (${WITH_TIDY},shared)
CONFIGURE_FLAGS+= --with-tidy=/src/lib
PHP_CONFIGURE_DEPS+= lib/lib/libtidy.so
SHARED_LIBS+= lib/lib/libtidy.so
TEST_LIST+=$(shell ls packages/libxml/test/*.mjs)
SKIP_LIBS+=- -ltidy
endif

third_party/tidy-html5/.gitignore:
	@ echo -e "\e[33;4mDownloading LibTidy\e[0m"
	${DOCKER_RUN} git clone https://github.com/htacg/tidy-html5.git third_party/tidy-html5 \
		--branch ${TIDYHTML_TAG} \
		--single-branch     \
		--depth 1;
	${DOCKER_RUN_IN_TIDY} git apply --no-index ../../patch/tidy-html.patch

lib/lib/libtidy.a: third_party/tidy-html5/.gitignore
	@ echo -e "\e[33;4mBuilding LibTidy\e[0m"
	${DOCKER_RUN_IN_TIDY} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="-I/emsdk/upstream/emscripten/system/lib/libc/musl/include/ -fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} "
	${DOCKER_RUN_IN_TIDY} emmake make -j${CPU_COUNT};
	${DOCKER_RUN_IN_TIDY} emmake make install;

lib/lib/libtidy.so:  third_party/tidy-html5/.gitignore
	@ echo -e "\e[33;4mBuilding LibTidy\e[0m"
	${DOCKER_RUN_IN_TIDY} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_SHARED_LIB:BOOL=true \
		-DCMAKE_PROJECT_INCLUDE=/src/source/force-shared.cmake \
		-DCMAKE_C_FLAGS="-I/emsdk/upstream/emscripten/system/lib/libc/musl/include/ -fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} "
	${DOCKER_RUN_IN_TIDY} emmake make -j${CPU_COUNT};
	${DOCKER_RUN_IN_TIDY} emmake make install;

packages/tidy/libtidy.so: lib/lib/libtidy.so
	cp -rL $^ $@
