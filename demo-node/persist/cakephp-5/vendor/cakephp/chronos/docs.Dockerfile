# Generate the HTML output.
FROM ghcr.io/cakephp/docs-builder as builder

RUN pip install git+https://github.com/sphinx-contrib/video.git@master

COPY docs /data/docs
ENV LANGS="en fr ja pt"

# build docs with sphinx
RUN cd /data/docs-builder && \
  make website LANGS="$LANGS" SOURCE=/data/docs DEST=/data/website

# Build a small nginx container with just the static site in it.
FROM ghcr.io/cakephp/docs-builder:runtime as runtime

ENV LANGS="en fr ja pt"
ENV SEARCH_SOURCE="/usr/share/nginx/html"
ENV SEARCH_URL_PREFIX="/chronos/3"

COPY --from=builder /data/docs /data/docs
COPY --from=builder /data/website /data/website
COPY --from=builder /data/docs-builder/nginx.conf /etc/nginx/conf.d/default.conf

# Move docs into place.
RUN cp -R /data/website/html/* /usr/share/nginx/html \
  && rm -rf /data/website
