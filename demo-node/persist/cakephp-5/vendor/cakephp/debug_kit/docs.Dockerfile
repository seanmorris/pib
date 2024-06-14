# Generate the HTML output.
FROM ghcr.io/cakephp/docs-builder as builder

RUN pip install git+https://github.com/sphinx-contrib/video.git@master

# Copy entire repo in with .git so we can build all versions in one image.
COPY docs /data/docs
ENV LANGS="en fr ja pt"

# Make docs
RUN cd /data/docs-builder \
  && make website LANGS="$LANGS" SOURCE=/data/docs DEST=/data/website \
  # Move media files into the output directory so video elements work.
  && mkdir -p /data/website/html/_static \
  && cp /data/docs/static/* /data/website/html/_static/

# Build a small nginx container with just the static site in it.
FROM ghcr.io/cakephp/docs-builder:runtime as runtime

# Configure search index script
ENV LANGS="en fr ja pt"
ENV SEARCH_SOURCE="/usr/share/nginx/html"
ENV SEARCH_URL_PREFIX="/debugkit/5"

COPY --from=builder /data/docs /data/docs
COPY --from=builder /data/website /data/website
COPY --from=builder /data/docs-builder/nginx.conf /etc/nginx/conf.d/default.conf

# Move files into final location
RUN cp -R /data/website/html/* /usr/share/nginx/html \
  && rm -rf /data/website/
