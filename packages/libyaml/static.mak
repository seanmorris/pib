#!/usr/bin/env make

ifeq (${WITH_YAML},1)

LIBYAML_TAG?=0.2.5
ARCHIVES+= lib/lib/libyaml.a
DEPENDENCIES+= third_party/php${PHP_VERSION}-src/ext/yaml/config.m4
CONFIGURE_FLAGS+= --with-yaml

DOCKER_RUN_IN_YAML=${DOCKER_ENV} -w /src/third_party/libyaml/ emscripten-builder
TEST_LIST+=$(shell ls packages/libyaml/test/*.mjs)

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
	${DOCKER_RUN_IN_YAML} emmake make -j`nproc` EMCC_CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_YAML} emmake make install

third_party/yaml-2.2.3/config.m4:
	@ echo -e "\e[33;4mDownloading ext-yaml\e[0m"
	${DOCKER_RUN} wget -q https://pecl.php.net/get/yaml-2.2.3.tgz
	${DOCKER_RUN} tar -C third_party -xvzf yaml-2.2.3.tgz yaml-2.2.3
	${DOCKER_RUN} rm yaml-2.2.3.tgz

third_party/php${PHP_VERSION}-src/ext/yaml/config.m4: third_party/yaml-2.2.3/config.m4 | third_party/php${PHP_VERSION}-src/patched
	@ echo -e "\e[33;4mImporting libyaml\e[0m"
	${DOCKER_RUN} cp -rfv third_party/yaml-2.2.3 third_party/php${PHP_VERSION}-src/ext/yaml


endif
