FROM emscripten/emsdk:3.1.61
MAINTAINER Sean Morris <sean@seanmorr.is>

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get update; \
	DEBIAN_FRONTEND=noninteractive \
	apt-get --no-install-recommends -y install \
		build-essential \
		automake \
		autoconf \
		autogen \
		libtool \
		gettext \
		shtool \
		brotli \
		pkgconf \
		gperf \
		groff \
		bison \
		flex \
		gzip \
		make \
		re2c \
		gdb \
		git \
		sed \
		pv

# RUN emsdk install tot; \
# 	emsdk activate tot;

RUN cd /emsdk/upstream && { \
	rm -rf emscripten; \
	git clone https://github.com/seanmorris/emscripten.git emscripten --branch sm-updates --depth=1; \
	cd emscripten && ./bootstrap; \
}

RUN emsdk install node-18.20.3-64bit; \
	emsdk activate node-18.20.3-64bit; \
	emsdk update; \
	source /emsdk/emsdk_env.sh;

# COPY ./emscripten /emsdk/upstream/emscripten
# RUN git config --global --add safe.directory /emsdk/upstream/emscripten
# RUN cd /emsdk/upstream/emscripten && ./bootstrap;

RUN emcc --check
