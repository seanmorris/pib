FROM emscripten/emsdk:3.1.43
# FROM emscripten/emsdk:latest
MAINTAINER Sean Morris <sean@seanmorr.is>

SHELL ["/bin/bash", "-c"]

RUN set -euxo pipefail;\
	apt-get update; \
	emsdk install latest; \
	apt-get --no-install-recommends -y install \
		build-essential \
		automake \
		libxml2-dev \
		autoconf \
		libtool \
		pkgconf \
		bison \
		flex \
		make \
		re2c \
		gdb \
		git \
		pv
