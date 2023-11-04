#!/usr/bin/env make

ifeq (${WITH_VRZNO}, 1)

VRZNO_BRANCH ?=DomAccess8.2
EXTRA_FLAGS+= -D WITH_VRZNO=1
PHP_CONFIGURE_DEPS+= third_party/php${PHP_VERSION}-src/ext/vrzno/config.m4
CONFIGURE_FLAGS+= --enable-vrzno
PHP_ARCHIVE_DEPS+= third_party/php${PHP_VERSION}-src/ext/vrzno/vrzno.c

# VRZNO_DEV_PATH?=

ifdef VRZNO_DEV_PATH
third_party/vrzno/vrzno.c: ${VRZNO_DEV_PATH}/*.c
	@ echo -e "\e[33;4mImporting VRZNO\e[0m"
	@ cp -prfv ${VRZNO_DEV_PATH} third_party/
	${DOCKER_RUN} touch third_party/vrzno/vrzno.c
else
third_party/vrzno/vrzno.c:
	@ echo -e "\e[33;4mDownloading and importing VRZNO\e[0m"
	${DOCKER_RUN} git clone https://github.com/seanmorris/vrzno.git third_party/vrzno \
		--branch ${VRZNO_BRANCH} \
		--single-branch          \
		--depth 1
endif

third_party/php${PHP_VERSION}-src/ext/vrzno/vrzno.c: third_party/vrzno/vrzno.c third_party/php${PHP_VERSION}-src/.gitignore
	@ ${DOCKER_RUN} cp -prf third_party/vrzno third_party/php${PHP_VERSION}-src/ext/

third_party/php${PHP_VERSION}-src/ext/vrzno/config.m4: third_party/vrzno/vrzno.c third_party/php${PHP_VERSION}-src/.gitignore
	@ ${DOCKER_RUN} cp -prf third_party/vrzno third_party/php${PHP_VERSION}-src/ext/

endif
