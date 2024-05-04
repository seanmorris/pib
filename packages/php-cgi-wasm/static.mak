ifeq (${WITH_CGI},1)

CGI_MJS=$(addprefix packages/php-cgi-wasm/,php-cgi-web.mjs php-cgi-webview.mjs php-cgi-node.mjs php-cgi-shell.mjs php-cgi-worker.mjs) \
	$(addprefix packages/php-cgi-wasm/,PhpCgiWeb.mjs PhpCgiWebview.mjs PhpCgiNode.mjs PhpCgiShell.mjs PhpCgiWorker.mjs) \
	$(addprefix packages/php-cgi-wasm/,webTransactions.mjs breakoutRequest.mjs parseResponse.mjs)

CGI_CJS=$(addprefix packages/php-cgi-wasm/,php-cgi-web.js php-cgi-webview.js php-cgi-node.js php-cgi-shell.js php-cgi-worker.js) \
	$(addprefix packages/php-cgi-wasm/,PhpCgiWeb.js PhpCgiWebview.js PhpCgiNode.js PhpCgiShell.js PhpCgiWorker.js) \
	$(addprefix packages/php-cgi-wasm/,webTransactions.js breakoutRequest.js parseResponse.js)

webCgiMjs: $(addprefix packages/php-cgi-wasm/,PhpCgiBase.mjs PhpCgiWeb.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-web.mjs)
webCgiJs:  $(addprefix packages/php-cgi-wasm/,PhpCgiBase.js  PhpCgiWeb.js  breakoutRequest.js  parseResponse.js  php-cgi-web.js)

workerCgiMjs: $(addprefix packages/php-cgi-wasm/,PhpCgiBase.mjs PhpCgiWorker.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-worker.mjs)
workerCgiJs:  $(addprefix packages/php-cgi-wasm/,PhpCgiBase.js  PhpCgiWorker.js  breakoutRequest.js  parseResponse.js  php-cgi-worker.js)

nodeCgiMjs: $(addprefix packages/php-cgi-wasm/,PhpCgiBase.mjs PhpCgiNode.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-node.mjs)
nodeCgiJs:  $(addprefix packages/php-cgi-wasm/,PhpCgiBase.js  PhpCgiNode.js  breakoutRequest.js  parseResponse.js  php-cgi-node.js)

webviewCgiMjs: $(addprefix packages/php-cgi-wasm/,PhpCgiBase.mjs PhpCgiWebview.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-webview.mjs)
webviewCgiJs:  $(addprefix packages/php-cgi-wasm/,PhpCgiBase.js  PhpCgiWebview.js  breakoutRequest.js  parseResponse.js  php-cgi-webview.js)

shellCgiMjs: $(addprefix packages/php-cgi-wasm/,PhpCgiBase.mjs PhpCgiShell.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-shell.mjs)
shellCgiJs:  $(addprefix packages/php-cgi-wasm/,PhpCgiBase.js  PhpCgiShell.js  breakoutRequest.js  parseResponse.js  php-cgi-shell.js)

packages/php-cgi-wasm/%.js: source/%.js
	npx babel $< --out-dir packages/php-cgi-wasm/

packages/php-cgi-wasm/%.mjs: source/%.js
	cp $< $@;
	perl -pi -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

packages/php-cgi-wasm/php-cgi-web.js: BUILD_TYPE=js
packages/php-cgi-wasm/php-cgi-web.js: ENVIRONMENT=web
packages/php-cgi-wasm/php-cgi-web.js: FS_TYPE=${WEB_FS_TYPE}
packages/php-cgi-wasm/php-cgi-web.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-web.mjs: BUILD_TYPE=mjs
packages/php-cgi-wasm/php-cgi-web.mjs: ENVIRONMENT=web
packages/php-cgi-wasm/php-cgi-web.mjs: FS_TYPE=${WEB_FS_TYPE}
packages/php-cgi-wasm/php-cgi-web.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-worker.js: BUILD_TYPE=js
packages/php-cgi-wasm/php-cgi-worker.js: ENVIRONMENT=worker
packages/php-cgi-wasm/php-cgi-worker.js: FS_TYPE=${WORKER_FS_TYPE}
packages/php-cgi-wasm/php-cgi-worker.js: PRELOAD_METHOD=--embed-file
packages/php-cgi-wasm/php-cgi-worker.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-worker.mjs: BUILD_TYPE=mjs
packages/php-cgi-wasm/php-cgi-worker.mjs: ENVIRONMENT=worker
packages/php-cgi-wasm/php-cgi-worker.mjs: FS_TYPE=${WORKER_FS_TYPE}
packages/php-cgi-wasm/php-cgi-worker.mjs: PRELOAD_METHOD=--embed-file
packages/php-cgi-wasm/php-cgi-worker.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-node.js: BUILD_TYPE=js
packages/php-cgi-wasm/php-cgi-node.js: ENVIRONMENT=node
packages/php-cgi-wasm/php-cgi-node.js: FS_TYPE=${NODE_FS_TYPE}
packages/php-cgi-wasm/php-cgi-node.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-node.mjs: BUILD_TYPE=mjs
packages/php-cgi-wasm/php-cgi-node.mjs: ENVIRONMENT=node
packages/php-cgi-wasm/php-cgi-node.mjs: FS_TYPE=${NODE_FS_TYPE}
packages/php-cgi-wasm/php-cgi-node.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-shell.js: BUILD_TYPE=js
packages/php-cgi-wasm/php-cgi-shell.js: ENVIRONMENT=shell
packages/php-cgi-wasm/php-cgi-shell.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-shell.mjs: BUILD_TYPE=mjs
packages/php-cgi-wasm/php-cgi-shell.mjs: ENVIRONMENT=shell
packages/php-cgi-wasm/php-cgi-shell.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}/
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-webview.js: BUILD_TYPE=js
packages/php-cgi-wasm/php-cgi-webview.js: ENVIRONMENT=webview
packages/php-cgi-wasm/php-cgi-webview.js: FS_TYPE=${WEB_FS_TYPE}
packages/php-cgi-wasm/php-cgi-webview.js: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

packages/php-cgi-wasm/php-cgi-webview.mjs: BUILD_TYPE=mjs
packages/php-cgi-wasm/php-cgi-webview.mjs: ENVIRONMENT=webview
packages/php-cgi-wasm/php-cgi-webview.mjs: FS_TYPE=${WEB_FS_TYPE}
packages/php-cgi-webview.mjs: ${DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make ${BUILD_FLAGS} PHP_BINARIES=cgi
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php8.2-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ./packages/php-cgi-wasm/

endif
