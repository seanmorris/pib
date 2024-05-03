#!/usr/bin/env make

ifeq (${WITH_ZLIB}, 1)

ZLIB_TAG?=v1.3.1
# ARCHIVES+= lib/lib/libgd.a
# CONFIGURE_FLAGS+= \
# 	--enable-gd

DOCKER_RUN_IN_ZLIB=${DOCKER_ENV} -w /src/third_party/zlib/ emscripten-builder

third_party/zlib/.gitignore:
	@ echo -e "\e[33;4mDownloading Zlib\e[0m"
	${DOCKER_RUN} git clone https://github.com/madler/zlib.git third_party/zlib \
		--branch ${ZLIB_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libz.a: third_party/zlib/.gitignore
	@ echo -e "\e[33;4mBuilding ZLib\e[0m"
	${DOCKER_RUN_IN_ZLIB} emconfigure ./configure --prefix=/src/lib/ --static
	${DOCKER_RUN_IN_ZLIB} emmake make EMCC_CFLAGS='-fPIC '
	${DOCKER_RUN_IN_ZLIB} emmake make install
	${DOCKER_RUN_IN_ZLIB} chown -R $(or ${UID},1000):$(or ${GID},1000) ./

endif
