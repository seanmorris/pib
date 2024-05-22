#!/usr/bin/env make

ZLIB_TAG?=v1.3.1
DOCKER_RUN_IN_ZLIB=${DOCKER_ENV} -w /src/third_party/zlib/ emscripten-builder

ifeq ($(filter ${WITH_ZLIB},0 1 shared static),)
$(error WITH_ZLIB MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR .env FILE.)
endif

ifeq (${WITH_ZLIB},1)
WITH_ZLIB=static
endif

ifeq (${WITH_ZLIB},static)
ARCHIVES+= lib/lib/libz.a
CONFIGURE_FLAGS+= --with-zlib
TEST_LIST+=$(shell ls packages/zlib/test/*.mjs)
endif

ifeq (${WITH_ZLIB},shared)
SHARED_LIBS+= lib/lib/libz.so
TEST_LIST+=$(shell ls packages/zlib/test/*.mjs)
SKIP_LIBS+=- -lz
endif

third_party/zlib/.gitignore:
	@ echo -e "\e[33;4mDownloading Zlib\e[0m"
	${DOCKER_RUN} git clone https://github.com/madler/zlib.git third_party/zlib \
		--branch ${ZLIB_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libz.a: third_party/zlib/.gitignore
	@ echo -e "\e[33;4mBuilding ZLib\e[0m"
	${DOCKER_RUN_IN_ZLIB} emconfigure ./configure --prefix=/src/lib/ --static --shared
	${DOCKER_RUN_IN_ZLIB} emmake make -j${CPU_COUNT} EMCC_CFLAGS='-fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} '
	${DOCKER_RUN_IN_ZLIB} emmake make install
	${DOCKER_RUN_IN_ZLIB} chown -R $(or ${UID},1000):$(or ${GID},1000) ./

lib/lib/libz.so: lib/lib/libz.a

packages/zlib/libz.so: lib/lib/libz.so
	cp $^ $@
