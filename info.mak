#!/usr/bin/env make

.PHONY: get-asset-path get-php-version

ENV_FILE?=.env
-include ${ENV_FILE}

ifdef PHP_BUILDER_DIR
ENV_DIR:=${PHP_BUILDER_DIR}
PHP_ASSET_PATH:=${ENV_DIR}/${PHP_ASSET_PATH}
endif

PHP_ASSET_PATH:=${ENV_DIR}/${PHP_ASSET_PATH}

get-asset-path:
	@ echo $(abspath ${PHP_ASSET_PATH});

get-php-version:
	@ echo ${PHP_VERSION};
