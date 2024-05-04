#!/usr/bin/env make

ifeq (${WITH_OPENSSL}, 1)

OPENSSL_TAG?=OpenSSL_1_1_1-stable
ARCHIVES+= lib/lib/libssl.a lib/lib/libcrypto.a
CONFIGURE_FLAGS+= \
	--with-openssl

DOCKER_RUN_IN_OPENSSL =${DOCKER_ENV} -eCC=emcc -eCXX=emcc -w /src/third_party/openssl/ emscripten-builder

TEST_LIST+=$(shell ls packages/openssl/test/*.mjs)

third_party/openssl/.gitignore:
	@ echo -e "\e[33;4mDownloading OpenSSL\e[0m"
	${DOCKER_RUN} git clone https://github.com/openssl/openssl.git third_party/openssl \
		--branch ${OPENSSL_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libssl.a: third_party/openssl/.gitignore
	@ echo -e "\e[33;4mBuilding OpenSSL\e[0m"
	${DOCKER_RUN_IN_OPENSSL} ./config -fPIC --prefix=/src/lib/ no-asm no-engine no-dso no-dgram no-srtp no-stdio no-ui no-err no-ocsp no-psk no-stdio no-ts -DNO_FORK -static --static
	${DOCKER_RUN_IN_OPENSSL} emmake make -j`nproc` build_generated libssl.a libcrypto.a
	${DOCKER_RUN_IN_OPENSSL} emmake make install_sw

endif

