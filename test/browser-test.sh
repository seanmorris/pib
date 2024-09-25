#!/usr/bin/env bash

set -x;

PORT=3000

pushd demo-web && {
	kill $(lsof -t -i:${PORT});
	npx webpack --config service-worker-dev.config.ts && PORT=${PORT} BROWSER=none npx react-scripts start &
	trap "lsof -t -i:${PORT} | xargs -I{} kill {}" 0;
	ps aux | grep ${SERVER_PID}
};

while ! nc -z localhost ${PORT}; do
	sleep 1
done

popd;

npx cvtest test/BrowserTest.mjs
