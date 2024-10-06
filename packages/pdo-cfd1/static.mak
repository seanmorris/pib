#!/usr/bin/env make

ifdef PDO_CFD1_DEV_PATH
third_party/pdo-cfd1/pdo_cfd1.c: $(wildcard ${PDO_CFD1_DEV_PATH}/*)
	echo -e "\e[33;4mImporting pdo-cfd1\e[0m"
	cp -Lprfv ${PDO_CFD1_DEV_PATH} third_party/pdo-cfd1
	- ${DOCKER_RUN} chown -R $(or ${UID},1000):$(or ${GID},1000) third_party/pdo-cfd1
	touch third_party/pdo-cfd1/pdo_cfd1.c
else
third_party/pdo-cfd1/pdo_cfd1.c:
	@ echo -e "\e[33;4mDownloading and importing pdo-cfd1\e[0m"
	${DOCKER_RUN} git clone https://github.com/seanmorris/pdo-cfd1.git third_party/pdo-cfd1 \
		--branch master \
		--single-branch \
		--depth 1
endif

third_party/php${PHP_VERSION}-src/ext/pdo_cfd1/%: third_party/pdo-cfd1/% third_party/php${PHP_VERSION}-src/patched
	@ echo -e "\e[33;4mimporting pdo_cfd1\e[0m"
	${DOCKER_RUN} cp -TLprfv third_party/pdo-cfd1/ third_party/php${PHP_VERSION}-src/ext/pdo_cfd1
