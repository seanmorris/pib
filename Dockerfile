FROM emscripten/emsdk:3.1.22
RUN apt-get update && \
	apt-get --no-install-recommends -y install \
		build-essential \
		automake \
		autoconf \
		libtool \
		pkgconf \
    python3 \
		bison \
		flex \
		make \
		re2c \
		gdb \
		git \
    libxml2 \
    libxml2-dev \
		pv \
    re2c

SHELL ["/bin/bash", "-c"]
