#!/usr/bin/env make

ifeq (${WITH_ICU}, 1)

LIBICU_TAG?=release-72-1
CONFIGURE_FLAGS+= --enable-intl
EXTRA_FLAGS+= -DU_STATIC_IMPLEMENTATION
ARCHIVES+= lib/lib/libicudata.a lib/lib/libicui18n.a lib/lib/libicuio.a lib/lib/libicutest.a lib/lib/libicutu.a lib/lib/libicuuc.a

DOCKER_RUN_IN_LIBICU=${DOCKER_ENV} -w /src/third_party/libicu/icu4c/source emscripten-builder
DOCKER_RUN_IN_LIBICU_ALT=${DOCKER_ENV} -w /src/third_party/libicu/libicu_alt/icu4c/source emscripten-builder
PRELOAD_ASSETS+= lib/share/icu/72.1/icudt72l.dat
PRE_JS_FILES+= packages/libicu/env.js

third_party/libicu/.gitignore:
	@ echo -e "\e[33;4mDownloading LIBICU\e[0m"
	${DOCKER_RUN} git clone https://github.com/unicode-org/icu.git third_party/libicu \
		--branch ${LIBICU_TAG} \
		--single-branch     \
		--depth 1;
	- ${DOCKER_RUN} cp -rf /src/third_party/libicu /src/third_party/libicu/libicu_alt

lib/share/icu/72.1/icudt72l.dat: lib/lib/libicudata.a

lib/lib/libicudata.a: third_party/libicu/.gitignore
	@ echo -e "\e[33;4mBuilding LIBICU\e[0m"
	${DOCKER_RUN_IN_LIBICU_ALT} ./configure --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --disable-shared --with-data-packaging=archive ICU_DATA_FILTER_FILE=/src/packages/libicu/filter.json
	${DOCKER_RUN_IN_LIBICU_ALT} make
	${DOCKER_RUN_IN_LIBICU} emconfigure ./configure --prefix=/src/lib/ --cache-file=/tmp/config-cache --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --disable-shared --with-data-packaging=archive  ICU_DATA_FILTER_FILE=/src/packages/libicu/filter.json
	- ${DOCKER_RUN_IN_LIBICU} emmake make -j`nproc` CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_LIBICU} rm -rf /src/third_party/libicu/icu4c/source/bin /src/third_party/libicu/icu4c/source/data/out/tmp/icudt* /src/third_party/libicu/icu4c/source/data/out/icudt*
	${DOCKER_RUN_IN_LIBICU} cp -rfv /src/third_party/libicu/libicu_alt/icu4c/source/bin /src/third_party/libicu/icu4c/source/
	${DOCKER_RUN_IN_LIBICU} bash -c 'chmod +x /src/third_party/libicu/icu4c/source/bin/*'
	${DOCKER_RUN_IN_LIBICU} emmake make -j`nproc` CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_LIBICU} emmake make install

endif

