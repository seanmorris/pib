#!/usr/bin/env make

ifeq (${WITH_ONIGURUMA},1)

ONIGURUMA_TAG?=v6.9.9
ARCHIVES+= lib/lib/libonig.a
CONFIGURE_FLAGS+= --with-onig

DOCKER_RUN_IN_ONIGURUMA=${DOCKER_ENV} -w /src/third_party/oniguruma/ emscripten-builder

third_party/oniguruma/.gitignore:
	@ echo -e "\e[33;4mDownloading ONIGURUMA\e[0m"
	${DOCKER_RUN} git clone https://github.com/kkos/oniguruma.git third_party/oniguruma \
		--branch ${ONIGURUMA_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libonig.a: third_party/oniguruma/.gitignore
	@ echo -e "\e[33;4mBuilding ONIGURUMA\e[0m"
	${DOCKER_RUN_IN_ONIGURUMA} emconfigure ./autogen.sh
	${DOCKER_RUN_IN_ONIGURUMA} emconfigure ./configure --prefix=/src/lib/ --enable-shared=no --enable-static=yes --cache-file=/tmp/config-cache
	${DOCKER_RUN_IN_ONIGURUMA} emmake make -j`nproc` EMCC_CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_ONIGURUMA} emmake make install

endif
