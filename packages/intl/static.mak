#!/usr/bin/env make

LIBICU_VERSION=72-1
LIBICU_TAG?=release-${LIBICU_VERSION}
LIBICU_DATFILE=lib/share/icu/72.1/icudt72l.dat
DOCKER_RUN_IN_LIBICU=${DOCKER_ENV} -w /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source emscripten-builder
DOCKER_RUN_IN_EXT_INTL=${DOCKER_ENV} -w /src/third_party/php${PHP_VERSION}-intl emscripten-builder
DOCKER_RUN_IN_LIBICU_ALT=${DOCKER_ENV} -w /src/third_party/libicu-${LIBICU_VERSION}/libicu_alt/icu4c/source emscripten-builder
ifeq (${PHP_VERSION},7.4)
LIBICU_VERSION=69-1
LIBICU_DATFILE=lib/share/icu/69.1/icudt69l.dat
endif

ifeq ($(filter ${WITH_INTL},0 1 shared static dynamic),)
$(error WITH_INTL MUST BE 0, 1, static, shared, or dynamic. PLEASE CHECK YOUR SETTINGS FILE: $(abspath ${ENV_FILE}))
endif

ifeq (${WITH_INTL},1)
WITH_INTL=static
endif

ifneq ($(filter ${WITH_INTL},shared static dynamic),)
# PRELOAD_ASSETS+=${LIBICU_DATFILE}
PRE_JS_FILES+=packages/intl/env.js
TEST_LIST+=$(shell ls packages/intl/test/*.mjs)
# TEST_LIST+= packages/intl/test/basic.mjs $(addprefix packages/intl/test/,$(addsuffix .php${PHP_VERSION}.generated.mjs, badargs breakiter_clone_basic breakiter_first_basic breakiter_setText_basic calendar_add_basic calendar_get_basic))
endif

ifeq (${WITH_INTL},static)
PRELOAD_ASSETS+=${LIBICU_DATFILE}
CONFIGURE_FLAGS+=--enable-intl
EXTRA_FLAGS+=-DU_STATIC_IMPLEMENTATION
ARCHIVES+=lib/lib/libicudata.a lib/lib/libicui18n.a lib/lib/libicuio.a lib/lib/libicutest.a lib/lib/libicutu.a lib/lib/libicuuc.a
SKIP_LIBS+= -licuio -licui18n -licuuc -licudata
endif

ifeq (${WITH_INTL},shared)
PRELOAD_ASSETS+=${LIBICU_DATFILE}
CONFIGURE_FLAGS+=--enable-intl
PHP_CONFIGURE_DEPS+= packages/intl/libicudata.so packages/intl/libicui18n.so packages/intl/libicuio.so packages/intl/libicutest.so packages/intl/libicutu.so packages/intl/libicuuc.so
SHARED_LIBS+= packages/intl/libicudata.so packages/intl/libicui18n.so packages/intl/libicuio.so packages/intl/libicutest.so packages/intl/libicutu.so packages/intl/libicuuc.so
PHP_ASSET_LIST+= libicudata.so libicui18n.so libicuio.so libicutest.so libicutu.so libicuuc.so php${PHP_VERSION}-intl.so $(notdir ${LIBICU_DATFILE})
SKIP_LIBS+= -licuio -licui18n -licuuc -licudata
endif

ifeq (${WITH_INTL},dynamic)
SKIP_LIBS+= -licuio -licui18n -licuuc -licudata
PHP_ASSET_LIST+= libicudata.so libicui18n.so libicuio.so libicutest.so libicutu.so libicuuc.so php${PHP_VERSION}-intl.so $(notdir ${LIBICU_DATFILE})
endif

third_party/libicu-${LIBICU_VERSION}/.gitignore:
	@ echo -e "\e[33;4mDownloading LIBICU\e[0m"
	${DOCKER_RUN} git clone https://github.com/unicode-org/icu.git third_party/libicu-${LIBICU_VERSION} \
		--branch ${LIBICU_TAG} \
		--single-branch     \
		--depth 1;
	${DOCKER_RUN} cp -rf /src/third_party/libicu-${LIBICU_VERSION} /src/third_party/libicu_alt
	${DOCKER_RUN} mv /src/third_party/libicu_alt /src/third_party/libicu-${LIBICU_VERSION}

third_party/llvm/.gitignore:
	@ echo -e "\e[33;4mDownloading LLVM\e[0m"
	${DOCKER_RUN} git clone https://github.com/emscripten-core/llvm-project.git third_party/llvm \
		--branch main \
		--single-branch     \
		--depth 1;

${LIBICU_DATFILE}: lib/lib/libicudata.a

ICU_DATA_FILTER_FILE=/src/packages/intl/filter.json

lib/share/icu/72.1/icudt72l.dat: lib/lib/libicudata.a
	${DOCKER_RUN_IN_LIBICU} emmake make -C data -j${CPU_COUNT} install

lib/lib/libicudata.a: lib/lib/libicuuc.a

lib/lib/libicui18n.a: lib/lib/libicuuc.a

lib/lib/libicuio.a: lib/lib/libicuuc.a

lib/lib/libicutest.a: lib/lib/libicuuc.a

lib/lib/libicutu.a: lib/lib/libicuuc.a

lib/lib/libicuuc.a: third_party/libicu-${LIBICU_VERSION}/.gitignore
	@ echo -e "\e[33;4mBuilding LIBICU\e[0m"
	${DOCKER_RUN_IN_LIBICU_ALT} ./configure \
		--with-data-packaging=archive \
		--without-assembly \
		--disable-draft    \
		--disable-extras   \
		--disable-layoutex \
		--disable-tests    \
		--disable-samples  \
		--enable-static    \
		--disable-shared   \
		CFLAGS='-O0' \
		CXXFLAGS='-O0'
	${DOCKER_RUN_IN_LIBICU_ALT} make -ej${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} emconfigure ./configure \
		--cache-file=/tmp/config-cache \
		--with-data-packaging=archive \
		--prefix=/src/lib/ \
		--without-assembly \
		--disable-draft    \
		--disable-extras   \
		--disable-layoutex \
		--disable-tests    \
		--disable-samples  \
		--enable-static    \
		--disable-shared   \
		ICU_DATA_FILTER_FILE=${ICU_DATA_FILTER_FILE} \
		CFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}' \
		CXXFLAGS='-fPIC -flto -O${SUB_OPTIMIZE}'
	- ${DOCKER_RUN_IN_LIBICU} emmake make -j${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} rm -rf \
		/src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin \
		/src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/tmp/icudt* \
		/src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/data/out/icudt*
	${DOCKER_RUN_IN_LIBICU} cp -rfv \
		/src/third_party/libicu-${LIBICU_VERSION}/libicu_alt/icu4c/source/bin \
		/src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/
	${DOCKER_RUN_IN_LIBICU} bash -c 'chmod +x /src/third_party/libicu-${LIBICU_VERSION}/icu4c/source/bin/*'
	${DOCKER_RUN_IN_LIBICU} emmake make -j${CPU_COUNT}
	${DOCKER_RUN_IN_LIBICU} emmake make install

lib/lib/libicui18n.so: lib/lib/libicui18n.a
	${DOCKER_RUN_IN_LIBICU} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

lib/lib/libicuio.so: lib/lib/libicuio.a
	${DOCKER_RUN_IN_LIBICU} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

lib/lib/libicutest.so: lib/lib/libicutest.a
	${DOCKER_RUN_IN_LIBICU} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

lib/lib/libicutu.so: lib/lib/libicutu.a
	${DOCKER_RUN_IN_LIBICU} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

lib/lib/libicuuc.so: lib/lib/libicuuc.a
	${DOCKER_RUN_IN_LIBICU} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

lib/lib/libicudata.so: lib/lib/libicudata.a
	${DOCKER_RUN_IN_LIBICU} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive /src/$^

packages/intl/libicui18n.so: lib/lib/libicui18n.so
	cp -Lp $^ $@

packages/intl/libicuio.so: lib/lib/libicuio.so
	cp -Lp $^ $@

packages/intl/libicutest.so: lib/lib/libicutest.so
	cp -Lp $^ $@

packages/intl/libicutu.so: lib/lib/libicutu.so
	cp -Lp $^ $@

packages/intl/libicuuc.so: lib/lib/libicuuc.so
	cp -Lp $^ $@

packages/intl/libicudata.so: lib/lib/libicudata.so
	cp -Lp $^ $@

packages/intl/$(notdir ${LIBICU_DATFILE}): ${LIBICU_DATFILE}
	cp -Lp $^ $@

$(addsuffix /libicui18n.so,$(sort ${SHARED_ASSET_PATHS})): packages/intl/libicui18n.so
	cp -Lp $^ $@

$(addsuffix /libicuio.so,$(sort ${SHARED_ASSET_PATHS})): packages/intl/libicuio.so
	cp -Lp $^ $@

$(addsuffix /libicutest.so,$(sort ${SHARED_ASSET_PATHS})): packages/intl/libicutest.so
	cp -Lp $^ $@

$(addsuffix /libicutu.so,$(sort ${SHARED_ASSET_PATHS})): packages/intl/libicutu.so
	cp -Lp $^ $@

$(addsuffix /libicuuc.so,$(sort ${SHARED_ASSET_PATHS})): packages/intl/libicuuc.so
	cp -Lp $^ $@

$(addsuffix /libicudata.so,$(sort ${SHARED_ASSET_PATHS})): packages/intl/libicudata.so
	cp -Lp $^ $@

$(addsuffix /$(notdir ${LIBICU_DATFILE}),$(sort ${SHARED_ASSET_PATHS})): packages/intl/$(notdir ${LIBICU_DATFILE})
	cp -Lp $^ $@

packages/intl/test/%.php${PHP_VERSION}.generated.mjs: third_party/php${PHP_VERSION}-src/ext/intl/tests/%.phpt
	node bin/translate-test.js --file $^ --phpVersion ${PHP_VERSION} --buildType static > $@

third_party/php${PHP_VERSION}-intl/config.m4: third_party/php${PHP_VERSION}-src/patched
	${DOCKER_RUN} cp -Lprf /src/third_party/php${PHP_VERSION}-src/ext/intl /src/third_party/php${PHP_VERSION}-intl

packages/intl/php${PHP_VERSION}-intl.so: ${PHPIZE} packages/intl/libicudata.so third_party/php${PHP_VERSION}-intl/config.m4
	@ echo -e "\e[33;4mBuilding php-intl\e[0m"
	${DOCKER_RUN_IN_EXT_INTL} chmod +x /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_INTL} /src/third_party/php${PHP_VERSION}-src/scripts/phpize;
	${DOCKER_RUN_IN_EXT_INTL} emconfigure ./configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix='/src/lib/php${PHP_VERSION}' --with-php-config=/src/lib/php${PHP_VERSION}/bin/php-config --cache-file=/tmp/config-cache;
	${DOCKER_RUN_IN_EXT_INTL} sed -i 's#-shared#-static#g' Makefile;
	${DOCKER_RUN_IN_EXT_INTL} sed -i 's#-export-dynamic##g' Makefile;
	${DOCKER_RUN_IN_EXT_INTL} emmake make -j${CPU_COUNT} EXTRA_INCLUDES='-I/src/third_party/php${PHP_VERSION}-src';
	${DOCKER_RUN_IN_EXT_INTL} emcc -shared -o /src/$@ -fPIC -flto -sSIDE_MODULE=1 -O${SUB_OPTIMIZE} -Wl,--whole-archive .libs/intl.a \
		/src/packages/intl/libicudata.so \
		/src/packages/intl/libicuuc.so \
		/src/packages/intl/libicui18n.so  \
		/src/packages/intl/libicuio.so \
		/src/packages/intl/libicutu.so \
		/src/packages/intl/libicutest.so

$(addsuffix /php${PHP_VERSION}-intl.so,$(sort ${SHARED_ASSET_PATHS})): packages/intl/php${PHP_VERSION}-intl.so
	cp -Lp $^ $@
