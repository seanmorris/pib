#!/usr/bin/env make

ifeq (${WITH_ICU}, 1)

ICU_TAG ?=release-74-rc
CONFIGURE_FLAGS+= --with-icu=/src/lib
ARCHIVES+=

third_party/libicu-src/.gitignore:
	${DOCKER_RUN} git clone https://github.com/unicode-org/icu.git third_party/libicu-src \
		--branch ${ICU_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libicudata.a: third_party/libicu-src/.gitignore
	@ echo -e "\e[33;4mBuilding LibIcu\e[0m"
	${DOCKER_RUN_IN_ICU} emconfigure ./configure --prefix=/src/lib/ --enable-icu-config --enable-extras=no --enable-tools=no --enable-samples=no --enable-tests=no --enable-shared=no --enable-static=yes
	${DOCKER_RUN_IN_ICU} emmake make clean install
endif
