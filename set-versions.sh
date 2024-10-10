#!/usr/bin/env bash

set -eux;

function updateFile
{
	local FILE=${1};
	local VERSION=${2};
	jq ".version = \"${VERSION}\"" "${FILE}" > ${FILE}.NEW
	mv ${FILE}.NEW ${FILE}
}

updateFile "package.json" "0.0.9-alpha-18";

ls packages | while read PACKAGE; do {

	updateFile "packages/${PACKAGE}/package.json" "0.0.9-alpha-18";

}; done;
