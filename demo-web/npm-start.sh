#/usr/bin/env bash

set -eux;

npx webpack --config service-worker-dev.config.ts;

if [ -d 'public/static/media/mapped' ]; then {
	rm public/static/media/*.map
	rm -rf public/static/media/mapped
}
fi

if [ -d '../packages/php-wasm/mapped' ]; then {
	cp -r ../packages/php-wasm/mapped public/static/media
	cp ../packages/php-wasm/*.map public/static/media
}
fi

if [ -d '../packages/php-cgi-wasm/mapped' ]; then {
	cp -r ../packages/php-cgi-wasm/mapped public/static/media
	cp ../packages/php-cgi-wasm/*.map public/static/media
}
fi

react-scripts start --no-cache
