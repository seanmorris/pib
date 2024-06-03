PHP_CGI_DIST_DIR?=packages/php-cgi-wasm

ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
PHP_CGI_ASSET_PATH?=${PHP_CGI_DIST_DIR}
else
PHP_CGI_ASSET_PATH?=${PHP_ASSET_PATH}
endif

SHARED_ASSET_PATHS+= ${PHP_CGI_ASSET_PATH}

CGI_MJS=$(addprefix ${PHP_CGI_DIST_DIR}/,php-cgi-web.mjs php-cgi-webview.mjs php-cgi-node.mjs php-cgi-shell.mjs php-cgi-worker.mjs) \
	$(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiWeb.mjs PhpCgiWebview.mjs PhpCgiNode.mjs PhpCgiShell.mjs PhpCgiWorker.mjs PhpCgiBase.mjs) \
	$(addprefix ${PHP_CGI_DIST_DIR}/,webTransactions.mjs breakoutRequest.mjs parseResponse.mjs fsOps.mjs msg-bus.mjs webTransactions.mjs)

CGI_CJS=$(addprefix ${PHP_CGI_DIST_DIR}/,php-cgi-web.js php-cgi-webview.js php-cgi-node.js php-cgi-shell.js php-cgi-worker.js) \
	$(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiWeb.js PhpCgiWebview.js PhpCgiNode.js PhpCgiShell.js PhpCgiWorker.js PhpCgiBase.js) \
	$(addprefix ${PHP_CGI_DIST_DIR}/,webTransactions.js breakoutRequest.js parseResponse.js fsOps.js msg-bus.js webTransactions.js)

CGI_ALL= ${CGI_MJS} ${CGI_CJS}
ALL+= ${CGI_ALL}

web-cgi-mjs: $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.mjs PhpCgiWebBase.mjs PhpCgiWeb.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-web.mjs fsOps.mjs msg-bus.mjs webTransactions.mjs)
web-cgi-js:  $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.js  PhpCgiWebBase.js  PhpCgiWeb.js  breakoutRequest.js  parseResponse.js  php-cgi-web.js  fsOps.js  msg-bus.js  webTransactions.js)

worker-cgi-mjs: $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.mjs PhpCgiWebBase.mjs PhpCgiWorker.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-worker.mjs fsOps.mjs msg-bus.mjs webTransactions.mjs)
worker-cgi-js:  $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.js  PhpCgiWebBase.js  PhpCgiWorker.js  breakoutRequest.js  parseResponse.js  php-cgi-worker.js  fsOps.js  msg-bus.js  webTransactions.js)

webview-cgi-mjs: $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.mjs PhpCgiWebBase.mjs PhpCgiWebview.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-webview.mjs fsOps.mjs msg-bus.mjs webTransactions.mjs)
webview-cgi-js:  $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.js  PhpCgiWebBase.js  PhpCgiWebview.js  breakoutRequest.js  parseResponse.js  php-cgi-webview.js  fsOps.js  msg-bus.js  webTransactions.js)

node-cgi-mjs: $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.mjs PhpCgiNode.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-node.mjs fsOps.mjs)
node-cgi-js:  $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.js  PhpCgiNode.js  breakoutRequest.js  parseResponse.js  php-cgi-node.js  fsOps.js)

shell-cgi-mjs: $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.mjs PhpCgiShell.mjs breakoutRequest.mjs parseResponse.mjs php-cgi-shell.mjs fsOps.mjs)
shell-cgi-js:  $(addprefix ${PHP_CGI_DIST_DIR}/,PhpCgiBase.js  PhpCgiShell.js  breakoutRequest.js  parseResponse.js  php-cgi-shell.js  fsOps.js)

cgi: ${CGI_MJS} ${CGI_CJS}

CGI_DEPENDENCIES+= third_party/php${PHP_VERSION}-src/configured ${PHP_CGI_DIST_DIR}/config.mjs # $(addprefix ${PHP_CGI_ASSET_PATH}/,${PHP_ASSET_LIST})

${PHP_CGI_DIST_DIR}/config.mjs:
	echo 'export const phpVersion = "${PHP_VERSION}";' > $@

${PHP_CGI_DIST_DIR}/%.js: source/%.js
	npx babel $< --out-dir ${PHP_CGI_DIST_DIR}/

${PHP_CGI_DIST_DIR}/%.mjs: source/%.js
	cp $< $@;
	perl -pi -w -e "s~\b(import.+ from )(['\"])(?!node\:)([^'\"]+)\2~\1\2\3.mjs\2~g" $@;

${PHP_CGI_DIST_DIR}/php-cgi-web.js: BUILD_TYPE=js
${PHP_CGI_DIST_DIR}/php-cgi-web.js: ENVIRONMENT=web
${PHP_CGI_DIST_DIR}/php-cgi-web.js: FS_TYPE=${WEB_FS_TYPE}
${PHP_CGI_DIST_DIR}/php-cgi-web.js: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-web.mjs: BUILD_TYPE=mjs
${PHP_CGI_DIST_DIR}/php-cgi-web.mjs: ENVIRONMENT=web
${PHP_CGI_DIST_DIR}/php-cgi-web.mjs: FS_TYPE=${WEB_FS_TYPE}
${PHP_CGI_DIST_DIR}/php-cgi-web.mjs: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|var _script(Dir\|Name) = import.meta.url;|const importMeta = import.meta;var _script\1 = importMeta.url;|g' ${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-worker.js: BUILD_TYPE=js
${PHP_CGI_DIST_DIR}/php-cgi-worker.js: ENVIRONMENT=worker
${PHP_CGI_DIST_DIR}/php-cgi-worker.js: FS_TYPE=${WORKER_FS_TYPE}
${PHP_CGI_DIST_DIR}/php-cgi-worker.js: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|${READ_ASYNC_OLD}|${READ_ASYNC_NEW}|' ${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs: BUILD_TYPE=mjs
${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs: ENVIRONMENT=worker
${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs: FS_TYPE=${WORKER_FS_TYPE}
${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|${READ_ASYNC_OLD}|${READ_ASYNC_NEW}|' ${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs
	perl -pi -w -e 's|var _script(Dir\|Name) = import.meta.url;|const importMeta = import.meta;var _script\1 = importMeta.url;|g' ${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-node.js: BUILD_TYPE=js
${PHP_CGI_DIST_DIR}/php-cgi-node.js: ENVIRONMENT=node
${PHP_CGI_DIST_DIR}/php-cgi-node.js: FS_TYPE=${NODE_FS_TYPE}
${PHP_CGI_DIST_DIR}/php-cgi-node.js: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-node.mjs: BUILD_TYPE=mjs
${PHP_CGI_DIST_DIR}/php-cgi-node.mjs: ENVIRONMENT=node
${PHP_CGI_DIST_DIR}/php-cgi-node.mjs: FS_TYPE=${NODE_FS_TYPE}
${PHP_CGI_DIST_DIR}/php-cgi-node.mjs: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-shell.js: BUILD_TYPE=js
${PHP_CGI_DIST_DIR}/php-cgi-shell.js: ENVIRONMENT=shell
${PHP_CGI_DIST_DIR}/php-cgi-shell.js: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-shell.mjs: BUILD_TYPE=mjs
${PHP_CGI_DIST_DIR}/php-cgi-shell.mjs: ENVIRONMENT=shell
${PHP_CGI_DIST_DIR}/php-cgi-shell.mjs: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}/
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-webview.js: BUILD_TYPE=js
${PHP_CGI_DIST_DIR}/php-cgi-webview.js: ENVIRONMENT=webview
${PHP_CGI_DIST_DIR}/php-cgi-webview.js: FS_TYPE=${WEB_FS_TYPE}
${PHP_CGI_DIST_DIR}/php-cgi-webview.js: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

${PHP_CGI_DIST_DIR}/php-cgi-webview.mjs: BUILD_TYPE=mjs
${PHP_CGI_DIST_DIR}/php-cgi-webview.mjs: ENVIRONMENT=webview
${PHP_CGI_DIST_DIR}/php-cgi-webview.mjs: FS_TYPE=${WEB_FS_TYPE}
${PHP_CGI_DIST_DIR}/php-cgi-webview.mjs: ${CGI_DEPENDENCIES} | ${ORDER_ONLY}
	@ echo -e "\e[33;4mBuilding PHP for ${ENVIRONMENT} {${BUILD_TYPE}}\e[0m"
	${DOCKER_RUN_IN_PHP} emmake make cgi install-cgi install-build install-programs install-headers -ej${CPU_COUNT} ${BUILD_FLAGS} PHP_BINARIES=cgi WASM_SHARED_LIBS="$(addprefix /src/,${SHARED_LIBS})"
	${DOCKER_RUN_IN_PHP} mv -f /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.${BUILD_TYPE} /src/third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}
	cp third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}* ${PHP_CGI_DIST_DIR}/
	perl -pi -w -e 's|import(name)|import(/* webpackIgnore: true */ name)|g' $@
	perl -pi -w -e 's|require("fs")|require(/* webpackIgnore: true */ "fs")|g' $@
	perl -pi -w -e 's|var _script(Dir\|Name) = import.meta.url;|const importMeta = import.meta;var _script\1 = importMeta.url;|g' ${PHP_CGI_DIST_DIR}/php-cgi-worker.mjs
ifneq (${PHP_DIST_DIR},${PHP_ASSET_PATH})
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/php-cgi-${ENVIRONMENT}${RELEASE_SUFFIX}.${BUILD_TYPE}.* ${PHP_ASSET_PATH}/
	cp -Lprf third_party/php${PHP_VERSION}-src/sapi/cgi/${PRELOAD_NAME}.data ${PHP_ASSET_PATH}/
endif

.SECONDEXPANSION:
cgi-assets: $$(addprefix $${PHP_CGI_ASSET_PATH}/,$${PHP_ASSET_LIST})
