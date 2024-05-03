#!/usr/bin/env make

ifeq (${WITH_FREETYPE}, 1)

ARCHIVES+= lib/lib/libfreetype.a
CONFIGURE_FLAGS+= \
	--with-freetype

DOCKER_RUN_IN_FREETYPE=${DOCKER_ENV} -w /src/third_party/freetype-2.10.0/build emscripten-builder

third_party/freetype-2.10.0/README:
	${DOCKER_RUN} wget -q https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.gz
	${DOCKER_RUN} tar -xvzf freetype-2.10.0.tar.gz -C third_party
	${DOCKER_RUN} rm freetype-2.10.0.tar.gz

lib/lib/libfreetype.a: third_party/freetype-2.10.0/README
	@ echo -e "\e[33;4mBuilding FREETYPE\e[0m"
	${DOCKER_RUN} rm -rf third_party/freetype-2.10.0/build
	${DOCKER_RUN} mkdir third_party/freetype-2.10.0/build
	${DOCKER_RUN_IN_FREETYPE} emcmake cmake .. \
		-DCMAKE_INSTALL_PREFIX=/src/lib/ \
		-DCMAKE_C_FLAGS=" -fPIC -O${OPTIMIZE}"
	${DOCKER_RUN_IN_FREETYPE} emmake make -j`nproc` EXTRA_CFLAGS='-fPIC -O${OPTIMIZE} '
	${DOCKER_RUN_IN_FREETYPE} emmake make install

endif

