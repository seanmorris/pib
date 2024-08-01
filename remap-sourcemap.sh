#!/usr/bin/env bash

# SOURCE_MAP=packages/php-wasm/php-node.mjs.wasm.map
# SOURCE_MAP=packages/php-wasm/php-web.mjs.wasm.map
SOURCE_MAP=packages/php-cgi-wasm/php-cgi-worker.js.wasm.map
SOURCE_MAP_DIR=`dirname ${SOURCE_MAP}`

MAPPED=${SOURCE_MAP_DIR}/mapped;
BACKUP=${SOURCE_MAP}.BAK
PHP_VERSION=8.3

if [ -e ${BACKUP} ]; then {
	exit 1;
} fi;

cp ${SOURCE_MAP} ${BACKUP}

mkdir -p ${MAPPED}

jq -r '.sources[] | select( match("^\\.\\./\\.\\./(?!\\.\\.)")) | sub("../../"; "")' < ${SOURCE_MAP} \
| while read SOURCE_FILE; do {
	DIRNAME=`dirname ${SOURCE_FILE}`;
	BASENAME=`basename ${SOURCE_FILE}`;
	DEST_DIR=${MAPPED}/php${PHP_VERSION}/${DIRNAME}/;
	mkdir -p ${DEST_DIR};
	cp third_party/php${PHP_VERSION}-src/${SOURCE_FILE} ${DEST_DIR}${BASENAME};
}; done;

jq -r '.sources[] | select( match("^\\.\\./\\.\\./\\.\\./\\.\\./\\.\\./")) | sub("../../../../../"; "/")' < ${SOURCE_MAP} \
| while read SOURCE_FILE; do {
	DIRNAME=`dirname ${SOURCE_FILE}`;
	BASENAME=`basename ${SOURCE_FILE}`;
	DEST_DIR=${MAPPED}/${DIRNAME}/;
	mkdir -p ${DEST_DIR};
	cp ${SOURCE_FILE} ${DEST_DIR}${BASENAME};
}; done;

sed -i 's|\.\./\.\./\.\./\.\./\.\./|mapped/|g' ${SOURCE_MAP}
sed -i 's|\.\./\.\./|mapped/php'"${PHP_VERSION}"'/|g' ${SOURCE_MAP}
