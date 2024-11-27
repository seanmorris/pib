#!/usr/bin/env bash

NPM_TAG=${1};

if [ -z "${NPM_TAG}" ]; then {
	echo "A tag is required.";
	exit 1;}
fi

echo -e "Getting ready to publish to channel: \033[33m${NPM_TAG}\033[0m"

sleep 3;

set -eu;

ls packages | while read PACKAGE; do {
	if [[ ${PACKAGE} == "sdl" ]]; then
		continue;
	fi;
	echo "Examining ${PACKAGE}...";
	cd "packages/${PACKAGE}";
	jq -r '.files | join("\n")' < package.json | while read FILE; do {
		if [[ ${FILE} == php8.[012]* ]]; then
			continue;
		fi;
		if [[ ${FILE} == "mapped/*" ]] || [[ ${FILE} == *.map ]]; then
			continue;
		fi;
		echo -e "\tChecking for ${FILE}...";
		ls -al "${FILE}" > /dev/null;
	}; done;
	cd "../..";
}; done

set -eux;

ls packages | while read PACKAGE; do {
	if [[ ${PACKAGE} == "sdl" ]]; then
		continue;
	fi;
	cd "packages/${PACKAGE}";
	npm publish --tag ${NPM_TAG};
	cd "../..";
}; done;
