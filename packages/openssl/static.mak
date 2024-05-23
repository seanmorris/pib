#!/usr/bin/env make

OPENSSL_TAG?=OpenSSL_1_1_1-stable

ifeq ($(filter ${WITH_OPENSSL},0 1 shared static),)
$(error WITH_OPENSSL MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_OPENSSL},1)
WITH_OPENSSL=static
endif

ifeq (${WITH_OPENSSL},static)
CONFIGURE_FLAGS+= --with-openssl
ARCHIVES+= lib/lib/libssl.a lib/lib/libcrypto.a
DOCKER_RUN_IN_OPENSSL =${DOCKER_ENV} -eCC='emcc -fPIC -O${OPTIMIZE}' -eCXX='emcc -fPIC -O${OPTIMIZE}' -w /src/third_party/openssl/ emscripten-builder
TEST_LIST+=$(shell ls packages/openssl/test/*.mjs)
endif

ifeq (${WITH_OPENSSL},shared)
CONFIGURE_FLAGS+= --with-openssl
SHARED_LIBS+= packages/openssl/libssl.so packages/openssl/libcrypto.so
PHP_CONFIGURE_DEPS+= packages/openssl/libssl.so packages/openssl/libcrypto.so
DOCKER_RUN_IN_OPENSSL =${DOCKER_ENV} -eCC='emcc -fPIC -sSIDE_MODULE=1 -sSHARED_MEMORY -O${OPTIMIZE}' -eCXX='emcc -fPIC -sSIDE_MODULE=1 -O${OPTIMIZE}' -w /src/third_party/openssl/ emscripten-builder
TEST_LIST+=$(shell ls packages/openssl/test/*.mjs)
SKIP_LIBS+= -lssl -lcrypto
ifdef PHP_ASSET_PATH
PHP_ASSET_LIST+= ${PHP_ASSET_PATH}/libssl.so ${PHP_ASSET_PATH}/libcrypto.so
endif
endif

third_party/openssl/.gitignore:
	@ echo -e "\e[33;4mDownloading OpenSSL\e[0m"
	${DOCKER_RUN} git clone https://github.com/openssl/openssl.git third_party/openssl \
		--branch ${OPENSSL_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libssl.a: third_party/openssl/.gitignore
	@ echo -e "\e[33;4mBuilding OpenSSL\e[0m"
	${DOCKER_RUN_IN_OPENSSL} ./config -fPIC --prefix=/src/lib/ no-asm no-engine no-dso no-dgram no-srtp no-stdio no-ui no-err no-ocsp no-psk no-stdio no-ts -DNO_FORK
	${DOCKER_RUN_IN_OPENSSL} emmake make -j${CPU_COUNT} build_generated libssl.a libcrypto.a
	${DOCKER_RUN_IN_OPENSSL} emmake make install_sw

lib/lib/libssl.so: lib/lib/libssl.a
	${DOCKER_RUN_IN_OPENSSL} emcc -shared -o /src/$@ -fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} -Wl,--whole-archive /src/$^

lib/lib/libcrypto.so: lib/lib/libcrypto.a
	${DOCKER_RUN_IN_OPENSSL} emcc -shared -o /src/$@ -fPIC -sSIDE_MODULE=1 -O${OPTIMIZE} -Wl,--whole-archive /src/$^

packages/openssl/libssl.so: lib/lib/libssl.so
	cp -Lp $^ $@

packages/openssl/libcrypto.so: lib/lib/libcrypto.so
	cp -Lp $^ $@

ifdef PHP_ASSET_PATH
${PHP_ASSET_PATH}/libssl.so: packages/openssl/libssl.so
	cp -Lp $^ $@

${PHP_ASSET_PATH}/libcrypto.so: packages/openssl/libcrypto.so
	cp -Lp $^ $@
endif
