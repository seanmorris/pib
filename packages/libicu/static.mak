#!/usr/bin/env make

LIBICU_VERSION=72-1
LIBICU_TAG?=release-${LIBICU_VERSION}
LIBICU_DATFILE=lib/share/icu/72.1/icudt72l.dat
DOCKER_RUN_IN_LIBICU=${DOCKER_ENV} -e EMCC_CFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}' -w /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source emscripten-builder
DOCKER_RUN_IN_LIBICU_ALT=${DOCKER_ENV} -e EMCC_CFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}' -w /src/third_party/libicu-${LIBICU_VERSION}/libicu_alt/icu4c/source emscripten-builder
ifeq (${PHP_VERSION},7.4)
LIBICU_VERSION=69-1
LIBICU_DATFILE=lib/share/icu/69.1/icudt69l.dat
endif

ifeq ($(filter ${WITH_ICU},0 1 shared static),)
$(error WITH_ICU MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_ICU},1)
WITH_ICU=static
endif

ifneq ($(filter ${WITH_ICU},shared static),)
CONFIGURE_FLAGS+=--enable-intl
PRELOAD_ASSETS+=${LIBICU_DATFILE}
PRE_JS_FILES+=packages/libicu/env.js
# TEST_LIST+=$(shell ls packages/libicu/test/*.mjs)
TEST_LIST+=packages/libicu/test/basic.mjs $(addprefix packages/libicu/test/,$(addsuffix .generated.mjs, badargs breakiter_clone_basic breakiter_first_basic breakiter_setText_basic calendar_add_basic calendar_get_basic))
endif

ifeq (${WITH_ICU},static)
EXTRA_FLAGS+=-DU_STATIC_IMPLEMENTATION
ARCHIVES+=lib/lib/libicudata.a lib/lib/libicui18n.a lib/lib/libicuio.a lib/lib/libicutest.a lib/lib/libicutu.a lib/lib/libicuuc.a
endif

ifeq (${WITH_ICU},shared)
SKIP_LIBS+= -licuio -licui18n -licuuc -licudata
PHP_CONFIGURE_DEPS+= packages/libicu/libicudata.so packages/libicu/libicui18n.so packages/libicu/libicuio.so packages/libicu/libicutest.so packages/libicu/libicutu.so packages/libicu/libicuuc.so
SHARED_LIBS+= packages/libicu/libicudata.so packages/libicu/libicui18n.so packages/libicu/libicuio.so packages/libicu/libicutest.so packages/libicu/libicutu.so packages/libicu/libicuuc.so
PHP_ASSET_LIST+= libicudata.so libicui18n.so libicuio.so libicutest.so libicutu.so libicuuc.so
endif

third_party/libicu-${LIBICU_VERSION}/.gitignore:
	@ echo -e "\e[33;4mDownloading LIBICU\e[0m"
	${DOCKER_RUN} git clone https://github.com/unicode-org/icu.git third_party/libicu-${LIBICU_VERSION} \
		--branch ${LIBICU_TAG} \
		--single-branch     \
		--depth 1;
	${DOCKER_RUN} cp -rf /src/third_party/libicu-${LIBICU_VERSION} /src/third_party/libicu_alt
	${DOCKER_RUN} mv /src/third_party/libicu_alt /src/third_party/libicu-${LIBICU_VERSION}
	${DOCKER_RUN_IN_LIBICU} git apply --no-index ../../../../patch/libicu.patch

${LIBICU_DATFILE}: lib/lib/libicudata.a

ICU_DATA_FILTER_FILE=/src/packages/libicu/filter.json

lib/lib/libicudata.a: third_party/libicu-${LIBICU_VERSION}/.gitignore
	@ echo -e "\e[33;4mBuilding LIBICU\e[0m"
	${DOCKER_RUN_IN_LIBICU_ALT} ./configure --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --disable-shared --with-data-packaging=archive
	${DOCKER_RUN_IN_LIBICU_ALT} make -ej${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} emconfigure ./configure --prefix=/src/lib/ --cache-file=/tmp/config-cache --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --disable-shared --with-data-packaging=archive ICU_DATA_FILTER_FILE=${ICU_DATA_FILTER_FILE}
	- ${DOCKER_RUN_IN_LIBICU} emmake make -ej${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} rm -rf /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/tmp/icudt* /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/icudt*
	${DOCKER_RUN_IN_LIBICU} cp -rfv /src/third_party/libicu-${LIBICU_VERSION}/libicu_alt/icu4c/source/bin /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/
	${DOCKER_RUN_IN_LIBICU} bash -c 'chmod +x /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin/*'
	${DOCKER_RUN_IN_LIBICU} emmake make -ej${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} emmake make install

lib/lib/libicudata.so: third_party/libicu-${LIBICU_VERSION}/.gitignore
	@ echo -e "\e[33;4mBuilding LIBICU\e[0m"
	${DOCKER_RUN_IN_LIBICU_ALT} ./configure --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --disable-shared --with-data-packaging=archive
	${DOCKER_RUN_IN_LIBICU_ALT} make -ej${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} emconfigure ./configure --prefix=/src/lib/ --cache-file=/tmp/config-cache --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --enable-shared --with-data-packaging=archive ICU_DATA_FILTER_FILE=${ICU_DATA_FILTER_FILE}
	- ${DOCKER_RUN_IN_LIBICU} emmake make -ej${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} rm -rf /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/tmp/icudt* /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/icudt*
	${DOCKER_RUN_IN_LIBICU} cp -rfv /src/third_party/libicu-${LIBICU_VERSION}/libicu_alt/icu4c/source/bin /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/
	${DOCKER_RUN_IN_LIBICU} bash -c 'chmod +x /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin/*'
	${DOCKER_RUN_IN_LIBICU} emmake make -ej${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} emmake make install

icu-clean:
	${DOCKER_RUN_IN_LIBICU} make clean
	${DOCKER_RUN} rm -rf lib/lib/libicu*

packages/libicu/libicui18n.so: lib/lib/libicui18n.so
	cp -Lp $^ $@

packages/libicu/libicuio.so: lib/lib/libicuio.so
	cp -Lp $^ $@

packages/libicu/libicutest.so: lib/lib/libicutest.so
	cp -Lp $^ $@

packages/libicu/libicutu.so: lib/lib/libicutu.so
	cp -Lp $^ $@

packages/libicu/libicuuc.so: lib/lib/libicuuc.so
	cp -Lp $^ $@

packages/libicu/libicudata.so: lib/lib/libicudata.so
	cp -Lp $^ $@

$(addsuffix /libicui18n.so,$(sort ${SHARED_ASSET_PATHS})): packages/libicu/libicui18n.so
	cp -Lp $^ $@

$(addsuffix /libicuio.so,$(sort ${SHARED_ASSET_PATHS})): packages/libicu/libicuio.so
	cp -Lp $^ $@

$(addsuffix /libicutest.so,$(sort ${SHARED_ASSET_PATHS})): packages/libicu/libicutest.so
	cp -Lp $^ $@

$(addsuffix /libicutu.so,$(sort ${SHARED_ASSET_PATHS})): packages/libicu/libicutu.so
	cp -Lp $^ $@

$(addsuffix /libicuuc.so,$(sort ${SHARED_ASSET_PATHS})): packages/libicu/libicuuc.so
	cp -Lp $^ $@

$(addsuffix /libicudata.so,$(sort ${SHARED_ASSET_PATHS})): packages/libicu/libicudata.so
	cp -Lp $^ $@

packages/libicu/test/%.generated.mjs: third_party/php8.3-src/ext/intl/tests/%.phpt
	node bin/translate-test.js $^ > $@
