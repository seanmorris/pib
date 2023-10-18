#!/usr/bin/env make

ifeq (${WITH_TIDY}, 1)

TIDYHTML_TAG?=5.6.0

ifneq (${WITH_LIBXML}, 1)
$(error TIDY REQUIRES LIBXML. PLEASE CHECK YOUR .env FILE.)
endif

ARCHIVES+= lib/lib/libtidy.a
CONFIGURE_FLAGS+= --with-tidy=/src/lib

lib/lib/libtidy.a: third_party/tidy-html5/.gitignore
	@ echo -e "\e[33;4mBuilding LibTidy\e[0m"
	${DOCKER_RUN_IN_TIDY} emcmake cmake . \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="-I/emsdk/upstream/emscripten/system/lib/libc/musl/include/ -fPIC"
	${DOCKER_RUN_IN_TIDY} emmake make;
	${DOCKER_RUN_IN_TIDY} emmake make install;

third_party/tidy-html5/.gitignore:
	${DOCKER_RUN} git clone https://github.com/htacg/tidy-html5.git third_party/tidy-html5 \
		--branch ${TIDYHTML_TAG} \
		--single-branch     \
		--depth 1;
	${DOCKER_RUN_IN_TIDY} git apply --no-index ../../patch/tidy-html.patch

endif
