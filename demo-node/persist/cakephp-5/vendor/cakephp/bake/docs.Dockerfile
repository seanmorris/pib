# Generate the HTML output.
FROM ghcr.io/cakephp/docs-builder as builder

# Copy entire repo in with .git so we can build all versions in one image.
COPY docs /data/docs

RUN cd /data/docs-builder \
  && make website LANGS="en es fr ja pt ru" SOURCE=/data/docs DEST=/data/website/

# Build a small nginx container with just the static site in it.
FROM ghcr.io/cakephp/docs-builder:runtime as runtime

# Configure search index script
ENV LANGS="en es fr ja pt ru"
ENV SEARCH_SOURCE="/usr/share/nginx/html"
ENV SEARCH_URL_PREFIX="/bake/3"

COPY --from=builder /data/docs /data/docs
COPY --from=builder /data/website /data/website
COPY --from=builder /data/docs-builder/nginx.conf /etc/nginx/conf.d/default.conf

# Copy docs into place.
RUN cp -R /data/website/html/* /usr/share/nginx/html \
  && rm -rf /data/website
