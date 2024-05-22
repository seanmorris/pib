#!/usr/bin/env make

ifeq (${WITH_GD}, 1)

# GD_TAG?=gd-2.3.3

# ARCHIVES+= \
# 	lib/lib/libgd.a
CONFIGURE_FLAGS+= --enable-gd

DOCKER_RUN_IN_GD=${DOCKER_ENV} -w /src/third_party/gd/ emscripten-builder
TEST_LIST+=$(shell ls packages/gd/test/*.mjs)

# third_party/gd/.gitignore:
# 	@ echo -e "\e[33;4mDownloading GD\e[0m"
# 	${DOCKER_RUN} git clone https://github.com/libgd/libgd.git third_party/gd \
# 		--branch ${GD_TAG} \
# 		--single-branch     \
# 		--depth 1;

# lib/lib/libgd.a: third_party/gd/.gitignore
# 	@ echo -e "\e[33;4mBuilding GD\e[0m"
# 	${DOCKER_RUN_IN_GD} emcmake cmake . \
# 		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
# 		-DCMAKE_BUILD_TYPE=Release \
# 		-DCMAKE_C_FLAGS="-I/emsdk/upstream/emscripten/system/lib/libc/musl/include/ -fPIC -O${OPTIMIZE} "
# 	${DOCKER_RUN_IN_GD} emmake make -j`nproc`;
# 	${DOCKER_RUN_IN_GD} emmake make install;

endif

