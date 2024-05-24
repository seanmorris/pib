#!/usr/bin/env make

OPENSSL_TAG?=OpenSSL_1_1_1-stable
DOCKER_RUN_IN_OPENSSL =${DOCKER_ENV} -eCC='emcc -fPIC -flto -O${SUB_OPTIMIZE}' -eCXX='emcc -fPIC -O${SUB_OPTIMIZE}' -w /src/third_party/openssl/ emscripten-builder

ifeq ($(filter ${WITH_OPENSSL},0 1 shared static),)
$(error WITH_OPENSSL MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_OPENSSL},1)
WITH_OPENSSL=static
endif

ifneq ($(filter ${WITH_OPENSSL},shared static),)
TEST_LIST+= packages/openssl/test/basic.mjs $(addprefix packages/openssl/test/,$(addsuffix .generated.mjs,openssl_digest_basic openssl_decrypt_basic))
CONFIGURE_FLAGS+= --with-openssl
endif

ifeq (${WITH_OPENSSL},static)
ARCHIVES+= lib/lib/libssl.a lib/lib/libcrypto.a
endif

ifeq (${WITH_OPENSSL},shared)
SKIP_LIBS+= -lssl -lcrypto
CONFIGURE_FLAGS+= --with-openssl
SHARED_LIBS+= packages/openssl/libssl.so packages/openssl/libcrypto.so
PHP_CONFIGURE_DEPS+= packages/openssl/libssl.so packages/openssl/libcrypto.so
PHP_ASSET_LIST+= libssl.so libcrypto.so
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
	${DOCKER_RUN_IN_OPENSSL} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

lib/lib/libcrypto.so: lib/lib/libcrypto.a
	${DOCKER_RUN_IN_OPENSSL} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

packages/openssl/libssl.so: lib/lib/libssl.so
	cp -Lp $^ $@

packages/openssl/libcrypto.so: lib/lib/libcrypto.so
	cp -Lp $^ $@

$(addsuffix /libcrypto.so,$(sort ${SHARED_ASSET_PATHS})): packages/openssl/libcrypto.so
	cp -Lp $^ $@

$(addsuffix /libssl.so,$(sort ${SHARED_ASSET_PATHS})): packages/openssl/libssl.so
	cp -Lp $^ $@

packages/openssl/test/%.generated.mjs: third_party/php8.3-src/ext/openssl/tests/%.phpt
	node bin/translate-test.js $^ > $@

