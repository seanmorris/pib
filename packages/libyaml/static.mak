#!/usr/bin/env make

LIBYAML_TAG?=0.2.5
DOCKER_RUN_IN_YAML=${DOCKER_ENV} -e EMCC_CFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}' -w /src/third_party/libyaml/ emscripten-builder

ifeq ($(filter ${WITH_YAML},0 1 shared static),)
$(error WITH_YAML MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_YAML},1)
WITH_YAML=static
endif

ifeq (${WITH_YAML},static)
ARCHIVES+= lib/lib/libyaml.a
PHP_CONFIGURE_DEPS+= third_party/php${PHP_VERSION}-src/ext/yaml/config.m4
CONFIGURE_FLAGS+= --with-yaml
TEST_LIST+=$(shell ls packages/libyaml/test/*.mjs)
endif

ifeq (${WITH_YAML},shared)
SHARED_LIBS+= lib/lib/libyaml.so
CONFIGURE_FLAGS+= --with-yaml
PHP_CONFIGURE_DEPS+= packages/libyaml/libyaml.so third_party/php${PHP_VERSION}-src/ext/yaml/config.m4
TEST_LIST+=$(shell ls packages/libyaml/test/*.mjs)
SKIP_LIBS+=- -lyaml
PHP_ASSET_LIST+= libyaml.so
endif

third_party/libyaml/.gitignore:
	@ echo -e "\e[33;4mDownloading libyaml\e[0m"
	${DOCKER_RUN} git clone https://github.com/yaml/libyaml.git third_party/libyaml \
		--branch ${LIBYAML_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libyaml.a: third_party/libyaml/.gitignore
	@ echo -e "\e[33;4mBuilding libyaml\e[0m"
	${DOCKER_RUN_IN_YAML} emconfigure ./bootstrap
	${DOCKER_RUN_IN_YAML} emconfigure ./configure --prefix=/src/lib/ --enable-shared=no --enable-static=yes --cache-file=/tmp/config-cache
	${DOCKER_RUN_IN_YAML} emmake make -j${CPU_COUNT}
	${DOCKER_RUN_IN_YAML} emmake make install

lib/lib/libyaml.so: lib/lib/libyaml.a
	${DOCKER_RUN_IN_YAML} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

third_party/yaml-2.2.3/config.m4:
	@ echo -e "\e[33;4mDownloading ext-yaml\e[0m"
	${DOCKER_RUN} wget -q https://pecl.php.net/get/yaml-2.2.3.tgz
	${DOCKER_RUN} tar -C third_party -xvzf yaml-2.2.3.tgz yaml-2.2.3
	${DOCKER_RUN} rm yaml-2.2.3.tgz

third_party/php${PHP_VERSION}-src/ext/yaml/config.m4: third_party/yaml-2.2.3/config.m4 | third_party/php${PHP_VERSION}-src/patched
	@ echo -e "\e[33;4mImporting libyaml\e[0m"
	${DOCKER_RUN} cp -rfv third_party/yaml-2.2.3 third_party/php${PHP_VERSION}-src/ext/yaml

packages/libyaml/libyaml.so: lib/lib/libyaml.so
	cp $^ $@

$(addsuffix /libyaml.so,$(sort ${SHARED_ASSET_PATHS})): packages/libyaml/libyaml.so
	cp -Lp $^ $@

# lib/lib/php/20230831/yaml.so: ${PHPIZE} lib/lib/libyaml.so third_party/php${PHP_VERSION}-src/ext/yaml/config.m4
# 	${DOCKER_RUN_IN_PHP} bash -euxc 'cd ext/yaml && { \
# 		../../scripts/phpize; \
# 		emconfigure ./configure --with-php-config=/src/lib/bin/php-config PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix=/src/lib/; \
# 		emmake make EXTRA_INCLUDES='-I/src/third_party/php8.3-src'; \
# 		emmake make install; \
# 	};'

# packages/libyaml/php-yaml.so: lib/lib/php/20230831/yaml.so
# 	cp $^ $@
