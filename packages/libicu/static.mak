#!/usr/bin/env make

ifdef WITH_ICU
ifneq (${WITH_ICU},0)

LIBICU_VERSION=72-1
LIBICU_TAG?=release-${LIBICU_VERSION}
LIBICU_DATFILE=lib/share/icu/72.1/icudt72l.dat
DOCKER_RUN_IN_LIBICU_ALT=${DOCKER_ENV} -w /src/third_party/libicu-${LIBICU_VERSION}/libicu_alt/icu4c/source emscripten-builder

ifeq (${PHP_VERSION},7.4)
LIBICU_VERSION=69-1
LIBICU_DATFILE=lib/share/icu/69.1/icudt69l.dat
endif

ifeq ($(filter ${WITH_ICU},0 1 shared static),)
$(error WITH_ICU MUST BE 0, 1, static OR shared. PLEASE CHECK YOUR .env FILE.)
endif

ifeq (${WITH_ICU},1)
WITH_ICU=static
endif

ifeq (${WITH_ICU},static)
CONFIGURE_FLAGS+= --enable-intl
EXTRA_FLAGS+= -DU_STATIC_IMPLEMENTATION
ARCHIVES+= lib/lib/libicudata.a lib/lib/libicui18n.a lib/lib/libicuio.a lib/lib/libicutest.a lib/lib/libicutu.a lib/lib/libicuuc.a
DOCKER_RUN_IN_LIBICU=${DOCKER_ENV} -e CFLAGS='-fPIC -O${OPTIMIZE}' -e CXXFLAGS='-fPIC -O${OPTIMIZE}' -w /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source emscripten-builder
endif

ifeq (${WITH_ICU},shared)
CONFIGURE_FLAGS+= --enable-intl
PHP_CONFIGURE_DEPS+= lib/lib/libicudata.so
SHARED_LIBS+= lib/lib/libicudata.so lib/lib/libicui18n.so lib/lib/libicuio.so lib/lib/libicutest.so lib/lib/libicutu.so lib/lib/libicuuc.so
DOCKER_RUN_IN_LIBICU=${DOCKER_ENV} -e CFLAGS='-fPIC -sSIDE_MODULE=1 -O${OPTIMIZE}' -e CXXFLAGS='-fPIC -sSIDE_MODULE=1 -O${OPTIMIZE}' -w /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source emscripten-builder
SKIP_LIBS+=- -licuio -licui18n -licuuc -licudata
endif

TEST_LIST+=$(shell ls packages/libicu/test/*.mjs)

PRELOAD_ASSETS+= ${LIBICU_DATFILE}
PRE_JS_FILES+= packages/libicu/env.js
# ZEND_EXTRA_LIBS+=' -lpthread -lm'

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

lib/lib/libicudata.a: third_party/libicu-${LIBICU_VERSION}/.gitignore
	@ echo -e "\e[33;4mBuilding LIBICU\e[0m"
	${DOCKER_RUN_IN_LIBICU_ALT} ./configure --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --disable-shared --with-data-packaging=archive ICU_DATA_FILTER_FILE=/src/packages/libicu/filter.json
	${DOCKER_RUN_IN_LIBICU_ALT} make VERBOSE=1
	${DOCKER_RUN_IN_LIBICU} emconfigure ./configure --prefix=/src/lib/ --cache-file=/tmp/config-cache --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --disable-shared --with-data-packaging=archive ICU_DATA_FILTER_FILE=/src/packages/libicu/filter.json
	- ${DOCKER_RUN_IN_LIBICU} emmake make -ej`nproc` VERBOSE=1
	${DOCKER_RUN_IN_LIBICU} rm -rf /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/tmp/icudt* /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/icudt*
	${DOCKER_RUN_IN_LIBICU} cp -rfv /src/third_party/libicu-${LIBICU_VERSION}/libicu_alt/icu4c/source/bin /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/
	${DOCKER_RUN_IN_LIBICU} bash -c 'chmod +x /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin/*'
	${DOCKER_RUN_IN_LIBICU} emmake make -ej`nproc` VERBOSE=1
	${DOCKER_RUN_IN_LIBICU} emmake make install

lib/lib/libicudata.so: third_party/libicu-${LIBICU_VERSION}/.gitignore
	@ echo -e "\e[33;4mBuilding LIBICU\e[0m"
	${DOCKER_RUN_IN_LIBICU_ALT} ./configure --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --disable-shared --with-data-packaging=archive ICU_DATA_FILTER_FILE=/src/packages/libicu/filter.json
	${DOCKER_RUN_IN_LIBICU_ALT} make VERBOSE=1
	${DOCKER_RUN_IN_LIBICU} emconfigure ./configure --prefix=/src/lib/ --cache-file=/tmp/config-cache --without-assembly --disable-draft --disable-extras --disable-layoutex --disable-tests --disable-samples --enable-static --enable-shared --with-data-packaging=archive ICU_DATA_FILTER_FILE=/src/packages/libicu/filter.json
	- ${DOCKER_RUN_IN_LIBICU} emmake make -ej`nproc` VERBOSE=1
	${DOCKER_RUN_IN_LIBICU} rm -rf /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/tmp/icudt* /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/icudt*
	${DOCKER_RUN_IN_LIBICU} cp -rfv /src/third_party/libicu-${LIBICU_VERSION}/libicu_alt/icu4c/source/bin /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/
	${DOCKER_RUN_IN_LIBICU} bash -c 'chmod +x /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin/*'
	${DOCKER_RUN_IN_LIBICU} emmake make -ej`nproc` VERBOSE=1
	${DOCKER_RUN_IN_LIBICU} emmake make install

icu-clean:
	${DOCKER_RUN_IN_LIBICU} make clean
	${DOCKER_RUN} rm -rf lib/lib/libicu*

demo-source/public/%.so: lib/lib/%.so
	cp -Lp $^ $@

endif
endif
# demo-source/public/libicudata.so demo-source/public/libicui18n.so demo-source/public/libicuio.so demo-source/public/libicutest.so demo-source/public/libicutu.so demo-source/public/libicuuc.so
