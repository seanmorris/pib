#!/usr/bin/env make

ifeq (${WITH_LIBXML}, 1)

LIBXML2_TAG?=v2.9.10
ARCHIVES+= lib/lib/libxml2.a
CONFIGURE_FLAGS+= \
	--enable-libxml \
	--enable-xml  \
	--enable-dom  \
	--enable-simplexml

DOCKER_RUN_IN_LIBXML =${DOCKER_ENV} -w /src/third_party/libxml2/ emscripten-builder
TEST_LIST+=$(shell ls packages/libxml/test/*.mjs)

third_party/libxml2/.gitignore:
	@ echo -e "\e[33;4mDownloading LibXML2\e[0m"
	${DOCKER_RUN} git clone https://gitlab.gnome.org/GNOME/libxml2.git third_party/libxml2 \
		--branch ${LIBXML2_TAG} \
		--single-branch     \
		--depth 1;

lib/lib/libxml2.a: third_party/libxml2/.gitignore
	@ echo -e "\e[33;4mBuilding LibXML2\e[0m"
	${DOCKER_RUN_IN_LIBXML} ./autogen.sh
	${DOCKER_RUN_IN_LIBXML} emconfigure ./configure --with-http=no --with-ftp=no --with-python=no --with-threads=no --enable-shared=no --prefix=/src/lib/ --cache-file=/tmp/config-cache
	${DOCKER_RUN_IN_LIBXML} emmake make -j`nproc` EXTRA_CFLAGS='-fPIC  -O${OPTIMIZE} '
	${DOCKER_RUN_IN_LIBXML} emmake make install

endif

