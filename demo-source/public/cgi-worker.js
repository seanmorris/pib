/*
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./src/cgi-worker.mjs":
/*!****************************!*\
  !*** ./src/cgi-worker.mjs ***!
  \****************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\nObject(function webpackMissingModule() { var e = new Error(\"Cannot find module 'php-cgi-wasm/PhpCgiWorker.mjs'\"); e.code = 'MODULE_NOT_FOUND'; throw e; }());\n/* eslint-disable no-restricted-globals */\n\n\n// Log requests & send lines to all tabs\nconst onRequest = (request, response) => {\n  const url = new URL(request.url);\n  const logLine = `[${new Date().toISOString()}]` + `#${php.count} 127.0.0.1 - \"${request.method}` + ` ${url.pathname}\" - HTTP/1.1 ${response.status}`;\n  console.log(logLine);\n\n  // self.clients.matchAll({includeUncontrolled: true}).then(clients => {\n  // \tclients.forEach(client => client.postMessage({\n  // \t\taction: 'logRequest',\n  // \t\tparams: [logLine, {status: response.status}],\n  // \t}))\n  // });\n};\nconst notFound = request => {\n  return new Response(`<body><h1>404</h1>${request.url} not found</body>`, {\n    status: 404,\n    headers: {\n      'Content-Type': 'text/html'\n    }\n  });\n};\n\n// Spawn the PHP-CGI binary\nconst php = new Object(function webpackMissingModule() { var e = new Error(\"Cannot find module 'php-cgi-wasm/PhpCgiWorker.mjs'\"); e.code = 'MODULE_NOT_FOUND'; throw e; }())({\n  onRequest,\n  notFound,\n  prefix: '/php-wasm/cgi-bin/',\n  docroot: '/persist/www',\n  types: {\n    jpeg: 'image/jpeg',\n    jpg: 'image/jpeg',\n    gif: 'image/gif',\n    png: 'image/png',\n    svg: 'image/svg+xml'\n  }\n});\n\n// Extras\nself.addEventListener('install', event => console.log('Install'));\nself.addEventListener('activate', event => console.log('Activate'));\n\n// Set up the event handlers\nself.addEventListener('install', event => php.handleInstallEvent(event));\nself.addEventListener('activate', event => php.handleActivateEvent(event));\nself.addEventListener('fetch', event => php.handleFetchEvent(event));\nself.addEventListener('message', event => php.handleMessageEvent(event));\n\n//# sourceURL=webpack://demo-source/./src/cgi-worker.mjs?");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The require scope
/******/ 	var __webpack_require__ = {};
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module can't be inlined because the eval devtool is used.
/******/ 	var __webpack_exports__ = {};
/******/ 	__webpack_modules__["./src/cgi-worker.mjs"](0, __webpack_exports__, __webpack_require__);
/******/ 	
/******/ })()
;