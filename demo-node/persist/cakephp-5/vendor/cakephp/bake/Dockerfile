# Basic docker based environment
# Necessary to trick dokku into building the documentation
# using dockerfile instead of herokuish
FROM ubuntu:22.04

# Add basic tools
RUN apt-get update && \
  apt-get install -y build-essential \
    software-properties-common \
    curl \
    git \
    libxml2 \
    libffi-dev \
    libssl-dev

# Prevent interactive timezone input
ENV DEBIAN_FRONTEND=noninteractive
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
  apt-get update && \
  apt-get install -y php8.1-cli php8.1-mbstring php8.1-xml php8.1-zip php8.1-intl php8.1-opcache php8.1-sqlite

WORKDIR /code

VOLUME ["/code"]

CMD [ '/bin/bash' ]
