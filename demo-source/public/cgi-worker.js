/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "../packages/php-cgi-wasm lazy recursive":
/*!**************************************************************!*\
  !*** ../packages/php-cgi-wasm/ lazy strict namespace object ***!
  \**************************************************************/
/***/ ((module) => {

function webpackEmptyAsyncContext(req) {
	// Here Promise.resolve().then() is used instead of new Promise() to prevent
	// uncaught exception popping up in devtools
	return Promise.resolve().then(() => {
		var e = new Error("Cannot find module '" + req + "'");
		e.code = 'MODULE_NOT_FOUND';
		throw e;
	});
}
webpackEmptyAsyncContext.keys = () => ([]);
webpackEmptyAsyncContext.resolve = webpackEmptyAsyncContext;
webpackEmptyAsyncContext.id = "../packages/php-cgi-wasm lazy recursive";
module.exports = webpackEmptyAsyncContext;

/***/ }),

/***/ "../packages/php-cgi-wasm/php-cgi-worker.mjs.wasm":
/*!********************************************************!*\
  !*** ../packages/php-cgi-wasm/php-cgi-worker.mjs.wasm ***!
  \********************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
module.exports = __webpack_require__.p + "291ab8548f69bce190cf.wasm";

/***/ }),

/***/ "../packages/php-cgi-wasm/PhpCgiBase.mjs":
/*!***********************************************!*\
  !*** ../packages/php-cgi-wasm/PhpCgiBase.mjs ***!
  \***********************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   PhpCgiBase: () => (/* binding */ PhpCgiBase)
/* harmony export */ });
/* harmony import */ var _parseResponse_mjs__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./parseResponse.mjs */ "../packages/php-cgi-wasm/parseResponse.mjs");
/* harmony import */ var _breakoutRequest_mjs__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./breakoutRequest.mjs */ "../packages/php-cgi-wasm/breakoutRequest.mjs");
/* harmony import */ var _fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./fsOps.mjs */ "../packages/php-cgi-wasm/fsOps.mjs");



const STR = 'string';
const NUM = 'number';
const putEnv = (php, key, value) => php.ccall('wasm_sapi_cgi_putenv', 'number', ['string', 'string'], [key, value]);
const requestTimes = new WeakMap();
class PhpCgiBase {
  docroot = null;
  prefix = '/php-wasm';
  rewrite = path => path;
  cookies = null;
  types = {};
  onRequest = () => {};
  phpArgs = {};
  maxRequestAge = 0;
  staticCacheTime = 0;
  dynamicCacheTime = 0;
  vHosts = [];
  php = null;
  input = [];
  output = [];
  error = [];
  count = 0;
  queue = [];
  constructor(PHP, {
    docroot,
    prefix,
    rewrite,
    entrypoint,
    cookies,
    types,
    onRequest,
    notFound,
    ...args
  } = {}) {
    this.PHP = PHP;
    this.docroot = docroot || this.docroot;
    this.prefix = prefix || this.prefix;
    this.rewrite = rewrite || this.rewrite;
    this.entrypoint = entrypoint || this.entrypoint;
    this.cookies = cookies || new Map();
    this.types = types || this.types;
    this.onRequest = onRequest || this.onRequest;
    this.notFound = notFound || this.notFound;
    this.phpArgs = args;
    this.autoTransaction = 'autoTransaction' in args ? args.autoTransaction : true;
    this.transactionStarted = false;
    this.maxRequestAge = args.maxRequestAge || 0;
    this.staticCacheTime = args.staticCacheTime || 0;
    this.dynamicCacheTime = args.dynamicCacheTime || 0;
    this.vHosts = args.vHosts || [];
    this.env = {};
    Object.assign(this.env, args.env || {});
    this.refresh();
  }
  handleInstallEvent(event) {
    return event.waitUntil(self.skipWaiting());
  }
  handleActivateEvent(event) {
    return event.waitUntil(self.clients.claim());
  }
  async handleMessageEvent(event) {
    const {
      data,
      source
    } = event;
    const {
      action,
      token,
      params = []
    } = data;
    switch (action) {
      case 'analyzePath':
      case 'readdir':
      case 'readFile':
      case 'stat':
      case 'mkdir':
      case 'rmdir':
      case 'writeFile':
      case 'rename':
      case 'unlink':
      case 'putEnv':
      case 'refresh':
      case 'getSettings':
      case 'setSettings':
      case 'getEnvs':
      case 'setEnvs':
      case 'storeInit':
        let result, error;
        try {
          result = await this[action](...params);
        } catch (_error) {
          error = JSON.parse(JSON.stringify(_error));
          console.warn(_error);
        } finally {
          source.postMessage({
            re: token,
            result,
            error
          });
        }
        break;
    }
  }
  handleFetchEvent(event) {
    const url = new URL(event.request.url);
    const prefix = this.prefix;
    if (url.pathname.substr(0, prefix.length) === prefix && url.hostname === self.location.hostname) {
      requestTimes.set(event.request, Date.now());
      const response = this.request(event.request);
      return event.respondWith(response);
    } else {
      return fetch(event.request);
    }
  }
  async _enqueue(callback, params = []) {
    let accept, reject;
    const coordinator = new Promise((a, r) => [accept, reject] = [a, r]);
    this.queue.push([callback, params, accept, reject]);
    if (!this.queue.length) {
      return;
    }
    while (this.queue.length) {
      const [callback, params, accept, reject] = this.queue.shift();
      await callback(...params).then(accept).catch(reject);
    }
    return coordinator;
  }
  async refresh() {
    this.binary = new this.PHP({
      stdin: () => this.input ? String(this.input.shift()).charCodeAt(0) : null,
      stdout: x => this.output.push(x),
      stderr: x => this.error.push(x),
      persist: [{
        mountPath: '/persist'
      }, {
        mountPath: '/config'
      }],
      ...this.phpArgs
    });
    const php = await this.binary;
    php.ccall('pib_storage_init', 'number', [], []);
    php.ccall('wasm_sapi_cgi_init', 'number', [], []);
    await this.loadInit();
  }
  _beforeRequest() {}
  _afterRequest() {}
  async request(request) {
    const {
      url,
      method = 'GET',
      get,
      post,
      contentType
    } = await (0,_breakoutRequest_mjs__WEBPACK_IMPORTED_MODULE_1__.breakoutRequest)(request);
    await this._beforeRequest();
    let docroot = this.docroot;
    let vHostEntrypoint, vHostPrefix;
    for (const {
      pathPrefix,
      directory,
      entrypoint
    } of this.vHosts) {
      if (pathPrefix === url.pathname.substr(0, pathPrefix.length)) {
        docroot = directory;
        vHostEntrypoint = entrypoint;
        vHostPrefix = pathPrefix;
        break;
      }
    }
    const rewrite = this.rewrite(url.pathname);
    let scriptName, path;
    if (typeof rewrite === 'object') {
      scriptName = rewrite.scriptName;
      path = docroot + rewrite.path;
    } else {
      path = docroot + rewrite.substr((vHostPrefix || this.prefix).length);
      scriptName = path;
    }
    if (vHostEntrypoint) {
      scriptName = vHostPrefix + '/' + vHostEntrypoint;
    }
    const cache = await caches.open('static-v1');
    const cached = await cache.match(url);

    // this.maxRequestAge

    if (cached) {
      const cacheTime = Number(cached.headers.get('x-php-wasm-cache-time'));
      if (this.staticCacheTime > 0 && this.staticCacheTime < Date.now() - cacheTime) {
        return cached;
      }
    }
    const php = await this.binary;
    let originalPath = url.pathname;
    const extension = path.split('.').pop();
    if (extension !== 'php') {
      const aboutPath = php.FS.analyzePath(path);

      // Return static file
      if (aboutPath.exists && php.FS.isFile(aboutPath.object.mode)) {
        const response = new Response(php.FS.readFile(path, {
          encoding: 'binary',
          url
        }), {});
        response.headers.append('x-php-wasm-cache-time', new Date().getTime());
        if (extension in this.types) {
          response.headers.append('Content-type', this.types[extension]);
        }
        cache.put(url, response.clone());
        this.onRequest(request, response);
        return response;
      } else if (aboutPath.exists && php.FS.isDir(aboutPath.object.mode) && '/' !== originalPath[-1 + originalPath.length]) {
        originalPath += '/';
      }

      // Rewrite to index
      path = docroot + '/index.php';
    }
    if (this.maxRequestAge > 0 && Date.now() - requestTimes.get(request) > this.maxRequestAge) {
      const response = new Response('408: Request Timed Out.', {
        status: 408
      });
      this.onRequest(request, response);
      return response;
    }
    const aboutPath = php.FS.analyzePath(path);
    if (!aboutPath.exists) {
      const rawResponse = this.notFound ? this.notFound(request) : '404 - Not Found.';
      if (rawResponse) {
        return rawResponse instanceof Response ? rawResponse : new Response(rawResponse, {
          status: 404
        });
      }
    }
    this.input = ['POST', 'PUT', 'PATCH'].includes(method) ? post.split('') : [];
    this.output = [];
    this.error = [];
    const selfUrl = new URL(globalThis.location);
    putEnv(php, 'PHP_INI_SCAN_DIR', '/config');
    for (const [name, value] of Object.entries(this.env)) {
      putEnv(php, name, value);
    }
    putEnv(php, 'SERVER_SOFTWARE', navigator.userAgent);
    putEnv(php, 'REQUEST_METHOD', method);
    putEnv(php, 'REMOTE_ADDR', '127.0.0.1');
    putEnv(php, 'HTTP_HOST', selfUrl.host);
    putEnv(php, 'REQUEST_SCHEME', selfUrl.protocol.substr(0, selfUrl.protocol.length - 0));
    putEnv(php, 'DOCUMENT_ROOT', docroot);
    putEnv(php, 'REQUEST_URI', originalPath);
    putEnv(php, 'SCRIPT_NAME', scriptName);
    putEnv(php, 'SCRIPT_FILENAME', path);
    putEnv(php, 'PATH_TRANSLATED', path);
    putEnv(php, 'QUERY_STRING', get);
    putEnv(php, 'HTTP_COOKIE', [...this.cookies.entries()].map(e => `${e[0]}=${e[1]}`).join(';'));
    putEnv(php, 'REDIRECT_STATUS', '200');
    putEnv(php, 'CONTENT_TYPE', contentType);
    putEnv(php, 'CONTENT_LENGTH', String(this.input.length));
    try {
      if (php._main() === 0)
        // PHP exited with code 0
        {
          this._afterRequest();
        }
    } catch (error) {
      console.error(error);
      this.refresh();
      const response = new Response(`500: Internal Server Error.\n` + `=`.repeat(80) + `\n\n` + `Stacktrace:\n${error.stack}\n` + `=`.repeat(80) + `\n\n` + `STDERR:\n${new TextDecoder().decode(new Uint8Array(this.error).buffer)}\n` + `=`.repeat(80) + `\n\n` + `STDOUT:\n${new TextDecoder().decode(new Uint8Array(this.output).buffer)}\n` + `=`.repeat(80) + `\n\n`, {
        status: 500
      });
      this.onRequest(request, response);
      return response;
    }
    ++this.count;
    console.log(this.error);
    const parsedResponse = (0,_parseResponse_mjs__WEBPACK_IMPORTED_MODULE_0__.parseResponse)(this.output);
    let status = 200;
    for (const [name, value] of Object.entries(parsedResponse.headers)) {
      if (name === 'Status') {
        status = value.substr(0, 3);
      }
    }
    if (parsedResponse.headers['Set-Cookie']) {
      const raw = parsedResponse.headers['Set-Cookie'];
      const semi = raw.indexOf(';');
      const equal = raw.indexOf('=');
      const key = raw.substr(0, equal);
      const value = raw.substr(1 + equal, -1 + semi - equal);
      this.cookies.set(key, value);
    }
    const headers = {
      'Content-Type': parsedResponse.headers["Content-Type"] ?? 'text/html; charset=utf-8'
    };
    if (parsedResponse.headers.Location) {
      headers.Location = parsedResponse.headers.Location;
    }
    const response = new Response(parsedResponse.body || '', {
      headers,
      status,
      url
    });
    this.onRequest(request, response);
    return response;
  }
  analyzePath(path) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.analyzePath, [this.binary, path]);
  }
  readdir(path) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.readdir, [this.binary, path]);
  }
  readFile(path, options) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.readFile, [this.binary, path, options]);
  }
  stat(path) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.stat, [this.binary, path]);
  }
  mkdir(path) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.mkdir, [this.binary, path]);
  }
  rmdir(path) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.rmdir, [this.binary, path]);
  }
  rename(path, newPath) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.rename, [this.binary, path, newPath]);
  }
  writeFile(path, data, options) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.writeFile, [this.binary, path, data, options]);
  }
  unlink(path) {
    return this._enqueue(_fsOps_mjs__WEBPACK_IMPORTED_MODULE_2__.fsOps.unlink, [this.binary, path]);
  }
  async putEnv(name, value) {
    return (await this.binary).ccall('wasm_sapi_cgi_putenv', 'number', ['string', 'string'], [name, value]);
  }
  async getSettings() {
    return {
      docroot: this.docroot,
      maxRequestAge: this.maxRequestAge,
      staticCacheTime: this.staticCacheTime,
      dynamicCacheTime: this.dynamicCacheTime,
      vHosts: this.vHosts
    };
  }
  async setSettings({
    docroot,
    maxRequestAge,
    staticCacheTime,
    dynamicCacheTime,
    vHosts
  }) {
    this.docroot = docroot ?? this.docroot;
    this.maxRequestAge = maxRequestAge ?? this.maxRequestAge;
    this.staticCacheTime = staticCacheTime ?? this.staticCacheTime;
    this.dynamicCacheTime = dynamicCacheTime ?? this.dynamicCacheTime;
    this.vHosts = vHosts ?? this.vHosts;
  }
  async getEnvs() {
    return {
      ...this.env
    };
  }
  async setEnvs(env) {
    for (const key of Object.keys(this.env)) {
      this.env[key] = undefined;
    }
    Object.assign(this.env, env);
  }
  async storeInit() {
    const settings = await this.getSettings();
    const env = await this.getEnvs();
    await this.writeFile('/config/init.json', JSON.stringify({
      settings,
      env
    }), {
      encoding: 'utf8'
    });
  }
  async loadInit() {
    const initPath = '/config/init.json';
    const php = await this.binary;
    const check = php.FS.analyzePath(initPath);
    if (!check.exists) {
      return;
    }
    const initJson = php.FS.readFile(initPath, {
      encoding: 'utf8'
    });
    const init = JSON.parse(initJson || '{}');
    const {
      settings,
      env
    } = init;
    this.setSettings(settings);
    this.setEnvs(env);
  }
}

/***/ }),

/***/ "../packages/php-cgi-wasm/PhpCgiWebBase.mjs":
/*!**************************************************!*\
  !*** ../packages/php-cgi-wasm/PhpCgiWebBase.mjs ***!
  \**************************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   PhpCgiWebBase: () => (/* binding */ PhpCgiWebBase)
/* harmony export */ });
/* harmony import */ var _PhpCgiBase_mjs__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./PhpCgiBase.mjs */ "../packages/php-cgi-wasm/PhpCgiBase.mjs");
/* harmony import */ var _webTransactions_mjs__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./webTransactions.mjs */ "../packages/php-cgi-wasm/webTransactions.mjs");


class PhpCgiWebBase extends _PhpCgiBase_mjs__WEBPACK_IMPORTED_MODULE_0__.PhpCgiBase {
  startTransaction() {
    return (0,_webTransactions_mjs__WEBPACK_IMPORTED_MODULE_1__.startTransaction)(this);
  }
  commitTransaction() {
    return (0,_webTransactions_mjs__WEBPACK_IMPORTED_MODULE_1__.commitTransaction)(this);
  }
  async _beforeRequest() {
    if (!this.initialized) {
      const php = await this.binary;
      await navigator.locks.request('php-wasm-fs-lock', async () => {
        await new Promise((accept, reject) => php.FS.syncfs(true, err => {
          if (err) reject(err);else accept();
        }));
      });
      await this.loadInit();
      this.initialized = true;
    }
  }
  _afterRequest() {
    navigator.locks.request('php-wasm-fs-lock', async () => {
      const php = await this.binary;
      await new Promise((accept, reject) => php.FS.syncfs(false, err => {
        if (err) reject(err);else accept();
      }));
    });
  }
  async refresh() {
    this.binary = new this.PHP({
      stdin: () => this.input ? String(this.input.shift()).charCodeAt(0) : null,
      stdout: x => this.output.push(x),
      stderr: x => this.error.push(x),
      persist: [{
        mountPath: '/persist'
      }, {
        mountPath: '/config'
      }],
      ...this.phpArgs
    });
    const php = await this.binary;
    this.initialized = false;
    php.ccall('pib_storage_init', 'number', [], []);
    php.ccall('wasm_sapi_cgi_init', 'number', [], []);
    await navigator.locks.request('php-wasm-fs-lock', async () => {
      return new Promise((accept, reject) => {
        php.FS.syncfs(true, error => {
          if (error) reject(error);else accept();
        });
      });
    });
    await this.loadInit();
  }
  _enqueue(callback, params = []) {
    let accept, reject;
    const coordinator = new Promise((a, r) => [accept, reject] = [a, r]);
    this.queue.push([callback, params, accept, reject]);
    navigator.locks.request('php-wasm-fs-lock', async () => {
      if (!this.queue.length) {
        return;
      }
      await (this.autoTransaction ? this.startTransaction() : Promise.resolve());
      do {
        const [callback, params, accept, reject] = this.queue.shift();
        await callback(...params).then(accept).catch(reject);
        // console.log(params);
        let lockChecks = 5;
        while (!this.queue.length && lockChecks--) {
          await new Promise(a => setTimeout(a, 5));
        }
      } while (this.queue.length);
      await (this.autoTransaction ? this.commitTransaction() : Promise.resolve());
    });
    return coordinator;
  }
}

/***/ }),

/***/ "../packages/php-cgi-wasm/PhpCgiWorker.mjs":
/*!*************************************************!*\
  !*** ../packages/php-cgi-wasm/PhpCgiWorker.mjs ***!
  \*************************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   PhpCgiWorker: () => (/* binding */ PhpCgiWorker)
/* harmony export */ });
/* harmony import */ var _PhpCgiWebBase_mjs__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./PhpCgiWebBase.mjs */ "../packages/php-cgi-wasm/PhpCgiWebBase.mjs");
/* harmony import */ var _php_cgi_worker_mjs__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./php-cgi-worker.mjs */ "../packages/php-cgi-wasm/php-cgi-worker.mjs");


class PhpCgiWorker extends _PhpCgiWebBase_mjs__WEBPACK_IMPORTED_MODULE_0__.PhpCgiWebBase {
  constructor({
    docroot,
    prefix,
    rewrite,
    cookies,
    types,
    onRequest,
    notFound,
    ...args
  } = {}) {
    super(_php_cgi_worker_mjs__WEBPACK_IMPORTED_MODULE_1__["default"], {
      docroot,
      prefix,
      rewrite,
      cookies,
      types,
      onRequest,
      notFound,
      ...args
    });
  }
}

/***/ }),

/***/ "../packages/php-cgi-wasm/breakoutRequest.mjs":
/*!****************************************************!*\
  !*** ../packages/php-cgi-wasm/breakoutRequest.mjs ***!
  \****************************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   breakoutRequest: () => (/* binding */ breakoutRequest)
/* harmony export */ });
const breakoutRequest = request => {
  let getPost = Promise.resolve('');
  if (request.body) {
    getPost = new Promise(accept => {
      const reader = request.body.getReader();
      const postBody = [];
      const processBody = ({
        done,
        value
      }) => {
        if (value) {
          postBody.push([...value].map(x => String.fromCharCode(x)).join(''));
        }
        if (!done) {
          return reader.read().then(processBody);
        }
        accept(postBody.join(''));
      };
      return reader.read().then(processBody);
    });
  } else if (request.arrayBuffer) {
    getPost = request.arrayBuffer().then(buffer => [...new Uint8Array(buffer)].map(x => String.fromCharCode(x)).join(''));
  }
  const url = new URL(request.url);
  return getPost.then(post => ({
    url,
    method: request.method,
    get: url.search ? url.search.substr(1) : '',
    post: request.method === 'POST' ? post : null,
    contentType: request.method === 'POST' ? request.headers.get('Content-Type') ?? 'application/x-www-form-urlencoded' : null
  }));
};

/***/ }),

/***/ "../packages/php-cgi-wasm/fsOps.mjs":
/*!******************************************!*\
  !*** ../packages/php-cgi-wasm/fsOps.mjs ***!
  \******************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   fsOps: () => (/* binding */ fsOps)
/* harmony export */ });
class fsOps {
  static async analyzePath(binary, path) {
    const result = (await binary).FS.analyzePath(path);
    if (!result.object) {
      return {
        exists: false
      };
    }
    const object = {
      exists: true,
      id: result.object.id,
      mode: result.object.mode,
      mount: {
        mountpoint: result.object.mount.mountpoint,
        mounts: result.object.mount.mounts.map(m => m.mountpoint)
      },
      isDevice: result.object.isDevice,
      isFolder: result.object.isFolder,
      read: result.object.read,
      write: result.object.write
    };
    return {
      ...result,
      object,
      parentObject: undefined
    };
  }
  static async readdir(binary, path) {
    return (await binary).FS.readdir(path);
  }
  static async readFile(binary, path) {
    return (await binary).FS.readFile(path);
  }
  static async stat(binary, path) {
    return (await binary).FS.stat(path);
  }
  static async mkdir(binary, path) {
    const php = await binary;
    const _result = php.FS.mkdir(path);
    return {
      id: _result.id,
      mode: _result.mode,
      mount: {
        mountpoint: _result.mount.mountpoint,
        mounts: _result.mount.mounts.map(m => m.mountpoint)
      },
      isDevice: _result.isDevice,
      isFolder: _result.isFolder,
      read: _result.read,
      write: _result.write
    };
  }
  static async rmdir(binary, path) {
    return (await binary).FS.rmdir(path);
  }
  static async rename(binary, path, newPath) {
    return (await binary).FS.rename(path, newPath);
  }
  static async writeFile(binary, path, data, options) {
    return (await binary).FS.writeFile(path, data, options);
  }
  static async unlink(binary, path) {
    return (await binary).FS.unlink(path);
  }
}

/***/ }),

/***/ "../packages/php-cgi-wasm/parseResponse.mjs":
/*!**************************************************!*\
  !*** ../packages/php-cgi-wasm/parseResponse.mjs ***!
  \**************************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   parseResponse: () => (/* binding */ parseResponse)
/* harmony export */ });
const parseResponse = response => {
  const headers = {};
  const line = [];
  const decoder = new TextDecoder();
  let i = 0;
  for (; i < response.length; i++) {
    if (response[i] === 0xD && response[i + 1] === 0xA)
      // We're at a CRLF
      {
        if (line.length) {
          const header = decoder.decode(new Uint8Array(line).buffer);
          const colon = header.indexOf(':');
          if (colon < 0) {
            headers[header] = true;
          } else {
            headers[header.substring(0, colon)] = header.substring(colon + 2);
          }
          line.length = 0;
          i++;
          continue;
        } else {
          i++;
          break;
        }
      }
    line.push(response[i]);
  }
  return {
    headers,
    body: new Uint8Array(response.slice(1 + i)).buffer
  };
};

/***/ }),

/***/ "../packages/php-cgi-wasm/php-cgi-worker.mjs":
/*!***************************************************!*\
  !*** ../packages/php-cgi-wasm/php-cgi-worker.mjs ***!
  \***************************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
var PHP = (() => {
  const importMeta = ({});
  var _scriptName = importMeta.url;
  return function (moduleArg = {}) {
    var moduleRtn;
    var Module = Object.assign({}, moduleArg);
    var readyPromiseResolve, readyPromiseReject;
    var readyPromise = new Promise((resolve, reject) => {
      readyPromiseResolve = resolve;
      readyPromiseReject = reject;
    });
    var ENVIRONMENT_IS_WEB = false;
    var ENVIRONMENT_IS_WORKER = true;
    var ENVIRONMENT_IS_NODE = false;
    Module.preRun = Module.preRun || [];
    if (typeof Module.preRun == "function") Module.preRun = [Module.preRun];
    Module.preRun.push(() => Object.assign(ENV, Module.ENV || {}));
    Module.preRun = Module.preRun || [];
    if (typeof Module.preRun == "function") Module.preRun = [Module.preRun];
    Module.preRun.push(() => ENV.ICU_DATA = ENV.ICU_DATA || "/preload");
    Module.WeakerMap = Module.WeakerMap || class WeakerMap {
      constructor(entries) {
        this.registry = new FinReg(held => this.delete(held));
        this.map = new Map();
        entries && entries.forEach(([key, value]) => this.set(key, value));
      }
      get size() {
        return this.map.size;
      }
      clear() {
        this.map.clear();
      }
      delete(key) {
        this.map.delete(key);
      }
      [Symbol.iterator]() {
        const mapIterator = this.map[Symbol.iterator]();
        return {
          next: () => {
            do {
              const entry = mapIterator.next();
              if (entry.done) {
                return {
                  done: true
                };
              }
              const [key, ref] = entry.value;
              const value = ref.deref();
              if (!value) {
                this.map.delete(key);
                continue;
              }
              return {
                done: false,
                value: [key, value]
              };
            } while (true);
          }
        };
      }
      entries() {
        return {
          [Symbol.iterator]: () => this[Symbol.iterator]()
        };
      }
      forEach(callback) {
        for (const [k, v] of this) {
          callback(v, k, this);
        }
      }
      get(key) {
        if (!this.has(key)) {
          return;
        }
        return this.map.get(key).deref();
      }
      has(key) {
        if (!this.map.has(key)) {
          return false;
        }
        const result = this.map.get(key).deref();
        if (!result) {
          this.map.delete(key);
        }
        return result;
      }
      keys() {
        return [...this].map(v => v[0]);
      }
      set(key, value) {
        if (typeof value !== "function" && typeof value !== "object") {
          throw new Error("WeakerMap values must be objects.");
        }
        if (this.map.has(key)) {
          this.registry.unregister(this.get(key));
        }
        this.registry.register(value, key, value);
        return this.map.set(key, new wRef(value));
      }
      values() {
        return [...this].map(v => v[1]);
      }
    };
    const FinReg = globalThis.FinalizationRegistry || class {
      register() {}
      unregister() {}
    };
    const wRef = globalThis.WeakRef || class {
      constructor(val) {
        this.val = val;
      }
      deref() {
        return this.val;
      }
    };
    Module.UniqueIndex = Module.UniqueIndex || class UniqueIndex {
      constructor() {
        this.byObject = new WeakMap();
        this.byInteger = new Module.WeakerMap();
        this.id = 0;
        Object.defineProperty(this, "clear", {
          configurable: false,
          writable: false,
          value: () => {
            this.byInteger.clear();
          }
        });
        Object.defineProperty(this, "add", {
          configurable: false,
          writable: false,
          value: callback => {
            if (this.byObject.has(callback)) {
              const id = this.byObject.get(callback);
              return id;
            }
            const newid = ++this.id;
            this.byObject.set(callback, newid);
            this.byInteger.set(newid, callback);
            return newid;
          }
        });
        Object.defineProperty(this, "has", {
          configurable: false,
          writable: false,
          value: obj => {
            if (this.byObject.has(obj)) {
              const id = this.byObject.get(obj);
              return this.byInteger.has(id);
            }
          }
        });
        Object.defineProperty(this, "hasId", {
          configurable: false,
          writable: false,
          value: address => {
            if (this.byInteger.has(address)) {
              return this.byInteger.get(address);
            }
          }
        });
        Object.defineProperty(this, "get", {
          configurable: false,
          writable: false,
          value: address => {
            if (this.byInteger.has(address)) {
              return this.byInteger.get(address);
            }
          }
        });
        Object.defineProperty(this, "getId", {
          configurable: false,
          writable: false,
          value: obj => {
            if (this.byObject.has(obj)) {
              return this.byObject.get(obj);
            }
          }
        });
        Object.defineProperty(this, "remove", {
          configurable: false,
          writable: false,
          value: address => {
            const obj = this.byInteger.get(address);
            if (obj) {
              this.byObject.delete(obj);
              this.byInteger.delete(address);
            }
          }
        });
      }
    };
    const zvalSym = Symbol("ZVAL");
    Module.marshalObject = zvalPtr => {
      const nativeTarget = Module.ccall("vrzno_expose_zval_is_target", "number", ["number"], [zvalPtr]);
      if (nativeTarget && Module.targets.hasId(nativeTarget)) {
        return Module.targets.get(nativeTarget);
      }
      const proxy = new Proxy({}, {
        ownKeys: target => {
          const keysLoc = Module.ccall("vrzno_expose_object_keys", "number", ["number"], [zvalPtr]);
          const keyJson = UTF8ToString(keysLoc);
          const keys = JSON.parse(keyJson);
          _free(keysLoc);
          keys.push(...Reflect.ownKeys(target));
          return keys;
        },
        has: (target, prop) => {
          if (typeof prop === "symbol") {
            return false;
          }
          const len = lengthBytesUTF8(prop) + 1;
          const namePtr = _malloc(len);
          stringToUTF8(prop, namePtr, len);
          const retPtr = Module.ccall("vrzno_expose_property_pointer", "number", ["number", "number"], [zvalPtr, namePtr]);
          return !!retPtr;
        },
        get: (target, prop, receiver) => {
          if (typeof prop === "symbol") {
            return target[prop];
          }
          const len = lengthBytesUTF8(prop) + 1;
          const namePtr = _malloc(len);
          stringToUTF8(prop, namePtr, len);
          const retPtr = Module.ccall("vrzno_expose_property_pointer", "number", ["number", "number"], [zvalPtr, namePtr]);
          const proxy = Module.zvalToJS(retPtr);
          if (proxy && ["function", "object"].includes(typeof proxy)) {
            Module.zvalMap.set(proxy, retPtr);
            Module._zvalMap.set(retPtr, proxy);
          }
          _free(namePtr);
          if (proxy == null) {
            return Reflect.get(target, prop);
          }
          return proxy;
        },
        getOwnPropertyDescriptor: (target, prop) => {
          if (typeof prop === "symbol" || prop in target) {
            return Reflect.getOwnPropertyDescriptor(target, prop);
          }
          const len = lengthBytesUTF8(prop) + 1;
          const namePtr = _malloc(len);
          stringToUTF8(prop, namePtr, len);
          const retPtr = Module.ccall("vrzno_expose_property_pointer", "number", ["number", "number"], [zvalPtr, namePtr]);
          const proxy = Module.zvalToJS(retPtr);
          if (proxy && ["function", "object"].includes(typeof proxy)) {
            Module.zvalMap.set(proxy, retPtr);
            Module._zvalMap.set(retPtr, proxy);
          }
          _free(namePtr);
          return {
            configurable: true,
            enumerable: true,
            value: target[prop]
          };
        }
      });
      Object.defineProperty(proxy, zvalSym, {
        value: `PHP_@{${zvalPtr}}`
      });
      Module.zvalMap.set(proxy, zvalPtr);
      Module._zvalMap.set(zvalPtr, proxy);
      if (!Module.targets.has(proxy)) {
        Module.targets.add(proxy);
        Module.ccall("vrzno_expose_inc_zrefcount", "number", ["number"], [zvalPtr]);
        Module.fRegistry.register(proxy, zvalPtr, proxy);
      }
      return proxy;
    };
    Module.callableToJs = Module.callableToJs || (funcPtr => {
      if (Module.callables.has(funcPtr)) {
        return Module.callables.get(funcPtr);
      }
      const wrapped = (...args) => {
        let paramPtrs = [],
          paramsPtr = null;
        if (args.length) {
          paramsPtr = Module.ccall("vrzno_expose_create_params", "number", ["number"], [args.length]);
          paramPtrs = args.map(a => Module.jsToZval(a));
          paramPtrs.forEach((paramPtr, i) => {
            Module.ccall("vrzno_expose_set_param", "number", ["number", "number", "number"], [paramsPtr, i, paramPtr]);
          });
        }
        const zvalPtr = Module.ccall("vrzno_exec_callback", "number", ["number", "number", "number"], [funcPtr, paramsPtr, args.length]);
        if (args.length) {
          paramPtrs.forEach((p, i) => {
            if (!args[i] || !["function", "object"].includes(typeof args[i])) {
              Module.ccall("vrzno_expose_efree", "number", ["number"], [p]);
            }
          });
          Module.ccall("vrzno_expose_efree", "number", ["number", "number"], [paramsPtr, false]);
        }
        if (zvalPtr) {
          const result = Module.zvalToJS(zvalPtr);
          if (!result || !["function", "object"].includes(typeof result)) {
            Module.ccall("vrzno_expose_efree", "number", ["number"], [zvalPtr]);
          }
          return result;
        }
      };
      Object.defineProperty(wrapped, "name", {
        value: `PHP_@{${funcPtr}}`
      });
      Module.ccall("vrzno_expose_inc_crefcount", "number", ["number"], [funcPtr]);
      Module.callables.set(funcPtr, wrapped);
      return wrapped;
    });
    Module.zvalToJS = Module.zvalToJS || (zvalPtr => {
      if (Module._zvalMap.has(zvalPtr)) {
        return Module._zvalMap.get(zvalPtr);
      }
      const IS_UNDEF = 0;
      const IS_NULL = 1;
      const IS_FALSE = 2;
      const IS_TRUE = 3;
      const IS_LONG = 4;
      const IS_DOUBLE = 5;
      const IS_STRING = 6;
      const IS_OBJECT = 8;
      const callable = Module.ccall("vrzno_expose_callable", "number", ["number"], [zvalPtr]);
      let valPtr;
      if (callable) {
        const nativeTarget = Module.ccall("vrzno_expose_zval_is_target", "number", ["number"], [zvalPtr]);
        if (nativeTarget) {
          return Module.targets.get(nativeTarget);
        }
        const wrapped = nativeTarget ? Module.targets.get(nativeTarget) : Module.callableToJs(callable);
        if (!Module.targets.has(wrapped)) {
          Module.targets.add(wrapped);
          Module.ccall("vrzno_expose_inc_zrefcount", "number", ["number"], [zvalPtr]);
        }
        Module.zvalMap.set(wrapped, zvalPtr);
        Module._zvalMap.set(zvalPtr, wrapped);
        Module.fRegistry.register(wrapped, zvalPtr, wrapped);
        return wrapped;
      }
      const type = Module.ccall("vrzno_expose_type", "number", ["number"], [zvalPtr]);
      switch (type) {
        case IS_UNDEF:
          return undefined;
          break;
        case IS_NULL:
          return null;
          break;
        case IS_TRUE:
          return true;
          break;
        case IS_FALSE:
          return false;
          break;
        case IS_LONG:
          return Module.ccall("vrzno_expose_long", "number", ["number"], [zvalPtr]);
          break;
        case IS_DOUBLE:
          valPtr = Module.ccall("vrzno_expose_double", "number", ["number"], [zvalPtr]);
          if (!valPtr) {
            return null;
          }
          return getValue(valPtr, "double");
          break;
        case IS_STRING:
          valPtr = Module.ccall("vrzno_expose_string", "number", ["number"], [zvalPtr]);
          if (!valPtr) {
            return null;
          }
          return UTF8ToString(valPtr);
          break;
        case IS_OBJECT:
          const proxy = Module.marshalObject(zvalPtr);
          return proxy;
          break;
        default:
          return null;
          break;
      }
    });
    Module.jsToZval = Module.jsToZval || (value => {
      let zvalPtr;
      if (typeof value === "undefined") {
        zvalPtr = Module.ccall("vrzno_expose_create_undef", "number", [], []);
      } else if (value === null) {
        zvalPtr = Module.ccall("vrzno_expose_create_null", "number", [], []);
      } else if ([true, false].includes(value)) {
        zvalPtr = Module.ccall("vrzno_expose_create_bool", "number", ["number"], [value]);
      } else if (value && ["function", "object"].includes(typeof value)) {
        let index, existed;
        if (!Module.targets.has(value)) {
          index = Module.targets.add(value);
          existed = false;
        } else {
          index = Module.targets.getId(value);
          existed = true;
        }
        const isFunction = typeof value === "function" ? index : 0;
        const isConstructor = isFunction && !!(value.prototype && value.prototype.constructor);
        zvalPtr = Module.ccall("vrzno_expose_create_object_for_target", "number", ["number", "number", "number"], [index, isFunction, isConstructor]);
        Module.zvalMap.set(value, zvalPtr);
        Module._zvalMap.set(zvalPtr, value);
        if (!existed) {
          Module.ccall("vrzno_expose_inc_zrefcount", "number", ["number"], [zvalPtr]);
          Module.fRegistry.register(value, zvalPtr, value);
        }
      } else if (typeof value === "number") {
        if (Number.isInteger(value)) {
          zvalPtr = Module.ccall("vrzno_expose_create_long", "number", ["number"], [value]);
        } else if (Number.isFinite(value)) {
          zvalPtr = Module.ccall("vrzno_expose_create_double", "number", ["number"], [value]);
        }
      } else if (typeof value === "string") {
        const len = lengthBytesUTF8(value) + 1;
        const strLoc = _malloc(len);
        stringToUTF8(value, strLoc, len);
        zvalPtr = Module.ccall("vrzno_expose_create_string", "number", ["number"], [strLoc]);
        _free(strLoc);
      }
      return zvalPtr;
    });
    Module.PdoD1Driver = Module.PdoD1Driver || class PdoD1Driver {
      prepare(db, query) {
        console.log("prepare", {
          db: db,
          query: query
        });
        return db.prepare(query);
      }
      doer(db, query) {
        console.log("doer", {
          db: db,
          query: query
        });
      }
    };
    HEAP8 = new Int8Array(1);
    Module.zvalMap = new WeakMap();
    Module._zvalMap = Module._zvalMap || new Module.WeakerMap();
    Module.fRegistry = Module.fRegistry || new FinReg(zvalPtr => {
      console.log("Garbage collecting! zVal@" + zvalPtr);
      Module.ccall("vrzno_expose_dec_zrefcount", "number", ["number"], [zvalPtr]);
    });
    Module.bufferMaps = new WeakMap();
    Module.callables = Module.callables || new Module.WeakerMap();
    Module.targets = Module.targets || new Module.UniqueIndex();
    Module.classes = Module.classes || new WeakMap();
    Module._classes = Module._classes || new Module.WeakerMap();
    Module.PdoParams = new WeakMap();
    Module.pdoDriver = Module.pdoDriver || new Module.PdoD1Driver();
    Module.targets.add(globalThis);
    Module.onRefresh = Module.onRefresh || new Set();
    Module.onRefresh.add(() => {
      Module.callables.clear();
      Module.targets.clear();
      Module._classes.clear();
      Module._zvalMap.clear();
      Module.targets.byObject.set(globalThis, 1);
      Module.targets.byInteger.set(1, globalThis);
    });
    var moduleOverrides = Object.assign({}, Module);
    var arguments_ = [];
    var thisProgram = "./this.program";
    var quit_ = (status, toThrow) => {
      throw toThrow;
    };
    var scriptDirectory = "";
    function locateFile(path) {
      if (Module["locateFile"]) {
        return Module["locateFile"](path, scriptDirectory);
      }
      return scriptDirectory + path;
    }
    var read_, readAsync, readBinary;
    if (ENVIRONMENT_IS_WEB || ENVIRONMENT_IS_WORKER) {
      if (ENVIRONMENT_IS_WORKER) {
        scriptDirectory = self.location.href;
      } else if (typeof document != "undefined" && document.currentScript) {
        scriptDirectory = document.currentScript.src;
      }
      if (_scriptName) {
        scriptDirectory = _scriptName;
      }
      if (scriptDirectory.startsWith("blob:")) {
        scriptDirectory = "";
      } else {
        scriptDirectory = scriptDirectory.substr(0, scriptDirectory.replace(/[?#].*/, "").lastIndexOf("/") + 1);
      }
      {
        read_ = url => {
          var xhr = new XMLHttpRequest();
          xhr.open("GET", url, false);
          xhr.send(null);
          return xhr.responseText;
        };
        if (ENVIRONMENT_IS_WORKER) {
          readBinary = url => {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", url, false);
            xhr.responseType = "arraybuffer";
            xhr.send(null);
            return new Uint8Array(xhr.response);
          };
        }
        readAsync = (url, onload, onerror) => {
          fetch(url).then(response => response.arrayBuffer()).then(onload).catch(onerror);
        };
      }
    } else {}
    var out = Module["print"] || console.log.bind(console);
    var err = Module["printErr"] || console.error.bind(console);
    Object.assign(Module, moduleOverrides);
    moduleOverrides = null;
    if (Module["arguments"]) arguments_ = Module["arguments"];
    if (Module["thisProgram"]) thisProgram = Module["thisProgram"];
    if (Module["quit"]) quit_ = Module["quit"];
    var dynamicLibraries = Module["dynamicLibraries"] || [];
    var wasmBinary;
    if (Module["wasmBinary"]) wasmBinary = Module["wasmBinary"];
    var wasmMemory;
    var ABORT = false;
    var EXITSTATUS;
    function assert(condition, text) {
      if (!condition) {
        abort(text);
      }
    }
    var HEAP8, HEAPU8, HEAP16, HEAPU16, HEAP32, HEAPU32, HEAPF32, HEAPF64;
    function updateMemoryViews() {
      var b = wasmMemory.buffer;
      Module["HEAP8"] = HEAP8 = new Int8Array(b);
      Module["HEAP16"] = HEAP16 = new Int16Array(b);
      Module["HEAPU8"] = HEAPU8 = new Uint8Array(b);
      Module["HEAPU16"] = HEAPU16 = new Uint16Array(b);
      Module["HEAP32"] = HEAP32 = new Int32Array(b);
      Module["HEAPU32"] = HEAPU32 = new Uint32Array(b);
      Module["HEAPF32"] = HEAPF32 = new Float32Array(b);
      Module["HEAPF64"] = HEAPF64 = new Float64Array(b);
    }
    if (Module["wasmMemory"]) {
      wasmMemory = Module["wasmMemory"];
    } else {
      var INITIAL_MEMORY = Module["INITIAL_MEMORY"] || 134217728;
      wasmMemory = new WebAssembly.Memory({
        initial: INITIAL_MEMORY / 65536,
        maximum: 4294967296 / 65536
      });
    }
    updateMemoryViews();
    var __ATPRERUN__ = [];
    var __ATINIT__ = [];
    var __ATMAIN__ = [];
    var __ATEXIT__ = [];
    var __ATPOSTRUN__ = [];
    var __RELOC_FUNCS__ = [];
    var runtimeInitialized = false;
    var runtimeExited = false;
    function preRun() {
      if (Module["preRun"]) {
        if (typeof Module["preRun"] == "function") Module["preRun"] = [Module["preRun"]];
        while (Module["preRun"].length) {
          addOnPreRun(Module["preRun"].shift());
        }
      }
      callRuntimeCallbacks(__ATPRERUN__);
    }
    function initRuntime() {
      runtimeInitialized = true;
      callRuntimeCallbacks(__RELOC_FUNCS__);
      if (!Module["noFSInit"] && !FS.init.initialized) FS.init();
      FS.ignorePermissions = false;
      TTY.init();
      SOCKFS.root = FS.mount(SOCKFS, {}, null);
      PIPEFS.root = FS.mount(PIPEFS, {}, null);
      callRuntimeCallbacks(__ATINIT__);
    }
    function preMain() {
      callRuntimeCallbacks(__ATMAIN__);
    }
    function exitRuntime() {
      ___funcs_on_exit();
      callRuntimeCallbacks(__ATEXIT__);
      FS.quit();
      TTY.shutdown();
      IDBFS.quit();
      runtimeExited = true;
    }
    function postRun() {
      if (Module["postRun"]) {
        if (typeof Module["postRun"] == "function") Module["postRun"] = [Module["postRun"]];
        while (Module["postRun"].length) {
          addOnPostRun(Module["postRun"].shift());
        }
      }
      callRuntimeCallbacks(__ATPOSTRUN__);
    }
    function addOnPreRun(cb) {
      __ATPRERUN__.unshift(cb);
    }
    function addOnInit(cb) {
      __ATINIT__.unshift(cb);
    }
    function addOnPostRun(cb) {
      __ATPOSTRUN__.unshift(cb);
    }
    var runDependencies = 0;
    var runDependencyWatcher = null;
    var dependenciesFulfilled = null;
    function getUniqueRunDependency(id) {
      return id;
    }
    function addRunDependency(id) {
      runDependencies++;
      Module["monitorRunDependencies"]?.(runDependencies);
    }
    function removeRunDependency(id) {
      runDependencies--;
      Module["monitorRunDependencies"]?.(runDependencies);
      if (runDependencies == 0) {
        if (runDependencyWatcher !== null) {
          clearInterval(runDependencyWatcher);
          runDependencyWatcher = null;
        }
        if (dependenciesFulfilled) {
          var callback = dependenciesFulfilled;
          dependenciesFulfilled = null;
          callback();
        }
      }
    }
    function abort(what) {
      Module["onAbort"]?.(what);
      what = "Aborted(" + what + ")";
      err(what);
      ABORT = true;
      EXITSTATUS = 1;
      what += ". Build with -sASSERTIONS for more info.";
      var e = new WebAssembly.RuntimeError(what);
      readyPromiseReject(e);
      throw e;
    }
    var dataURIPrefix = "data:application/octet-stream;base64,";
    var isDataURI = filename => filename.startsWith(dataURIPrefix);
    function findWasmBinary() {
      if (Module["locateFile"]) {
        var f = "php-cgi-worker.mjs.wasm";
        if (!isDataURI(f)) {
          return locateFile(f);
        }
        return f;
      }
      return new URL(/* asset import */ __webpack_require__(/*! php-cgi-worker.mjs.wasm */ "../packages/php-cgi-wasm/php-cgi-worker.mjs.wasm"), __webpack_require__.b).href;
    }
    var wasmBinaryFile;
    function getBinarySync(file) {
      if (file == wasmBinaryFile && wasmBinary) {
        return new Uint8Array(wasmBinary);
      }
      if (readBinary) {
        return readBinary(file);
      }
      throw "both async and sync fetching of the wasm failed";
    }
    function getBinaryPromise(binaryFile) {
      if (!wasmBinary && (ENVIRONMENT_IS_WEB || ENVIRONMENT_IS_WORKER)) {
        if (typeof fetch == "function") {
          return fetch(binaryFile, {
            credentials: "same-origin"
          }).then(response => {
            if (!response["ok"]) {
              throw `failed to load wasm binary file at '${binaryFile}'`;
            }
            return response["arrayBuffer"]();
          }).catch(() => getBinarySync(binaryFile));
        }
      }
      return Promise.resolve().then(() => getBinarySync(binaryFile));
    }
    function instantiateArrayBuffer(binaryFile, imports, receiver) {
      return getBinaryPromise(binaryFile).then(binary => WebAssembly.instantiate(binary, imports)).then(receiver, reason => {
        err(`failed to asynchronously prepare wasm: ${reason}`);
        abort(reason);
      });
    }
    function instantiateAsync(binary, binaryFile, imports, callback) {
      if (!binary && typeof WebAssembly.instantiateStreaming == "function" && !isDataURI(binaryFile) && typeof fetch == "function") {
        return fetch(binaryFile, {
          credentials: "same-origin"
        }).then(response => {
          var result = WebAssembly.instantiateStreaming(response, imports);
          return result.then(callback, function (reason) {
            err(`wasm streaming compile failed: ${reason}`);
            err("falling back to ArrayBuffer instantiation");
            return instantiateArrayBuffer(binaryFile, imports, callback);
          });
        });
      }
      return instantiateArrayBuffer(binaryFile, imports, callback);
    }
    function getWasmImports() {
      return {
        env: wasmImports,
        wasi_snapshot_preview1: wasmImports,
        "GOT.mem": new Proxy(wasmImports, GOTHandler),
        "GOT.func": new Proxy(wasmImports, GOTHandler)
      };
    }
    function createWasm() {
      var info = getWasmImports();
      function receiveInstance(instance, module) {
        wasmExports = instance.exports;
        wasmExports = relocateExports(wasmExports, 1024);
        wasmExports = Asyncify.instrumentWasmExports(wasmExports);
        var metadata = getDylinkMetadata(module);
        if (metadata.neededDynlibs) {
          dynamicLibraries = metadata.neededDynlibs.concat(dynamicLibraries);
        }
        mergeLibSymbols(wasmExports, "main");
        LDSO.init();
        loadDylibs();
        wasmExports = applySignatureConversions(wasmExports);
        addOnInit(wasmExports["__wasm_call_ctors"]);
        __RELOC_FUNCS__.push(wasmExports["__wasm_apply_data_relocs"]);
        removeRunDependency("wasm-instantiate");
        return wasmExports;
      }
      addRunDependency("wasm-instantiate");
      function receiveInstantiationResult(result) {
        receiveInstance(result["instance"], result["module"]);
      }
      if (Module["instantiateWasm"]) {
        try {
          return Module["instantiateWasm"](info, receiveInstance);
        } catch (e) {
          err(`Module.instantiateWasm callback failed with error: ${e}`);
          readyPromiseReject(e);
        }
      }
      if (!wasmBinaryFile) wasmBinaryFile = findWasmBinary();
      instantiateAsync(wasmBinary, wasmBinaryFile, info, receiveInstantiationResult).catch(readyPromiseReject);
      return {};
    }
    var tempDouble;
    var tempI64;
    var asyncifyStubs = {};
    var ASM_CONSTS = {
      1961024: $0 => {
        if (Module.persist) {
          const persist = Array.isArray(Module.persist) ? Module.persist : [Module.persist];
          const useNodeRawFS = $0;
          persist.forEach(p => {
            const mountPath = p.mountPath || "/persist";
            const localPath = p.localPath || "./persist";
            FS.mkdir(mountPath);
            if (ENVIRONMENT_IS_WEB || ENVIRONMENT_IS_WORKER) {
              FS.mount(IDBFS, {
                autoPersist: false
              }, mountPath);
            } else if (ENVIRONMENT_IS_NODE) {
              if (!useNodeRawFS) {
                const fs = require("fs");
                if (!fs.existsSync(localPath)) {
                  fs.mkdirSync(localPath, {
                    recursive: true
                  });
                }
                FS.mount(NODEFS, {
                  root: localPath
                }, mountPath);
              }
            }
          });
        }
      },
      1961610: ($0, $1) => {
        const target = Module.targets.get($0);
        const property = UTF8ToString($1);
        if (!(property in target)) {
          return Module.jsToZval(undefined);
        }
        if (target[property] === null) {
          return Module.jsToZval(null);
        }
        const result = target[property];
        if (!result || !["function", "object"].includes(typeof result)) {
          return Module.jsToZval(result);
        }
        return 0;
      },
      1961958: ($0, $1, $2) => {
        const target = Module.targets.get($0);
        const property = UTF8ToString($1);
        const result = target[property];
        const zvalPtr = $2;
        if (result && ["function", "object"].includes(typeof result)) {
          let index = Module.targets.getId(result);
          if (!Module.targets.has(result)) {
            index = Module.targets.add(result);
            Module.zvalMap.set(result, zvalPtr);
            Module._zvalMap.set(zvalPtr, result);
          }
          return index;
        }
        return 0;
      },
      1962366: $0 => "function" === typeof Module.targets.get($0) ? $0 : 0,
      1962434: $0 => !!(Module.targets.get($0).prototype && Module.targets.get($0).prototype.constructor),
      1962535: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
        })();
      },
      1962647: ($0, $1, $2, $3, $4) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          const funcPtr = $2;
          target[property] = Module.callableToJs(funcPtr);
        })();
      },
      1962850: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          const zvalPtr = $2;
          if (!Module.targets.has(target[property])) {
            target[property] = Module.marshalObject(zvalPtr);
          }
        })();
      },
      1963057: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          delete target[property];
        })();
      },
      1963173: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          target[property] = null;
        })();
      },
      1963289: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          target[property] = false;
        })();
      },
      1963406: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          target[property] = true;
        })();
      },
      1963522: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          target[property] = $2;
        })();
      },
      1963636: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          target[property] = $2;
        })();
      },
      1963750: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          const newValue = UTF8ToString($2);
          target[property] = newValue;
        })();
      },
      1963905: ($0, $1) => {
        let target = Module.targets.get($0);
        const property = $1;
        if (target instanceof ArrayBuffer) {
          if (!Module.bufferMaps.has(target)) {
            Module.bufferMaps.set(target, new Uint8Array(target));
          }
          target = Module.bufferMaps.get(target);
        }
        if (!(property in target)) {
          const jsRet = "UN";
          const len = lengthBytesUTF8(jsRet) + 1;
          const strLoc = _malloc(len);
          stringToUTF8(jsRet, strLoc, len);
          return strLoc;
        }
        if (target[property] === null) {
          const jsRet = "NU";
          const len = lengthBytesUTF8(jsRet) + 1;
          const strLoc = _malloc(len);
          stringToUTF8(jsRet, strLoc, len);
          return strLoc;
        }
        const result = target[property];
        if (!result || !["function", "object"].includes(typeof result)) {
          const jsRet = "OK" + String(result);
          const len = lengthBytesUTF8(jsRet) + 1;
          const strLoc = _malloc(len);
          stringToUTF8(jsRet, strLoc, len);
          return strLoc;
        }
        const jsRet = "XX";
        const len = lengthBytesUTF8(jsRet) + 1;
        const strLoc = _malloc(len);
        stringToUTF8(jsRet, strLoc, len);
        return strLoc;
      },
      1964871: ($0, $1, $2) => {
        const target = Module.targets.get($0);
        const property = UTF8ToString($1);
        const result = target[property];
        const zvalPtr = $2;
        if (result && ["function", "object"].includes(typeof result)) {
          let index = Module.targets.getId(result);
          if (!Module.targets.has(result)) {
            index = Module.targets.add(result);
            Module.zvalMap.set(result, zvalPtr);
            Module._zvalMap.set(zvalPtr, result);
          }
          return index;
        }
        return 0;
      },
      1965279: $0 => "function" === typeof Module.targets.get($0) ? $0 : 0,
      1965347: $0 => !!(Module.targets.get($0).prototype && Module.targets.get($0).prototype.constructor),
      1965448: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
        })();
      },
      1965546: ($0, $1, $2, $3) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          const funcPtr = $2;
          target[property] = Module.callableToJs(funcPtr);
        })();
      },
      1965712: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          const zvalPtr = $2;
          if (!Module.targets.has(target[property])) {
            target[property] = Module.marshalObject(zvalPtr);
          }
        })();
      },
      1965905: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          delete target[property];
        })();
      },
      1966007: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          target[property] = null;
        })();
      },
      1966109: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          target[property] = false;
        })();
      },
      1966212: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          target[property] = true;
        })();
      },
      1966314: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          target[property] = $2;
        })();
      },
      1966414: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          target[property] = $2;
        })();
      },
      1966514: ($0, $1, $2) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          const newValue = UTF8ToString($2);
          target[property] = newValue;
        })();
      },
      1966655: ($0, $1, $2) => {
        const target = Module.targets.get($0);
        const property = $1;
        const check_empty = $2;
        if (Array.isArray(target)) {
          return typeof target[property] !== "undefined";
        }
        if (target instanceof ArrayBuffer) {
          if (!Module.bufferMaps.has(target)) {
            Module.bufferMaps.set(target, new Uint8Array(target));
          }
          const targetBytes = Module.bufferMaps.get(target);
          return targetBytes[property] !== "undefined";
        }
        if (!check_empty) {
          return property in target;
        } else {
          return !!target[property];
        }
      },
      1967134: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = UTF8ToString($1);
          delete target[property];
        })();
      },
      1967250: ($0, $1) => {
        (() => {
          const target = Module.targets.get($0);
          const property = $1;
          delete target[property];
        })();
      },
      1967352: $0 => {
        const target = Module.targets.get($0);
        let json;
        if (typeof target === "function") {
          json = JSON.stringify({});
        } else {
          try {
            json = JSON.stringify({
              ...target
            });
          } catch {
            json = JSON.stringify({});
          }
        }
        const jsRet = String(json);
        const len = lengthBytesUTF8(jsRet) + 1;
        const strLoc = _malloc(len);
        stringToUTF8(jsRet, strLoc, len);
        return strLoc;
      },
      1967704: ($0, $1) => {
        const target = Module.targets.get($0);
        const property = UTF8ToString($1);
        return property in target;
      },
      1967809: $0 => {
        const target = Module.targets.get($0);
        const name = target.constructor && target.constructor.name || "Object";
        const len = lengthBytesUTF8(name) + 1;
        const namePtr = _malloc(name);
        stringToUTF8(name, namePtr, len);
        return namePtr;
      },
      1968046: ($0, $1, $2, $3, $4) => {
        const target = Module.targets.get($0);
        const method_name = UTF8ToString($1);
        const argp = $2;
        const argc = $3;
        const size = $4;
        const args = [];
        for (let i = 0; i < argc; i++) {
          const loc = argp + i * size;
          const ptr = Module.getValue(loc, "*");
          const arg = Module.zvalToJS(ptr);
          args.push(arg);
        }
        const jsRet = target[method_name](...args);
        const retZval = Module.jsToZval(jsRet);
        return retZval;
      },
      1968447: ($0, $1, $2, $3) => {
        const target = Module.targets.get($0);
        const argv = $1;
        const argc = $2;
        const size = $3;
        const args = [];
        for (let i = 0; i < argc; i++) {
          args.push(Module.zvalToJS(argv + i * size));
        }
        const jsRet = target(...args);
        return Module.jsToZval(jsRet);
      },
      1968699: ($0, $1) => {
        const target = Module.targets.get($0);
        const property_name = UTF8ToString($1);
        const jsRet = target[property_name];
        return Module.jsToZval(jsRet);
      },
      1968850: ($0, $1, $2, $3) => {
        const _class = Module._classes.get($0);
        const argv = $1;
        const argc = $2;
        const size = $3;
        const args = [];
        for (let i = 0; i < argc; i++) {
          args.push(Module.zvalToJS(argv + i * size));
        }
        const _object = new _class(...args);
        const index = Module.targets.add(_object);
        return index;
      },
      1969135: $0 => {
        const jsRet = String(eval(UTF8ToString($0)));
        const len = lengthBytesUTF8(jsRet) + 1;
        const strLoc = _malloc(len);
        stringToUTF8(jsRet, strLoc, len);
        return strLoc;
      },
      1969303: ($0, $1) => {
        const funcName = UTF8ToString($0);
        const argJson = UTF8ToString($1);
        const func = globalThis[funcName];
        const args = JSON.parse(argJson || "[]") || [];
        const jsRet = String(func(...args));
        const len = lengthBytesUTF8(jsRet) + 1;
        const strLoc = _malloc(len);
        stringToUTF8(jsRet, strLoc, len);
        return strLoc;
      },
      1969614: ($0, $1) => {
        const timeout = Number(UTF8ToString($0));
        const funcPtr = $1;
        setTimeout(() => {
          Module.ccall("vrzno_exec_callback", "number", ["number", "number", "number"], [funcPtr, null, 0]);
          Module.ccall("vrzno_del_callback", "number", ["number"], [funcPtr]);
        }, timeout);
      },
      1969886: $0 => Module.jsToZval(Module[UTF8ToString($0)]),
      1969940: ($0, $1, $2, $3) => {
        const _class = Module.targets.get($0);
        const argv = $1;
        const argc = $2;
        const size = $3;
        const args = [];
        for (let i = 0; i < argc; i++) {
          args.push(Module.zvalToJS(argv + i * size));
        }
        const _object = new _class(...args);
        return Module.jsToZval(_object);
      },
      1970200: $0 => {
        const name = UTF8ToString($0);
        return Module.jsToZval(__webpack_require__("../packages/php-cgi-wasm lazy recursive")(name));
      },
      1970273: $0 => {
        const target = Module.targets.get($0);
        return Module.classes.get(target);
      },
      1970351: ($0, $1) => {
        const target = Module.targets.get($0);
        Module.classes.set(target, $1);
        Module._classes.set($1, target);
      },
      1970459: $0 => {
        const results = Module.targets.get($0);
        if (results) {
          return results.length;
        }
        return 0;
      },
      1970552: $0 => {
        const results = Module.targets.get($0);
        if (results.length) {
          return Object.keys(results[0]).length;
        }
        return 0;
      },
      1970668: ($0, $1) => {
        const targetId = $0;
        const target = Module.targets.get(targetId);
        const current = $1;
        if (current >= target.length) {
          return null;
        }
        return Module.jsToZval(target[current]);
      },
      1970845: ($0, $1) => {
        const results = Module.targets.get($0);
        if (results.length) {
          const jsRet = Object.keys(results[0])[$1];
          const len = lengthBytesUTF8(jsRet) + 1;
          const strLoc = _malloc(len);
          stringToUTF8(jsRet, strLoc, len);
          return strLoc;
        }
        return 0;
      },
      1971083: ($0, $1, $2) => {
        const results = Module.targets.get($0);
        const current = -1 + $1;
        if (current >= results.length) {
          return null;
        }
        const result = results[current];
        const key = Object.keys(result)[$2];
        const zval = Module.jsToZval(result[key]);
        return zval;
      },
      1971343: ($0, $1) => {
        const statement = Module.targets.get($0);
        const paramVal = Module.zvalToJS($1);
        if (!Module.PdoParams.has(statement)) {
          Module.PdoParams.set(statement, []);
        }
        const paramList = Module.PdoParams.get(statement);
        paramList.push(paramVal);
      },
      1971582: ($0, $1, $2) => {
        console.log("GET ATTR", $0, $1, $2);
      },
      1971623: ($0, $1, $2) => {
        console.log("COL META", $0, $1, $2);
      },
      1971664: ($0, $1, $2) => {
        console.log("CLOSE", $0, $1, $2);
      },
      1971702: $0 => {
        console.log("CLOSE", $0);
      },
      1971732: ($0, $1) => {
        const target = Module.targets.get($0);
        const query = UTF8ToString($1);
        if (Module.pdoDriver && Module.pdoDriver.prepare) {
          const prepared = Module.pdoDriver.prepare(target, query);
          const zval = Module.jsToZval(prepared);
          return zval;
        }
        return null;
      },
      1971984: ($0, $1) => {
        console.log("DO", $0, UTF8ToString($1));
        const target = Module.targets.get($0);
        const query = UTF8ToString($1);
        if (Module.pdoDriver && Module.pdoDriver.doer) {
          return Module.pdoDriver.doer(target, query);
        }
        return 1;
      },
      1972205: $0 => {
        console.log("BEGIN TXN", $0);
        return true;
      },
      1972252: $0 => {
        console.log("COMMIT TXN", $0);
        return true;
      },
      1972300: $0 => {
        console.log("ROLLBACK TXN", $0);
        return true;
      },
      1972350: ($0, $1, $2) => {
        console.log("SET ATTR", $0, $1, $2);
        return true;
      },
      1972404: ($0, $1) => {
        console.log("LAST INSERT ID", $0, UTF8ToString($1));
        return 0;
      },
      1972471: ($0, $1, $2) => {
        console.log("FETCH ERROR FUNC", $0, $1, $2);
      },
      1972520: ($0, $1, $2) => {
        console.log("GET ATTR", $0, $1, $2);
        return 0;
      },
      1972571: $0 => {
        console.log("SHUTDOWN", $0);
      },
      1972604: ($0, $1) => {
        console.log("GET GC", $0, $1);
      },
      1972639: () => Module.targets.getId(globalThis),
      1972684: ($0, $1) => {
        let target = Module.targets.get($0);
        const property = $1;
        if (target instanceof ArrayBuffer) {
          if (!Module.bufferMaps.has(target)) {
            Module.bufferMaps.set(target, new Uint8Array(target));
          }
          target = Module.bufferMaps.get(target);
        }
        if (Array.isArray(target) || ArrayBuffer.isView(target)) {
          if (property >= 0 && property < target.length) {
            return 1;
          }
        }
        return 0;
      },
      1973047: ($0, $1) => {
        let target = Module.targets.get($0);
        const property = $1;
        if (target instanceof ArrayBuffer) {
          if (!Module.bufferMaps.has(target)) {
            Module.bufferMaps.set(target, new Uint8Array(target));
          }
          target = Module.bufferMaps.get(target);
        }
        return Module.jsToZval(target[property]);
      }
    };
    function __asyncjs__vrzno_await_internal(targetId) {
      return Asyncify.handleAsync(async () => {
        const target = Module.targets.get(targetId);
        const result = await target;
        return Module.jsToZval(result);
      });
    }
    __asyncjs__vrzno_await_internal.sig = "ii";
    function __asyncjs__pdo_vrzno_real_stmt_execute(targetId) {
      return Asyncify.handleAsync(async () => {
        let statement = Module.targets.get(targetId);
        if (!Module.PdoParams.has(statement)) {
          Module.PdoParams.set(statement, []);
        }
        const paramList = Module.PdoParams.get(statement);
        const bound = paramList.length ? statement.bind(...paramList) : statement;
        const result = await bound.run();
        Module.PdoParams.delete(statement);
        if (!result.success) {
          return false;
        }
        return Module.jsToZval(result.results);
      });
    }
    __asyncjs__pdo_vrzno_real_stmt_execute.sig = "ii";
    function ExitStatus(status) {
      this.name = "ExitStatus";
      this.message = `Program terminated with exit(${status})`;
      this.status = status;
    }
    var GOT = {};
    var currentModuleWeakSymbols = new Set([]);
    var GOTHandler = {
      get(obj, symName) {
        var rtn = GOT[symName];
        if (!rtn) {
          rtn = GOT[symName] = new WebAssembly.Global({
            value: "i32",
            mutable: true
          });
        }
        if (!currentModuleWeakSymbols.has(symName)) {
          rtn.required = true;
        }
        return rtn;
      }
    };
    var callRuntimeCallbacks = callbacks => {
      while (callbacks.length > 0) {
        callbacks.shift()(Module);
      }
    };
    var UTF8Decoder = typeof TextDecoder != "undefined" ? new TextDecoder("utf8") : undefined;
    var UTF8ArrayToString = (heapOrArray, idx, maxBytesToRead) => {
      idx >>>= 0;
      var endIdx = idx + maxBytesToRead;
      var endPtr = idx;
      while (heapOrArray[endPtr] && !(endPtr >= endIdx)) ++endPtr;
      if (endPtr - idx > 16 && heapOrArray.buffer && UTF8Decoder) {
        return UTF8Decoder.decode(heapOrArray.subarray(idx, endPtr));
      }
      var str = "";
      while (idx < endPtr) {
        var u0 = heapOrArray[idx++];
        if (!(u0 & 128)) {
          str += String.fromCharCode(u0);
          continue;
        }
        var u1 = heapOrArray[idx++] & 63;
        if ((u0 & 224) == 192) {
          str += String.fromCharCode((u0 & 31) << 6 | u1);
          continue;
        }
        var u2 = heapOrArray[idx++] & 63;
        if ((u0 & 240) == 224) {
          u0 = (u0 & 15) << 12 | u1 << 6 | u2;
        } else {
          u0 = (u0 & 7) << 18 | u1 << 12 | u2 << 6 | heapOrArray[idx++] & 63;
        }
        if (u0 < 65536) {
          str += String.fromCharCode(u0);
        } else {
          var ch = u0 - 65536;
          str += String.fromCharCode(55296 | ch >> 10, 56320 | ch & 1023);
        }
      }
      return str;
    };
    var getDylinkMetadata = binary => {
      var offset = 0;
      var end = 0;
      function getU8() {
        return binary[offset++];
      }
      function getLEB() {
        var ret = 0;
        var mul = 1;
        while (1) {
          var byte = binary[offset++];
          ret += (byte & 127) * mul;
          mul *= 128;
          if (!(byte & 128)) break;
        }
        return ret;
      }
      function getString() {
        var len = getLEB();
        offset += len;
        return UTF8ArrayToString(binary, offset - len, len);
      }
      function failIf(condition, message) {
        if (condition) throw new Error(message);
      }
      var name = "dylink.0";
      if (binary instanceof WebAssembly.Module) {
        var dylinkSection = WebAssembly.Module.customSections(binary, name);
        if (dylinkSection.length === 0) {
          name = "dylink";
          dylinkSection = WebAssembly.Module.customSections(binary, name);
        }
        failIf(dylinkSection.length === 0, "need dylink section");
        binary = new Uint8Array(dylinkSection[0]);
        end = binary.length;
      } else {
        var int32View = new Uint32Array(new Uint8Array(binary.subarray(0, 24)).buffer);
        var magicNumberFound = int32View[0] == 1836278016;
        failIf(!magicNumberFound, "need to see wasm magic number");
        failIf(binary[8] !== 0, "need the dylink section to be first");
        offset = 9;
        var section_size = getLEB();
        end = offset + section_size;
        name = getString();
      }
      var customSection = {
        neededDynlibs: [],
        tlsExports: new Set(),
        weakImports: new Set()
      };
      if (name == "dylink") {
        customSection.memorySize = getLEB();
        customSection.memoryAlign = getLEB();
        customSection.tableSize = getLEB();
        customSection.tableAlign = getLEB();
        var neededDynlibsCount = getLEB();
        for (var i = 0; i < neededDynlibsCount; ++i) {
          var libname = getString();
          customSection.neededDynlibs.push(libname);
        }
      } else {
        failIf(name !== "dylink.0");
        var WASM_DYLINK_MEM_INFO = 1;
        var WASM_DYLINK_NEEDED = 2;
        var WASM_DYLINK_EXPORT_INFO = 3;
        var WASM_DYLINK_IMPORT_INFO = 4;
        var WASM_SYMBOL_TLS = 256;
        var WASM_SYMBOL_BINDING_MASK = 3;
        var WASM_SYMBOL_BINDING_WEAK = 1;
        while (offset < end) {
          var subsectionType = getU8();
          var subsectionSize = getLEB();
          if (subsectionType === WASM_DYLINK_MEM_INFO) {
            customSection.memorySize = getLEB();
            customSection.memoryAlign = getLEB();
            customSection.tableSize = getLEB();
            customSection.tableAlign = getLEB();
          } else if (subsectionType === WASM_DYLINK_NEEDED) {
            var neededDynlibsCount = getLEB();
            for (var i = 0; i < neededDynlibsCount; ++i) {
              libname = getString();
              customSection.neededDynlibs.push(libname);
            }
          } else if (subsectionType === WASM_DYLINK_EXPORT_INFO) {
            var count = getLEB();
            while (count--) {
              var symname = getString();
              var flags = getLEB();
              if (flags & WASM_SYMBOL_TLS) {
                customSection.tlsExports.add(symname);
              }
            }
          } else if (subsectionType === WASM_DYLINK_IMPORT_INFO) {
            var count = getLEB();
            while (count--) {
              var modname = getString();
              var symname = getString();
              var flags = getLEB();
              if ((flags & WASM_SYMBOL_BINDING_MASK) == WASM_SYMBOL_BINDING_WEAK) {
                customSection.weakImports.add(symname);
              }
            }
          } else {
            offset += subsectionSize;
          }
        }
      }
      return customSection;
    };
    function getValue(ptr, type = "i8") {
      if (type.endsWith("*")) type = "*";
      switch (type) {
        case "i1":
          return HEAP8[ptr >>> 0];
        case "i8":
          return HEAP8[ptr >>> 0];
        case "i16":
          return HEAP16[ptr >>> 1 >>> 0];
        case "i32":
          return HEAP32[ptr >>> 2 >>> 0];
        case "i64":
          abort("to do getValue(i64) use WASM_BIGINT");
        case "float":
          return HEAPF32[ptr >>> 2 >>> 0];
        case "double":
          return HEAPF64[ptr >>> 3 >>> 0];
        case "*":
          return HEAPU32[ptr >>> 2 >>> 0];
        default:
          abort(`invalid type for getValue: ${type}`);
      }
    }
    var newDSO = (name, handle, syms) => {
      var dso = {
        refcount: Infinity,
        name: name,
        exports: syms,
        global: true
      };
      LDSO.loadedLibsByName[name] = dso;
      if (handle != undefined) {
        LDSO.loadedLibsByHandle[handle] = dso;
      }
      return dso;
    };
    var LDSO = {
      loadedLibsByName: {},
      loadedLibsByHandle: {},
      init() {
        newDSO("__main__", 0, wasmImports);
      }
    };
    var ___heap_base = 35638976;
    var zeroMemory = (address, size) => {
      HEAPU8.fill(0, address, address + size);
      return address;
    };
    var alignMemory = (size, alignment) => Math.ceil(size / alignment) * alignment;
    var getMemory = size => {
      if (runtimeInitialized) {
        return zeroMemory(_malloc(size), size);
      }
      var ret = ___heap_base;
      var end = ret + alignMemory(size, 16);
      ___heap_base = end;
      GOT["__heap_base"].value = end;
      return ret;
    };
    var isInternalSym = symName => ["__cpp_exception", "__c_longjmp", "__wasm_apply_data_relocs", "__dso_handle", "__tls_size", "__tls_align", "__set_stack_limits", "_emscripten_tls_init", "__wasm_init_tls", "__wasm_call_ctors", "__start_em_asm", "__stop_em_asm", "__start_em_js", "__stop_em_js"].includes(symName) || symName.startsWith("__em_js__");
    var uleb128Encode = (n, target) => {
      if (n < 128) {
        target.push(n);
      } else {
        target.push(n % 128 | 128, n >> 7);
      }
    };
    var sigToWasmTypes = sig => {
      var typeNames = {
        i: "i32",
        j: "i64",
        f: "f32",
        d: "f64",
        e: "externref",
        p: "i32"
      };
      var type = {
        parameters: [],
        results: sig[0] == "v" ? [] : [typeNames[sig[0]]]
      };
      for (var i = 1; i < sig.length; ++i) {
        type.parameters.push(typeNames[sig[i]]);
      }
      return type;
    };
    var generateFuncType = (sig, target) => {
      var sigRet = sig.slice(0, 1);
      var sigParam = sig.slice(1);
      var typeCodes = {
        i: 127,
        p: 127,
        j: 126,
        f: 125,
        d: 124,
        e: 111
      };
      target.push(96);
      uleb128Encode(sigParam.length, target);
      for (var i = 0; i < sigParam.length; ++i) {
        target.push(typeCodes[sigParam[i]]);
      }
      if (sigRet == "v") {
        target.push(0);
      } else {
        target.push(1, typeCodes[sigRet]);
      }
    };
    var convertJsFunctionToWasm = (func, sig) => {
      if (typeof WebAssembly.Function == "function") {
        return new WebAssembly.Function(sigToWasmTypes(sig), func);
      }
      var typeSectionBody = [1];
      generateFuncType(sig, typeSectionBody);
      var bytes = [0, 97, 115, 109, 1, 0, 0, 0, 1];
      uleb128Encode(typeSectionBody.length, bytes);
      bytes.push(...typeSectionBody);
      bytes.push(2, 7, 1, 1, 101, 1, 102, 0, 0, 7, 5, 1, 1, 102, 0, 0);
      var module = new WebAssembly.Module(new Uint8Array(bytes));
      var instance = new WebAssembly.Instance(module, {
        e: {
          f: func
        }
      });
      var wrappedFunc = instance.exports["f"];
      return wrappedFunc;
    };
    var wasmTableMirror = [];
    var wasmTable = new WebAssembly.Table({
      initial: 4462,
      element: "anyfunc"
    });
    var getWasmTableEntry = funcPtr => {
      var func = wasmTableMirror[funcPtr];
      if (!func) {
        if (funcPtr >= wasmTableMirror.length) wasmTableMirror.length = funcPtr + 1;
        wasmTableMirror[funcPtr] = func = wasmTable.get(funcPtr);
      }
      return func;
    };
    var updateTableMap = (offset, count) => {
      if (functionsInTableMap) {
        for (var i = offset; i < offset + count; i++) {
          var item = getWasmTableEntry(i);
          if (item) {
            functionsInTableMap.set(item, i);
          }
        }
      }
    };
    var functionsInTableMap;
    var getFunctionAddress = func => {
      if (!functionsInTableMap) {
        functionsInTableMap = new WeakMap();
        updateTableMap(0, wasmTable.length);
      }
      return functionsInTableMap.get(func) || 0;
    };
    var freeTableIndexes = [];
    var getEmptyTableSlot = () => {
      if (freeTableIndexes.length) {
        return freeTableIndexes.pop();
      }
      try {
        wasmTable.grow(1);
      } catch (err) {
        if (!(err instanceof RangeError)) {
          throw err;
        }
        throw "Unable to grow wasm table. Set ALLOW_TABLE_GROWTH.";
      }
      return wasmTable.length - 1;
    };
    var setWasmTableEntry = (idx, func) => {
      wasmTable.set(idx, func);
      wasmTableMirror[idx] = wasmTable.get(idx);
    };
    var addFunction = (func, sig) => {
      var rtn = getFunctionAddress(func);
      if (rtn) {
        return rtn;
      }
      var ret = getEmptyTableSlot();
      try {
        setWasmTableEntry(ret, func);
      } catch (err) {
        if (!(err instanceof TypeError)) {
          throw err;
        }
        var wrapped = convertJsFunctionToWasm(func, sig);
        setWasmTableEntry(ret, wrapped);
      }
      functionsInTableMap.set(func, ret);
      return ret;
    };
    var updateGOT = (exports, replace) => {
      for (var symName in exports) {
        if (isInternalSym(symName)) {
          continue;
        }
        var value = exports[symName];
        if (symName.startsWith("orig$")) {
          symName = symName.split("$")[1];
          replace = true;
        }
        GOT[symName] ||= new WebAssembly.Global({
          value: "i32",
          mutable: true
        });
        if (replace || GOT[symName].value == 0) {
          if (typeof value == "function") {
            GOT[symName].value = addFunction(value);
          } else if (typeof value == "number") {
            GOT[symName].value = value;
          } else {
            err(`unhandled export type for '${symName}': ${typeof value}`);
          }
        }
      }
    };
    var relocateExports = (exports, memoryBase, replace) => {
      var relocated = {};
      for (var e in exports) {
        var value = exports[e];
        if (typeof value == "object") {
          value = value.value;
        }
        if (typeof value == "number") {
          value += memoryBase;
        }
        relocated[e] = value;
      }
      updateGOT(relocated, replace);
      return relocated;
    };
    var isSymbolDefined = symName => {
      var existing = wasmImports[symName];
      if (!existing || existing.stub) {
        return false;
      }
      if (symName in asyncifyStubs && !asyncifyStubs[symName]) {
        return false;
      }
      return true;
    };
    var dynCallLegacy = (sig, ptr, args) => {
      sig = sig.replace(/p/g, "i");
      var f = Module["dynCall_" + sig];
      return f(ptr, ...args);
    };
    var dynCall = (sig, ptr, args = []) => {
      var rtn = dynCallLegacy(sig, ptr, args);
      return sig[0] == "p" ? rtn >>> 0 : rtn;
    };
    var stackSave = () => _emscripten_stack_get_current();
    var stackRestore = val => __emscripten_stack_restore(val);
    var createInvokeFunction = sig => (ptr, ...args) => {
      var sp = stackSave();
      try {
        return dynCall(sig, ptr, args);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    };
    var resolveGlobalSymbol = (symName, direct = false) => {
      var sym;
      if (direct && "orig$" + symName in wasmImports) {
        symName = "orig$" + symName;
      }
      if (isSymbolDefined(symName)) {
        sym = wasmImports[symName];
      } else if (symName.startsWith("invoke_")) {
        sym = wasmImports[symName] = createInvokeFunction(symName.split("_")[1]);
      }
      return {
        sym: sym,
        name: symName
      };
    };
    var UTF8ToString = (ptr, maxBytesToRead) => {
      ptr >>>= 0;
      return ptr ? UTF8ArrayToString(HEAPU8, ptr, maxBytesToRead) : "";
    };
    var loadWebAssemblyModule = (binary, flags, libName, localScope, handle) => {
      var metadata = getDylinkMetadata(binary);
      currentModuleWeakSymbols = metadata.weakImports;
      function loadModule() {
        var firstLoad = !handle || !HEAP8[handle + 8 >>> 0];
        if (firstLoad) {
          var memAlign = Math.pow(2, metadata.memoryAlign);
          var memoryBase = metadata.memorySize ? alignMemory(getMemory(metadata.memorySize + memAlign), memAlign) : 0;
          var tableBase = metadata.tableSize ? wasmTable.length : 0;
          if (handle) {
            HEAP8[handle + 8 >>> 0] = 1;
            HEAPU32[handle + 12 >>> 2 >>> 0] = memoryBase;
            HEAP32[handle + 16 >>> 2 >>> 0] = metadata.memorySize;
            HEAPU32[handle + 20 >>> 2 >>> 0] = tableBase;
            HEAP32[handle + 24 >>> 2 >>> 0] = metadata.tableSize;
          }
        } else {
          memoryBase = HEAPU32[handle + 12 >>> 2 >>> 0];
          tableBase = HEAPU32[handle + 20 >>> 2 >>> 0];
        }
        var tableGrowthNeeded = tableBase + metadata.tableSize - wasmTable.length;
        if (tableGrowthNeeded > 0) {
          wasmTable.grow(tableGrowthNeeded);
        }
        var moduleExports;
        function resolveSymbol(sym) {
          var resolved = resolveGlobalSymbol(sym).sym;
          if (!resolved && localScope) {
            resolved = localScope[sym];
          }
          if (!resolved) {
            resolved = moduleExports[sym];
          }
          return resolved;
        }
        var proxyHandler = {
          get(stubs, prop) {
            switch (prop) {
              case "__memory_base":
                return memoryBase;
              case "__table_base":
                return tableBase;
            }
            if (prop in wasmImports && !wasmImports[prop].stub) {
              return wasmImports[prop];
            }
            if (!(prop in stubs)) {
              var resolved;
              stubs[prop] = (...args) => {
                resolved ||= resolveSymbol(prop);
                return resolved(...args);
              };
            }
            return stubs[prop];
          }
        };
        var proxy = new Proxy({}, proxyHandler);
        var info = {
          "GOT.mem": new Proxy({}, GOTHandler),
          "GOT.func": new Proxy({}, GOTHandler),
          env: proxy,
          wasi_snapshot_preview1: proxy
        };
        function postInstantiation(module, instance) {
          updateTableMap(tableBase, metadata.tableSize);
          moduleExports = relocateExports(instance.exports, memoryBase);
          moduleExports = Asyncify.instrumentWasmExports(moduleExports);
          if (!flags.allowUndefined) {
            reportUndefinedSymbols();
          }
          function addEmAsm(addr, body) {
            var args = [];
            var arity = 0;
            for (; arity < 16; arity++) {
              if (body.indexOf("$" + arity) != -1) {
                args.push("$" + arity);
              } else {
                break;
              }
            }
            args = args.join(",");
            var func = `(${args}) => { ${body} };`;
            ASM_CONSTS[start] = eval(func);
          }
          if ("__start_em_asm" in moduleExports) {
            var start = moduleExports["__start_em_asm"];
            var stop = moduleExports["__stop_em_asm"];
            while (start < stop) {
              var jsString = UTF8ToString(start);
              addEmAsm(start, jsString);
              start = HEAPU8.indexOf(0, start) + 1;
            }
          }
          function addEmJs(name, cSig, body) {
            var jsArgs = [];
            cSig = cSig.slice(1, -1);
            if (cSig != "void") {
              cSig = cSig.split(",");
              for (var i in cSig) {
                var jsArg = cSig[i].split(" ").pop();
                jsArgs.push(jsArg.replace("*", ""));
              }
            }
            var func = `(${jsArgs}) => ${body};`;
            moduleExports[name] = eval(func);
          }
          for (var name in moduleExports) {
            if (name.startsWith("__em_js__")) {
              var start = moduleExports[name];
              var jsString = UTF8ToString(start);
              var parts = jsString.split("<::>");
              addEmJs(name.replace("__em_js__", ""), parts[0], parts[1]);
              delete moduleExports[name];
            }
          }
          var applyRelocs = moduleExports["__wasm_apply_data_relocs"];
          if (applyRelocs) {
            if (runtimeInitialized) {
              applyRelocs();
            } else {
              __RELOC_FUNCS__.push(applyRelocs);
            }
          }
          var init = moduleExports["__wasm_call_ctors"];
          if (init) {
            if (runtimeInitialized) {
              init();
            } else {
              __ATINIT__.push(init);
            }
          }
          return moduleExports;
        }
        if (flags.loadAsync) {
          if (binary instanceof WebAssembly.Module) {
            var instance = new WebAssembly.Instance(binary, info);
            return Promise.resolve(postInstantiation(binary, instance));
          }
          return WebAssembly.instantiate(binary, info).then(result => postInstantiation(result.module, result.instance));
        }
        var module = binary instanceof WebAssembly.Module ? binary : new WebAssembly.Module(binary);
        var instance = new WebAssembly.Instance(module, info);
        return postInstantiation(module, instance);
      }
      if (flags.loadAsync) {
        return metadata.neededDynlibs.reduce((chain, dynNeeded) => chain.then(() => loadDynamicLibrary(dynNeeded, flags)), Promise.resolve()).then(loadModule);
      }
      metadata.neededDynlibs.forEach(needed => loadDynamicLibrary(needed, flags, localScope));
      return loadModule();
    };
    var mergeLibSymbols = (exports, libName) => {
      for (var [sym, exp] of Object.entries(exports)) {
        const setImport = target => {
          if (target in asyncifyStubs) {
            asyncifyStubs[target] = exp;
          }
          if (!isSymbolDefined(target)) {
            wasmImports[target] = exp;
          }
        };
        setImport(sym);
        if (sym.startsWith("dynCall_") && !Module.hasOwnProperty(sym)) {
          Module[sym] = exp;
        }
      }
    };
    var asyncLoad = (url, onload, onerror, noRunDep) => {
      var dep = !noRunDep ? getUniqueRunDependency(`al ${url}`) : "";
      readAsync(url, arrayBuffer => {
        onload(new Uint8Array(arrayBuffer));
        if (dep) removeRunDependency(dep);
      }, event => {
        if (onerror) {
          onerror();
        } else {
          throw `Loading data file "${url}" failed.`;
        }
      });
      if (dep) addRunDependency(dep);
    };
    var preloadPlugins = Module["preloadPlugins"] || [];
    var registerWasmPlugin = () => {
      var wasmPlugin = {
        promiseChainEnd: Promise.resolve(),
        canHandle: name => !Module.noWasmDecoding && name.endsWith(".so"),
        handle: (byteArray, name, onload, onerror) => {
          wasmPlugin["promiseChainEnd"] = wasmPlugin["promiseChainEnd"].then(() => loadWebAssemblyModule(byteArray, {
            loadAsync: true,
            nodelete: true
          }, name)).then(exports => {
            preloadedWasm[name] = exports;
            onload(byteArray);
          }, error => {
            err(`failed to instantiate wasm: ${name}: ${error}`);
            onerror();
          });
        }
      };
      preloadPlugins.push(wasmPlugin);
    };
    var preloadedWasm = {};
    function loadDynamicLibrary(libName, flags = {
      global: true,
      nodelete: true
    }, localScope, handle) {
      var dso = LDSO.loadedLibsByName[libName];
      if (dso) {
        if (!flags.global) {
          if (localScope) {
            Object.assign(localScope, dso.exports);
          }
        } else if (!dso.global) {
          dso.global = true;
          mergeLibSymbols(dso.exports, libName);
        }
        if (flags.nodelete && dso.refcount !== Infinity) {
          dso.refcount = Infinity;
        }
        dso.refcount++;
        if (handle) {
          LDSO.loadedLibsByHandle[handle] = dso;
        }
        return flags.loadAsync ? Promise.resolve(true) : true;
      }
      dso = newDSO(libName, handle, "loading");
      dso.refcount = flags.nodelete ? Infinity : 1;
      dso.global = flags.global;
      function loadLibData() {
        if (handle) {
          var data = HEAPU32[handle + 28 >>> 2 >>> 0];
          var dataSize = HEAPU32[handle + 32 >>> 2 >>> 0];
          if (data && dataSize) {
            var libData = HEAP8.slice(data, data + dataSize);
            return flags.loadAsync ? Promise.resolve(libData) : libData;
          }
        }
        var libFile = locateFile(libName);
        if (flags.loadAsync) {
          return new Promise(function (resolve, reject) {
            asyncLoad(libFile, resolve, reject);
          });
        }
        if (!readBinary) {
          throw new Error(`${libFile}: file not found, and synchronous loading of external files is not available`);
        }
        return readBinary(libFile);
      }
      function getExports() {
        var preloaded = preloadedWasm[libName];
        if (preloaded) {
          return flags.loadAsync ? Promise.resolve(preloaded) : preloaded;
        }
        if (flags.loadAsync) {
          return loadLibData().then(libData => loadWebAssemblyModule(libData, flags, libName, localScope, handle));
        }
        return loadWebAssemblyModule(loadLibData(), flags, libName, localScope, handle);
      }
      function moduleLoaded(exports) {
        if (dso.global) {
          mergeLibSymbols(exports, libName);
        } else if (localScope) {
          Object.assign(localScope, exports);
        }
        dso.exports = exports;
      }
      if (flags.loadAsync) {
        return getExports().then(exports => {
          moduleLoaded(exports);
          return true;
        });
      }
      moduleLoaded(getExports());
      return true;
    }
    var reportUndefinedSymbols = () => {
      for (var [symName, entry] of Object.entries(GOT)) {
        if (entry.value == 0) {
          var value = resolveGlobalSymbol(symName, true).sym;
          if (!value && !entry.required) {
            continue;
          }
          if (typeof value == "function") {
            entry.value = addFunction(value, value.sig);
          } else if (typeof value == "number") {
            entry.value = value;
          } else {
            throw new Error(`bad export type for '${symName}': ${typeof value}`);
          }
        }
      }
    };
    var loadDylibs = () => {
      if (!dynamicLibraries.length) {
        reportUndefinedSymbols();
        return;
      }
      addRunDependency("loadDylibs");
      dynamicLibraries.reduce((chain, lib) => chain.then(() => loadDynamicLibrary(lib, {
        loadAsync: true,
        global: true,
        nodelete: true,
        allowUndefined: true
      })), Promise.resolve()).then(() => {
        reportUndefinedSymbols();
        removeRunDependency("loadDylibs");
      });
    };
    var noExitRuntime = Module["noExitRuntime"] || false;
    var convertI32PairToI53Checked = (lo, hi) => hi + 2097152 >>> 0 < 4194305 - !!lo ? (lo >>> 0) + hi * 4294967296 : NaN;
    function ___assert_fail(condition, filename, line, func) {
      condition >>>= 0;
      filename >>>= 0;
      func >>>= 0;
      abort(`Assertion failed: ${UTF8ToString(condition)}, at: ` + [filename ? UTF8ToString(filename) : "unknown filename", line, func ? UTF8ToString(func) : "unknown function"]);
    }
    ___assert_fail.sig = "vppip";
    var ___asyncify_data = new WebAssembly.Global({
      value: "i32",
      mutable: true
    }, 0);
    var ___asyncify_state = new WebAssembly.Global({
      value: "i32",
      mutable: true
    }, 0);
    var ___call_sighandler = function (fp, sig) {
      fp >>>= 0;
      return (a1 => dynCall_vi(fp, a1))(sig);
    };
    ___call_sighandler.sig = "vpi";
    var ___memory_base = new WebAssembly.Global({
      value: "i32",
      mutable: false
    }, 1024);
    var ___stack_pointer = new WebAssembly.Global({
      value: "i32",
      mutable: true
    }, 35638976);
    var PATH = {
      isAbs: path => path.charAt(0) === "/",
      splitPath: filename => {
        var splitPathRe = /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/;
        return splitPathRe.exec(filename).slice(1);
      },
      normalizeArray: (parts, allowAboveRoot) => {
        var up = 0;
        for (var i = parts.length - 1; i >= 0; i--) {
          var last = parts[i];
          if (last === ".") {
            parts.splice(i, 1);
          } else if (last === "..") {
            parts.splice(i, 1);
            up++;
          } else if (up) {
            parts.splice(i, 1);
            up--;
          }
        }
        if (allowAboveRoot) {
          for (; up; up--) {
            parts.unshift("..");
          }
        }
        return parts;
      },
      normalize: path => {
        var isAbsolute = PATH.isAbs(path),
          trailingSlash = path.substr(-1) === "/";
        path = PATH.normalizeArray(path.split("/").filter(p => !!p), !isAbsolute).join("/");
        if (!path && !isAbsolute) {
          path = ".";
        }
        if (path && trailingSlash) {
          path += "/";
        }
        return (isAbsolute ? "/" : "") + path;
      },
      dirname: path => {
        var result = PATH.splitPath(path),
          root = result[0],
          dir = result[1];
        if (!root && !dir) {
          return ".";
        }
        if (dir) {
          dir = dir.substr(0, dir.length - 1);
        }
        return root + dir;
      },
      basename: path => {
        if (path === "/") return "/";
        path = PATH.normalize(path);
        path = path.replace(/\/$/, "");
        var lastSlash = path.lastIndexOf("/");
        if (lastSlash === -1) return path;
        return path.substr(lastSlash + 1);
      },
      join: (...paths) => PATH.normalize(paths.join("/")),
      join2: (l, r) => PATH.normalize(l + "/" + r)
    };
    var initRandomFill = () => {
      if (typeof crypto == "object" && typeof crypto["getRandomValues"] == "function") {
        return view => crypto.getRandomValues(view);
      } else abort("initRandomDevice");
    };
    var randomFill = view => (randomFill = initRandomFill())(view);
    var PATH_FS = {
      resolve: (...args) => {
        var resolvedPath = "",
          resolvedAbsolute = false;
        for (var i = args.length - 1; i >= -1 && !resolvedAbsolute; i--) {
          var path = i >= 0 ? args[i] : FS.cwd();
          if (typeof path != "string") {
            throw new TypeError("Arguments to path.resolve must be strings");
          } else if (!path) {
            return "";
          }
          resolvedPath = path + "/" + resolvedPath;
          resolvedAbsolute = PATH.isAbs(path);
        }
        resolvedPath = PATH.normalizeArray(resolvedPath.split("/").filter(p => !!p), !resolvedAbsolute).join("/");
        return (resolvedAbsolute ? "/" : "") + resolvedPath || ".";
      },
      relative: (from, to) => {
        from = PATH_FS.resolve(from).substr(1);
        to = PATH_FS.resolve(to).substr(1);
        function trim(arr) {
          var start = 0;
          for (; start < arr.length; start++) {
            if (arr[start] !== "") break;
          }
          var end = arr.length - 1;
          for (; end >= 0; end--) {
            if (arr[end] !== "") break;
          }
          if (start > end) return [];
          return arr.slice(start, end - start + 1);
        }
        var fromParts = trim(from.split("/"));
        var toParts = trim(to.split("/"));
        var length = Math.min(fromParts.length, toParts.length);
        var samePartsLength = length;
        for (var i = 0; i < length; i++) {
          if (fromParts[i] !== toParts[i]) {
            samePartsLength = i;
            break;
          }
        }
        var outputParts = [];
        for (var i = samePartsLength; i < fromParts.length; i++) {
          outputParts.push("..");
        }
        outputParts = outputParts.concat(toParts.slice(samePartsLength));
        return outputParts.join("/");
      }
    };
    var FS_stdin_getChar_buffer = [];
    var lengthBytesUTF8 = str => {
      var len = 0;
      for (var i = 0; i < str.length; ++i) {
        var c = str.charCodeAt(i);
        if (c <= 127) {
          len++;
        } else if (c <= 2047) {
          len += 2;
        } else if (c >= 55296 && c <= 57343) {
          len += 4;
          ++i;
        } else {
          len += 3;
        }
      }
      return len;
    };
    var stringToUTF8Array = (str, heap, outIdx, maxBytesToWrite) => {
      outIdx >>>= 0;
      if (!(maxBytesToWrite > 0)) return 0;
      var startIdx = outIdx;
      var endIdx = outIdx + maxBytesToWrite - 1;
      for (var i = 0; i < str.length; ++i) {
        var u = str.charCodeAt(i);
        if (u >= 55296 && u <= 57343) {
          var u1 = str.charCodeAt(++i);
          u = 65536 + ((u & 1023) << 10) | u1 & 1023;
        }
        if (u <= 127) {
          if (outIdx >= endIdx) break;
          heap[outIdx++ >>> 0] = u;
        } else if (u <= 2047) {
          if (outIdx + 1 >= endIdx) break;
          heap[outIdx++ >>> 0] = 192 | u >> 6;
          heap[outIdx++ >>> 0] = 128 | u & 63;
        } else if (u <= 65535) {
          if (outIdx + 2 >= endIdx) break;
          heap[outIdx++ >>> 0] = 224 | u >> 12;
          heap[outIdx++ >>> 0] = 128 | u >> 6 & 63;
          heap[outIdx++ >>> 0] = 128 | u & 63;
        } else {
          if (outIdx + 3 >= endIdx) break;
          heap[outIdx++ >>> 0] = 240 | u >> 18;
          heap[outIdx++ >>> 0] = 128 | u >> 12 & 63;
          heap[outIdx++ >>> 0] = 128 | u >> 6 & 63;
          heap[outIdx++ >>> 0] = 128 | u & 63;
        }
      }
      heap[outIdx >>> 0] = 0;
      return outIdx - startIdx;
    };
    function intArrayFromString(stringy, dontAddNull, length) {
      var len = length > 0 ? length : lengthBytesUTF8(stringy) + 1;
      var u8array = new Array(len);
      var numBytesWritten = stringToUTF8Array(stringy, u8array, 0, u8array.length);
      if (dontAddNull) u8array.length = numBytesWritten;
      return u8array;
    }
    var FS_stdin_getChar = () => {
      if (!FS_stdin_getChar_buffer.length) {
        var result = null;
        {}
        if (!result) {
          return null;
        }
        FS_stdin_getChar_buffer = intArrayFromString(result, true);
      }
      return FS_stdin_getChar_buffer.shift();
    };
    var TTY = {
      ttys: [],
      init() {},
      shutdown() {},
      register(dev, ops) {
        TTY.ttys[dev] = {
          input: [],
          output: [],
          ops: ops
        };
        FS.registerDevice(dev, TTY.stream_ops);
      },
      stream_ops: {
        open(stream) {
          var tty = TTY.ttys[stream.node.rdev];
          if (!tty) {
            throw new FS.ErrnoError(43);
          }
          stream.tty = tty;
          stream.seekable = false;
        },
        close(stream) {
          stream.tty.ops.fsync(stream.tty);
        },
        fsync(stream) {
          stream.tty.ops.fsync(stream.tty);
        },
        read(stream, buffer, offset, length, pos) {
          if (!stream.tty || !stream.tty.ops.get_char) {
            throw new FS.ErrnoError(60);
          }
          var bytesRead = 0;
          for (var i = 0; i < length; i++) {
            var result;
            try {
              result = stream.tty.ops.get_char(stream.tty);
            } catch (e) {
              throw new FS.ErrnoError(29);
            }
            if (result === undefined && bytesRead === 0) {
              throw new FS.ErrnoError(6);
            }
            if (result === null || result === undefined) break;
            bytesRead++;
            buffer[offset + i] = result;
          }
          if (bytesRead) {
            stream.node.timestamp = Date.now();
          }
          return bytesRead;
        },
        write(stream, buffer, offset, length, pos) {
          if (!stream.tty || !stream.tty.ops.put_char) {
            throw new FS.ErrnoError(60);
          }
          try {
            for (var i = 0; i < length; i++) {
              stream.tty.ops.put_char(stream.tty, buffer[offset + i]);
            }
          } catch (e) {
            throw new FS.ErrnoError(29);
          }
          if (length) {
            stream.node.timestamp = Date.now();
          }
          return i;
        }
      },
      default_tty_ops: {
        get_char(tty) {
          return FS_stdin_getChar();
        },
        put_char(tty, val) {
          if (val === null || val === 10) {
            out(UTF8ArrayToString(tty.output, 0));
            tty.output = [];
          } else {
            if (val != 0) tty.output.push(val);
          }
        },
        fsync(tty) {
          if (tty.output && tty.output.length > 0) {
            out(UTF8ArrayToString(tty.output, 0));
            tty.output = [];
          }
        },
        ioctl_tcgets(tty) {
          return {
            c_iflag: 25856,
            c_oflag: 5,
            c_cflag: 191,
            c_lflag: 35387,
            c_cc: [3, 28, 127, 21, 4, 0, 1, 0, 17, 19, 26, 0, 18, 15, 23, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          };
        },
        ioctl_tcsets(tty, optional_actions, data) {
          return 0;
        },
        ioctl_tiocgwinsz(tty) {
          return [24, 80];
        }
      },
      default_tty1_ops: {
        put_char(tty, val) {
          if (val === null || val === 10) {
            err(UTF8ArrayToString(tty.output, 0));
            tty.output = [];
          } else {
            if (val != 0) tty.output.push(val);
          }
        },
        fsync(tty) {
          if (tty.output && tty.output.length > 0) {
            err(UTF8ArrayToString(tty.output, 0));
            tty.output = [];
          }
        }
      }
    };
    var mmapAlloc = size => {
      size = alignMemory(size, 65536);
      var ptr = _emscripten_builtin_memalign(65536, size);
      if (!ptr) return 0;
      return zeroMemory(ptr, size);
    };
    var MEMFS = {
      ops_table: null,
      mount(mount) {
        return MEMFS.createNode(null, "/", 16384 | 511, 0);
      },
      createNode(parent, name, mode, dev) {
        if (FS.isBlkdev(mode) || FS.isFIFO(mode)) {
          throw new FS.ErrnoError(63);
        }
        MEMFS.ops_table ||= {
          dir: {
            node: {
              getattr: MEMFS.node_ops.getattr,
              setattr: MEMFS.node_ops.setattr,
              lookup: MEMFS.node_ops.lookup,
              mknod: MEMFS.node_ops.mknod,
              rename: MEMFS.node_ops.rename,
              unlink: MEMFS.node_ops.unlink,
              rmdir: MEMFS.node_ops.rmdir,
              readdir: MEMFS.node_ops.readdir,
              symlink: MEMFS.node_ops.symlink
            },
            stream: {
              llseek: MEMFS.stream_ops.llseek
            }
          },
          file: {
            node: {
              getattr: MEMFS.node_ops.getattr,
              setattr: MEMFS.node_ops.setattr
            },
            stream: {
              llseek: MEMFS.stream_ops.llseek,
              read: MEMFS.stream_ops.read,
              write: MEMFS.stream_ops.write,
              allocate: MEMFS.stream_ops.allocate,
              mmap: MEMFS.stream_ops.mmap,
              msync: MEMFS.stream_ops.msync
            }
          },
          link: {
            node: {
              getattr: MEMFS.node_ops.getattr,
              setattr: MEMFS.node_ops.setattr,
              readlink: MEMFS.node_ops.readlink
            },
            stream: {}
          },
          chrdev: {
            node: {
              getattr: MEMFS.node_ops.getattr,
              setattr: MEMFS.node_ops.setattr
            },
            stream: FS.chrdev_stream_ops
          }
        };
        var node = FS.createNode(parent, name, mode, dev);
        if (FS.isDir(node.mode)) {
          node.node_ops = MEMFS.ops_table.dir.node;
          node.stream_ops = MEMFS.ops_table.dir.stream;
          node.contents = {};
        } else if (FS.isFile(node.mode)) {
          node.node_ops = MEMFS.ops_table.file.node;
          node.stream_ops = MEMFS.ops_table.file.stream;
          node.usedBytes = 0;
          node.contents = null;
        } else if (FS.isLink(node.mode)) {
          node.node_ops = MEMFS.ops_table.link.node;
          node.stream_ops = MEMFS.ops_table.link.stream;
        } else if (FS.isChrdev(node.mode)) {
          node.node_ops = MEMFS.ops_table.chrdev.node;
          node.stream_ops = MEMFS.ops_table.chrdev.stream;
        }
        node.timestamp = Date.now();
        if (parent) {
          parent.contents[name] = node;
          parent.timestamp = node.timestamp;
        }
        return node;
      },
      getFileDataAsTypedArray(node) {
        if (!node.contents) return new Uint8Array(0);
        if (node.contents.subarray) return node.contents.subarray(0, node.usedBytes);
        return new Uint8Array(node.contents);
      },
      expandFileStorage(node, newCapacity) {
        var prevCapacity = node.contents ? node.contents.length : 0;
        if (prevCapacity >= newCapacity) return;
        var CAPACITY_DOUBLING_MAX = 1024 * 1024;
        newCapacity = Math.max(newCapacity, prevCapacity * (prevCapacity < CAPACITY_DOUBLING_MAX ? 2 : 1.125) >>> 0);
        if (prevCapacity != 0) newCapacity = Math.max(newCapacity, 256);
        var oldContents = node.contents;
        node.contents = new Uint8Array(newCapacity);
        if (node.usedBytes > 0) node.contents.set(oldContents.subarray(0, node.usedBytes), 0);
      },
      resizeFileStorage(node, newSize) {
        if (node.usedBytes == newSize) return;
        if (newSize == 0) {
          node.contents = null;
          node.usedBytes = 0;
        } else {
          var oldContents = node.contents;
          node.contents = new Uint8Array(newSize);
          if (oldContents) {
            node.contents.set(oldContents.subarray(0, Math.min(newSize, node.usedBytes)));
          }
          node.usedBytes = newSize;
        }
      },
      node_ops: {
        getattr(node) {
          var attr = {};
          attr.dev = FS.isChrdev(node.mode) ? node.id : 1;
          attr.ino = node.id;
          attr.mode = node.mode;
          attr.nlink = 1;
          attr.uid = 0;
          attr.gid = 0;
          attr.rdev = node.rdev;
          if (FS.isDir(node.mode)) {
            attr.size = 4096;
          } else if (FS.isFile(node.mode)) {
            attr.size = node.usedBytes;
          } else if (FS.isLink(node.mode)) {
            attr.size = node.link.length;
          } else {
            attr.size = 0;
          }
          attr.atime = new Date(node.timestamp);
          attr.mtime = new Date(node.timestamp);
          attr.ctime = new Date(node.timestamp);
          attr.blksize = 4096;
          attr.blocks = Math.ceil(attr.size / attr.blksize);
          return attr;
        },
        setattr(node, attr) {
          if (attr.mode !== undefined) {
            node.mode = attr.mode;
          }
          if (attr.timestamp !== undefined) {
            node.timestamp = attr.timestamp;
          }
          if (attr.size !== undefined) {
            MEMFS.resizeFileStorage(node, attr.size);
          }
        },
        lookup(parent, name) {
          throw FS.genericErrors[44];
        },
        mknod(parent, name, mode, dev) {
          return MEMFS.createNode(parent, name, mode, dev);
        },
        rename(old_node, new_dir, new_name) {
          if (FS.isDir(old_node.mode)) {
            var new_node;
            try {
              new_node = FS.lookupNode(new_dir, new_name);
            } catch (e) {}
            if (new_node) {
              for (var i in new_node.contents) {
                throw new FS.ErrnoError(55);
              }
            }
          }
          delete old_node.parent.contents[old_node.name];
          old_node.parent.timestamp = Date.now();
          old_node.name = new_name;
          new_dir.contents[new_name] = old_node;
          new_dir.timestamp = old_node.parent.timestamp;
        },
        unlink(parent, name) {
          delete parent.contents[name];
          parent.timestamp = Date.now();
        },
        rmdir(parent, name) {
          var node = FS.lookupNode(parent, name);
          for (var i in node.contents) {
            throw new FS.ErrnoError(55);
          }
          delete parent.contents[name];
          parent.timestamp = Date.now();
        },
        readdir(node) {
          var entries = [".", ".."];
          for (var key of Object.keys(node.contents)) {
            entries.push(key);
          }
          return entries;
        },
        symlink(parent, newname, oldpath) {
          var node = MEMFS.createNode(parent, newname, 511 | 40960, 0);
          node.link = oldpath;
          return node;
        },
        readlink(node) {
          if (!FS.isLink(node.mode)) {
            throw new FS.ErrnoError(28);
          }
          return node.link;
        }
      },
      stream_ops: {
        read(stream, buffer, offset, length, position) {
          var contents = stream.node.contents;
          if (position >= stream.node.usedBytes) return 0;
          var size = Math.min(stream.node.usedBytes - position, length);
          if (size > 8 && contents.subarray) {
            buffer.set(contents.subarray(position, position + size), offset);
          } else {
            for (var i = 0; i < size; i++) buffer[offset + i] = contents[position + i];
          }
          return size;
        },
        write(stream, buffer, offset, length, position, canOwn) {
          if (buffer.buffer === HEAP8.buffer) {
            canOwn = false;
          }
          if (!length) return 0;
          var node = stream.node;
          node.timestamp = Date.now();
          if (buffer.subarray && (!node.contents || node.contents.subarray)) {
            if (canOwn) {
              node.contents = buffer.subarray(offset, offset + length);
              node.usedBytes = length;
              return length;
            } else if (node.usedBytes === 0 && position === 0) {
              node.contents = buffer.slice(offset, offset + length);
              node.usedBytes = length;
              return length;
            } else if (position + length <= node.usedBytes) {
              node.contents.set(buffer.subarray(offset, offset + length), position);
              return length;
            }
          }
          MEMFS.expandFileStorage(node, position + length);
          if (node.contents.subarray && buffer.subarray) {
            node.contents.set(buffer.subarray(offset, offset + length), position);
          } else {
            for (var i = 0; i < length; i++) {
              node.contents[position + i] = buffer[offset + i];
            }
          }
          node.usedBytes = Math.max(node.usedBytes, position + length);
          return length;
        },
        llseek(stream, offset, whence) {
          var position = offset;
          if (whence === 1) {
            position += stream.position;
          } else if (whence === 2) {
            if (FS.isFile(stream.node.mode)) {
              position += stream.node.usedBytes;
            }
          }
          if (position < 0) {
            throw new FS.ErrnoError(28);
          }
          return position;
        },
        allocate(stream, offset, length) {
          MEMFS.expandFileStorage(stream.node, offset + length);
          stream.node.usedBytes = Math.max(stream.node.usedBytes, offset + length);
        },
        mmap(stream, length, position, prot, flags) {
          if (!FS.isFile(stream.node.mode)) {
            throw new FS.ErrnoError(43);
          }
          var ptr;
          var allocated;
          var contents = stream.node.contents;
          if (!(flags & 2) && contents.buffer === HEAP8.buffer) {
            allocated = false;
            ptr = contents.byteOffset;
          } else {
            if (position > 0 || position + length < contents.length) {
              if (contents.subarray) {
                contents = contents.subarray(position, position + length);
              } else {
                contents = Array.prototype.slice.call(contents, position, position + length);
              }
            }
            allocated = true;
            ptr = mmapAlloc(length);
            if (!ptr) {
              throw new FS.ErrnoError(48);
            }
            HEAP8.set(contents, ptr >>> 0);
          }
          return {
            ptr: ptr,
            allocated: allocated
          };
        },
        msync(stream, buffer, offset, length, mmapFlags) {
          MEMFS.stream_ops.write(stream, buffer, 0, length, offset, false);
          return 0;
        }
      }
    };
    var FS_createDataFile = (parent, name, fileData, canRead, canWrite, canOwn) => {
      FS.createDataFile(parent, name, fileData, canRead, canWrite, canOwn);
    };
    var FS_handledByPreloadPlugin = (byteArray, fullname, finish, onerror) => {
      if (typeof Browser != "undefined") Browser.init();
      var handled = false;
      preloadPlugins.forEach(plugin => {
        if (handled) return;
        if (plugin["canHandle"](fullname)) {
          plugin["handle"](byteArray, fullname, finish, onerror);
          handled = true;
        }
      });
      return handled;
    };
    var FS_createPreloadedFile = (parent, name, url, canRead, canWrite, onload, onerror, dontCreateFile, canOwn, preFinish) => {
      var fullname = name ? PATH_FS.resolve(PATH.join2(parent, name)) : parent;
      var dep = getUniqueRunDependency(`cp ${fullname}`);
      function processData(byteArray) {
        function finish(byteArray) {
          preFinish?.();
          if (!dontCreateFile) {
            FS_createDataFile(parent, name, byteArray, canRead, canWrite, canOwn);
          }
          onload?.();
          removeRunDependency(dep);
        }
        if (FS_handledByPreloadPlugin(byteArray, fullname, finish, () => {
          onerror?.();
          removeRunDependency(dep);
        })) {
          return;
        }
        finish(byteArray);
      }
      addRunDependency(dep);
      if (typeof url == "string") {
        asyncLoad(url, processData, onerror);
      } else {
        processData(url);
      }
    };
    var FS_modeStringToFlags = str => {
      var flagModes = {
        r: 0,
        "r+": 2,
        w: 512 | 64 | 1,
        "w+": 512 | 64 | 2,
        a: 1024 | 64 | 1,
        "a+": 1024 | 64 | 2
      };
      var flags = flagModes[str];
      if (typeof flags == "undefined") {
        throw new Error(`Unknown file open mode: ${str}`);
      }
      return flags;
    };
    var FS_getMode = (canRead, canWrite) => {
      var mode = 0;
      if (canRead) mode |= 292 | 73;
      if (canWrite) mode |= 146;
      return mode;
    };
    var IDBFS = {
      dbs: {},
      indexedDB: () => {
        if (typeof indexedDB != "undefined") return indexedDB;
        var ret = null;
        if (typeof window == "object") ret = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
        return ret;
      },
      DB_VERSION: 21,
      DB_STORE_NAME: "FILE_DATA",
      queuePersist: mount => {
        function onPersistComplete() {
          if (mount.idbPersistState === "again") startPersist();else mount.idbPersistState = 0;
        }
        function startPersist() {
          mount.idbPersistState = "idb";
          IDBFS.syncfs(mount, false, onPersistComplete);
        }
        if (!mount.idbPersistState) {
          mount.idbPersistState = setTimeout(startPersist, 0);
        } else if (mount.idbPersistState === "idb") {
          mount.idbPersistState = "again";
        }
      },
      mount: mount => {
        var mnt = MEMFS.mount(mount);
        if (mount?.opts?.autoPersist) {
          mnt.idbPersistState = 0;
          var memfs_node_ops = mnt.node_ops;
          mnt.node_ops = Object.assign({}, mnt.node_ops);
          mnt.node_ops.mknod = (parent, name, mode, dev) => {
            var node = memfs_node_ops.mknod(parent, name, mode, dev);
            node.node_ops = mnt.node_ops;
            node.idbfs_mount = mnt.mount;
            node.memfs_stream_ops = node.stream_ops;
            node.stream_ops = Object.assign({}, node.stream_ops);
            node.stream_ops.write = (stream, buffer, offset, length, position, canOwn) => {
              stream.node.isModified = true;
              return node.memfs_stream_ops.write(stream, buffer, offset, length, position, canOwn);
            };
            node.stream_ops.close = stream => {
              var n = stream.node;
              if (n.isModified) {
                IDBFS.queuePersist(n.idbfs_mount);
                n.isModified = false;
              }
              if (n.memfs_stream_ops.close) return n.memfs_stream_ops.close(stream);
            };
            return node;
          };
          mnt.node_ops.mkdir = (...args) => (IDBFS.queuePersist(mnt.mount), memfs_node_ops.mkdir(...args));
          mnt.node_ops.rmdir = (...args) => (IDBFS.queuePersist(mnt.mount), memfs_node_ops.rmdir(...args));
          mnt.node_ops.symlink = (...args) => (IDBFS.queuePersist(mnt.mount), memfs_node_ops.symlink(...args));
          mnt.node_ops.unlink = (...args) => (IDBFS.queuePersist(mnt.mount), memfs_node_ops.unlink(...args));
          mnt.node_ops.rename = (...args) => (IDBFS.queuePersist(mnt.mount), memfs_node_ops.rename(...args));
        }
        return mnt;
      },
      syncfs: (mount, populate, callback) => {
        IDBFS.getLocalSet(mount, (err, local) => {
          if (err) return callback(err);
          IDBFS.getRemoteSet(mount, (err, remote) => {
            if (err) return callback(err);
            var src = populate ? remote : local;
            var dst = populate ? local : remote;
            IDBFS.reconcile(src, dst, callback);
          });
        });
      },
      quit: () => {
        Object.values(IDBFS.dbs).forEach(value => value.close());
        IDBFS.dbs = {};
      },
      getDB: (name, callback) => {
        var db = IDBFS.dbs[name];
        if (db) {
          return callback(null, db);
        }
        var req;
        try {
          req = IDBFS.indexedDB().open(name, IDBFS.DB_VERSION);
        } catch (e) {
          return callback(e);
        }
        if (!req) {
          return callback("Unable to connect to IndexedDB");
        }
        req.onupgradeneeded = e => {
          var db = e.target.result;
          var transaction = e.target.transaction;
          var fileStore;
          if (db.objectStoreNames.contains(IDBFS.DB_STORE_NAME)) {
            fileStore = transaction.objectStore(IDBFS.DB_STORE_NAME);
          } else {
            fileStore = db.createObjectStore(IDBFS.DB_STORE_NAME);
          }
          if (!fileStore.indexNames.contains("timestamp")) {
            fileStore.createIndex("timestamp", "timestamp", {
              unique: false
            });
          }
        };
        req.onsuccess = () => {
          db = req.result;
          IDBFS.dbs[name] = db;
          callback(null, db);
        };
        req.onerror = e => {
          callback(e.target.error);
          e.preventDefault();
        };
      },
      getLocalSet: (mount, callback) => {
        var entries = {};
        function isRealDir(p) {
          return p !== "." && p !== "..";
        }
        function toAbsolute(root) {
          return p => PATH.join2(root, p);
        }
        var check = FS.readdir(mount.mountpoint).filter(isRealDir).map(toAbsolute(mount.mountpoint));
        while (check.length) {
          var path = check.pop();
          var stat;
          try {
            stat = FS.stat(path);
          } catch (e) {
            return callback(e);
          }
          if (FS.isDir(stat.mode)) {
            check.push(...FS.readdir(path).filter(isRealDir).map(toAbsolute(path)));
          }
          entries[path] = {
            timestamp: stat.mtime
          };
        }
        return callback(null, {
          type: "local",
          entries: entries
        });
      },
      getRemoteSet: (mount, callback) => {
        var entries = {};
        IDBFS.getDB(mount.mountpoint, (err, db) => {
          if (err) return callback(err);
          try {
            var transaction = db.transaction([IDBFS.DB_STORE_NAME], "readonly");
            transaction.onerror = e => {
              callback(e.target.error);
              e.preventDefault();
            };
            var store = transaction.objectStore(IDBFS.DB_STORE_NAME);
            var index = store.index("timestamp");
            index.openKeyCursor().onsuccess = event => {
              var cursor = event.target.result;
              if (!cursor) {
                return callback(null, {
                  type: "remote",
                  db: db,
                  entries: entries
                });
              }
              entries[cursor.primaryKey] = {
                timestamp: cursor.key
              };
              cursor.continue();
            };
          } catch (e) {
            return callback(e);
          }
        });
      },
      loadLocalEntry: (path, callback) => {
        var stat, node;
        try {
          var lookup = FS.lookupPath(path);
          node = lookup.node;
          stat = FS.stat(path);
        } catch (e) {
          return callback(e);
        }
        if (FS.isDir(stat.mode)) {
          return callback(null, {
            timestamp: stat.mtime,
            mode: stat.mode
          });
        } else if (FS.isFile(stat.mode)) {
          node.contents = MEMFS.getFileDataAsTypedArray(node);
          return callback(null, {
            timestamp: stat.mtime,
            mode: stat.mode,
            contents: node.contents
          });
        } else {
          return callback(new Error("node type not supported"));
        }
      },
      storeLocalEntry: (path, entry, callback) => {
        try {
          if (FS.isDir(entry["mode"])) {
            FS.mkdirTree(path, entry["mode"]);
          } else if (FS.isFile(entry["mode"])) {
            FS.writeFile(path, entry["contents"], {
              canOwn: true
            });
          } else {
            return callback(new Error("node type not supported"));
          }
          FS.chmod(path, entry["mode"]);
          FS.utime(path, entry["timestamp"], entry["timestamp"]);
        } catch (e) {
          return callback(e);
        }
        callback(null);
      },
      removeLocalEntry: (path, callback) => {
        try {
          var stat = FS.stat(path);
          if (FS.isDir(stat.mode)) {
            FS.rmdir(path);
          } else if (FS.isFile(stat.mode)) {
            FS.unlink(path);
          }
        } catch (e) {
          return callback(e);
        }
        callback(null);
      },
      loadRemoteEntry: (store, path, callback) => {
        var req = store.get(path);
        req.onsuccess = event => callback(null, event.target.result);
        req.onerror = e => {
          callback(e.target.error);
          e.preventDefault();
        };
      },
      storeRemoteEntry: (store, path, entry, callback) => {
        try {
          var req = store.put(entry, path);
        } catch (e) {
          callback(e);
          return;
        }
        req.onsuccess = event => callback();
        req.onerror = e => {
          callback(e.target.error);
          e.preventDefault();
        };
      },
      removeRemoteEntry: (store, path, callback) => {
        var req = store.delete(path);
        req.onsuccess = event => callback();
        req.onerror = e => {
          callback(e.target.error);
          e.preventDefault();
        };
      },
      reconcile: (src, dst, callback) => {
        var total = 0;
        var create = [];
        Object.keys(src.entries).forEach(function (key) {
          var e = src.entries[key];
          var e2 = dst.entries[key];
          if (!e2 || e["timestamp"].getTime() != e2["timestamp"].getTime()) {
            create.push(key);
            total++;
          }
        });
        var remove = [];
        Object.keys(dst.entries).forEach(function (key) {
          if (!src.entries[key]) {
            remove.push(key);
            total++;
          }
        });
        if (!total) {
          return callback(null);
        }
        var errored = false;
        var db = src.type === "remote" ? src.db : dst.db;
        var transaction = db.transaction([IDBFS.DB_STORE_NAME], "readwrite");
        var store = transaction.objectStore(IDBFS.DB_STORE_NAME);
        function done(err) {
          if (err && !errored) {
            errored = true;
            return callback(err);
          }
        }
        transaction.onerror = transaction.onabort = e => {
          done(e.target.error);
          e.preventDefault();
        };
        transaction.oncomplete = e => {
          if (!errored) {
            callback(null);
          }
        };
        create.sort().forEach(path => {
          if (dst.type === "local") {
            IDBFS.loadRemoteEntry(store, path, (err, entry) => {
              if (err) return done(err);
              IDBFS.storeLocalEntry(path, entry, done);
            });
          } else {
            IDBFS.loadLocalEntry(path, (err, entry) => {
              if (err) return done(err);
              IDBFS.storeRemoteEntry(store, path, entry, done);
            });
          }
        });
        remove.sort().reverse().forEach(path => {
          if (dst.type === "local") {
            IDBFS.removeLocalEntry(path, done);
          } else {
            IDBFS.removeRemoteEntry(store, path, done);
          }
        });
      }
    };
    var FS = {
      root: null,
      mounts: [],
      devices: {},
      streams: [],
      nextInode: 1,
      nameTable: null,
      currentPath: "/",
      initialized: false,
      ignorePermissions: true,
      ErrnoError: class {
        constructor(errno) {
          this.name = "ErrnoError";
          this.errno = errno;
        }
      },
      genericErrors: {},
      filesystems: null,
      syncFSRequests: 0,
      FSStream: class {
        constructor() {
          this.shared = {};
        }
        get object() {
          return this.node;
        }
        set object(val) {
          this.node = val;
        }
        get isRead() {
          return (this.flags & 2097155) !== 1;
        }
        get isWrite() {
          return (this.flags & 2097155) !== 0;
        }
        get isAppend() {
          return this.flags & 1024;
        }
        get flags() {
          return this.shared.flags;
        }
        set flags(val) {
          this.shared.flags = val;
        }
        get position() {
          return this.shared.position;
        }
        set position(val) {
          this.shared.position = val;
        }
      },
      FSNode: class {
        constructor(parent, name, mode, rdev) {
          if (!parent) {
            parent = this;
          }
          this.parent = parent;
          this.mount = parent.mount;
          this.mounted = null;
          this.id = FS.nextInode++;
          this.name = name;
          this.mode = mode;
          this.node_ops = {};
          this.stream_ops = {};
          this.rdev = rdev;
          this.readMode = 292 | 73;
          this.writeMode = 146;
        }
        get read() {
          return (this.mode & this.readMode) === this.readMode;
        }
        set read(val) {
          val ? this.mode |= this.readMode : this.mode &= ~this.readMode;
        }
        get write() {
          return (this.mode & this.writeMode) === this.writeMode;
        }
        set write(val) {
          val ? this.mode |= this.writeMode : this.mode &= ~this.writeMode;
        }
        get isFolder() {
          return FS.isDir(this.mode);
        }
        get isDevice() {
          return FS.isChrdev(this.mode);
        }
      },
      lookupPath(path, opts = {}) {
        path = PATH_FS.resolve(path);
        if (!path) return {
          path: "",
          node: null
        };
        var defaults = {
          follow_mount: true,
          recurse_count: 0
        };
        opts = Object.assign(defaults, opts);
        if (opts.recurse_count > 8) {
          throw new FS.ErrnoError(32);
        }
        var parts = path.split("/").filter(p => !!p);
        var current = FS.root;
        var current_path = "/";
        for (var i = 0; i < parts.length; i++) {
          var islast = i === parts.length - 1;
          if (islast && opts.parent) {
            break;
          }
          current = FS.lookupNode(current, parts[i]);
          current_path = PATH.join2(current_path, parts[i]);
          if (FS.isMountpoint(current)) {
            if (!islast || islast && opts.follow_mount) {
              current = current.mounted.root;
            }
          }
          if (!islast || opts.follow) {
            var count = 0;
            while (FS.isLink(current.mode)) {
              var link = FS.readlink(current_path);
              current_path = PATH_FS.resolve(PATH.dirname(current_path), link);
              var lookup = FS.lookupPath(current_path, {
                recurse_count: opts.recurse_count + 1
              });
              current = lookup.node;
              if (count++ > 40) {
                throw new FS.ErrnoError(32);
              }
            }
          }
        }
        return {
          path: current_path,
          node: current
        };
      },
      getPath(node) {
        var path;
        while (true) {
          if (FS.isRoot(node)) {
            var mount = node.mount.mountpoint;
            if (!path) return mount;
            return mount[mount.length - 1] !== "/" ? `${mount}/${path}` : mount + path;
          }
          path = path ? `${node.name}/${path}` : node.name;
          node = node.parent;
        }
      },
      hashName(parentid, name) {
        var hash = 0;
        for (var i = 0; i < name.length; i++) {
          hash = (hash << 5) - hash + name.charCodeAt(i) | 0;
        }
        return (parentid + hash >>> 0) % FS.nameTable.length;
      },
      hashAddNode(node) {
        var hash = FS.hashName(node.parent.id, node.name);
        node.name_next = FS.nameTable[hash];
        FS.nameTable[hash] = node;
      },
      hashRemoveNode(node) {
        var hash = FS.hashName(node.parent.id, node.name);
        if (FS.nameTable[hash] === node) {
          FS.nameTable[hash] = node.name_next;
        } else {
          var current = FS.nameTable[hash];
          while (current) {
            if (current.name_next === node) {
              current.name_next = node.name_next;
              break;
            }
            current = current.name_next;
          }
        }
      },
      lookupNode(parent, name) {
        var errCode = FS.mayLookup(parent);
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        var hash = FS.hashName(parent.id, name);
        for (var node = FS.nameTable[hash]; node; node = node.name_next) {
          var nodeName = node.name;
          if (node.parent.id === parent.id && nodeName === name) {
            return node;
          }
        }
        return FS.lookup(parent, name);
      },
      createNode(parent, name, mode, rdev) {
        var node = new FS.FSNode(parent, name, mode, rdev);
        FS.hashAddNode(node);
        return node;
      },
      destroyNode(node) {
        FS.hashRemoveNode(node);
      },
      isRoot(node) {
        return node === node.parent;
      },
      isMountpoint(node) {
        return !!node.mounted;
      },
      isFile(mode) {
        return (mode & 61440) === 32768;
      },
      isDir(mode) {
        return (mode & 61440) === 16384;
      },
      isLink(mode) {
        return (mode & 61440) === 40960;
      },
      isChrdev(mode) {
        return (mode & 61440) === 8192;
      },
      isBlkdev(mode) {
        return (mode & 61440) === 24576;
      },
      isFIFO(mode) {
        return (mode & 61440) === 4096;
      },
      isSocket(mode) {
        return (mode & 49152) === 49152;
      },
      flagsToPermissionString(flag) {
        var perms = ["r", "w", "rw"][flag & 3];
        if (flag & 512) {
          perms += "w";
        }
        return perms;
      },
      nodePermissions(node, perms) {
        if (FS.ignorePermissions) {
          return 0;
        }
        if (perms.includes("r") && !(node.mode & 292)) {
          return 2;
        } else if (perms.includes("w") && !(node.mode & 146)) {
          return 2;
        } else if (perms.includes("x") && !(node.mode & 73)) {
          return 2;
        }
        return 0;
      },
      mayLookup(dir) {
        if (!FS.isDir(dir.mode)) return 54;
        var errCode = FS.nodePermissions(dir, "x");
        if (errCode) return errCode;
        if (!dir.node_ops.lookup) return 2;
        return 0;
      },
      mayCreate(dir, name) {
        try {
          var node = FS.lookupNode(dir, name);
          return 20;
        } catch (e) {}
        return FS.nodePermissions(dir, "wx");
      },
      mayDelete(dir, name, isdir) {
        var node;
        try {
          node = FS.lookupNode(dir, name);
        } catch (e) {
          return e.errno;
        }
        var errCode = FS.nodePermissions(dir, "wx");
        if (errCode) {
          return errCode;
        }
        if (isdir) {
          if (!FS.isDir(node.mode)) {
            return 54;
          }
          if (FS.isRoot(node) || FS.getPath(node) === FS.cwd()) {
            return 10;
          }
        } else {
          if (FS.isDir(node.mode)) {
            return 31;
          }
        }
        return 0;
      },
      mayOpen(node, flags) {
        if (!node) {
          return 44;
        }
        if (FS.isLink(node.mode)) {
          return 32;
        } else if (FS.isDir(node.mode)) {
          if (FS.flagsToPermissionString(flags) !== "r" || flags & 512) {
            return 31;
          }
        }
        return FS.nodePermissions(node, FS.flagsToPermissionString(flags));
      },
      MAX_OPEN_FDS: 4096,
      nextfd() {
        for (var fd = 0; fd <= FS.MAX_OPEN_FDS; fd++) {
          if (!FS.streams[fd]) {
            return fd;
          }
        }
        throw new FS.ErrnoError(33);
      },
      getStreamChecked(fd) {
        var stream = FS.getStream(fd);
        if (!stream) {
          throw new FS.ErrnoError(8);
        }
        return stream;
      },
      getStream: fd => FS.streams[fd],
      createStream(stream, fd = -1) {
        stream = Object.assign(new FS.FSStream(), stream);
        if (fd == -1) {
          fd = FS.nextfd();
        }
        stream.fd = fd;
        FS.streams[fd] = stream;
        return stream;
      },
      closeStream(fd) {
        FS.streams[fd] = null;
      },
      dupStream(origStream, fd = -1) {
        var stream = FS.createStream(origStream, fd);
        stream.stream_ops?.dup?.(stream);
        return stream;
      },
      chrdev_stream_ops: {
        open(stream) {
          var device = FS.getDevice(stream.node.rdev);
          stream.stream_ops = device.stream_ops;
          stream.stream_ops.open?.(stream);
        },
        llseek() {
          throw new FS.ErrnoError(70);
        }
      },
      major: dev => dev >> 8,
      minor: dev => dev & 255,
      makedev: (ma, mi) => ma << 8 | mi,
      registerDevice(dev, ops) {
        FS.devices[dev] = {
          stream_ops: ops
        };
      },
      getDevice: dev => FS.devices[dev],
      getMounts(mount) {
        var mounts = [];
        var check = [mount];
        while (check.length) {
          var m = check.pop();
          mounts.push(m);
          check.push(...m.mounts);
        }
        return mounts;
      },
      syncfs(populate, callback) {
        if (typeof populate == "function") {
          callback = populate;
          populate = false;
        }
        FS.syncFSRequests++;
        if (FS.syncFSRequests > 1) {
          err(`warning: ${FS.syncFSRequests} FS.syncfs operations in flight at once, probably just doing extra work`);
        }
        var mounts = FS.getMounts(FS.root.mount);
        var completed = 0;
        function doCallback(errCode) {
          FS.syncFSRequests--;
          return callback(errCode);
        }
        function done(errCode) {
          if (errCode) {
            if (!done.errored) {
              done.errored = true;
              return doCallback(errCode);
            }
            return;
          }
          if (++completed >= mounts.length) {
            doCallback(null);
          }
        }
        mounts.forEach(mount => {
          if (!mount.type.syncfs) {
            return done(null);
          }
          mount.type.syncfs(mount, populate, done);
        });
      },
      mount(type, opts, mountpoint) {
        var root = mountpoint === "/";
        var pseudo = !mountpoint;
        var node;
        if (root && FS.root) {
          throw new FS.ErrnoError(10);
        } else if (!root && !pseudo) {
          var lookup = FS.lookupPath(mountpoint, {
            follow_mount: false
          });
          mountpoint = lookup.path;
          node = lookup.node;
          if (FS.isMountpoint(node)) {
            throw new FS.ErrnoError(10);
          }
          if (!FS.isDir(node.mode)) {
            throw new FS.ErrnoError(54);
          }
        }
        var mount = {
          type: type,
          opts: opts,
          mountpoint: mountpoint,
          mounts: []
        };
        var mountRoot = type.mount(mount);
        mountRoot.mount = mount;
        mount.root = mountRoot;
        if (root) {
          FS.root = mountRoot;
        } else if (node) {
          node.mounted = mount;
          if (node.mount) {
            node.mount.mounts.push(mount);
          }
        }
        return mountRoot;
      },
      unmount(mountpoint) {
        var lookup = FS.lookupPath(mountpoint, {
          follow_mount: false
        });
        if (!FS.isMountpoint(lookup.node)) {
          throw new FS.ErrnoError(28);
        }
        var node = lookup.node;
        var mount = node.mounted;
        var mounts = FS.getMounts(mount);
        Object.keys(FS.nameTable).forEach(hash => {
          var current = FS.nameTable[hash];
          while (current) {
            var next = current.name_next;
            if (mounts.includes(current.mount)) {
              FS.destroyNode(current);
            }
            current = next;
          }
        });
        node.mounted = null;
        var idx = node.mount.mounts.indexOf(mount);
        node.mount.mounts.splice(idx, 1);
      },
      lookup(parent, name) {
        return parent.node_ops.lookup(parent, name);
      },
      mknod(path, mode, dev) {
        var lookup = FS.lookupPath(path, {
          parent: true
        });
        var parent = lookup.node;
        var name = PATH.basename(path);
        if (!name || name === "." || name === "..") {
          throw new FS.ErrnoError(28);
        }
        var errCode = FS.mayCreate(parent, name);
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        if (!parent.node_ops.mknod) {
          throw new FS.ErrnoError(63);
        }
        return parent.node_ops.mknod(parent, name, mode, dev);
      },
      create(path, mode) {
        mode = mode !== undefined ? mode : 438;
        mode &= 4095;
        mode |= 32768;
        return FS.mknod(path, mode, 0);
      },
      mkdir(path, mode) {
        mode = mode !== undefined ? mode : 511;
        mode &= 511 | 512;
        mode |= 16384;
        return FS.mknod(path, mode, 0);
      },
      mkdirTree(path, mode) {
        var dirs = path.split("/");
        var d = "";
        for (var i = 0; i < dirs.length; ++i) {
          if (!dirs[i]) continue;
          d += "/" + dirs[i];
          try {
            FS.mkdir(d, mode);
          } catch (e) {
            if (e.errno != 20) throw e;
          }
        }
      },
      mkdev(path, mode, dev) {
        if (typeof dev == "undefined") {
          dev = mode;
          mode = 438;
        }
        mode |= 8192;
        return FS.mknod(path, mode, dev);
      },
      symlink(oldpath, newpath) {
        if (!PATH_FS.resolve(oldpath)) {
          throw new FS.ErrnoError(44);
        }
        var lookup = FS.lookupPath(newpath, {
          parent: true
        });
        var parent = lookup.node;
        if (!parent) {
          throw new FS.ErrnoError(44);
        }
        var newname = PATH.basename(newpath);
        var errCode = FS.mayCreate(parent, newname);
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        if (!parent.node_ops.symlink) {
          throw new FS.ErrnoError(63);
        }
        return parent.node_ops.symlink(parent, newname, oldpath);
      },
      rename(old_path, new_path) {
        var old_dirname = PATH.dirname(old_path);
        var new_dirname = PATH.dirname(new_path);
        var old_name = PATH.basename(old_path);
        var new_name = PATH.basename(new_path);
        var lookup, old_dir, new_dir;
        lookup = FS.lookupPath(old_path, {
          parent: true
        });
        old_dir = lookup.node;
        lookup = FS.lookupPath(new_path, {
          parent: true
        });
        new_dir = lookup.node;
        if (!old_dir || !new_dir) throw new FS.ErrnoError(44);
        if (old_dir.mount !== new_dir.mount) {
          throw new FS.ErrnoError(75);
        }
        var old_node = FS.lookupNode(old_dir, old_name);
        var relative = PATH_FS.relative(old_path, new_dirname);
        if (relative.charAt(0) !== ".") {
          throw new FS.ErrnoError(28);
        }
        relative = PATH_FS.relative(new_path, old_dirname);
        if (relative.charAt(0) !== ".") {
          throw new FS.ErrnoError(55);
        }
        var new_node;
        try {
          new_node = FS.lookupNode(new_dir, new_name);
        } catch (e) {}
        if (old_node === new_node) {
          return;
        }
        var isdir = FS.isDir(old_node.mode);
        var errCode = FS.mayDelete(old_dir, old_name, isdir);
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        errCode = new_node ? FS.mayDelete(new_dir, new_name, isdir) : FS.mayCreate(new_dir, new_name);
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        if (!old_dir.node_ops.rename) {
          throw new FS.ErrnoError(63);
        }
        if (FS.isMountpoint(old_node) || new_node && FS.isMountpoint(new_node)) {
          throw new FS.ErrnoError(10);
        }
        if (new_dir !== old_dir) {
          errCode = FS.nodePermissions(old_dir, "w");
          if (errCode) {
            throw new FS.ErrnoError(errCode);
          }
        }
        FS.hashRemoveNode(old_node);
        try {
          old_dir.node_ops.rename(old_node, new_dir, new_name);
          old_node.parent = new_dir;
        } catch (e) {
          throw e;
        } finally {
          FS.hashAddNode(old_node);
        }
      },
      rmdir(path) {
        var lookup = FS.lookupPath(path, {
          parent: true
        });
        var parent = lookup.node;
        var name = PATH.basename(path);
        var node = FS.lookupNode(parent, name);
        var errCode = FS.mayDelete(parent, name, true);
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        if (!parent.node_ops.rmdir) {
          throw new FS.ErrnoError(63);
        }
        if (FS.isMountpoint(node)) {
          throw new FS.ErrnoError(10);
        }
        parent.node_ops.rmdir(parent, name);
        FS.destroyNode(node);
      },
      readdir(path) {
        var lookup = FS.lookupPath(path, {
          follow: true
        });
        var node = lookup.node;
        if (!node.node_ops.readdir) {
          throw new FS.ErrnoError(54);
        }
        return node.node_ops.readdir(node);
      },
      unlink(path) {
        var lookup = FS.lookupPath(path, {
          parent: true
        });
        var parent = lookup.node;
        if (!parent) {
          throw new FS.ErrnoError(44);
        }
        var name = PATH.basename(path);
        var node = FS.lookupNode(parent, name);
        var errCode = FS.mayDelete(parent, name, false);
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        if (!parent.node_ops.unlink) {
          throw new FS.ErrnoError(63);
        }
        if (FS.isMountpoint(node)) {
          throw new FS.ErrnoError(10);
        }
        parent.node_ops.unlink(parent, name);
        FS.destroyNode(node);
      },
      readlink(path) {
        var lookup = FS.lookupPath(path);
        var link = lookup.node;
        if (!link) {
          throw new FS.ErrnoError(44);
        }
        if (!link.node_ops.readlink) {
          throw new FS.ErrnoError(28);
        }
        return PATH_FS.resolve(FS.getPath(link.parent), link.node_ops.readlink(link));
      },
      stat(path, dontFollow) {
        var lookup = FS.lookupPath(path, {
          follow: !dontFollow
        });
        var node = lookup.node;
        if (!node) {
          throw new FS.ErrnoError(44);
        }
        if (!node.node_ops.getattr) {
          throw new FS.ErrnoError(63);
        }
        return node.node_ops.getattr(node);
      },
      lstat(path) {
        return FS.stat(path, true);
      },
      chmod(path, mode, dontFollow) {
        var node;
        if (typeof path == "string") {
          var lookup = FS.lookupPath(path, {
            follow: !dontFollow
          });
          node = lookup.node;
        } else {
          node = path;
        }
        if (!node.node_ops.setattr) {
          throw new FS.ErrnoError(63);
        }
        node.node_ops.setattr(node, {
          mode: mode & 4095 | node.mode & ~4095,
          timestamp: Date.now()
        });
      },
      lchmod(path, mode) {
        FS.chmod(path, mode, true);
      },
      fchmod(fd, mode) {
        var stream = FS.getStreamChecked(fd);
        FS.chmod(stream.node, mode);
      },
      chown(path, uid, gid, dontFollow) {
        var node;
        if (typeof path == "string") {
          var lookup = FS.lookupPath(path, {
            follow: !dontFollow
          });
          node = lookup.node;
        } else {
          node = path;
        }
        if (!node.node_ops.setattr) {
          throw new FS.ErrnoError(63);
        }
        node.node_ops.setattr(node, {
          timestamp: Date.now()
        });
      },
      lchown(path, uid, gid) {
        FS.chown(path, uid, gid, true);
      },
      fchown(fd, uid, gid) {
        var stream = FS.getStreamChecked(fd);
        FS.chown(stream.node, uid, gid);
      },
      truncate(path, len) {
        if (len < 0) {
          throw new FS.ErrnoError(28);
        }
        var node;
        if (typeof path == "string") {
          var lookup = FS.lookupPath(path, {
            follow: true
          });
          node = lookup.node;
        } else {
          node = path;
        }
        if (!node.node_ops.setattr) {
          throw new FS.ErrnoError(63);
        }
        if (FS.isDir(node.mode)) {
          throw new FS.ErrnoError(31);
        }
        if (!FS.isFile(node.mode)) {
          throw new FS.ErrnoError(28);
        }
        var errCode = FS.nodePermissions(node, "w");
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        node.node_ops.setattr(node, {
          size: len,
          timestamp: Date.now()
        });
      },
      ftruncate(fd, len) {
        var stream = FS.getStreamChecked(fd);
        if ((stream.flags & 2097155) === 0) {
          throw new FS.ErrnoError(28);
        }
        FS.truncate(stream.node, len);
      },
      utime(path, atime, mtime) {
        var lookup = FS.lookupPath(path, {
          follow: true
        });
        var node = lookup.node;
        node.node_ops.setattr(node, {
          timestamp: Math.max(atime, mtime)
        });
      },
      open(path, flags, mode) {
        if (path === "") {
          throw new FS.ErrnoError(44);
        }
        flags = typeof flags == "string" ? FS_modeStringToFlags(flags) : flags;
        if (flags & 64) {
          mode = typeof mode == "undefined" ? 438 : mode;
          mode = mode & 4095 | 32768;
        } else {
          mode = 0;
        }
        var node;
        if (typeof path == "object") {
          node = path;
        } else {
          path = PATH.normalize(path);
          try {
            var lookup = FS.lookupPath(path, {
              follow: !(flags & 131072)
            });
            node = lookup.node;
          } catch (e) {}
        }
        var created = false;
        if (flags & 64) {
          if (node) {
            if (flags & 128) {
              throw new FS.ErrnoError(20);
            }
          } else {
            node = FS.mknod(path, mode, 0);
            created = true;
          }
        }
        if (!node) {
          throw new FS.ErrnoError(44);
        }
        if (FS.isChrdev(node.mode)) {
          flags &= ~512;
        }
        if (flags & 65536 && !FS.isDir(node.mode)) {
          throw new FS.ErrnoError(54);
        }
        if (!created) {
          var errCode = FS.mayOpen(node, flags);
          if (errCode) {
            throw new FS.ErrnoError(errCode);
          }
        }
        if (flags & 512 && !created) {
          FS.truncate(node, 0);
        }
        flags &= ~(128 | 512 | 131072);
        var stream = FS.createStream({
          node: node,
          path: FS.getPath(node),
          flags: flags,
          seekable: true,
          position: 0,
          stream_ops: node.stream_ops,
          ungotten: [],
          error: false
        });
        if (stream.stream_ops.open) {
          stream.stream_ops.open(stream);
        }
        if (Module["logReadFiles"] && !(flags & 1)) {
          if (!FS.readFiles) FS.readFiles = {};
          if (!(path in FS.readFiles)) {
            FS.readFiles[path] = 1;
          }
        }
        return stream;
      },
      close(stream) {
        if (FS.isClosed(stream)) {
          throw new FS.ErrnoError(8);
        }
        if (stream.getdents) stream.getdents = null;
        try {
          if (stream.stream_ops.close) {
            stream.stream_ops.close(stream);
          }
        } catch (e) {
          throw e;
        } finally {
          FS.closeStream(stream.fd);
        }
        stream.fd = null;
      },
      isClosed(stream) {
        return stream.fd === null;
      },
      llseek(stream, offset, whence) {
        if (FS.isClosed(stream)) {
          throw new FS.ErrnoError(8);
        }
        if (!stream.seekable || !stream.stream_ops.llseek) {
          throw new FS.ErrnoError(70);
        }
        if (whence != 0 && whence != 1 && whence != 2) {
          throw new FS.ErrnoError(28);
        }
        stream.position = stream.stream_ops.llseek(stream, offset, whence);
        stream.ungotten = [];
        return stream.position;
      },
      read(stream, buffer, offset, length, position) {
        if (length < 0 || position < 0) {
          throw new FS.ErrnoError(28);
        }
        if (FS.isClosed(stream)) {
          throw new FS.ErrnoError(8);
        }
        if ((stream.flags & 2097155) === 1) {
          throw new FS.ErrnoError(8);
        }
        if (FS.isDir(stream.node.mode)) {
          throw new FS.ErrnoError(31);
        }
        if (!stream.stream_ops.read) {
          throw new FS.ErrnoError(28);
        }
        var seeking = typeof position != "undefined";
        if (!seeking) {
          position = stream.position;
        } else if (!stream.seekable) {
          throw new FS.ErrnoError(70);
        }
        var bytesRead = stream.stream_ops.read(stream, buffer, offset, length, position);
        if (!seeking) stream.position += bytesRead;
        return bytesRead;
      },
      write(stream, buffer, offset, length, position, canOwn) {
        if (length < 0 || position < 0) {
          throw new FS.ErrnoError(28);
        }
        if (FS.isClosed(stream)) {
          throw new FS.ErrnoError(8);
        }
        if ((stream.flags & 2097155) === 0) {
          throw new FS.ErrnoError(8);
        }
        if (FS.isDir(stream.node.mode)) {
          throw new FS.ErrnoError(31);
        }
        if (!stream.stream_ops.write) {
          throw new FS.ErrnoError(28);
        }
        if (stream.seekable && stream.flags & 1024) {
          FS.llseek(stream, 0, 2);
        }
        var seeking = typeof position != "undefined";
        if (!seeking) {
          position = stream.position;
        } else if (!stream.seekable) {
          throw new FS.ErrnoError(70);
        }
        var bytesWritten = stream.stream_ops.write(stream, buffer, offset, length, position, canOwn);
        if (!seeking) stream.position += bytesWritten;
        return bytesWritten;
      },
      allocate(stream, offset, length) {
        if (FS.isClosed(stream)) {
          throw new FS.ErrnoError(8);
        }
        if (offset < 0 || length <= 0) {
          throw new FS.ErrnoError(28);
        }
        if ((stream.flags & 2097155) === 0) {
          throw new FS.ErrnoError(8);
        }
        if (!FS.isFile(stream.node.mode) && !FS.isDir(stream.node.mode)) {
          throw new FS.ErrnoError(43);
        }
        if (!stream.stream_ops.allocate) {
          throw new FS.ErrnoError(138);
        }
        stream.stream_ops.allocate(stream, offset, length);
      },
      mmap(stream, length, position, prot, flags) {
        if ((prot & 2) !== 0 && (flags & 2) === 0 && (stream.flags & 2097155) !== 2) {
          throw new FS.ErrnoError(2);
        }
        if ((stream.flags & 2097155) === 1) {
          throw new FS.ErrnoError(2);
        }
        if (!stream.stream_ops.mmap) {
          throw new FS.ErrnoError(43);
        }
        return stream.stream_ops.mmap(stream, length, position, prot, flags);
      },
      msync(stream, buffer, offset, length, mmapFlags) {
        if (!stream.stream_ops.msync) {
          return 0;
        }
        return stream.stream_ops.msync(stream, buffer, offset, length, mmapFlags);
      },
      ioctl(stream, cmd, arg) {
        if (!stream.stream_ops.ioctl) {
          throw new FS.ErrnoError(59);
        }
        return stream.stream_ops.ioctl(stream, cmd, arg);
      },
      readFile(path, opts = {}) {
        opts.flags = opts.flags || 0;
        opts.encoding = opts.encoding || "binary";
        if (opts.encoding !== "utf8" && opts.encoding !== "binary") {
          throw new Error(`Invalid encoding type "${opts.encoding}"`);
        }
        var ret;
        var stream = FS.open(path, opts.flags);
        var stat = FS.stat(path);
        var length = stat.size;
        var buf = new Uint8Array(length);
        FS.read(stream, buf, 0, length, 0);
        if (opts.encoding === "utf8") {
          ret = UTF8ArrayToString(buf, 0);
        } else if (opts.encoding === "binary") {
          ret = buf;
        }
        FS.close(stream);
        return ret;
      },
      writeFile(path, data, opts = {}) {
        opts.flags = opts.flags || 577;
        var stream = FS.open(path, opts.flags, opts.mode);
        if (typeof data == "string") {
          var buf = new Uint8Array(lengthBytesUTF8(data) + 1);
          var actualNumBytes = stringToUTF8Array(data, buf, 0, buf.length);
          FS.write(stream, buf, 0, actualNumBytes, undefined, opts.canOwn);
        } else if (ArrayBuffer.isView(data)) {
          FS.write(stream, data, 0, data.byteLength, undefined, opts.canOwn);
        } else {
          throw new Error("Unsupported data type");
        }
        FS.close(stream);
      },
      cwd: () => FS.currentPath,
      chdir(path) {
        var lookup = FS.lookupPath(path, {
          follow: true
        });
        if (lookup.node === null) {
          throw new FS.ErrnoError(44);
        }
        if (!FS.isDir(lookup.node.mode)) {
          throw new FS.ErrnoError(54);
        }
        var errCode = FS.nodePermissions(lookup.node, "x");
        if (errCode) {
          throw new FS.ErrnoError(errCode);
        }
        FS.currentPath = lookup.path;
      },
      createDefaultDirectories() {
        FS.mkdir("/tmp");
        FS.mkdir("/home");
        FS.mkdir("/home/web_user");
      },
      createDefaultDevices() {
        FS.mkdir("/dev");
        FS.registerDevice(FS.makedev(1, 3), {
          read: () => 0,
          write: (stream, buffer, offset, length, pos) => length
        });
        FS.mkdev("/dev/null", FS.makedev(1, 3));
        TTY.register(FS.makedev(5, 0), TTY.default_tty_ops);
        TTY.register(FS.makedev(6, 0), TTY.default_tty1_ops);
        FS.mkdev("/dev/tty", FS.makedev(5, 0));
        FS.mkdev("/dev/tty1", FS.makedev(6, 0));
        var randomBuffer = new Uint8Array(1024),
          randomLeft = 0;
        var randomByte = () => {
          if (randomLeft === 0) {
            randomLeft = randomFill(randomBuffer).byteLength;
          }
          return randomBuffer[--randomLeft];
        };
        FS.createDevice("/dev", "random", randomByte);
        FS.createDevice("/dev", "urandom", randomByte);
        FS.mkdir("/dev/shm");
        FS.mkdir("/dev/shm/tmp");
      },
      createSpecialDirectories() {
        FS.mkdir("/proc");
        var proc_self = FS.mkdir("/proc/self");
        FS.mkdir("/proc/self/fd");
        FS.mount({
          mount() {
            var node = FS.createNode(proc_self, "fd", 16384 | 511, 73);
            node.node_ops = {
              lookup(parent, name) {
                var fd = +name;
                var stream = FS.getStreamChecked(fd);
                var ret = {
                  parent: null,
                  mount: {
                    mountpoint: "fake"
                  },
                  node_ops: {
                    readlink: () => stream.path
                  }
                };
                ret.parent = ret;
                return ret;
              }
            };
            return node;
          }
        }, {}, "/proc/self/fd");
      },
      createStandardStreams() {
        if (Module["stdin"]) {
          FS.createDevice("/dev", "stdin", Module["stdin"]);
        } else {
          FS.symlink("/dev/tty", "/dev/stdin");
        }
        if (Module["stdout"]) {
          FS.createDevice("/dev", "stdout", null, Module["stdout"]);
        } else {
          FS.symlink("/dev/tty", "/dev/stdout");
        }
        if (Module["stderr"]) {
          FS.createDevice("/dev", "stderr", null, Module["stderr"]);
        } else {
          FS.symlink("/dev/tty1", "/dev/stderr");
        }
        var stdin = FS.open("/dev/stdin", 0);
        var stdout = FS.open("/dev/stdout", 1);
        var stderr = FS.open("/dev/stderr", 1);
      },
      staticInit() {
        [44].forEach(code => {
          FS.genericErrors[code] = new FS.ErrnoError(code);
          FS.genericErrors[code].stack = "<generic error, no stack>";
        });
        FS.nameTable = new Array(4096);
        FS.mount(MEMFS, {}, "/");
        FS.createDefaultDirectories();
        FS.createDefaultDevices();
        FS.createSpecialDirectories();
        FS.filesystems = {
          MEMFS: MEMFS,
          IDBFS: IDBFS
        };
      },
      init(input, output, error) {
        FS.init.initialized = true;
        Module["stdin"] = input || Module["stdin"];
        Module["stdout"] = output || Module["stdout"];
        Module["stderr"] = error || Module["stderr"];
        FS.createStandardStreams();
      },
      quit() {
        FS.init.initialized = false;
        _fflush(0);
        for (var i = 0; i < FS.streams.length; i++) {
          var stream = FS.streams[i];
          if (!stream) {
            continue;
          }
          FS.close(stream);
        }
      },
      findObject(path, dontResolveLastLink) {
        var ret = FS.analyzePath(path, dontResolveLastLink);
        if (!ret.exists) {
          return null;
        }
        return ret.object;
      },
      analyzePath(path, dontResolveLastLink) {
        try {
          var lookup = FS.lookupPath(path, {
            follow: !dontResolveLastLink
          });
          path = lookup.path;
        } catch (e) {}
        var ret = {
          isRoot: false,
          exists: false,
          error: 0,
          name: null,
          path: null,
          object: null,
          parentExists: false,
          parentPath: null,
          parentObject: null
        };
        try {
          var lookup = FS.lookupPath(path, {
            parent: true
          });
          ret.parentExists = true;
          ret.parentPath = lookup.path;
          ret.parentObject = lookup.node;
          ret.name = PATH.basename(path);
          lookup = FS.lookupPath(path, {
            follow: !dontResolveLastLink
          });
          ret.exists = true;
          ret.path = lookup.path;
          ret.object = lookup.node;
          ret.name = lookup.node.name;
          ret.isRoot = lookup.path === "/";
        } catch (e) {
          ret.error = e.errno;
        }
        return ret;
      },
      createPath(parent, path, canRead, canWrite) {
        parent = typeof parent == "string" ? parent : FS.getPath(parent);
        var parts = path.split("/").reverse();
        while (parts.length) {
          var part = parts.pop();
          if (!part) continue;
          var current = PATH.join2(parent, part);
          try {
            FS.mkdir(current);
          } catch (e) {}
          parent = current;
        }
        return current;
      },
      createFile(parent, name, properties, canRead, canWrite) {
        var path = PATH.join2(typeof parent == "string" ? parent : FS.getPath(parent), name);
        var mode = FS_getMode(canRead, canWrite);
        return FS.create(path, mode);
      },
      createDataFile(parent, name, data, canRead, canWrite, canOwn) {
        var path = name;
        if (parent) {
          parent = typeof parent == "string" ? parent : FS.getPath(parent);
          path = name ? PATH.join2(parent, name) : parent;
        }
        var mode = FS_getMode(canRead, canWrite);
        var node = FS.create(path, mode);
        if (data) {
          if (typeof data == "string") {
            var arr = new Array(data.length);
            for (var i = 0, len = data.length; i < len; ++i) arr[i] = data.charCodeAt(i);
            data = arr;
          }
          FS.chmod(node, mode | 146);
          var stream = FS.open(node, 577);
          FS.write(stream, data, 0, data.length, 0, canOwn);
          FS.close(stream);
          FS.chmod(node, mode);
        }
      },
      createDevice(parent, name, input, output) {
        var path = PATH.join2(typeof parent == "string" ? parent : FS.getPath(parent), name);
        var mode = FS_getMode(!!input, !!output);
        if (!FS.createDevice.major) FS.createDevice.major = 64;
        var dev = FS.makedev(FS.createDevice.major++, 0);
        FS.registerDevice(dev, {
          open(stream) {
            stream.seekable = false;
          },
          close(stream) {
            if (output?.buffer?.length) {
              output(10);
            }
          },
          read(stream, buffer, offset, length, pos) {
            var bytesRead = 0;
            for (var i = 0; i < length; i++) {
              var result;
              try {
                result = input();
              } catch (e) {
                throw new FS.ErrnoError(29);
              }
              if (result === undefined && bytesRead === 0) {
                throw new FS.ErrnoError(6);
              }
              if (result === null || result === undefined) break;
              bytesRead++;
              buffer[offset + i] = result;
            }
            if (bytesRead) {
              stream.node.timestamp = Date.now();
            }
            return bytesRead;
          },
          write(stream, buffer, offset, length, pos) {
            for (var i = 0; i < length; i++) {
              try {
                output(buffer[offset + i]);
              } catch (e) {
                throw new FS.ErrnoError(29);
              }
            }
            if (length) {
              stream.node.timestamp = Date.now();
            }
            return i;
          }
        });
        return FS.mkdev(path, mode, dev);
      },
      forceLoadFile(obj) {
        if (obj.isDevice || obj.isFolder || obj.link || obj.contents) return true;
        if (typeof XMLHttpRequest != "undefined") {
          throw new Error("Lazy loading should have been performed (contents set) in createLazyFile, but it was not. Lazy loading only works in web workers. Use --embed-file or --preload-file in emcc on the main thread.");
        } else if (read_) {
          try {
            obj.contents = intArrayFromString(read_(obj.url), true);
            obj.usedBytes = obj.contents.length;
          } catch (e) {
            throw new FS.ErrnoError(29);
          }
        } else {
          throw new Error("Cannot load without read() or XMLHttpRequest.");
        }
      },
      createLazyFile(parent, name, url, canRead, canWrite) {
        class LazyUint8Array {
          constructor() {
            this.lengthKnown = false;
            this.chunks = [];
          }
          get(idx) {
            if (idx > this.length - 1 || idx < 0) {
              return undefined;
            }
            var chunkOffset = idx % this.chunkSize;
            var chunkNum = idx / this.chunkSize | 0;
            return this.getter(chunkNum)[chunkOffset];
          }
          setDataGetter(getter) {
            this.getter = getter;
          }
          cacheLength() {
            var xhr = new XMLHttpRequest();
            xhr.open("HEAD", url, false);
            xhr.send(null);
            if (!(xhr.status >= 200 && xhr.status < 300 || xhr.status === 304)) throw new Error("Couldn't load " + url + ". Status: " + xhr.status);
            var datalength = Number(xhr.getResponseHeader("Content-length"));
            var header;
            var hasByteServing = (header = xhr.getResponseHeader("Accept-Ranges")) && header === "bytes";
            var usesGzip = (header = xhr.getResponseHeader("Content-Encoding")) && header === "gzip";
            var chunkSize = 1024 * 1024;
            if (!hasByteServing) chunkSize = datalength;
            var doXHR = (from, to) => {
              if (from > to) throw new Error("invalid range (" + from + ", " + to + ") or no bytes requested!");
              if (to > datalength - 1) throw new Error("only " + datalength + " bytes available! programmer error!");
              var xhr = new XMLHttpRequest();
              xhr.open("GET", url, false);
              if (datalength !== chunkSize) xhr.setRequestHeader("Range", "bytes=" + from + "-" + to);
              xhr.responseType = "arraybuffer";
              if (xhr.overrideMimeType) {
                xhr.overrideMimeType("text/plain; charset=x-user-defined");
              }
              xhr.send(null);
              if (!(xhr.status >= 200 && xhr.status < 300 || xhr.status === 304)) throw new Error("Couldn't load " + url + ". Status: " + xhr.status);
              if (xhr.response !== undefined) {
                return new Uint8Array(xhr.response || []);
              }
              return intArrayFromString(xhr.responseText || "", true);
            };
            var lazyArray = this;
            lazyArray.setDataGetter(chunkNum => {
              var start = chunkNum * chunkSize;
              var end = (chunkNum + 1) * chunkSize - 1;
              end = Math.min(end, datalength - 1);
              if (typeof lazyArray.chunks[chunkNum] == "undefined") {
                lazyArray.chunks[chunkNum] = doXHR(start, end);
              }
              if (typeof lazyArray.chunks[chunkNum] == "undefined") throw new Error("doXHR failed!");
              return lazyArray.chunks[chunkNum];
            });
            if (usesGzip || !datalength) {
              chunkSize = datalength = 1;
              datalength = this.getter(0).length;
              chunkSize = datalength;
              out("LazyFiles on gzip forces download of the whole file when length is accessed");
            }
            this._length = datalength;
            this._chunkSize = chunkSize;
            this.lengthKnown = true;
          }
          get length() {
            if (!this.lengthKnown) {
              this.cacheLength();
            }
            return this._length;
          }
          get chunkSize() {
            if (!this.lengthKnown) {
              this.cacheLength();
            }
            return this._chunkSize;
          }
        }
        if (typeof XMLHttpRequest != "undefined") {
          if (!ENVIRONMENT_IS_WORKER) throw "Cannot do synchronous binary XHRs outside webworkers in modern browsers. Use --embed-file or --preload-file in emcc";
          var lazyArray = new LazyUint8Array();
          var properties = {
            isDevice: false,
            contents: lazyArray
          };
        } else {
          var properties = {
            isDevice: false,
            url: url
          };
        }
        var node = FS.createFile(parent, name, properties, canRead, canWrite);
        if (properties.contents) {
          node.contents = properties.contents;
        } else if (properties.url) {
          node.contents = null;
          node.url = properties.url;
        }
        Object.defineProperties(node, {
          usedBytes: {
            get: function () {
              return this.contents.length;
            }
          }
        });
        var stream_ops = {};
        var keys = Object.keys(node.stream_ops);
        keys.forEach(key => {
          var fn = node.stream_ops[key];
          stream_ops[key] = (...args) => {
            FS.forceLoadFile(node);
            return fn(...args);
          };
        });
        function writeChunks(stream, buffer, offset, length, position) {
          var contents = stream.node.contents;
          if (position >= contents.length) return 0;
          var size = Math.min(contents.length - position, length);
          if (contents.slice) {
            for (var i = 0; i < size; i++) {
              buffer[offset + i] = contents[position + i];
            }
          } else {
            for (var i = 0; i < size; i++) {
              buffer[offset + i] = contents.get(position + i);
            }
          }
          return size;
        }
        stream_ops.read = (stream, buffer, offset, length, position) => {
          FS.forceLoadFile(node);
          return writeChunks(stream, buffer, offset, length, position);
        };
        stream_ops.mmap = (stream, length, position, prot, flags) => {
          FS.forceLoadFile(node);
          var ptr = mmapAlloc(length);
          if (!ptr) {
            throw new FS.ErrnoError(48);
          }
          writeChunks(stream, HEAP8, ptr, length, position);
          return {
            ptr: ptr,
            allocated: true
          };
        };
        node.stream_ops = stream_ops;
        return node;
      }
    };
    var SYSCALLS = {
      DEFAULT_POLLMASK: 5,
      calculateAt(dirfd, path, allowEmpty) {
        if (PATH.isAbs(path)) {
          return path;
        }
        var dir;
        if (dirfd === -100) {
          dir = FS.cwd();
        } else {
          var dirstream = SYSCALLS.getStreamFromFD(dirfd);
          dir = dirstream.path;
        }
        if (path.length == 0) {
          if (!allowEmpty) {
            throw new FS.ErrnoError(44);
          }
          return dir;
        }
        return PATH.join2(dir, path);
      },
      doStat(func, path, buf) {
        var stat = func(path);
        HEAP32[buf >>> 2 >>> 0] = stat.dev;
        HEAP32[buf + 4 >>> 2 >>> 0] = stat.mode;
        HEAPU32[buf + 8 >>> 2 >>> 0] = stat.nlink;
        HEAP32[buf + 12 >>> 2 >>> 0] = stat.uid;
        HEAP32[buf + 16 >>> 2 >>> 0] = stat.gid;
        HEAP32[buf + 20 >>> 2 >>> 0] = stat.rdev;
        tempI64 = [stat.size >>> 0, (tempDouble = stat.size, +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[buf + 24 >>> 2 >>> 0] = tempI64[0], HEAP32[buf + 28 >>> 2 >>> 0] = tempI64[1];
        HEAP32[buf + 32 >>> 2 >>> 0] = 4096;
        HEAP32[buf + 36 >>> 2 >>> 0] = stat.blocks;
        var atime = stat.atime.getTime();
        var mtime = stat.mtime.getTime();
        var ctime = stat.ctime.getTime();
        tempI64 = [Math.floor(atime / 1e3) >>> 0, (tempDouble = Math.floor(atime / 1e3), +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[buf + 40 >>> 2 >>> 0] = tempI64[0], HEAP32[buf + 44 >>> 2 >>> 0] = tempI64[1];
        HEAPU32[buf + 48 >>> 2 >>> 0] = atime % 1e3 * 1e3;
        tempI64 = [Math.floor(mtime / 1e3) >>> 0, (tempDouble = Math.floor(mtime / 1e3), +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[buf + 56 >>> 2 >>> 0] = tempI64[0], HEAP32[buf + 60 >>> 2 >>> 0] = tempI64[1];
        HEAPU32[buf + 64 >>> 2 >>> 0] = mtime % 1e3 * 1e3;
        tempI64 = [Math.floor(ctime / 1e3) >>> 0, (tempDouble = Math.floor(ctime / 1e3), +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[buf + 72 >>> 2 >>> 0] = tempI64[0], HEAP32[buf + 76 >>> 2 >>> 0] = tempI64[1];
        HEAPU32[buf + 80 >>> 2 >>> 0] = ctime % 1e3 * 1e3;
        tempI64 = [stat.ino >>> 0, (tempDouble = stat.ino, +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[buf + 88 >>> 2 >>> 0] = tempI64[0], HEAP32[buf + 92 >>> 2 >>> 0] = tempI64[1];
        return 0;
      },
      doMsync(addr, stream, len, flags, offset) {
        if (!FS.isFile(stream.node.mode)) {
          throw new FS.ErrnoError(43);
        }
        if (flags & 2) {
          return 0;
        }
        var buffer = HEAPU8.slice(addr, addr + len);
        FS.msync(stream, buffer, offset, len, flags);
      },
      getStreamFromFD(fd) {
        var stream = FS.getStreamChecked(fd);
        return stream;
      },
      varargs: undefined,
      getStr(ptr) {
        var ret = UTF8ToString(ptr);
        return ret;
      }
    };
    function ___syscall__newselect(nfds, readfds, writefds, exceptfds, timeout) {
      readfds >>>= 0;
      writefds >>>= 0;
      exceptfds >>>= 0;
      timeout >>>= 0;
      try {
        var total = 0;
        var srcReadLow = readfds ? HEAP32[readfds >>> 2 >>> 0] : 0,
          srcReadHigh = readfds ? HEAP32[readfds + 4 >>> 2 >>> 0] : 0;
        var srcWriteLow = writefds ? HEAP32[writefds >>> 2 >>> 0] : 0,
          srcWriteHigh = writefds ? HEAP32[writefds + 4 >>> 2 >>> 0] : 0;
        var srcExceptLow = exceptfds ? HEAP32[exceptfds >>> 2 >>> 0] : 0,
          srcExceptHigh = exceptfds ? HEAP32[exceptfds + 4 >>> 2 >>> 0] : 0;
        var dstReadLow = 0,
          dstReadHigh = 0;
        var dstWriteLow = 0,
          dstWriteHigh = 0;
        var dstExceptLow = 0,
          dstExceptHigh = 0;
        var allLow = (readfds ? HEAP32[readfds >>> 2 >>> 0] : 0) | (writefds ? HEAP32[writefds >>> 2 >>> 0] : 0) | (exceptfds ? HEAP32[exceptfds >>> 2 >>> 0] : 0);
        var allHigh = (readfds ? HEAP32[readfds + 4 >>> 2 >>> 0] : 0) | (writefds ? HEAP32[writefds + 4 >>> 2 >>> 0] : 0) | (exceptfds ? HEAP32[exceptfds + 4 >>> 2 >>> 0] : 0);
        var check = function (fd, low, high, val) {
          return fd < 32 ? low & val : high & val;
        };
        for (var fd = 0; fd < nfds; fd++) {
          var mask = 1 << fd % 32;
          if (!check(fd, allLow, allHigh, mask)) {
            continue;
          }
          var stream = SYSCALLS.getStreamFromFD(fd);
          var flags = SYSCALLS.DEFAULT_POLLMASK;
          if (stream.stream_ops.poll) {
            var timeoutInMillis = -1;
            if (timeout) {
              var tv_sec = readfds ? HEAP32[timeout >>> 2 >>> 0] : 0,
                tv_usec = readfds ? HEAP32[timeout + 4 >>> 2 >>> 0] : 0;
              timeoutInMillis = (tv_sec + tv_usec / 1e6) * 1e3;
            }
            flags = stream.stream_ops.poll(stream, timeoutInMillis);
          }
          if (flags & 1 && check(fd, srcReadLow, srcReadHigh, mask)) {
            fd < 32 ? dstReadLow = dstReadLow | mask : dstReadHigh = dstReadHigh | mask;
            total++;
          }
          if (flags & 4 && check(fd, srcWriteLow, srcWriteHigh, mask)) {
            fd < 32 ? dstWriteLow = dstWriteLow | mask : dstWriteHigh = dstWriteHigh | mask;
            total++;
          }
          if (flags & 2 && check(fd, srcExceptLow, srcExceptHigh, mask)) {
            fd < 32 ? dstExceptLow = dstExceptLow | mask : dstExceptHigh = dstExceptHigh | mask;
            total++;
          }
        }
        if (readfds) {
          HEAP32[readfds >>> 2 >>> 0] = dstReadLow;
          HEAP32[readfds + 4 >>> 2 >>> 0] = dstReadHigh;
        }
        if (writefds) {
          HEAP32[writefds >>> 2 >>> 0] = dstWriteLow;
          HEAP32[writefds + 4 >>> 2 >>> 0] = dstWriteHigh;
        }
        if (exceptfds) {
          HEAP32[exceptfds >>> 2 >>> 0] = dstExceptLow;
          HEAP32[exceptfds + 4 >>> 2 >>> 0] = dstExceptHigh;
        }
        return total;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall__newselect.sig = "iipppp";
    var SOCKFS = {
      mount(mount) {
        Module["websocket"] = Module["websocket"] && "object" === typeof Module["websocket"] ? Module["websocket"] : {};
        Module["websocket"]._callbacks = {};
        Module["websocket"]["on"] = function (event, callback) {
          if ("function" === typeof callback) {
            this._callbacks[event] = callback;
          }
          return this;
        };
        Module["websocket"].emit = function (event, param) {
          if ("function" === typeof this._callbacks[event]) {
            this._callbacks[event].call(this, param);
          }
        };
        return FS.createNode(null, "/", 16384 | 511, 0);
      },
      createSocket(family, type, protocol) {
        type &= ~526336;
        var streaming = type == 1;
        if (streaming && protocol && protocol != 6) {
          throw new FS.ErrnoError(66);
        }
        var sock = {
          family: family,
          type: type,
          protocol: protocol,
          server: null,
          error: null,
          peers: {},
          pending: [],
          recv_queue: [],
          sock_ops: SOCKFS.websocket_sock_ops
        };
        var name = SOCKFS.nextname();
        var node = FS.createNode(SOCKFS.root, name, 49152, 0);
        node.sock = sock;
        var stream = FS.createStream({
          path: name,
          node: node,
          flags: 2,
          seekable: false,
          stream_ops: SOCKFS.stream_ops
        });
        sock.stream = stream;
        return sock;
      },
      getSocket(fd) {
        var stream = FS.getStream(fd);
        if (!stream || !FS.isSocket(stream.node.mode)) {
          return null;
        }
        return stream.node.sock;
      },
      stream_ops: {
        poll(stream) {
          var sock = stream.node.sock;
          return sock.sock_ops.poll(sock);
        },
        ioctl(stream, request, varargs) {
          var sock = stream.node.sock;
          return sock.sock_ops.ioctl(sock, request, varargs);
        },
        read(stream, buffer, offset, length, position) {
          var sock = stream.node.sock;
          var msg = sock.sock_ops.recvmsg(sock, length);
          if (!msg) {
            return 0;
          }
          buffer.set(msg.buffer, offset);
          return msg.buffer.length;
        },
        write(stream, buffer, offset, length, position) {
          var sock = stream.node.sock;
          return sock.sock_ops.sendmsg(sock, buffer, offset, length);
        },
        close(stream) {
          var sock = stream.node.sock;
          sock.sock_ops.close(sock);
        }
      },
      nextname() {
        if (!SOCKFS.nextname.current) {
          SOCKFS.nextname.current = 0;
        }
        return "socket[" + SOCKFS.nextname.current++ + "]";
      },
      websocket_sock_ops: {
        createPeer(sock, addr, port) {
          var ws;
          if (typeof addr == "object") {
            ws = addr;
            addr = null;
            port = null;
          }
          if (ws) {
            if (ws._socket) {
              addr = ws._socket.remoteAddress;
              port = ws._socket.remotePort;
            } else {
              var result = /ws[s]?:\/\/([^:]+):(\d+)/.exec(ws.url);
              if (!result) {
                throw new Error("WebSocket URL must be in the format ws(s)://address:port");
              }
              addr = result[1];
              port = parseInt(result[2], 10);
            }
          } else {
            try {
              var runtimeConfig = Module["websocket"] && "object" === typeof Module["websocket"];
              var url = "ws:#".replace("#", "//");
              if (runtimeConfig) {
                if ("string" === typeof Module["websocket"]["url"]) {
                  url = Module["websocket"]["url"];
                }
              }
              if (url === "ws://" || url === "wss://") {
                var parts = addr.split("/");
                url = url + parts[0] + ":" + port + "/" + parts.slice(1).join("/");
              }
              var subProtocols = "binary";
              if (runtimeConfig) {
                if ("string" === typeof Module["websocket"]["subprotocol"]) {
                  subProtocols = Module["websocket"]["subprotocol"];
                }
              }
              var opts = undefined;
              if (subProtocols !== "null") {
                subProtocols = subProtocols.replace(/^ +| +$/g, "").split(/ *, */);
                opts = subProtocols;
              }
              if (runtimeConfig && null === Module["websocket"]["subprotocol"]) {
                subProtocols = "null";
                opts = undefined;
              }
              var WebSocketConstructor;
              {
                WebSocketConstructor = WebSocket;
              }
              ws = new WebSocketConstructor(url, opts);
              ws.binaryType = "arraybuffer";
            } catch (e) {
              throw new FS.ErrnoError(23);
            }
          }
          var peer = {
            addr: addr,
            port: port,
            socket: ws,
            dgram_send_queue: []
          };
          SOCKFS.websocket_sock_ops.addPeer(sock, peer);
          SOCKFS.websocket_sock_ops.handlePeerEvents(sock, peer);
          if (sock.type === 2 && typeof sock.sport != "undefined") {
            peer.dgram_send_queue.push(new Uint8Array([255, 255, 255, 255, "p".charCodeAt(0), "o".charCodeAt(0), "r".charCodeAt(0), "t".charCodeAt(0), (sock.sport & 65280) >> 8, sock.sport & 255]));
          }
          return peer;
        },
        getPeer(sock, addr, port) {
          return sock.peers[addr + ":" + port];
        },
        addPeer(sock, peer) {
          sock.peers[peer.addr + ":" + peer.port] = peer;
        },
        removePeer(sock, peer) {
          delete sock.peers[peer.addr + ":" + peer.port];
        },
        handlePeerEvents(sock, peer) {
          var first = true;
          var handleOpen = function () {
            Module["websocket"].emit("open", sock.stream.fd);
            try {
              var queued = peer.dgram_send_queue.shift();
              while (queued) {
                peer.socket.send(queued);
                queued = peer.dgram_send_queue.shift();
              }
            } catch (e) {
              peer.socket.close();
            }
          };
          function handleMessage(data) {
            if (typeof data == "string") {
              var encoder = new TextEncoder();
              data = encoder.encode(data);
            } else {
              assert(data.byteLength !== undefined);
              if (data.byteLength == 0) {
                return;
              }
              data = new Uint8Array(data);
            }
            var wasfirst = first;
            first = false;
            if (wasfirst && data.length === 10 && data[0] === 255 && data[1] === 255 && data[2] === 255 && data[3] === 255 && data[4] === "p".charCodeAt(0) && data[5] === "o".charCodeAt(0) && data[6] === "r".charCodeAt(0) && data[7] === "t".charCodeAt(0)) {
              var newport = data[8] << 8 | data[9];
              SOCKFS.websocket_sock_ops.removePeer(sock, peer);
              peer.port = newport;
              SOCKFS.websocket_sock_ops.addPeer(sock, peer);
              return;
            }
            sock.recv_queue.push({
              addr: peer.addr,
              port: peer.port,
              data: data
            });
            Module["websocket"].emit("message", sock.stream.fd);
          }
          if (ENVIRONMENT_IS_NODE) {
            peer.socket.on("open", handleOpen);
            peer.socket.on("message", function (data, isBinary) {
              if (!isBinary) {
                return;
              }
              handleMessage(new Uint8Array(data).buffer);
            });
            peer.socket.on("close", function () {
              Module["websocket"].emit("close", sock.stream.fd);
            });
            peer.socket.on("error", function (error) {
              sock.error = 14;
              Module["websocket"].emit("error", [sock.stream.fd, sock.error, "ECONNREFUSED: Connection refused"]);
            });
          } else {
            peer.socket.onopen = handleOpen;
            peer.socket.onclose = function () {
              Module["websocket"].emit("close", sock.stream.fd);
            };
            peer.socket.onmessage = function peer_socket_onmessage(event) {
              handleMessage(event.data);
            };
            peer.socket.onerror = function (error) {
              sock.error = 14;
              Module["websocket"].emit("error", [sock.stream.fd, sock.error, "ECONNREFUSED: Connection refused"]);
            };
          }
        },
        poll(sock) {
          if (sock.type === 1 && sock.server) {
            return sock.pending.length ? 64 | 1 : 0;
          }
          var mask = 0;
          var dest = sock.type === 1 ? SOCKFS.websocket_sock_ops.getPeer(sock, sock.daddr, sock.dport) : null;
          if (sock.recv_queue.length || !dest || dest && dest.socket.readyState === dest.socket.CLOSING || dest && dest.socket.readyState === dest.socket.CLOSED) {
            mask |= 64 | 1;
          }
          if (!dest || dest && dest.socket.readyState === dest.socket.OPEN) {
            mask |= 4;
          }
          if (dest && dest.socket.readyState === dest.socket.CLOSING || dest && dest.socket.readyState === dest.socket.CLOSED) {
            mask |= 16;
          }
          return mask;
        },
        ioctl(sock, request, arg) {
          switch (request) {
            case 21531:
              var bytes = 0;
              if (sock.recv_queue.length) {
                bytes = sock.recv_queue[0].data.length;
              }
              HEAP32[arg >>> 2 >>> 0] = bytes;
              return 0;
            default:
              return 28;
          }
        },
        close(sock) {
          if (sock.server) {
            try {
              sock.server.close();
            } catch (e) {}
            sock.server = null;
          }
          var peers = Object.keys(sock.peers);
          for (var i = 0; i < peers.length; i++) {
            var peer = sock.peers[peers[i]];
            try {
              peer.socket.close();
            } catch (e) {}
            SOCKFS.websocket_sock_ops.removePeer(sock, peer);
          }
          return 0;
        },
        bind(sock, addr, port) {
          if (typeof sock.saddr != "undefined" || typeof sock.sport != "undefined") {
            throw new FS.ErrnoError(28);
          }
          sock.saddr = addr;
          sock.sport = port;
          if (sock.type === 2) {
            if (sock.server) {
              sock.server.close();
              sock.server = null;
            }
            try {
              sock.sock_ops.listen(sock, 0);
            } catch (e) {
              if (!(e.name === "ErrnoError")) throw e;
              if (e.errno !== 138) throw e;
            }
          }
        },
        connect(sock, addr, port) {
          if (sock.server) {
            throw new FS.ErrnoError(138);
          }
          if (typeof sock.daddr != "undefined" && typeof sock.dport != "undefined") {
            var dest = SOCKFS.websocket_sock_ops.getPeer(sock, sock.daddr, sock.dport);
            if (dest) {
              if (dest.socket.readyState === dest.socket.CONNECTING) {
                throw new FS.ErrnoError(7);
              } else {
                throw new FS.ErrnoError(30);
              }
            }
          }
          var peer = SOCKFS.websocket_sock_ops.createPeer(sock, addr, port);
          sock.daddr = peer.addr;
          sock.dport = peer.port;
          throw new FS.ErrnoError(26);
        },
        listen(sock, backlog) {
          if (!ENVIRONMENT_IS_NODE) {
            throw new FS.ErrnoError(138);
          }
        },
        accept(listensock) {
          if (!listensock.server || !listensock.pending.length) {
            throw new FS.ErrnoError(28);
          }
          var newsock = listensock.pending.shift();
          newsock.stream.flags = listensock.stream.flags;
          return newsock;
        },
        getname(sock, peer) {
          var addr, port;
          if (peer) {
            if (sock.daddr === undefined || sock.dport === undefined) {
              throw new FS.ErrnoError(53);
            }
            addr = sock.daddr;
            port = sock.dport;
          } else {
            addr = sock.saddr || 0;
            port = sock.sport || 0;
          }
          return {
            addr: addr,
            port: port
          };
        },
        sendmsg(sock, buffer, offset, length, addr, port) {
          if (sock.type === 2) {
            if (addr === undefined || port === undefined) {
              addr = sock.daddr;
              port = sock.dport;
            }
            if (addr === undefined || port === undefined) {
              throw new FS.ErrnoError(17);
            }
          } else {
            addr = sock.daddr;
            port = sock.dport;
          }
          var dest = SOCKFS.websocket_sock_ops.getPeer(sock, addr, port);
          if (sock.type === 1) {
            if (!dest || dest.socket.readyState === dest.socket.CLOSING || dest.socket.readyState === dest.socket.CLOSED) {
              throw new FS.ErrnoError(53);
            } else if (dest.socket.readyState === dest.socket.CONNECTING) {
              throw new FS.ErrnoError(6);
            }
          }
          if (ArrayBuffer.isView(buffer)) {
            offset += buffer.byteOffset;
            buffer = buffer.buffer;
          }
          var data;
          data = buffer.slice(offset, offset + length);
          if (sock.type === 2) {
            if (!dest || dest.socket.readyState !== dest.socket.OPEN) {
              if (!dest || dest.socket.readyState === dest.socket.CLOSING || dest.socket.readyState === dest.socket.CLOSED) {
                dest = SOCKFS.websocket_sock_ops.createPeer(sock, addr, port);
              }
              dest.dgram_send_queue.push(data);
              return length;
            }
          }
          try {
            dest.socket.send(data);
            return length;
          } catch (e) {
            throw new FS.ErrnoError(28);
          }
        },
        recvmsg(sock, length) {
          if (sock.type === 1 && sock.server) {
            throw new FS.ErrnoError(53);
          }
          var queued = sock.recv_queue.shift();
          if (!queued) {
            if (sock.type === 1) {
              var dest = SOCKFS.websocket_sock_ops.getPeer(sock, sock.daddr, sock.dport);
              if (!dest) {
                throw new FS.ErrnoError(53);
              }
              if (dest.socket.readyState === dest.socket.CLOSING || dest.socket.readyState === dest.socket.CLOSED) {
                return null;
              }
              throw new FS.ErrnoError(6);
            }
            throw new FS.ErrnoError(6);
          }
          var queuedLength = queued.data.byteLength || queued.data.length;
          var queuedOffset = queued.data.byteOffset || 0;
          var queuedBuffer = queued.data.buffer || queued.data;
          var bytesRead = Math.min(length, queuedLength);
          var res = {
            buffer: new Uint8Array(queuedBuffer, queuedOffset, bytesRead),
            addr: queued.addr,
            port: queued.port
          };
          if (sock.type === 1 && bytesRead < queuedLength) {
            var bytesRemaining = queuedLength - bytesRead;
            queued.data = new Uint8Array(queuedBuffer, queuedOffset + bytesRead, bytesRemaining);
            sock.recv_queue.unshift(queued);
          }
          return res;
        }
      }
    };
    var getSocketFromFD = fd => {
      var socket = SOCKFS.getSocket(fd);
      if (!socket) throw new FS.ErrnoError(8);
      return socket;
    };
    var inetPton4 = str => {
      var b = str.split(".");
      for (var i = 0; i < 4; i++) {
        var tmp = Number(b[i]);
        if (isNaN(tmp)) return null;
        b[i] = tmp;
      }
      return (b[0] | b[1] << 8 | b[2] << 16 | b[3] << 24) >>> 0;
    };
    var jstoi_q = str => parseInt(str);
    var inetPton6 = str => {
      var words;
      var w, offset, z;
      var valid6regx = /^((?=.*::)(?!.*::.+::)(::)?([\dA-F]{1,4}:(:|\b)|){5}|([\dA-F]{1,4}:){6})((([\dA-F]{1,4}((?!\3)::|:\b|$))|(?!\2\3)){2}|(((2[0-4]|1\d|[1-9])?\d|25[0-5])\.?\b){4})$/i;
      var parts = [];
      if (!valid6regx.test(str)) {
        return null;
      }
      if (str === "::") {
        return [0, 0, 0, 0, 0, 0, 0, 0];
      }
      if (str.startsWith("::")) {
        str = str.replace("::", "Z:");
      } else {
        str = str.replace("::", ":Z:");
      }
      if (str.indexOf(".") > 0) {
        str = str.replace(new RegExp("[.]", "g"), ":");
        words = str.split(":");
        words[words.length - 4] = jstoi_q(words[words.length - 4]) + jstoi_q(words[words.length - 3]) * 256;
        words[words.length - 3] = jstoi_q(words[words.length - 2]) + jstoi_q(words[words.length - 1]) * 256;
        words = words.slice(0, words.length - 2);
      } else {
        words = str.split(":");
      }
      offset = 0;
      z = 0;
      for (w = 0; w < words.length; w++) {
        if (typeof words[w] == "string") {
          if (words[w] === "Z") {
            for (z = 0; z < 8 - words.length + 1; z++) {
              parts[w + z] = 0;
            }
            offset = z - 1;
          } else {
            parts[w + offset] = _htons(parseInt(words[w], 16));
          }
        } else {
          parts[w + offset] = words[w];
        }
      }
      return [parts[1] << 16 | parts[0], parts[3] << 16 | parts[2], parts[5] << 16 | parts[4], parts[7] << 16 | parts[6]];
    };
    var writeSockaddr = (sa, family, addr, port, addrlen) => {
      switch (family) {
        case 2:
          addr = inetPton4(addr);
          zeroMemory(sa, 16);
          if (addrlen) {
            HEAP32[addrlen >>> 2 >>> 0] = 16;
          }
          HEAP16[sa >>> 1 >>> 0] = family;
          HEAP32[sa + 4 >>> 2 >>> 0] = addr;
          HEAP16[sa + 2 >>> 1 >>> 0] = _htons(port);
          break;
        case 10:
          addr = inetPton6(addr);
          zeroMemory(sa, 28);
          if (addrlen) {
            HEAP32[addrlen >>> 2 >>> 0] = 28;
          }
          HEAP32[sa >>> 2 >>> 0] = family;
          HEAP32[sa + 8 >>> 2 >>> 0] = addr[0];
          HEAP32[sa + 12 >>> 2 >>> 0] = addr[1];
          HEAP32[sa + 16 >>> 2 >>> 0] = addr[2];
          HEAP32[sa + 20 >>> 2 >>> 0] = addr[3];
          HEAP16[sa + 2 >>> 1 >>> 0] = _htons(port);
          break;
        default:
          return 5;
      }
      return 0;
    };
    var DNS = {
      address_map: {
        id: 1,
        addrs: {},
        names: {}
      },
      lookup_name(name) {
        var res = inetPton4(name);
        if (res !== null) {
          return name;
        }
        res = inetPton6(name);
        if (res !== null) {
          return name;
        }
        var addr;
        if (DNS.address_map.addrs[name]) {
          addr = DNS.address_map.addrs[name];
        } else {
          var id = DNS.address_map.id++;
          assert(id < 65535, "exceeded max address mappings of 65535");
          addr = "172.29." + (id & 255) + "." + (id & 65280);
          DNS.address_map.names[addr] = name;
          DNS.address_map.addrs[name] = addr;
        }
        return addr;
      },
      lookup_addr(addr) {
        if (DNS.address_map.names[addr]) {
          return DNS.address_map.names[addr];
        }
        return null;
      }
    };
    function ___syscall_accept4(fd, addr, addrlen, flags, d1, d2) {
      addr >>>= 0;
      addrlen >>>= 0;
      try {
        var sock = getSocketFromFD(fd);
        var newsock = sock.sock_ops.accept(sock);
        if (addr) {
          var errno = writeSockaddr(addr, newsock.family, DNS.lookup_name(newsock.daddr), newsock.dport, addrlen);
        }
        return newsock.stream.fd;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_accept4.sig = "iippiii";
    var inetNtop4 = addr => (addr & 255) + "." + (addr >> 8 & 255) + "." + (addr >> 16 & 255) + "." + (addr >> 24 & 255);
    var inetNtop6 = ints => {
      var str = "";
      var word = 0;
      var longest = 0;
      var lastzero = 0;
      var zstart = 0;
      var len = 0;
      var i = 0;
      var parts = [ints[0] & 65535, ints[0] >> 16, ints[1] & 65535, ints[1] >> 16, ints[2] & 65535, ints[2] >> 16, ints[3] & 65535, ints[3] >> 16];
      var hasipv4 = true;
      var v4part = "";
      for (i = 0; i < 5; i++) {
        if (parts[i] !== 0) {
          hasipv4 = false;
          break;
        }
      }
      if (hasipv4) {
        v4part = inetNtop4(parts[6] | parts[7] << 16);
        if (parts[5] === -1) {
          str = "::ffff:";
          str += v4part;
          return str;
        }
        if (parts[5] === 0) {
          str = "::";
          if (v4part === "0.0.0.0") v4part = "";
          if (v4part === "0.0.0.1") v4part = "1";
          str += v4part;
          return str;
        }
      }
      for (word = 0; word < 8; word++) {
        if (parts[word] === 0) {
          if (word - lastzero > 1) {
            len = 0;
          }
          lastzero = word;
          len++;
        }
        if (len > longest) {
          longest = len;
          zstart = word - longest + 1;
        }
      }
      for (word = 0; word < 8; word++) {
        if (longest > 1) {
          if (parts[word] === 0 && word >= zstart && word < zstart + longest) {
            if (word === zstart) {
              str += ":";
              if (zstart === 0) str += ":";
            }
            continue;
          }
        }
        str += Number(_ntohs(parts[word] & 65535)).toString(16);
        str += word < 7 ? ":" : "";
      }
      return str;
    };
    var readSockaddr = (sa, salen) => {
      var family = HEAP16[sa >>> 1 >>> 0];
      var port = _ntohs(HEAPU16[sa + 2 >>> 1 >>> 0]);
      var addr;
      switch (family) {
        case 2:
          if (salen !== 16) {
            return {
              errno: 28
            };
          }
          addr = HEAP32[sa + 4 >>> 2 >>> 0];
          addr = inetNtop4(addr);
          break;
        case 10:
          if (salen !== 28) {
            return {
              errno: 28
            };
          }
          addr = [HEAP32[sa + 8 >>> 2 >>> 0], HEAP32[sa + 12 >>> 2 >>> 0], HEAP32[sa + 16 >>> 2 >>> 0], HEAP32[sa + 20 >>> 2 >>> 0]];
          addr = inetNtop6(addr);
          break;
        default:
          return {
            errno: 5
          };
      }
      return {
        family: family,
        addr: addr,
        port: port
      };
    };
    var getSocketAddress = (addrp, addrlen, allowNull) => {
      if (allowNull && addrp === 0) return null;
      var info = readSockaddr(addrp, addrlen);
      if (info.errno) throw new FS.ErrnoError(info.errno);
      info.addr = DNS.lookup_addr(info.addr) || info.addr;
      return info;
    };
    function ___syscall_bind(fd, addr, addrlen, d1, d2, d3) {
      addr >>>= 0;
      addrlen >>>= 0;
      try {
        var sock = getSocketFromFD(fd);
        var info = getSocketAddress(addr, addrlen);
        sock.sock_ops.bind(sock, info.addr, info.port);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_bind.sig = "iippiii";
    function ___syscall_chdir(path) {
      path >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        FS.chdir(path);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_chdir.sig = "ip";
    function ___syscall_chmod(path, mode) {
      path >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        FS.chmod(path, mode);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_chmod.sig = "ipi";
    function ___syscall_connect(fd, addr, addrlen, d1, d2, d3) {
      addr >>>= 0;
      addrlen >>>= 0;
      try {
        var sock = getSocketFromFD(fd);
        var info = getSocketAddress(addr, addrlen);
        sock.sock_ops.connect(sock, info.addr, info.port);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_connect.sig = "iippiii";
    function ___syscall_dup(fd) {
      try {
        var old = SYSCALLS.getStreamFromFD(fd);
        return FS.dupStream(old).fd;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_dup.sig = "ii";
    function ___syscall_faccessat(dirfd, path, amode, flags) {
      path >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        path = SYSCALLS.calculateAt(dirfd, path);
        if (amode & ~7) {
          return -28;
        }
        var lookup = FS.lookupPath(path, {
          follow: true
        });
        var node = lookup.node;
        if (!node) {
          return -44;
        }
        var perms = "";
        if (amode & 4) perms += "r";
        if (amode & 2) perms += "w";
        if (amode & 1) perms += "x";
        if (perms && FS.nodePermissions(node, perms)) {
          return -2;
        }
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_faccessat.sig = "iipii";
    function ___syscall_fchownat(dirfd, path, owner, group, flags) {
      path >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        var nofollow = flags & 256;
        flags = flags & ~256;
        path = SYSCALLS.calculateAt(dirfd, path);
        (nofollow ? FS.lchown : FS.chown)(path, owner, group);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_fchownat.sig = "iipiii";
    function syscallGetVarargI() {
      var ret = HEAP32[+SYSCALLS.varargs >>> 2 >>> 0];
      SYSCALLS.varargs += 4;
      return ret;
    }
    var syscallGetVarargP = syscallGetVarargI;
    function ___syscall_fcntl64(fd, cmd, varargs) {
      varargs >>>= 0;
      SYSCALLS.varargs = varargs;
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        switch (cmd) {
          case 0:
            {
              var arg = syscallGetVarargI();
              if (arg < 0) {
                return -28;
              }
              while (FS.streams[arg]) {
                arg++;
              }
              var newStream;
              newStream = FS.dupStream(stream, arg);
              return newStream.fd;
            }
          case 1:
          case 2:
            return 0;
          case 3:
            return stream.flags;
          case 4:
            {
              var arg = syscallGetVarargI();
              stream.flags |= arg;
              return 0;
            }
          case 12:
            {
              var arg = syscallGetVarargP();
              var offset = 0;
              HEAP16[arg + offset >>> 1 >>> 0] = 2;
              return 0;
            }
          case 13:
          case 14:
            return 0;
        }
        return -28;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_fcntl64.sig = "iiip";
    function ___syscall_fdatasync(fd) {
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_fdatasync.sig = "ii";
    function ___syscall_fstat64(fd, buf) {
      buf >>>= 0;
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        return SYSCALLS.doStat(FS.stat, stream.path, buf);
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_fstat64.sig = "iip";
    function ___syscall_ftruncate64(fd, length_low, length_high) {
      var length = convertI32PairToI53Checked(length_low, length_high);
      try {
        if (isNaN(length)) return 61;
        FS.ftruncate(fd, length);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_ftruncate64.sig = "iiii";
    var stringToUTF8 = (str, outPtr, maxBytesToWrite) => stringToUTF8Array(str, HEAPU8, outPtr, maxBytesToWrite);
    function ___syscall_getcwd(buf, size) {
      buf >>>= 0;
      size >>>= 0;
      try {
        if (size === 0) return -28;
        var cwd = FS.cwd();
        var cwdLengthInBytes = lengthBytesUTF8(cwd) + 1;
        if (size < cwdLengthInBytes) return -68;
        stringToUTF8(cwd, buf, size);
        return cwdLengthInBytes;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_getcwd.sig = "ipp";
    function ___syscall_getdents64(fd, dirp, count) {
      dirp >>>= 0;
      count >>>= 0;
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        stream.getdents ||= FS.readdir(stream.path);
        var struct_size = 280;
        var pos = 0;
        var off = FS.llseek(stream, 0, 1);
        var idx = Math.floor(off / struct_size);
        while (idx < stream.getdents.length && pos + struct_size <= count) {
          var id;
          var type;
          var name = stream.getdents[idx];
          if (name === ".") {
            id = stream.node.id;
            type = 4;
          } else if (name === "..") {
            var lookup = FS.lookupPath(stream.path, {
              parent: true
            });
            id = lookup.node.id;
            type = 4;
          } else {
            var child = FS.lookupNode(stream.node, name);
            id = child.id;
            type = FS.isChrdev(child.mode) ? 2 : FS.isDir(child.mode) ? 4 : FS.isLink(child.mode) ? 10 : 8;
          }
          tempI64 = [id >>> 0, (tempDouble = id, +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[dirp + pos >>> 2 >>> 0] = tempI64[0], HEAP32[dirp + pos + 4 >>> 2 >>> 0] = tempI64[1];
          tempI64 = [(idx + 1) * struct_size >>> 0, (tempDouble = (idx + 1) * struct_size, +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[dirp + pos + 8 >>> 2 >>> 0] = tempI64[0], HEAP32[dirp + pos + 12 >>> 2 >>> 0] = tempI64[1];
          HEAP16[dirp + pos + 16 >>> 1 >>> 0] = 280;
          HEAP8[dirp + pos + 18 >>> 0] = type;
          stringToUTF8(name, dirp + pos + 19, 256);
          pos += struct_size;
          idx += 1;
        }
        FS.llseek(stream, idx * struct_size, 0);
        return pos;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_getdents64.sig = "iipp";
    function ___syscall_getpeername(fd, addr, addrlen, d1, d2, d3) {
      addr >>>= 0;
      addrlen >>>= 0;
      try {
        var sock = getSocketFromFD(fd);
        if (!sock.daddr) {
          return -53;
        }
        var errno = writeSockaddr(addr, sock.family, DNS.lookup_name(sock.daddr), sock.dport, addrlen);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_getpeername.sig = "iippiii";
    function ___syscall_getsockname(fd, addr, addrlen, d1, d2, d3) {
      addr >>>= 0;
      addrlen >>>= 0;
      try {
        var sock = getSocketFromFD(fd);
        var errno = writeSockaddr(addr, sock.family, DNS.lookup_name(sock.saddr || "0.0.0.0"), sock.sport, addrlen);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_getsockname.sig = "iippiii";
    function ___syscall_getsockopt(fd, level, optname, optval, optlen, d1) {
      optval >>>= 0;
      optlen >>>= 0;
      try {
        var sock = getSocketFromFD(fd);
        if (level === 1) {
          if (optname === 4) {
            HEAP32[optval >>> 2 >>> 0] = sock.error;
            HEAP32[optlen >>> 2 >>> 0] = 4;
            sock.error = null;
            return 0;
          }
        }
        return -50;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_getsockopt.sig = "iiiippi";
    function ___syscall_ioctl(fd, op, varargs) {
      varargs >>>= 0;
      SYSCALLS.varargs = varargs;
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        switch (op) {
          case 21509:
            {
              if (!stream.tty) return -59;
              return 0;
            }
          case 21505:
            {
              if (!stream.tty) return -59;
              if (stream.tty.ops.ioctl_tcgets) {
                var termios = stream.tty.ops.ioctl_tcgets(stream);
                var argp = syscallGetVarargP();
                HEAP32[argp >>> 2 >>> 0] = termios.c_iflag || 0;
                HEAP32[argp + 4 >>> 2 >>> 0] = termios.c_oflag || 0;
                HEAP32[argp + 8 >>> 2 >>> 0] = termios.c_cflag || 0;
                HEAP32[argp + 12 >>> 2 >>> 0] = termios.c_lflag || 0;
                for (var i = 0; i < 32; i++) {
                  HEAP8[argp + i + 17 >>> 0] = termios.c_cc[i] || 0;
                }
                return 0;
              }
              return 0;
            }
          case 21510:
          case 21511:
          case 21512:
            {
              if (!stream.tty) return -59;
              return 0;
            }
          case 21506:
          case 21507:
          case 21508:
            {
              if (!stream.tty) return -59;
              if (stream.tty.ops.ioctl_tcsets) {
                var argp = syscallGetVarargP();
                var c_iflag = HEAP32[argp >>> 2 >>> 0];
                var c_oflag = HEAP32[argp + 4 >>> 2 >>> 0];
                var c_cflag = HEAP32[argp + 8 >>> 2 >>> 0];
                var c_lflag = HEAP32[argp + 12 >>> 2 >>> 0];
                var c_cc = [];
                for (var i = 0; i < 32; i++) {
                  c_cc.push(HEAP8[argp + i + 17 >>> 0]);
                }
                return stream.tty.ops.ioctl_tcsets(stream.tty, op, {
                  c_iflag: c_iflag,
                  c_oflag: c_oflag,
                  c_cflag: c_cflag,
                  c_lflag: c_lflag,
                  c_cc: c_cc
                });
              }
              return 0;
            }
          case 21519:
            {
              if (!stream.tty) return -59;
              var argp = syscallGetVarargP();
              HEAP32[argp >>> 2 >>> 0] = 0;
              return 0;
            }
          case 21520:
            {
              if (!stream.tty) return -59;
              return -28;
            }
          case 21531:
            {
              var argp = syscallGetVarargP();
              return FS.ioctl(stream, op, argp);
            }
          case 21523:
            {
              if (!stream.tty) return -59;
              if (stream.tty.ops.ioctl_tiocgwinsz) {
                var winsize = stream.tty.ops.ioctl_tiocgwinsz(stream.tty);
                var argp = syscallGetVarargP();
                HEAP16[argp >>> 1 >>> 0] = winsize[0];
                HEAP16[argp + 2 >>> 1 >>> 0] = winsize[1];
              }
              return 0;
            }
          case 21524:
            {
              if (!stream.tty) return -59;
              return 0;
            }
          case 21515:
            {
              if (!stream.tty) return -59;
              return 0;
            }
          default:
            return -28;
        }
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_ioctl.sig = "iiip";
    function ___syscall_listen(fd, backlog) {
      try {
        var sock = getSocketFromFD(fd);
        sock.sock_ops.listen(sock, backlog);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_listen.sig = "iiiiiii";
    function ___syscall_lstat64(path, buf) {
      path >>>= 0;
      buf >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        return SYSCALLS.doStat(FS.lstat, path, buf);
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_lstat64.sig = "ipp";
    function ___syscall_mkdirat(dirfd, path, mode) {
      path >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        path = SYSCALLS.calculateAt(dirfd, path);
        path = PATH.normalize(path);
        if (path[path.length - 1] === "/") path = path.substr(0, path.length - 1);
        FS.mkdir(path, mode, 0);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_mkdirat.sig = "iipi";
    function ___syscall_newfstatat(dirfd, path, buf, flags) {
      path >>>= 0;
      buf >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        var nofollow = flags & 256;
        var allowEmpty = flags & 4096;
        flags = flags & ~6400;
        path = SYSCALLS.calculateAt(dirfd, path, allowEmpty);
        return SYSCALLS.doStat(nofollow ? FS.lstat : FS.stat, path, buf);
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_newfstatat.sig = "iippi";
    function ___syscall_openat(dirfd, path, flags, varargs) {
      path >>>= 0;
      varargs >>>= 0;
      SYSCALLS.varargs = varargs;
      try {
        path = SYSCALLS.getStr(path);
        path = SYSCALLS.calculateAt(dirfd, path);
        var mode = varargs ? syscallGetVarargI() : 0;
        return FS.open(path, flags, mode).fd;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_openat.sig = "iipip";
    var PIPEFS = {
      BUCKET_BUFFER_SIZE: 8192,
      mount(mount) {
        return FS.createNode(null, "/", 16384 | 511, 0);
      },
      createPipe() {
        var pipe = {
          buckets: [],
          refcnt: 2
        };
        pipe.buckets.push({
          buffer: new Uint8Array(PIPEFS.BUCKET_BUFFER_SIZE),
          offset: 0,
          roffset: 0
        });
        var rName = PIPEFS.nextname();
        var wName = PIPEFS.nextname();
        var rNode = FS.createNode(PIPEFS.root, rName, 4096, 0);
        var wNode = FS.createNode(PIPEFS.root, wName, 4096, 0);
        rNode.pipe = pipe;
        wNode.pipe = pipe;
        var readableStream = FS.createStream({
          path: rName,
          node: rNode,
          flags: 0,
          seekable: false,
          stream_ops: PIPEFS.stream_ops
        });
        rNode.stream = readableStream;
        var writableStream = FS.createStream({
          path: wName,
          node: wNode,
          flags: 1,
          seekable: false,
          stream_ops: PIPEFS.stream_ops
        });
        wNode.stream = writableStream;
        return {
          readable_fd: readableStream.fd,
          writable_fd: writableStream.fd
        };
      },
      stream_ops: {
        poll(stream) {
          var pipe = stream.node.pipe;
          if ((stream.flags & 2097155) === 1) {
            return 256 | 4;
          }
          if (pipe.buckets.length > 0) {
            for (var i = 0; i < pipe.buckets.length; i++) {
              var bucket = pipe.buckets[i];
              if (bucket.offset - bucket.roffset > 0) {
                return 64 | 1;
              }
            }
          }
          return 0;
        },
        ioctl(stream, request, varargs) {
          return 28;
        },
        fsync(stream) {
          return 28;
        },
        read(stream, buffer, offset, length, position) {
          var pipe = stream.node.pipe;
          var currentLength = 0;
          for (var i = 0; i < pipe.buckets.length; i++) {
            var bucket = pipe.buckets[i];
            currentLength += bucket.offset - bucket.roffset;
          }
          var data = buffer.subarray(offset, offset + length);
          if (length <= 0) {
            return 0;
          }
          if (currentLength == 0) {
            throw new FS.ErrnoError(6);
          }
          var toRead = Math.min(currentLength, length);
          var totalRead = toRead;
          var toRemove = 0;
          for (var i = 0; i < pipe.buckets.length; i++) {
            var currBucket = pipe.buckets[i];
            var bucketSize = currBucket.offset - currBucket.roffset;
            if (toRead <= bucketSize) {
              var tmpSlice = currBucket.buffer.subarray(currBucket.roffset, currBucket.offset);
              if (toRead < bucketSize) {
                tmpSlice = tmpSlice.subarray(0, toRead);
                currBucket.roffset += toRead;
              } else {
                toRemove++;
              }
              data.set(tmpSlice);
              break;
            } else {
              var tmpSlice = currBucket.buffer.subarray(currBucket.roffset, currBucket.offset);
              data.set(tmpSlice);
              data = data.subarray(tmpSlice.byteLength);
              toRead -= tmpSlice.byteLength;
              toRemove++;
            }
          }
          if (toRemove && toRemove == pipe.buckets.length) {
            toRemove--;
            pipe.buckets[toRemove].offset = 0;
            pipe.buckets[toRemove].roffset = 0;
          }
          pipe.buckets.splice(0, toRemove);
          return totalRead;
        },
        write(stream, buffer, offset, length, position) {
          var pipe = stream.node.pipe;
          var data = buffer.subarray(offset, offset + length);
          var dataLen = data.byteLength;
          if (dataLen <= 0) {
            return 0;
          }
          var currBucket = null;
          if (pipe.buckets.length == 0) {
            currBucket = {
              buffer: new Uint8Array(PIPEFS.BUCKET_BUFFER_SIZE),
              offset: 0,
              roffset: 0
            };
            pipe.buckets.push(currBucket);
          } else {
            currBucket = pipe.buckets[pipe.buckets.length - 1];
          }
          assert(currBucket.offset <= PIPEFS.BUCKET_BUFFER_SIZE);
          var freeBytesInCurrBuffer = PIPEFS.BUCKET_BUFFER_SIZE - currBucket.offset;
          if (freeBytesInCurrBuffer >= dataLen) {
            currBucket.buffer.set(data, currBucket.offset);
            currBucket.offset += dataLen;
            return dataLen;
          } else if (freeBytesInCurrBuffer > 0) {
            currBucket.buffer.set(data.subarray(0, freeBytesInCurrBuffer), currBucket.offset);
            currBucket.offset += freeBytesInCurrBuffer;
            data = data.subarray(freeBytesInCurrBuffer, data.byteLength);
          }
          var numBuckets = data.byteLength / PIPEFS.BUCKET_BUFFER_SIZE | 0;
          var remElements = data.byteLength % PIPEFS.BUCKET_BUFFER_SIZE;
          for (var i = 0; i < numBuckets; i++) {
            var newBucket = {
              buffer: new Uint8Array(PIPEFS.BUCKET_BUFFER_SIZE),
              offset: PIPEFS.BUCKET_BUFFER_SIZE,
              roffset: 0
            };
            pipe.buckets.push(newBucket);
            newBucket.buffer.set(data.subarray(0, PIPEFS.BUCKET_BUFFER_SIZE));
            data = data.subarray(PIPEFS.BUCKET_BUFFER_SIZE, data.byteLength);
          }
          if (remElements > 0) {
            var newBucket = {
              buffer: new Uint8Array(PIPEFS.BUCKET_BUFFER_SIZE),
              offset: data.byteLength,
              roffset: 0
            };
            pipe.buckets.push(newBucket);
            newBucket.buffer.set(data);
          }
          return dataLen;
        },
        close(stream) {
          var pipe = stream.node.pipe;
          pipe.refcnt--;
          if (pipe.refcnt === 0) {
            pipe.buckets = null;
          }
        }
      },
      nextname() {
        if (!PIPEFS.nextname.current) {
          PIPEFS.nextname.current = 0;
        }
        return "pipe[" + PIPEFS.nextname.current++ + "]";
      }
    };
    function ___syscall_pipe(fdPtr) {
      fdPtr >>>= 0;
      try {
        if (fdPtr == 0) {
          throw new FS.ErrnoError(21);
        }
        var res = PIPEFS.createPipe();
        HEAP32[fdPtr >>> 2 >>> 0] = res.readable_fd;
        HEAP32[fdPtr + 4 >>> 2 >>> 0] = res.writable_fd;
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_pipe.sig = "ip";
    function ___syscall_poll(fds, nfds, timeout) {
      fds >>>= 0;
      try {
        var nonzero = 0;
        for (var i = 0; i < nfds; i++) {
          var pollfd = fds + 8 * i;
          var fd = HEAP32[pollfd >>> 2 >>> 0];
          var events = HEAP16[pollfd + 4 >>> 1 >>> 0];
          var mask = 32;
          var stream = FS.getStream(fd);
          if (stream) {
            mask = SYSCALLS.DEFAULT_POLLMASK;
            if (stream.stream_ops.poll) {
              mask = stream.stream_ops.poll(stream, -1);
            }
          }
          mask &= events | 8 | 16;
          if (mask) nonzero++;
          HEAP16[pollfd + 6 >>> 1 >>> 0] = mask;
        }
        return nonzero;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_poll.sig = "ipii";
    function ___syscall_readlinkat(dirfd, path, buf, bufsize) {
      path >>>= 0;
      buf >>>= 0;
      bufsize >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        path = SYSCALLS.calculateAt(dirfd, path);
        if (bufsize <= 0) return -28;
        var ret = FS.readlink(path);
        var len = Math.min(bufsize, lengthBytesUTF8(ret));
        var endChar = HEAP8[buf + len >>> 0];
        stringToUTF8(ret, buf, bufsize + 1);
        HEAP8[buf + len >>> 0] = endChar;
        return len;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_readlinkat.sig = "iippp";
    function ___syscall_recvfrom(fd, buf, len, flags, addr, addrlen) {
      buf >>>= 0;
      len >>>= 0;
      addr >>>= 0;
      addrlen >>>= 0;
      try {
        var sock = getSocketFromFD(fd);
        var msg = sock.sock_ops.recvmsg(sock, len);
        if (!msg) return 0;
        if (addr) {
          var errno = writeSockaddr(addr, sock.family, DNS.lookup_name(msg.addr), msg.port, addrlen);
        }
        HEAPU8.set(msg.buffer, buf >>> 0);
        return msg.buffer.byteLength;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_recvfrom.sig = "iippipp";
    function ___syscall_renameat(olddirfd, oldpath, newdirfd, newpath) {
      oldpath >>>= 0;
      newpath >>>= 0;
      try {
        oldpath = SYSCALLS.getStr(oldpath);
        newpath = SYSCALLS.getStr(newpath);
        oldpath = SYSCALLS.calculateAt(olddirfd, oldpath);
        newpath = SYSCALLS.calculateAt(newdirfd, newpath);
        FS.rename(oldpath, newpath);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_renameat.sig = "iipip";
    function ___syscall_rmdir(path) {
      path >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        FS.rmdir(path);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_rmdir.sig = "ip";
    function ___syscall_sendto(fd, message, length, flags, addr, addr_len) {
      message >>>= 0;
      length >>>= 0;
      addr >>>= 0;
      addr_len >>>= 0;
      try {
        var sock = getSocketFromFD(fd);
        var dest = getSocketAddress(addr, addr_len, true);
        if (!dest) {
          return FS.write(sock.stream, HEAP8, message, length);
        }
        return sock.sock_ops.sendmsg(sock, HEAP8, message, length, dest.addr, dest.port);
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_sendto.sig = "iippipp";
    function ___syscall_socket(domain, type, protocol) {
      try {
        var sock = SOCKFS.createSocket(domain, type, protocol);
        return sock.stream.fd;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_socket.sig = "iiiiiii";
    function ___syscall_stat64(path, buf) {
      path >>>= 0;
      buf >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        return SYSCALLS.doStat(FS.stat, path, buf);
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_stat64.sig = "ipp";
    function ___syscall_statfs64(path, size, buf) {
      path >>>= 0;
      size >>>= 0;
      buf >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        HEAP32[buf + 4 >>> 2 >>> 0] = 4096;
        HEAP32[buf + 40 >>> 2 >>> 0] = 4096;
        HEAP32[buf + 8 >>> 2 >>> 0] = 1e6;
        HEAP32[buf + 12 >>> 2 >>> 0] = 5e5;
        HEAP32[buf + 16 >>> 2 >>> 0] = 5e5;
        HEAP32[buf + 20 >>> 2 >>> 0] = FS.nextInode;
        HEAP32[buf + 24 >>> 2 >>> 0] = 1e6;
        HEAP32[buf + 28 >>> 2 >>> 0] = 42;
        HEAP32[buf + 44 >>> 2 >>> 0] = 2;
        HEAP32[buf + 36 >>> 2 >>> 0] = 255;
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_statfs64.sig = "ippp";
    function ___syscall_symlink(target, linkpath) {
      target >>>= 0;
      linkpath >>>= 0;
      try {
        target = SYSCALLS.getStr(target);
        linkpath = SYSCALLS.getStr(linkpath);
        FS.symlink(target, linkpath);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_symlink.sig = "ipp";
    function ___syscall_unlinkat(dirfd, path, flags) {
      path >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        path = SYSCALLS.calculateAt(dirfd, path);
        if (flags === 0) {
          FS.unlink(path);
        } else if (flags === 512) {
          FS.rmdir(path);
        } else {
          abort("Invalid flags passed to unlinkat");
        }
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_unlinkat.sig = "iipi";
    var readI53FromI64 = ptr => HEAPU32[ptr >>> 2 >>> 0] + HEAP32[ptr + 4 >>> 2 >>> 0] * 4294967296;
    function ___syscall_utimensat(dirfd, path, times, flags) {
      path >>>= 0;
      times >>>= 0;
      try {
        path = SYSCALLS.getStr(path);
        path = SYSCALLS.calculateAt(dirfd, path, true);
        if (!times) {
          var atime = Date.now();
          var mtime = atime;
        } else {
          var seconds = readI53FromI64(times);
          var nanoseconds = HEAP32[times + 8 >>> 2 >>> 0];
          atime = seconds * 1e3 + nanoseconds / (1e3 * 1e3);
          times += 16;
          seconds = readI53FromI64(times);
          nanoseconds = HEAP32[times + 8 >>> 2 >>> 0];
          mtime = seconds * 1e3 + nanoseconds / (1e3 * 1e3);
        }
        FS.utime(path, atime, mtime);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    ___syscall_utimensat.sig = "iippi";
    var ___table_base = new WebAssembly.Global({
      value: "i32",
      mutable: false
    }, 1);
    var __abort_js = () => {
      abort("");
    };
    __abort_js.sig = "v";
    var ENV = {};
    var stackAlloc = sz => __emscripten_stack_alloc(sz);
    var stringToUTF8OnStack = str => {
      var size = lengthBytesUTF8(str) + 1;
      var ret = stackAlloc(size);
      stringToUTF8(str, ret, size);
      return ret;
    };
    var dlSetError = msg => {
      var sp = stackSave();
      var cmsg = stringToUTF8OnStack(msg);
      ___dl_seterr(cmsg, 0);
      stackRestore(sp);
    };
    var dlopenInternal = (handle, jsflags) => {
      var filename = UTF8ToString(handle + 36);
      var flags = HEAP32[handle + 4 >>> 2 >>> 0];
      filename = PATH.normalize(filename);
      var global = Boolean(flags & 256);
      var localScope = global ? null : {};
      var combinedFlags = {
        global: global,
        nodelete: Boolean(flags & 4096),
        loadAsync: jsflags.loadAsync
      };
      if (jsflags.loadAsync) {
        return loadDynamicLibrary(filename, combinedFlags, localScope, handle);
      }
      try {
        return loadDynamicLibrary(filename, combinedFlags, localScope, handle);
      } catch (e) {
        dlSetError(`Could not load dynamic lib: ${filename}\n${e}`);
        return 0;
      }
    };
    var __dlopen_js = function (handle) {
      handle >>>= 0;
      return Asyncify.handleSleep(wakeUp => {
        dlopenInternal(handle, {
          loadAsync: true
        }).then(wakeUp).catch(() => wakeUp(0));
      });
    };
    __dlopen_js.sig = "pp";
    __dlopen_js.isAsync = true;
    function __dlsym_js(handle, symbol, symbolIndex) {
      handle >>>= 0;
      symbol >>>= 0;
      symbolIndex >>>= 0;
      symbol = UTF8ToString(symbol);
      var result;
      var newSymIndex;
      var lib = LDSO.loadedLibsByHandle[handle];
      if (!lib.exports.hasOwnProperty(symbol) || lib.exports[symbol].stub) {
        dlSetError(`Tried to lookup unknown symbol "${symbol}" in dynamic lib: ${lib.name}`);
        return 0;
      }
      newSymIndex = Object.keys(lib.exports).indexOf(symbol);
      var origSym = "orig$" + symbol;
      result = lib.exports[origSym];
      if (result) {
        newSymIndex = Object.keys(lib.exports).indexOf(origSym);
      } else result = lib.exports[symbol];
      if (typeof result == "function") {
        if ("orig" in result) {
          result = result.orig;
        }
        var addr = getFunctionAddress(result);
        if (addr) {
          result = addr;
        } else {
          result = addFunction(result, result.sig);
          HEAPU32[symbolIndex >>> 2 >>> 0] = newSymIndex;
        }
      }
      return result;
    }
    __dlsym_js.sig = "pppp";
    var nowIsMonotonic = 1;
    var __emscripten_get_now_is_monotonic = () => nowIsMonotonic;
    __emscripten_get_now_is_monotonic.sig = "i";
    function __emscripten_lookup_name(name) {
      name >>>= 0;
      var nameString = UTF8ToString(name);
      return inetPton4(DNS.lookup_name(nameString));
    }
    __emscripten_lookup_name.sig = "ip";
    function __emscripten_memcpy_js(dest, src, num) {
      dest >>>= 0;
      src >>>= 0;
      num >>>= 0;
      return HEAPU8.copyWithin(dest >>> 0, src >>> 0, src + num >>> 0);
    }
    __emscripten_memcpy_js.sig = "vppp";
    var __emscripten_runtime_keepalive_clear = () => {
      noExitRuntime = false;
      runtimeKeepaliveCounter = 0;
    };
    __emscripten_runtime_keepalive_clear.sig = "v";
    var __emscripten_throw_longjmp = () => {
      throw Infinity;
    };
    __emscripten_throw_longjmp.sig = "v";
    function __gmtime_js(time_low, time_high, tmPtr) {
      var time = convertI32PairToI53Checked(time_low, time_high);
      tmPtr >>>= 0;
      var date = new Date(time * 1e3);
      HEAP32[tmPtr >>> 2 >>> 0] = date.getUTCSeconds();
      HEAP32[tmPtr + 4 >>> 2 >>> 0] = date.getUTCMinutes();
      HEAP32[tmPtr + 8 >>> 2 >>> 0] = date.getUTCHours();
      HEAP32[tmPtr + 12 >>> 2 >>> 0] = date.getUTCDate();
      HEAP32[tmPtr + 16 >>> 2 >>> 0] = date.getUTCMonth();
      HEAP32[tmPtr + 20 >>> 2 >>> 0] = date.getUTCFullYear() - 1900;
      HEAP32[tmPtr + 24 >>> 2 >>> 0] = date.getUTCDay();
      var start = Date.UTC(date.getUTCFullYear(), 0, 1, 0, 0, 0, 0);
      var yday = (date.getTime() - start) / (1e3 * 60 * 60 * 24) | 0;
      HEAP32[tmPtr + 28 >>> 2 >>> 0] = yday;
    }
    __gmtime_js.sig = "viip";
    var isLeapYear = year => year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0);
    var MONTH_DAYS_LEAP_CUMULATIVE = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
    var MONTH_DAYS_REGULAR_CUMULATIVE = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    var ydayFromDate = date => {
      var leap = isLeapYear(date.getFullYear());
      var monthDaysCumulative = leap ? MONTH_DAYS_LEAP_CUMULATIVE : MONTH_DAYS_REGULAR_CUMULATIVE;
      var yday = monthDaysCumulative[date.getMonth()] + date.getDate() - 1;
      return yday;
    };
    function __localtime_js(time_low, time_high, tmPtr) {
      var time = convertI32PairToI53Checked(time_low, time_high);
      tmPtr >>>= 0;
      var date = new Date(time * 1e3);
      HEAP32[tmPtr >>> 2 >>> 0] = date.getSeconds();
      HEAP32[tmPtr + 4 >>> 2 >>> 0] = date.getMinutes();
      HEAP32[tmPtr + 8 >>> 2 >>> 0] = date.getHours();
      HEAP32[tmPtr + 12 >>> 2 >>> 0] = date.getDate();
      HEAP32[tmPtr + 16 >>> 2 >>> 0] = date.getMonth();
      HEAP32[tmPtr + 20 >>> 2 >>> 0] = date.getFullYear() - 1900;
      HEAP32[tmPtr + 24 >>> 2 >>> 0] = date.getDay();
      var yday = ydayFromDate(date) | 0;
      HEAP32[tmPtr + 28 >>> 2 >>> 0] = yday;
      HEAP32[tmPtr + 36 >>> 2 >>> 0] = -(date.getTimezoneOffset() * 60);
      var start = new Date(date.getFullYear(), 0, 1);
      var summerOffset = new Date(date.getFullYear(), 6, 1).getTimezoneOffset();
      var winterOffset = start.getTimezoneOffset();
      var dst = (summerOffset != winterOffset && date.getTimezoneOffset() == Math.min(winterOffset, summerOffset)) | 0;
      HEAP32[tmPtr + 32 >>> 2 >>> 0] = dst;
    }
    __localtime_js.sig = "viip";
    var setTempRet0 = val => __emscripten_tempret_set(val);
    var __mktime_js = function (tmPtr) {
      tmPtr >>>= 0;
      var ret = (() => {
        var date = new Date(HEAP32[tmPtr + 20 >>> 2 >>> 0] + 1900, HEAP32[tmPtr + 16 >>> 2 >>> 0], HEAP32[tmPtr + 12 >>> 2 >>> 0], HEAP32[tmPtr + 8 >>> 2 >>> 0], HEAP32[tmPtr + 4 >>> 2 >>> 0], HEAP32[tmPtr >>> 2 >>> 0], 0);
        var dst = HEAP32[tmPtr + 32 >>> 2 >>> 0];
        var guessedOffset = date.getTimezoneOffset();
        var start = new Date(date.getFullYear(), 0, 1);
        var summerOffset = new Date(date.getFullYear(), 6, 1).getTimezoneOffset();
        var winterOffset = start.getTimezoneOffset();
        var dstOffset = Math.min(winterOffset, summerOffset);
        if (dst < 0) {
          HEAP32[tmPtr + 32 >>> 2 >>> 0] = Number(summerOffset != winterOffset && dstOffset == guessedOffset);
        } else if (dst > 0 != (dstOffset == guessedOffset)) {
          var nonDstOffset = Math.max(winterOffset, summerOffset);
          var trueOffset = dst > 0 ? dstOffset : nonDstOffset;
          date.setTime(date.getTime() + (trueOffset - guessedOffset) * 6e4);
        }
        HEAP32[tmPtr + 24 >>> 2 >>> 0] = date.getDay();
        var yday = ydayFromDate(date) | 0;
        HEAP32[tmPtr + 28 >>> 2 >>> 0] = yday;
        HEAP32[tmPtr >>> 2 >>> 0] = date.getSeconds();
        HEAP32[tmPtr + 4 >>> 2 >>> 0] = date.getMinutes();
        HEAP32[tmPtr + 8 >>> 2 >>> 0] = date.getHours();
        HEAP32[tmPtr + 12 >>> 2 >>> 0] = date.getDate();
        HEAP32[tmPtr + 16 >>> 2 >>> 0] = date.getMonth();
        HEAP32[tmPtr + 20 >>> 2 >>> 0] = date.getYear();
        var timeMs = date.getTime();
        if (isNaN(timeMs)) {
          return -1;
        }
        return timeMs / 1e3;
      })();
      return setTempRet0((tempDouble = ret, +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)), ret >>> 0;
    };
    __mktime_js.sig = "ip";
    function __mmap_js(len, prot, flags, fd, offset_low, offset_high, allocated, addr) {
      len >>>= 0;
      var offset = convertI32PairToI53Checked(offset_low, offset_high);
      allocated >>>= 0;
      addr >>>= 0;
      try {
        if (isNaN(offset)) return 61;
        var stream = SYSCALLS.getStreamFromFD(fd);
        var res = FS.mmap(stream, len, offset, prot, flags);
        var ptr = res.ptr;
        HEAP32[allocated >>> 2 >>> 0] = res.allocated;
        HEAPU32[addr >>> 2 >>> 0] = ptr;
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    __mmap_js.sig = "ipiiiiipp";
    function __munmap_js(addr, len, prot, flags, fd, offset_low, offset_high) {
      addr >>>= 0;
      len >>>= 0;
      var offset = convertI32PairToI53Checked(offset_low, offset_high);
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        if (prot & 2) {
          SYSCALLS.doMsync(addr, stream, len, flags, offset);
        }
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return -e.errno;
      }
    }
    __munmap_js.sig = "ippiiiii";
    var timers = {};
    var handleException = e => {
      if (e instanceof ExitStatus || e == "unwind") {
        return EXITSTATUS;
      }
      quit_(1, e);
    };
    var runtimeKeepaliveCounter = 0;
    var keepRuntimeAlive = () => noExitRuntime || runtimeKeepaliveCounter > 0;
    var _proc_exit = code => {
      EXITSTATUS = code;
      if (!keepRuntimeAlive()) {
        Module["onExit"]?.(code);
        ABORT = true;
      }
      quit_(code, new ExitStatus(code));
    };
    _proc_exit.sig = "vi";
    var exitJS = (status, implicit) => {
      EXITSTATUS = status;
      if (!keepRuntimeAlive()) {
        exitRuntime();
      }
      _proc_exit(status);
    };
    var _exit = exitJS;
    _exit.sig = "vi";
    var maybeExit = () => {
      if (runtimeExited) {
        return;
      }
      if (!keepRuntimeAlive()) {
        try {
          _exit(EXITSTATUS);
        } catch (e) {
          handleException(e);
        }
      }
    };
    var callUserCallback = func => {
      if (runtimeExited || ABORT) {
        return;
      }
      try {
        func();
        maybeExit();
      } catch (e) {
        handleException(e);
      }
    };
    var _emscripten_get_now;
    _emscripten_get_now = () => performance.now();
    _emscripten_get_now.sig = "d";
    var __setitimer_js = (which, timeout_ms) => {
      if (timers[which]) {
        clearTimeout(timers[which].id);
        delete timers[which];
      }
      if (!timeout_ms) return 0;
      var id = setTimeout(() => {
        delete timers[which];
        callUserCallback(() => __emscripten_timeout(which, _emscripten_get_now()));
      }, timeout_ms);
      timers[which] = {
        id: id,
        timeout_ms: timeout_ms
      };
      return 0;
    };
    __setitimer_js.sig = "iid";
    var __tzset_js = function (timezone, daylight, std_name, dst_name) {
      timezone >>>= 0;
      daylight >>>= 0;
      std_name >>>= 0;
      dst_name >>>= 0;
      var currentYear = new Date().getFullYear();
      var winter = new Date(currentYear, 0, 1);
      var summer = new Date(currentYear, 6, 1);
      var winterOffset = winter.getTimezoneOffset();
      var summerOffset = summer.getTimezoneOffset();
      var stdTimezoneOffset = Math.max(winterOffset, summerOffset);
      HEAPU32[timezone >>> 2 >>> 0] = stdTimezoneOffset * 60;
      HEAP32[daylight >>> 2 >>> 0] = Number(winterOffset != summerOffset);
      var extractZone = date => date.toLocaleTimeString(undefined, {
        hour12: false,
        timeZoneName: "short"
      }).split(" ")[1];
      var winterName = extractZone(winter);
      var summerName = extractZone(summer);
      if (summerOffset < winterOffset) {
        stringToUTF8(winterName, std_name, 17);
        stringToUTF8(summerName, dst_name, 17);
      } else {
        stringToUTF8(winterName, dst_name, 17);
        stringToUTF8(summerName, std_name, 17);
      }
    };
    __tzset_js.sig = "vpppp";
    var readEmAsmArgsArray = [];
    var readEmAsmArgs = (sigPtr, buf) => {
      readEmAsmArgsArray.length = 0;
      var ch;
      while (ch = HEAPU8[sigPtr++ >>> 0]) {
        var wide = ch != 105;
        wide &= ch != 112;
        buf += wide && buf % 8 ? 4 : 0;
        readEmAsmArgsArray.push(ch == 112 ? HEAPU32[buf >>> 2 >>> 0] : ch == 105 ? HEAP32[buf >>> 2 >>> 0] : HEAPF64[buf >>> 3 >>> 0]);
        buf += wide ? 8 : 4;
      }
      return readEmAsmArgsArray;
    };
    var runEmAsmFunction = (code, sigPtr, argbuf) => {
      var args = readEmAsmArgs(sigPtr, argbuf);
      return ASM_CONSTS[code](...args);
    };
    function _emscripten_asm_const_int(code, sigPtr, argbuf) {
      code >>>= 0;
      sigPtr >>>= 0;
      argbuf >>>= 0;
      return runEmAsmFunction(code, sigPtr, argbuf);
    }
    _emscripten_asm_const_int.sig = "ippp";
    function _emscripten_asm_const_ptr(code, sigPtr, argbuf) {
      code >>>= 0;
      sigPtr >>>= 0;
      argbuf >>>= 0;
      return runEmAsmFunction(code, sigPtr, argbuf);
    }
    _emscripten_asm_const_ptr.sig = "pppp";
    var _emscripten_date_now = () => Date.now();
    _emscripten_date_now.sig = "d";
    var getHeapMax = () => 4294901760;
    function _emscripten_get_heap_max() {
      return getHeapMax();
    }
    _emscripten_get_heap_max.sig = "p";
    var growMemory = size => {
      var b = wasmMemory.buffer;
      var pages = (size - b.byteLength + 65535) / 65536;
      try {
        wasmMemory.grow(pages);
        updateMemoryViews();
        return 1;
      } catch (e) {}
    };
    function _emscripten_resize_heap(requestedSize) {
      requestedSize >>>= 0;
      var oldSize = HEAPU8.length;
      var maxHeapSize = getHeapMax();
      if (requestedSize > maxHeapSize) {
        return false;
      }
      var alignUp = (x, multiple) => x + (multiple - x % multiple) % multiple;
      for (var cutDown = 1; cutDown <= 4; cutDown *= 2) {
        var overGrownHeapSize = oldSize * (1 + .2 / cutDown);
        overGrownHeapSize = Math.min(overGrownHeapSize, requestedSize + 100663296);
        var newSize = Math.min(maxHeapSize, alignUp(Math.max(requestedSize, overGrownHeapSize), 65536));
        var replacement = growMemory(newSize);
        if (replacement) {
          return true;
        }
      }
      return false;
    }
    _emscripten_resize_heap.sig = "ip";
    var getExecutableName = () => thisProgram || "./this.program";
    var getEnvStrings = () => {
      if (!getEnvStrings.strings) {
        var lang = (typeof navigator == "object" && navigator.languages && navigator.languages[0] || "C").replace("-", "_") + ".UTF-8";
        var env = {
          USER: "web_user",
          LOGNAME: "web_user",
          PATH: "/",
          PWD: "/",
          HOME: "/home/web_user",
          LANG: lang,
          _: getExecutableName()
        };
        for (var x in ENV) {
          if (ENV[x] === undefined) delete env[x];else env[x] = ENV[x];
        }
        var strings = [];
        for (var x in env) {
          strings.push(`${x}=${env[x]}`);
        }
        getEnvStrings.strings = strings;
      }
      return getEnvStrings.strings;
    };
    var stringToAscii = (str, buffer) => {
      for (var i = 0; i < str.length; ++i) {
        HEAP8[buffer++ >>> 0] = str.charCodeAt(i);
      }
      HEAP8[buffer >>> 0] = 0;
    };
    var _environ_get = function (__environ, environ_buf) {
      __environ >>>= 0;
      environ_buf >>>= 0;
      var bufSize = 0;
      getEnvStrings().forEach((string, i) => {
        var ptr = environ_buf + bufSize;
        HEAPU32[__environ + i * 4 >>> 2 >>> 0] = ptr;
        stringToAscii(string, ptr);
        bufSize += string.length + 1;
      });
      return 0;
    };
    _environ_get.sig = "ipp";
    var _environ_sizes_get = function (penviron_count, penviron_buf_size) {
      penviron_count >>>= 0;
      penviron_buf_size >>>= 0;
      var strings = getEnvStrings();
      HEAPU32[penviron_count >>> 2 >>> 0] = strings.length;
      var bufSize = 0;
      strings.forEach(string => bufSize += string.length + 1);
      HEAPU32[penviron_buf_size >>> 2 >>> 0] = bufSize;
      return 0;
    };
    _environ_sizes_get.sig = "ipp";
    function _fd_close(fd) {
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        FS.close(stream);
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return e.errno;
      }
    }
    _fd_close.sig = "ii";
    function _fd_fdstat_get(fd, pbuf) {
      pbuf >>>= 0;
      try {
        var rightsBase = 0;
        var rightsInheriting = 0;
        var flags = 0;
        {
          var stream = SYSCALLS.getStreamFromFD(fd);
          var type = stream.tty ? 2 : FS.isDir(stream.mode) ? 3 : FS.isLink(stream.mode) ? 7 : 4;
        }
        HEAP8[pbuf >>> 0] = type;
        HEAP16[pbuf + 2 >>> 1 >>> 0] = flags;
        tempI64 = [rightsBase >>> 0, (tempDouble = rightsBase, +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[pbuf + 8 >>> 2 >>> 0] = tempI64[0], HEAP32[pbuf + 12 >>> 2 >>> 0] = tempI64[1];
        tempI64 = [rightsInheriting >>> 0, (tempDouble = rightsInheriting, +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[pbuf + 16 >>> 2 >>> 0] = tempI64[0], HEAP32[pbuf + 20 >>> 2 >>> 0] = tempI64[1];
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return e.errno;
      }
    }
    _fd_fdstat_get.sig = "iip";
    var doReadv = (stream, iov, iovcnt, offset) => {
      var ret = 0;
      for (var i = 0; i < iovcnt; i++) {
        var ptr = HEAPU32[iov >>> 2 >>> 0];
        var len = HEAPU32[iov + 4 >>> 2 >>> 0];
        iov += 8;
        var curr = FS.read(stream, HEAP8, ptr, len, offset);
        if (curr < 0) return -1;
        ret += curr;
        if (curr < len) break;
        if (typeof offset != "undefined") {
          offset += curr;
        }
      }
      return ret;
    };
    function _fd_read(fd, iov, iovcnt, pnum) {
      iov >>>= 0;
      iovcnt >>>= 0;
      pnum >>>= 0;
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        var num = doReadv(stream, iov, iovcnt);
        HEAPU32[pnum >>> 2 >>> 0] = num;
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return e.errno;
      }
    }
    _fd_read.sig = "iippp";
    function _fd_seek(fd, offset_low, offset_high, whence, newOffset) {
      var offset = convertI32PairToI53Checked(offset_low, offset_high);
      newOffset >>>= 0;
      try {
        if (isNaN(offset)) return 61;
        var stream = SYSCALLS.getStreamFromFD(fd);
        FS.llseek(stream, offset, whence);
        tempI64 = [stream.position >>> 0, (tempDouble = stream.position, +Math.abs(tempDouble) >= 1 ? tempDouble > 0 ? +Math.floor(tempDouble / 4294967296) >>> 0 : ~~+Math.ceil((tempDouble - +(~~tempDouble >>> 0)) / 4294967296) >>> 0 : 0)], HEAP32[newOffset >>> 2 >>> 0] = tempI64[0], HEAP32[newOffset + 4 >>> 2 >>> 0] = tempI64[1];
        if (stream.getdents && offset === 0 && whence === 0) stream.getdents = null;
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return e.errno;
      }
    }
    _fd_seek.sig = "iiiiip";
    var _fd_sync = function (fd) {
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        return Asyncify.handleSleep(wakeUp => {
          var mount = stream.node.mount;
          if (!mount.type.syncfs) {
            wakeUp(0);
            return;
          }
          mount.type.syncfs(mount, false, err => {
            if (err) {
              wakeUp(29);
              return;
            }
            wakeUp(0);
          });
        });
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return e.errno;
      }
    };
    _fd_sync.sig = "ii";
    _fd_sync.isAsync = true;
    var doWritev = (stream, iov, iovcnt, offset) => {
      var ret = 0;
      for (var i = 0; i < iovcnt; i++) {
        var ptr = HEAPU32[iov >>> 2 >>> 0];
        var len = HEAPU32[iov + 4 >>> 2 >>> 0];
        iov += 8;
        var curr = FS.write(stream, HEAP8, ptr, len, offset);
        if (curr < 0) return -1;
        ret += curr;
        if (typeof offset != "undefined") {
          offset += curr;
        }
      }
      return ret;
    };
    function _fd_write(fd, iov, iovcnt, pnum) {
      iov >>>= 0;
      iovcnt >>>= 0;
      pnum >>>= 0;
      try {
        var stream = SYSCALLS.getStreamFromFD(fd);
        var num = doWritev(stream, iov, iovcnt);
        HEAPU32[pnum >>> 2 >>> 0] = num;
        return 0;
      } catch (e) {
        if (typeof FS == "undefined" || !(e.name === "ErrnoError")) throw e;
        return e.errno;
      }
    }
    _fd_write.sig = "iippp";
    function _getaddrinfo(node, service, hint, out) {
      node >>>= 0;
      service >>>= 0;
      hint >>>= 0;
      out >>>= 0;
      var addr = 0;
      var port = 0;
      var flags = 0;
      var family = 0;
      var type = 0;
      var proto = 0;
      var ai;
      function allocaddrinfo(family, type, proto, canon, addr, port) {
        var sa, salen, ai;
        var errno;
        salen = family === 10 ? 28 : 16;
        addr = family === 10 ? inetNtop6(addr) : inetNtop4(addr);
        sa = _malloc(salen);
        errno = writeSockaddr(sa, family, addr, port);
        assert(!errno);
        ai = _malloc(32);
        HEAP32[ai + 4 >>> 2 >>> 0] = family;
        HEAP32[ai + 8 >>> 2 >>> 0] = type;
        HEAP32[ai + 12 >>> 2 >>> 0] = proto;
        HEAPU32[ai + 24 >>> 2 >>> 0] = canon;
        HEAPU32[ai + 20 >>> 2 >>> 0] = sa;
        if (family === 10) {
          HEAP32[ai + 16 >>> 2 >>> 0] = 28;
        } else {
          HEAP32[ai + 16 >>> 2 >>> 0] = 16;
        }
        HEAP32[ai + 28 >>> 2 >>> 0] = 0;
        return ai;
      }
      if (hint) {
        flags = HEAP32[hint >>> 2 >>> 0];
        family = HEAP32[hint + 4 >>> 2 >>> 0];
        type = HEAP32[hint + 8 >>> 2 >>> 0];
        proto = HEAP32[hint + 12 >>> 2 >>> 0];
      }
      if (type && !proto) {
        proto = type === 2 ? 17 : 6;
      }
      if (!type && proto) {
        type = proto === 17 ? 2 : 1;
      }
      if (proto === 0) {
        proto = 6;
      }
      if (type === 0) {
        type = 1;
      }
      if (!node && !service) {
        return -2;
      }
      if (flags & ~(1 | 2 | 4 | 1024 | 8 | 16 | 32)) {
        return -1;
      }
      if (hint !== 0 && HEAP32[hint >>> 2 >>> 0] & 2 && !node) {
        return -1;
      }
      if (flags & 32) {
        return -2;
      }
      if (type !== 0 && type !== 1 && type !== 2) {
        return -7;
      }
      if (family !== 0 && family !== 2 && family !== 10) {
        return -6;
      }
      if (service) {
        service = UTF8ToString(service);
        port = parseInt(service, 10);
        if (isNaN(port)) {
          if (flags & 1024) {
            return -2;
          }
          return -8;
        }
      }
      if (!node) {
        if (family === 0) {
          family = 2;
        }
        if ((flags & 1) === 0) {
          if (family === 2) {
            addr = _htonl(2130706433);
          } else {
            addr = [0, 0, 0, 1];
          }
        }
        ai = allocaddrinfo(family, type, proto, null, addr, port);
        HEAPU32[out >>> 2 >>> 0] = ai;
        return 0;
      }
      node = UTF8ToString(node);
      addr = inetPton4(node);
      if (addr !== null) {
        if (family === 0 || family === 2) {
          family = 2;
        } else if (family === 10 && flags & 8) {
          addr = [0, 0, _htonl(65535), addr];
          family = 10;
        } else {
          return -2;
        }
      } else {
        addr = inetPton6(node);
        if (addr !== null) {
          if (family === 0 || family === 10) {
            family = 10;
          } else {
            return -2;
          }
        }
      }
      if (addr != null) {
        ai = allocaddrinfo(family, type, proto, node, addr, port);
        HEAPU32[out >>> 2 >>> 0] = ai;
        return 0;
      }
      if (flags & 4) {
        return -2;
      }
      node = DNS.lookup_name(node);
      addr = inetPton4(node);
      if (family === 0) {
        family = 2;
      } else if (family === 10) {
        addr = [0, 0, _htonl(65535), addr];
      }
      ai = allocaddrinfo(family, type, proto, null, addr, port);
      HEAPU32[out >>> 2 >>> 0] = ai;
      return 0;
    }
    _getaddrinfo.sig = "ipppp";
    function _getcontext(...args) {
      return asyncifyStubs["getcontext"](...args);
    }
    _getcontext.stub = true;
    asyncifyStubs["getcontext"] = undefined;
    function _getdtablesize(...args) {
      return asyncifyStubs["getdtablesize"](...args);
    }
    _getdtablesize.stub = true;
    asyncifyStubs["getdtablesize"] = undefined;
    function _getnameinfo(sa, salen, node, nodelen, serv, servlen, flags) {
      sa >>>= 0;
      node >>>= 0;
      serv >>>= 0;
      var info = readSockaddr(sa, salen);
      if (info.errno) {
        return -6;
      }
      var port = info.port;
      var addr = info.addr;
      var overflowed = false;
      if (node && nodelen) {
        var lookup;
        if (flags & 1 || !(lookup = DNS.lookup_addr(addr))) {
          if (flags & 8) {
            return -2;
          }
        } else {
          addr = lookup;
        }
        var numBytesWrittenExclNull = stringToUTF8(addr, node, nodelen);
        if (numBytesWrittenExclNull + 1 >= nodelen) {
          overflowed = true;
        }
      }
      if (serv && servlen) {
        port = "" + port;
        var numBytesWrittenExclNull = stringToUTF8(port, serv, servlen);
        if (numBytesWrittenExclNull + 1 >= servlen) {
          overflowed = true;
        }
      }
      if (overflowed) {
        return -12;
      }
      return 0;
    }
    _getnameinfo.sig = "ipipipii";
    var Protocols = {
      list: [],
      map: {}
    };
    var _setprotoent = stayopen => {
      function allocprotoent(name, proto, aliases) {
        var nameBuf = _malloc(name.length + 1);
        stringToAscii(name, nameBuf);
        var j = 0;
        var length = aliases.length;
        var aliasListBuf = _malloc((length + 1) * 4);
        for (var i = 0; i < length; i++, j += 4) {
          var alias = aliases[i];
          var aliasBuf = _malloc(alias.length + 1);
          stringToAscii(alias, aliasBuf);
          HEAPU32[aliasListBuf + j >>> 2 >>> 0] = aliasBuf;
        }
        HEAPU32[aliasListBuf + j >>> 2 >>> 0] = 0;
        var pe = _malloc(12);
        HEAPU32[pe >>> 2 >>> 0] = nameBuf;
        HEAPU32[pe + 4 >>> 2 >>> 0] = aliasListBuf;
        HEAP32[pe + 8 >>> 2 >>> 0] = proto;
        return pe;
      }
      var list = Protocols.list;
      var map = Protocols.map;
      if (list.length === 0) {
        var entry = allocprotoent("tcp", 6, ["TCP"]);
        list.push(entry);
        map["tcp"] = map["6"] = entry;
        entry = allocprotoent("udp", 17, ["UDP"]);
        list.push(entry);
        map["udp"] = map["17"] = entry;
      }
      _setprotoent.index = 0;
    };
    _setprotoent.sig = "vi";
    function _getprotobyname(name) {
      name >>>= 0;
      name = UTF8ToString(name);
      _setprotoent(true);
      var result = Protocols.map[name];
      return result;
    }
    _getprotobyname.sig = "pp";
    function _getprotobynumber(number) {
      _setprotoent(true);
      var result = Protocols.map[number];
      return result;
    }
    _getprotobynumber.sig = "pi";
    function _makecontext(...args) {
      return asyncifyStubs["makecontext"](...args);
    }
    _makecontext.stub = true;
    asyncifyStubs["makecontext"] = undefined;
    function _php_embed_init(...args) {
      return asyncifyStubs["php_embed_init"](...args);
    }
    _php_embed_init.stub = true;
    asyncifyStubs["php_embed_init"] = undefined;
    function _php_embed_shutdown(...args) {
      return asyncifyStubs["php_embed_shutdown"](...args);
    }
    _php_embed_shutdown.stub = true;
    asyncifyStubs["php_embed_shutdown"] = undefined;
    function _php_pdo_register_driver(...args) {
      return asyncifyStubs["php_pdo_register_driver"](...args);
    }
    _php_pdo_register_driver.stub = true;
    asyncifyStubs["php_pdo_register_driver"] = undefined;
    function _posix_spawnp(...args) {
      return asyncifyStubs["posix_spawnp"](...args);
    }
    _posix_spawnp.stub = true;
    asyncifyStubs["posix_spawnp"] = undefined;
    var arraySum = (array, index) => {
      var sum = 0;
      for (var i = 0; i <= index; sum += array[i++]) {}
      return sum;
    };
    var MONTH_DAYS_LEAP = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var MONTH_DAYS_REGULAR = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var addDays = (date, days) => {
      var newDate = new Date(date.getTime());
      while (days > 0) {
        var leap = isLeapYear(newDate.getFullYear());
        var currentMonth = newDate.getMonth();
        var daysInCurrentMonth = (leap ? MONTH_DAYS_LEAP : MONTH_DAYS_REGULAR)[currentMonth];
        if (days > daysInCurrentMonth - newDate.getDate()) {
          days -= daysInCurrentMonth - newDate.getDate() + 1;
          newDate.setDate(1);
          if (currentMonth < 11) {
            newDate.setMonth(currentMonth + 1);
          } else {
            newDate.setMonth(0);
            newDate.setFullYear(newDate.getFullYear() + 1);
          }
        } else {
          newDate.setDate(newDate.getDate() + days);
          return newDate;
        }
      }
      return newDate;
    };
    var writeArrayToMemory = (array, buffer) => {
      HEAP8.set(array, buffer >>> 0);
    };
    function _strftime(s, maxsize, format, tm) {
      s >>>= 0;
      maxsize >>>= 0;
      format >>>= 0;
      tm >>>= 0;
      var tm_zone = HEAPU32[tm + 40 >>> 2 >>> 0];
      var date = {
        tm_sec: HEAP32[tm >>> 2 >>> 0],
        tm_min: HEAP32[tm + 4 >>> 2 >>> 0],
        tm_hour: HEAP32[tm + 8 >>> 2 >>> 0],
        tm_mday: HEAP32[tm + 12 >>> 2 >>> 0],
        tm_mon: HEAP32[tm + 16 >>> 2 >>> 0],
        tm_year: HEAP32[tm + 20 >>> 2 >>> 0],
        tm_wday: HEAP32[tm + 24 >>> 2 >>> 0],
        tm_yday: HEAP32[tm + 28 >>> 2 >>> 0],
        tm_isdst: HEAP32[tm + 32 >>> 2 >>> 0],
        tm_gmtoff: HEAP32[tm + 36 >>> 2 >>> 0],
        tm_zone: tm_zone ? UTF8ToString(tm_zone) : ""
      };
      var pattern = UTF8ToString(format);
      var EXPANSION_RULES_1 = {
        "%c": "%a %b %d %H:%M:%S %Y",
        "%D": "%m/%d/%y",
        "%F": "%Y-%m-%d",
        "%h": "%b",
        "%r": "%I:%M:%S %p",
        "%R": "%H:%M",
        "%T": "%H:%M:%S",
        "%x": "%m/%d/%y",
        "%X": "%H:%M:%S",
        "%Ec": "%c",
        "%EC": "%C",
        "%Ex": "%m/%d/%y",
        "%EX": "%H:%M:%S",
        "%Ey": "%y",
        "%EY": "%Y",
        "%Od": "%d",
        "%Oe": "%e",
        "%OH": "%H",
        "%OI": "%I",
        "%Om": "%m",
        "%OM": "%M",
        "%OS": "%S",
        "%Ou": "%u",
        "%OU": "%U",
        "%OV": "%V",
        "%Ow": "%w",
        "%OW": "%W",
        "%Oy": "%y"
      };
      for (var rule in EXPANSION_RULES_1) {
        pattern = pattern.replace(new RegExp(rule, "g"), EXPANSION_RULES_1[rule]);
      }
      var WEEKDAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
      var MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      function leadingSomething(value, digits, character) {
        var str = typeof value == "number" ? value.toString() : value || "";
        while (str.length < digits) {
          str = character[0] + str;
        }
        return str;
      }
      function leadingNulls(value, digits) {
        return leadingSomething(value, digits, "0");
      }
      function compareByDay(date1, date2) {
        function sgn(value) {
          return value < 0 ? -1 : value > 0 ? 1 : 0;
        }
        var compare;
        if ((compare = sgn(date1.getFullYear() - date2.getFullYear())) === 0) {
          if ((compare = sgn(date1.getMonth() - date2.getMonth())) === 0) {
            compare = sgn(date1.getDate() - date2.getDate());
          }
        }
        return compare;
      }
      function getFirstWeekStartDate(janFourth) {
        switch (janFourth.getDay()) {
          case 0:
            return new Date(janFourth.getFullYear() - 1, 11, 29);
          case 1:
            return janFourth;
          case 2:
            return new Date(janFourth.getFullYear(), 0, 3);
          case 3:
            return new Date(janFourth.getFullYear(), 0, 2);
          case 4:
            return new Date(janFourth.getFullYear(), 0, 1);
          case 5:
            return new Date(janFourth.getFullYear() - 1, 11, 31);
          case 6:
            return new Date(janFourth.getFullYear() - 1, 11, 30);
        }
      }
      function getWeekBasedYear(date) {
        var thisDate = addDays(new Date(date.tm_year + 1900, 0, 1), date.tm_yday);
        var janFourthThisYear = new Date(thisDate.getFullYear(), 0, 4);
        var janFourthNextYear = new Date(thisDate.getFullYear() + 1, 0, 4);
        var firstWeekStartThisYear = getFirstWeekStartDate(janFourthThisYear);
        var firstWeekStartNextYear = getFirstWeekStartDate(janFourthNextYear);
        if (compareByDay(firstWeekStartThisYear, thisDate) <= 0) {
          if (compareByDay(firstWeekStartNextYear, thisDate) <= 0) {
            return thisDate.getFullYear() + 1;
          }
          return thisDate.getFullYear();
        }
        return thisDate.getFullYear() - 1;
      }
      var EXPANSION_RULES_2 = {
        "%a": date => WEEKDAYS[date.tm_wday].substring(0, 3),
        "%A": date => WEEKDAYS[date.tm_wday],
        "%b": date => MONTHS[date.tm_mon].substring(0, 3),
        "%B": date => MONTHS[date.tm_mon],
        "%C": date => {
          var year = date.tm_year + 1900;
          return leadingNulls(year / 100 | 0, 2);
        },
        "%d": date => leadingNulls(date.tm_mday, 2),
        "%e": date => leadingSomething(date.tm_mday, 2, " "),
        "%g": date => getWeekBasedYear(date).toString().substring(2),
        "%G": getWeekBasedYear,
        "%H": date => leadingNulls(date.tm_hour, 2),
        "%I": date => {
          var twelveHour = date.tm_hour;
          if (twelveHour == 0) twelveHour = 12;else if (twelveHour > 12) twelveHour -= 12;
          return leadingNulls(twelveHour, 2);
        },
        "%j": date => leadingNulls(date.tm_mday + arraySum(isLeapYear(date.tm_year + 1900) ? MONTH_DAYS_LEAP : MONTH_DAYS_REGULAR, date.tm_mon - 1), 3),
        "%m": date => leadingNulls(date.tm_mon + 1, 2),
        "%M": date => leadingNulls(date.tm_min, 2),
        "%n": () => "\n",
        "%p": date => {
          if (date.tm_hour >= 0 && date.tm_hour < 12) {
            return "AM";
          }
          return "PM";
        },
        "%S": date => leadingNulls(date.tm_sec, 2),
        "%t": () => "\t",
        "%u": date => date.tm_wday || 7,
        "%U": date => {
          var days = date.tm_yday + 7 - date.tm_wday;
          return leadingNulls(Math.floor(days / 7), 2);
        },
        "%V": date => {
          var val = Math.floor((date.tm_yday + 7 - (date.tm_wday + 6) % 7) / 7);
          if ((date.tm_wday + 371 - date.tm_yday - 2) % 7 <= 2) {
            val++;
          }
          if (!val) {
            val = 52;
            var dec31 = (date.tm_wday + 7 - date.tm_yday - 1) % 7;
            if (dec31 == 4 || dec31 == 5 && isLeapYear(date.tm_year % 400 - 1)) {
              val++;
            }
          } else if (val == 53) {
            var jan1 = (date.tm_wday + 371 - date.tm_yday) % 7;
            if (jan1 != 4 && (jan1 != 3 || !isLeapYear(date.tm_year))) val = 1;
          }
          return leadingNulls(val, 2);
        },
        "%w": date => date.tm_wday,
        "%W": date => {
          var days = date.tm_yday + 7 - (date.tm_wday + 6) % 7;
          return leadingNulls(Math.floor(days / 7), 2);
        },
        "%y": date => (date.tm_year + 1900).toString().substring(2),
        "%Y": date => date.tm_year + 1900,
        "%z": date => {
          var off = date.tm_gmtoff;
          var ahead = off >= 0;
          off = Math.abs(off) / 60;
          off = off / 60 * 100 + off % 60;
          return (ahead ? "+" : "-") + String("0000" + off).slice(-4);
        },
        "%Z": date => date.tm_zone,
        "%%": () => "%"
      };
      pattern = pattern.replace(/%%/g, "\0\0");
      for (var rule in EXPANSION_RULES_2) {
        if (pattern.includes(rule)) {
          pattern = pattern.replace(new RegExp(rule, "g"), EXPANSION_RULES_2[rule](date));
        }
      }
      pattern = pattern.replace(/\0\0/g, "%");
      var bytes = intArrayFromString(pattern, false);
      if (bytes.length > maxsize) {
        return 0;
      }
      writeArrayToMemory(bytes, s);
      return bytes.length - 1;
    }
    _strftime.sig = "ppppp";
    function _strftime_l(s, maxsize, format, tm, loc) {
      s >>>= 0;
      maxsize >>>= 0;
      format >>>= 0;
      tm >>>= 0;
      loc >>>= 0;
      return _strftime(s, maxsize, format, tm);
    }
    _strftime_l.sig = "pppppp";
    function _strptime(buf, format, tm) {
      buf >>>= 0;
      format >>>= 0;
      tm >>>= 0;
      var pattern = UTF8ToString(format);
      var SPECIAL_CHARS = "\\!@#$^&*()+=-[]/{}|:<>?,.";
      for (var i = 0, ii = SPECIAL_CHARS.length; i < ii; ++i) {
        pattern = pattern.replace(new RegExp("\\" + SPECIAL_CHARS[i], "g"), "\\" + SPECIAL_CHARS[i]);
      }
      var EQUIVALENT_MATCHERS = {
        A: "%a",
        B: "%b",
        c: "%a %b %d %H:%M:%S %Y",
        D: "%m\\/%d\\/%y",
        e: "%d",
        F: "%Y-%m-%d",
        h: "%b",
        R: "%H\\:%M",
        r: "%I\\:%M\\:%S\\s%p",
        T: "%H\\:%M\\:%S",
        x: "%m\\/%d\\/(?:%y|%Y)",
        X: "%H\\:%M\\:%S"
      };
      var DATE_PATTERNS = {
        a: "(?:Sun(?:day)?)|(?:Mon(?:day)?)|(?:Tue(?:sday)?)|(?:Wed(?:nesday)?)|(?:Thu(?:rsday)?)|(?:Fri(?:day)?)|(?:Sat(?:urday)?)",
        b: "(?:Jan(?:uary)?)|(?:Feb(?:ruary)?)|(?:Mar(?:ch)?)|(?:Apr(?:il)?)|May|(?:Jun(?:e)?)|(?:Jul(?:y)?)|(?:Aug(?:ust)?)|(?:Sep(?:tember)?)|(?:Oct(?:ober)?)|(?:Nov(?:ember)?)|(?:Dec(?:ember)?)",
        C: "\\d\\d",
        d: "0[1-9]|[1-9](?!\\d)|1\\d|2\\d|30|31",
        H: "\\d(?!\\d)|[0,1]\\d|20|21|22|23",
        I: "\\d(?!\\d)|0\\d|10|11|12",
        j: "00[1-9]|0?[1-9](?!\\d)|0?[1-9]\\d(?!\\d)|[1,2]\\d\\d|3[0-6]\\d",
        m: "0[1-9]|[1-9](?!\\d)|10|11|12",
        M: "0\\d|\\d(?!\\d)|[1-5]\\d",
        n: " ",
        p: "AM|am|PM|pm|A\\.M\\.|a\\.m\\.|P\\.M\\.|p\\.m\\.",
        S: "0\\d|\\d(?!\\d)|[1-5]\\d|60",
        U: "0\\d|\\d(?!\\d)|[1-4]\\d|50|51|52|53",
        W: "0\\d|\\d(?!\\d)|[1-4]\\d|50|51|52|53",
        w: "[0-6]",
        y: "\\d\\d",
        Y: "\\d\\d\\d\\d",
        t: " ",
        z: "Z|(?:[\\+\\-]\\d\\d:?(?:\\d\\d)?)"
      };
      var MONTH_NUMBERS = {
        JAN: 0,
        FEB: 1,
        MAR: 2,
        APR: 3,
        MAY: 4,
        JUN: 5,
        JUL: 6,
        AUG: 7,
        SEP: 8,
        OCT: 9,
        NOV: 10,
        DEC: 11
      };
      var DAY_NUMBERS_SUN_FIRST = {
        SUN: 0,
        MON: 1,
        TUE: 2,
        WED: 3,
        THU: 4,
        FRI: 5,
        SAT: 6
      };
      var DAY_NUMBERS_MON_FIRST = {
        MON: 0,
        TUE: 1,
        WED: 2,
        THU: 3,
        FRI: 4,
        SAT: 5,
        SUN: 6
      };
      var capture = [];
      var pattern_out = pattern.replace(/%(.)/g, (m, c) => EQUIVALENT_MATCHERS[c] || m).replace(/%(.)/g, (_, c) => {
        let pat = DATE_PATTERNS[c];
        if (pat) {
          capture.push(c);
          return `(${pat})`;
        } else {
          return c;
        }
      }).replace(/\s+/g, "\\s*");
      var matches = new RegExp("^" + pattern_out, "i").exec(UTF8ToString(buf));
      function initDate() {
        function fixup(value, min, max) {
          return typeof value != "number" || isNaN(value) ? min : value >= min ? value <= max ? value : max : min;
        }
        return {
          year: fixup(HEAP32[tm + 20 >>> 2 >>> 0] + 1900, 1970, 9999),
          month: fixup(HEAP32[tm + 16 >>> 2 >>> 0], 0, 11),
          day: fixup(HEAP32[tm + 12 >>> 2 >>> 0], 1, 31),
          hour: fixup(HEAP32[tm + 8 >>> 2 >>> 0], 0, 23),
          min: fixup(HEAP32[tm + 4 >>> 2 >>> 0], 0, 59),
          sec: fixup(HEAP32[tm >>> 2 >>> 0], 0, 59),
          gmtoff: 0
        };
      }
      if (matches) {
        var date = initDate();
        var value;
        var getMatch = symbol => {
          var pos = capture.indexOf(symbol);
          if (pos >= 0) {
            return matches[pos + 1];
          }
          return;
        };
        if (value = getMatch("S")) {
          date.sec = jstoi_q(value);
        }
        if (value = getMatch("M")) {
          date.min = jstoi_q(value);
        }
        if (value = getMatch("H")) {
          date.hour = jstoi_q(value);
        } else if (value = getMatch("I")) {
          var hour = jstoi_q(value);
          if (value = getMatch("p")) {
            hour += value.toUpperCase()[0] === "P" ? 12 : 0;
          }
          date.hour = hour;
        }
        if (value = getMatch("Y")) {
          date.year = jstoi_q(value);
        } else if (value = getMatch("y")) {
          var year = jstoi_q(value);
          if (value = getMatch("C")) {
            year += jstoi_q(value) * 100;
          } else {
            year += year < 69 ? 2e3 : 1900;
          }
          date.year = year;
        }
        if (value = getMatch("m")) {
          date.month = jstoi_q(value) - 1;
        } else if (value = getMatch("b")) {
          date.month = MONTH_NUMBERS[value.substring(0, 3).toUpperCase()] || 0;
        }
        if (value = getMatch("d")) {
          date.day = jstoi_q(value);
        } else if (value = getMatch("j")) {
          var day = jstoi_q(value);
          var leapYear = isLeapYear(date.year);
          for (var month = 0; month < 12; ++month) {
            var daysUntilMonth = arraySum(leapYear ? MONTH_DAYS_LEAP : MONTH_DAYS_REGULAR, month - 1);
            if (day <= daysUntilMonth + (leapYear ? MONTH_DAYS_LEAP : MONTH_DAYS_REGULAR)[month]) {
              date.day = day - daysUntilMonth;
            }
          }
        } else if (value = getMatch("a")) {
          var weekDay = value.substring(0, 3).toUpperCase();
          if (value = getMatch("U")) {
            var weekDayNumber = DAY_NUMBERS_SUN_FIRST[weekDay];
            var weekNumber = jstoi_q(value);
            var janFirst = new Date(date.year, 0, 1);
            var endDate;
            if (janFirst.getDay() === 0) {
              endDate = addDays(janFirst, weekDayNumber + 7 * (weekNumber - 1));
            } else {
              endDate = addDays(janFirst, 7 - janFirst.getDay() + weekDayNumber + 7 * (weekNumber - 1));
            }
            date.day = endDate.getDate();
            date.month = endDate.getMonth();
          } else if (value = getMatch("W")) {
            var weekDayNumber = DAY_NUMBERS_MON_FIRST[weekDay];
            var weekNumber = jstoi_q(value);
            var janFirst = new Date(date.year, 0, 1);
            var endDate;
            if (janFirst.getDay() === 1) {
              endDate = addDays(janFirst, weekDayNumber + 7 * (weekNumber - 1));
            } else {
              endDate = addDays(janFirst, 7 - janFirst.getDay() + 1 + weekDayNumber + 7 * (weekNumber - 1));
            }
            date.day = endDate.getDate();
            date.month = endDate.getMonth();
          }
        }
        if (value = getMatch("z")) {
          if (value.toLowerCase() === "z") {
            date.gmtoff = 0;
          } else {
            var match = value.match(/^((?:\-|\+)\d\d):?(\d\d)?/);
            date.gmtoff = match[1] * 3600;
            if (match[2]) {
              date.gmtoff += date.gmtoff > 0 ? match[2] * 60 : -match[2] * 60;
            }
          }
        }
        var fullDate = new Date(date.year, date.month, date.day, date.hour, date.min, date.sec, 0);
        HEAP32[tm >>> 2 >>> 0] = fullDate.getSeconds();
        HEAP32[tm + 4 >>> 2 >>> 0] = fullDate.getMinutes();
        HEAP32[tm + 8 >>> 2 >>> 0] = fullDate.getHours();
        HEAP32[tm + 12 >>> 2 >>> 0] = fullDate.getDate();
        HEAP32[tm + 16 >>> 2 >>> 0] = fullDate.getMonth();
        HEAP32[tm + 20 >>> 2 >>> 0] = fullDate.getFullYear() - 1900;
        HEAP32[tm + 24 >>> 2 >>> 0] = fullDate.getDay();
        HEAP32[tm + 28 >>> 2 >>> 0] = arraySum(isLeapYear(fullDate.getFullYear()) ? MONTH_DAYS_LEAP : MONTH_DAYS_REGULAR, fullDate.getMonth() - 1) + fullDate.getDate() - 1;
        HEAP32[tm + 32 >>> 2 >>> 0] = 0;
        HEAP32[tm + 36 >>> 2 >>> 0] = date.gmtoff;
        return buf + intArrayFromString(matches[0]).length - 1;
      }
      return 0;
    }
    _strptime.sig = "pppp";
    function _swapcontext(...args) {
      return asyncifyStubs["swapcontext"](...args);
    }
    _swapcontext.stub = true;
    asyncifyStubs["swapcontext"] = undefined;
    var runAndAbortIfError = func => {
      try {
        return func();
      } catch (e) {
        abort(e);
      }
    };
    var runtimeKeepalivePush = () => {
      runtimeKeepaliveCounter += 1;
    };
    runtimeKeepalivePush.sig = "v";
    var runtimeKeepalivePop = () => {
      runtimeKeepaliveCounter -= 1;
    };
    runtimeKeepalivePop.sig = "v";
    var Asyncify = {
      instrumentWasmImports(imports) {
        var importPattern = /^(invoke_.*|__asyncjs__.*)$/;
        for (let [x, original] of Object.entries(imports)) {
          if (typeof original == "function") {
            let isAsyncifyImport = original.isAsync || importPattern.test(x);
          }
        }
      },
      instrumentWasmExports(exports) {
        var ret = {};
        for (let [x, original] of Object.entries(exports)) {
          if (typeof original == "function") {
            ret[x] = (...args) => {
              Asyncify.exportCallStack.push(x);
              try {
                return original(...args);
              } finally {
                if (!ABORT) {
                  var y = Asyncify.exportCallStack.pop();
                  Asyncify.maybeStopUnwind();
                }
              }
            };
            ret[x].orig = original;
          } else {
            ret[x] = original;
          }
        }
        return ret;
      },
      State: {
        Normal: 0,
        Unwinding: 1,
        Rewinding: 2,
        Disabled: 3
      },
      state: 0,
      StackSize: 4096,
      currData: null,
      handleSleepReturnValue: 0,
      exportCallStack: [],
      callStackNameToId: {},
      callStackIdToName: {},
      callStackId: 0,
      asyncPromiseHandlers: null,
      sleepCallbacks: [],
      getCallStackId(funcName) {
        var id = Asyncify.callStackNameToId[funcName];
        if (id === undefined) {
          id = Asyncify.callStackId++;
          Asyncify.callStackNameToId[funcName] = id;
          Asyncify.callStackIdToName[id] = funcName;
        }
        return id;
      },
      maybeStopUnwind() {
        if (Asyncify.currData && Asyncify.state === Asyncify.State.Unwinding && Asyncify.exportCallStack.length === 0) {
          Asyncify.state = Asyncify.State.Normal;
          runtimeKeepalivePush();
          runAndAbortIfError(_asyncify_stop_unwind);
          if (typeof Fibers != "undefined") {
            Fibers.trampoline();
          }
        }
      },
      whenDone() {
        return new Promise((resolve, reject) => {
          Asyncify.asyncPromiseHandlers = {
            resolve: resolve,
            reject: reject
          };
        });
      },
      allocateData() {
        var ptr = _malloc(12 + Asyncify.StackSize);
        Asyncify.setDataHeader(ptr, ptr + 12, Asyncify.StackSize);
        Asyncify.setDataRewindFunc(ptr);
        return ptr;
      },
      setDataHeader(ptr, stack, stackSize) {
        HEAPU32[ptr >>> 2 >>> 0] = stack;
        HEAPU32[ptr + 4 >>> 2 >>> 0] = stack + stackSize;
      },
      setDataRewindFunc(ptr) {
        var bottomOfCallStack = Asyncify.exportCallStack[0];
        var rewindId = Asyncify.getCallStackId(bottomOfCallStack);
        HEAP32[ptr + 8 >>> 2 >>> 0] = rewindId;
      },
      getDataRewindFuncName(ptr) {
        var id = HEAP32[ptr + 8 >>> 2 >>> 0];
        var name = Asyncify.callStackIdToName[id];
        return name;
      },
      getDataRewindFunc__deps: ["$resolveGlobalSymbol"],
      getDataRewindFunc(name) {
        var func = wasmExports[name];
        if (!func) {
          func = resolveGlobalSymbol(name, false).sym;
        }
        return func;
      },
      doRewind(ptr) {
        var name = Asyncify.getDataRewindFuncName(ptr);
        var func = Asyncify.getDataRewindFunc(name);
        runtimeKeepalivePop();
        return func();
      },
      handleSleep(startAsync) {
        if (ABORT) return;
        if (Asyncify.state === Asyncify.State.Normal) {
          var reachedCallback = false;
          var reachedAfterCallback = false;
          startAsync((handleSleepReturnValue = 0) => {
            if (ABORT) return;
            Asyncify.handleSleepReturnValue = handleSleepReturnValue;
            reachedCallback = true;
            if (!reachedAfterCallback) {
              return;
            }
            Asyncify.state = Asyncify.State.Rewinding;
            runAndAbortIfError(() => _asyncify_start_rewind(Asyncify.currData));
            if (typeof Browser != "undefined" && Browser.mainLoop.func) {
              Browser.mainLoop.resume();
            }
            var asyncWasmReturnValue,
              isError = false;
            try {
              asyncWasmReturnValue = Asyncify.doRewind(Asyncify.currData);
            } catch (err) {
              asyncWasmReturnValue = err;
              isError = true;
            }
            var handled = false;
            if (!Asyncify.currData) {
              var asyncPromiseHandlers = Asyncify.asyncPromiseHandlers;
              if (asyncPromiseHandlers) {
                Asyncify.asyncPromiseHandlers = null;
                (isError ? asyncPromiseHandlers.reject : asyncPromiseHandlers.resolve)(asyncWasmReturnValue);
                handled = true;
              }
            }
            if (isError && !handled) {
              throw asyncWasmReturnValue;
            }
          });
          reachedAfterCallback = true;
          if (!reachedCallback) {
            Asyncify.state = Asyncify.State.Unwinding;
            Asyncify.currData = Asyncify.allocateData();
            if (typeof Browser != "undefined" && Browser.mainLoop.func) {
              Browser.mainLoop.pause();
            }
            runAndAbortIfError(() => _asyncify_start_unwind(Asyncify.currData));
          }
        } else if (Asyncify.state === Asyncify.State.Rewinding) {
          Asyncify.state = Asyncify.State.Normal;
          runAndAbortIfError(_asyncify_stop_rewind);
          _free(Asyncify.currData);
          Asyncify.currData = null;
          Asyncify.sleepCallbacks.forEach(callUserCallback);
        } else {
          abort(`invalid state: ${Asyncify.state}`);
        }
        return Asyncify.handleSleepReturnValue;
      },
      handleAsync(startAsync) {
        return Asyncify.handleSleep(wakeUp => {
          startAsync().then(wakeUp);
        });
      }
    };
    var getCFunc = ident => {
      var func = Module["_" + ident];
      return func;
    };
    var ccall = (ident, returnType, argTypes, args, opts) => {
      var toC = {
        string: str => {
          var ret = 0;
          if (str !== null && str !== undefined && str !== 0) {
            ret = stringToUTF8OnStack(str);
          }
          return ret;
        },
        array: arr => {
          var ret = stackAlloc(arr.length);
          writeArrayToMemory(arr, ret);
          return ret;
        }
      };
      function convertReturnValue(ret) {
        if (returnType === "string") {
          return UTF8ToString(ret);
        }
        if (returnType === "boolean") return Boolean(ret);
        return ret;
      }
      var func = getCFunc(ident);
      var cArgs = [];
      var stack = 0;
      if (args) {
        for (var i = 0; i < args.length; i++) {
          var converter = toC[argTypes[i]];
          if (converter) {
            if (stack === 0) stack = stackSave();
            cArgs[i] = converter(args[i]);
          } else {
            cArgs[i] = args[i];
          }
        }
      }
      var previousAsync = Asyncify.currData;
      var ret = func(...cArgs);
      function onDone(ret) {
        runtimeKeepalivePop();
        if (stack !== 0) stackRestore(stack);
        return convertReturnValue(ret);
      }
      var asyncMode = opts?.async;
      runtimeKeepalivePush();
      if (Asyncify.currData != previousAsync) {
        return Asyncify.whenDone().then(onDone);
      }
      ret = onDone(ret);
      if (asyncMode) return Promise.resolve(ret);
      return ret;
    };
    var FS_createPath = FS.createPath;
    var FS_unlink = path => FS.unlink(path);
    var FS_createLazyFile = FS.createLazyFile;
    var FS_createDevice = FS.createDevice;
    registerWasmPlugin();
    FS.createPreloadedFile = FS_createPreloadedFile;
    FS.staticInit();
    Module["FS_createPath"] = FS.createPath;
    Module["FS_createDataFile"] = FS.createDataFile;
    Module["FS_createPreloadedFile"] = FS.createPreloadedFile;
    Module["FS_unlink"] = FS.unlink;
    Module["FS_createLazyFile"] = FS.createLazyFile;
    Module["FS_createDevice"] = FS.createDevice;
    var wasmImports = {
      __assert_fail: ___assert_fail,
      __asyncify_data: ___asyncify_data,
      __asyncify_state: ___asyncify_state,
      __asyncjs__pdo_vrzno_real_stmt_execute: __asyncjs__pdo_vrzno_real_stmt_execute,
      __asyncjs__vrzno_await_internal: __asyncjs__vrzno_await_internal,
      __call_sighandler: ___call_sighandler,
      __heap_base: ___heap_base,
      __indirect_function_table: wasmTable,
      __memory_base: ___memory_base,
      __stack_pointer: ___stack_pointer,
      __syscall__newselect: ___syscall__newselect,
      __syscall_accept4: ___syscall_accept4,
      __syscall_bind: ___syscall_bind,
      __syscall_chdir: ___syscall_chdir,
      __syscall_chmod: ___syscall_chmod,
      __syscall_connect: ___syscall_connect,
      __syscall_dup: ___syscall_dup,
      __syscall_faccessat: ___syscall_faccessat,
      __syscall_fchownat: ___syscall_fchownat,
      __syscall_fcntl64: ___syscall_fcntl64,
      __syscall_fdatasync: ___syscall_fdatasync,
      __syscall_fstat64: ___syscall_fstat64,
      __syscall_ftruncate64: ___syscall_ftruncate64,
      __syscall_getcwd: ___syscall_getcwd,
      __syscall_getdents64: ___syscall_getdents64,
      __syscall_getpeername: ___syscall_getpeername,
      __syscall_getsockname: ___syscall_getsockname,
      __syscall_getsockopt: ___syscall_getsockopt,
      __syscall_ioctl: ___syscall_ioctl,
      __syscall_listen: ___syscall_listen,
      __syscall_lstat64: ___syscall_lstat64,
      __syscall_mkdirat: ___syscall_mkdirat,
      __syscall_newfstatat: ___syscall_newfstatat,
      __syscall_openat: ___syscall_openat,
      __syscall_pipe: ___syscall_pipe,
      __syscall_poll: ___syscall_poll,
      __syscall_readlinkat: ___syscall_readlinkat,
      __syscall_recvfrom: ___syscall_recvfrom,
      __syscall_renameat: ___syscall_renameat,
      __syscall_rmdir: ___syscall_rmdir,
      __syscall_sendto: ___syscall_sendto,
      __syscall_socket: ___syscall_socket,
      __syscall_stat64: ___syscall_stat64,
      __syscall_statfs64: ___syscall_statfs64,
      __syscall_symlink: ___syscall_symlink,
      __syscall_unlinkat: ___syscall_unlinkat,
      __syscall_utimensat: ___syscall_utimensat,
      __table_base: ___table_base,
      _abort_js: __abort_js,
      _dlopen_js: __dlopen_js,
      _dlsym_js: __dlsym_js,
      _emscripten_get_now_is_monotonic: __emscripten_get_now_is_monotonic,
      _emscripten_lookup_name: __emscripten_lookup_name,
      _emscripten_memcpy_js: __emscripten_memcpy_js,
      _emscripten_runtime_keepalive_clear: __emscripten_runtime_keepalive_clear,
      _emscripten_throw_longjmp: __emscripten_throw_longjmp,
      _gmtime_js: __gmtime_js,
      _localtime_js: __localtime_js,
      _mktime_js: __mktime_js,
      _mmap_js: __mmap_js,
      _munmap_js: __munmap_js,
      _setitimer_js: __setitimer_js,
      _tzset_js: __tzset_js,
      emscripten_asm_const_int: _emscripten_asm_const_int,
      emscripten_asm_const_ptr: _emscripten_asm_const_ptr,
      emscripten_date_now: _emscripten_date_now,
      emscripten_get_heap_max: _emscripten_get_heap_max,
      emscripten_get_now: _emscripten_get_now,
      emscripten_resize_heap: _emscripten_resize_heap,
      environ_get: _environ_get,
      environ_sizes_get: _environ_sizes_get,
      exit: _exit,
      fd_close: _fd_close,
      fd_fdstat_get: _fd_fdstat_get,
      fd_read: _fd_read,
      fd_seek: _fd_seek,
      fd_sync: _fd_sync,
      fd_write: _fd_write,
      getaddrinfo: _getaddrinfo,
      getcontext: _getcontext,
      getdtablesize: _getdtablesize,
      getnameinfo: _getnameinfo,
      getprotobyname: _getprotobyname,
      getprotobynumber: _getprotobynumber,
      invoke_i: invoke_i,
      invoke_ii: invoke_ii,
      invoke_iii: invoke_iii,
      invoke_iiii: invoke_iiii,
      invoke_iiiii: invoke_iiiii,
      invoke_iiiiii: invoke_iiiiii,
      invoke_iiiiiii: invoke_iiiiiii,
      invoke_iiiiiiii: invoke_iiiiiiii,
      invoke_iiiiiiiiii: invoke_iiiiiiiiii,
      invoke_v: invoke_v,
      invoke_vi: invoke_vi,
      invoke_vii: invoke_vii,
      invoke_viii: invoke_viii,
      invoke_viiii: invoke_viiii,
      invoke_viiiii: invoke_viiiii,
      invoke_viiiiii: invoke_viiiiii,
      makecontext: _makecontext,
      memory: wasmMemory,
      php_embed_init: _php_embed_init,
      php_embed_shutdown: _php_embed_shutdown,
      php_pdo_register_driver: _php_pdo_register_driver,
      posix_spawnp: _posix_spawnp,
      proc_exit: _proc_exit,
      strftime: _strftime,
      strftime_l: _strftime_l,
      strptime: _strptime,
      swapcontext: _swapcontext
    };
    var wasmExports = createWasm();
    var ___wasm_call_ctors = () => (___wasm_call_ctors = wasmExports["__wasm_call_ctors"])();
    var ___wasm_apply_data_relocs = () => (___wasm_apply_data_relocs = wasmExports["__wasm_apply_data_relocs"])();
    var _strlen = a0 => (_strlen = wasmExports["strlen"])(a0);
    var _memcmp = (a0, a1, a2) => (_memcmp = wasmExports["memcmp"])(a0, a1, a2);
    var _strcmp = (a0, a1) => (_strcmp = wasmExports["strcmp"])(a0, a1);
    var _free = Module["_free"] = a0 => (_free = Module["_free"] = wasmExports["free"])(a0);
    var _malloc = Module["_malloc"] = a0 => (_malloc = Module["_malloc"] = wasmExports["malloc"])(a0);
    var _strncmp = (a0, a1, a2) => (_strncmp = wasmExports["strncmp"])(a0, a1, a2);
    var _main = Module["_main"] = (a0, a1) => (_main = Module["_main"] = wasmExports["main"])(a0, a1);
    var _pib_storage_init = Module["_pib_storage_init"] = () => (_pib_storage_init = Module["_pib_storage_init"] = wasmExports["pib_storage_init"])();
    var _pib_init = Module["_pib_init"] = () => (_pib_init = Module["_pib_init"] = wasmExports["pib_init"])();
    var _pib_destroy = Module["_pib_destroy"] = () => (_pib_destroy = Module["_pib_destroy"] = wasmExports["pib_destroy"])();
    var _pib_refresh = Module["_pib_refresh"] = () => (_pib_refresh = Module["_pib_refresh"] = wasmExports["pib_refresh"])();
    var _pib_flush = Module["_pib_flush"] = () => (_pib_flush = Module["_pib_flush"] = wasmExports["pib_flush"])();
    var _pib_exec = Module["_pib_exec"] = a0 => (_pib_exec = Module["_pib_exec"] = wasmExports["pib_exec"])(a0);
    var _pib_run = Module["_pib_run"] = a0 => (_pib_run = Module["_pib_run"] = wasmExports["pib_run"])(a0);
    var _pib_tokenize = Module["_pib_tokenize"] = a0 => (_pib_tokenize = Module["_pib_tokenize"] = wasmExports["pib_tokenize"])(a0);
    var _realloc = Module["_realloc"] = (a0, a1) => (_realloc = Module["_realloc"] = wasmExports["realloc"])(a0, a1);
    var _htonl = a0 => (_htonl = wasmExports["htonl"])(a0);
    var _ntohs = a0 => (_ntohs = wasmExports["ntohs"])(a0);
    var _htons = a0 => (_htons = wasmExports["htons"])(a0);
    var _vrzno_expose_inc_zrefcount = Module["_vrzno_expose_inc_zrefcount"] = a0 => (_vrzno_expose_inc_zrefcount = Module["_vrzno_expose_inc_zrefcount"] = wasmExports["vrzno_expose_inc_zrefcount"])(a0);
    var _vrzno_expose_dec_zrefcount = Module["_vrzno_expose_dec_zrefcount"] = a0 => (_vrzno_expose_dec_zrefcount = Module["_vrzno_expose_dec_zrefcount"] = wasmExports["vrzno_expose_dec_zrefcount"])(a0);
    var _vrzno_expose_zrefcount = Module["_vrzno_expose_zrefcount"] = a0 => (_vrzno_expose_zrefcount = Module["_vrzno_expose_zrefcount"] = wasmExports["vrzno_expose_zrefcount"])(a0);
    var _vrzno_expose_inc_crefcount = Module["_vrzno_expose_inc_crefcount"] = a0 => (_vrzno_expose_inc_crefcount = Module["_vrzno_expose_inc_crefcount"] = wasmExports["vrzno_expose_inc_crefcount"])(a0);
    var _vrzno_expose_dec_crefcount = Module["_vrzno_expose_dec_crefcount"] = a0 => (_vrzno_expose_dec_crefcount = Module["_vrzno_expose_dec_crefcount"] = wasmExports["vrzno_expose_dec_crefcount"])(a0);
    var _vrzno_expose_crefcount = Module["_vrzno_expose_crefcount"] = a0 => (_vrzno_expose_crefcount = Module["_vrzno_expose_crefcount"] = wasmExports["vrzno_expose_crefcount"])(a0);
    var _vrzno_expose_efree = Module["_vrzno_expose_efree"] = a0 => (_vrzno_expose_efree = Module["_vrzno_expose_efree"] = wasmExports["vrzno_expose_efree"])(a0);
    var _vrzno_expose_create_bool = Module["_vrzno_expose_create_bool"] = a0 => (_vrzno_expose_create_bool = Module["_vrzno_expose_create_bool"] = wasmExports["vrzno_expose_create_bool"])(a0);
    var _vrzno_expose_create_null = Module["_vrzno_expose_create_null"] = () => (_vrzno_expose_create_null = Module["_vrzno_expose_create_null"] = wasmExports["vrzno_expose_create_null"])();
    var _vrzno_expose_create_undef = Module["_vrzno_expose_create_undef"] = () => (_vrzno_expose_create_undef = Module["_vrzno_expose_create_undef"] = wasmExports["vrzno_expose_create_undef"])();
    var _vrzno_expose_create_long = Module["_vrzno_expose_create_long"] = a0 => (_vrzno_expose_create_long = Module["_vrzno_expose_create_long"] = wasmExports["vrzno_expose_create_long"])(a0);
    var _vrzno_expose_create_double = Module["_vrzno_expose_create_double"] = a0 => (_vrzno_expose_create_double = Module["_vrzno_expose_create_double"] = wasmExports["vrzno_expose_create_double"])(a0);
    var _vrzno_expose_create_string = Module["_vrzno_expose_create_string"] = a0 => (_vrzno_expose_create_string = Module["_vrzno_expose_create_string"] = wasmExports["vrzno_expose_create_string"])(a0);
    var _vrzno_expose_create_object_for_target = Module["_vrzno_expose_create_object_for_target"] = (a0, a1, a2) => (_vrzno_expose_create_object_for_target = Module["_vrzno_expose_create_object_for_target"] = wasmExports["vrzno_expose_create_object_for_target"])(a0, a1, a2);
    var _vrzno_expose_create_params = Module["_vrzno_expose_create_params"] = a0 => (_vrzno_expose_create_params = Module["_vrzno_expose_create_params"] = wasmExports["vrzno_expose_create_params"])(a0);
    var _vrzno_expose_set_param = Module["_vrzno_expose_set_param"] = (a0, a1, a2) => (_vrzno_expose_set_param = Module["_vrzno_expose_set_param"] = wasmExports["vrzno_expose_set_param"])(a0, a1, a2);
    var _vrzno_expose_zval_is_target = Module["_vrzno_expose_zval_is_target"] = a0 => (_vrzno_expose_zval_is_target = Module["_vrzno_expose_zval_is_target"] = wasmExports["vrzno_expose_zval_is_target"])(a0);
    var _vrzno_expose_object_keys = Module["_vrzno_expose_object_keys"] = a0 => (_vrzno_expose_object_keys = Module["_vrzno_expose_object_keys"] = wasmExports["vrzno_expose_object_keys"])(a0);
    var _vrzno_expose_zval_dump = Module["_vrzno_expose_zval_dump"] = a0 => (_vrzno_expose_zval_dump = Module["_vrzno_expose_zval_dump"] = wasmExports["vrzno_expose_zval_dump"])(a0);
    var _vrzno_expose_type = Module["_vrzno_expose_type"] = a0 => (_vrzno_expose_type = Module["_vrzno_expose_type"] = wasmExports["vrzno_expose_type"])(a0);
    var _vrzno_expose_callable = Module["_vrzno_expose_callable"] = a0 => (_vrzno_expose_callable = Module["_vrzno_expose_callable"] = wasmExports["vrzno_expose_callable"])(a0);
    var _vrzno_expose_long = Module["_vrzno_expose_long"] = a0 => (_vrzno_expose_long = Module["_vrzno_expose_long"] = wasmExports["vrzno_expose_long"])(a0);
    var _vrzno_expose_double = Module["_vrzno_expose_double"] = a0 => (_vrzno_expose_double = Module["_vrzno_expose_double"] = wasmExports["vrzno_expose_double"])(a0);
    var _vrzno_expose_string = Module["_vrzno_expose_string"] = a0 => (_vrzno_expose_string = Module["_vrzno_expose_string"] = wasmExports["vrzno_expose_string"])(a0);
    var _vrzno_expose_property_pointer = Module["_vrzno_expose_property_pointer"] = (a0, a1) => (_vrzno_expose_property_pointer = Module["_vrzno_expose_property_pointer"] = wasmExports["vrzno_expose_property_pointer"])(a0, a1);
    var _vrzno_exec_callback = Module["_vrzno_exec_callback"] = (a0, a1, a2) => (_vrzno_exec_callback = Module["_vrzno_exec_callback"] = wasmExports["vrzno_exec_callback"])(a0, a1, a2);
    var _vrzno_del_callback = Module["_vrzno_del_callback"] = a0 => (_vrzno_del_callback = Module["_vrzno_del_callback"] = wasmExports["vrzno_del_callback"])(a0);
    var _fwrite = (a0, a1, a2, a3) => (_fwrite = wasmExports["fwrite"])(a0, a1, a2, a3);
    var _strdup = a0 => (_strdup = wasmExports["strdup"])(a0);
    var _fflush = a0 => (_fflush = wasmExports["fflush"])(a0);
    var _fread = (a0, a1, a2, a3) => (_fread = wasmExports["fread"])(a0, a1, a2, a3);
    var _calloc = (a0, a1) => (_calloc = wasmExports["calloc"])(a0, a1);
    var _main = Module["_main"] = (a0, a1) => (_main = Module["_main"] = wasmExports["__main_argc_argv"])(a0, a1);
    var _wasm_sapi_cgi_init = Module["_wasm_sapi_cgi_init"] = () => (_wasm_sapi_cgi_init = Module["_wasm_sapi_cgi_init"] = wasmExports["wasm_sapi_cgi_init"])();
    var _wasm_sapi_cgi_getenv = Module["_wasm_sapi_cgi_getenv"] = a0 => (_wasm_sapi_cgi_getenv = Module["_wasm_sapi_cgi_getenv"] = wasmExports["wasm_sapi_cgi_getenv"])(a0);
    var _wasm_sapi_cgi_putenv = Module["_wasm_sapi_cgi_putenv"] = (a0, a1) => (_wasm_sapi_cgi_putenv = Module["_wasm_sapi_cgi_putenv"] = wasmExports["wasm_sapi_cgi_putenv"])(a0, a1);
    var _memset = (a0, a1, a2) => (_memset = wasmExports["memset"])(a0, a1, a2);
    var ___funcs_on_exit = () => (___funcs_on_exit = wasmExports["__funcs_on_exit"])();
    var ___dl_seterr = (a0, a1) => (___dl_seterr = wasmExports["__dl_seterr"])(a0, a1);
    var _memcpy = (a0, a1, a2) => (_memcpy = wasmExports["memcpy"])(a0, a1, a2);
    var _memmove = (a0, a1, a2) => (_memmove = wasmExports["memmove"])(a0, a1, a2);
    var _ferror = a0 => (_ferror = wasmExports["ferror"])(a0);
    var _emscripten_builtin_memalign = (a0, a1) => (_emscripten_builtin_memalign = wasmExports["emscripten_builtin_memalign"])(a0, a1);
    var __emscripten_timeout = (a0, a1) => (__emscripten_timeout = wasmExports["_emscripten_timeout"])(a0, a1);
    var _siprintf = (a0, a1, a2) => (_siprintf = wasmExports["siprintf"])(a0, a1, a2);
    var _setThrew = (a0, a1) => (_setThrew = wasmExports["setThrew"])(a0, a1);
    var __emscripten_tempret_set = a0 => (__emscripten_tempret_set = wasmExports["_emscripten_tempret_set"])(a0);
    var __emscripten_stack_restore = a0 => (__emscripten_stack_restore = wasmExports["_emscripten_stack_restore"])(a0);
    var __emscripten_stack_alloc = a0 => (__emscripten_stack_alloc = wasmExports["_emscripten_stack_alloc"])(a0);
    var _emscripten_stack_get_current = () => (_emscripten_stack_get_current = wasmExports["emscripten_stack_get_current"])();
    var dynCall_iii = Module["dynCall_iii"] = (a0, a1, a2) => (dynCall_iii = Module["dynCall_iii"] = wasmExports["dynCall_iii"])(a0, a1, a2);
    var dynCall_ii = Module["dynCall_ii"] = (a0, a1) => (dynCall_ii = Module["dynCall_ii"] = wasmExports["dynCall_ii"])(a0, a1);
    var dynCall_vi = Module["dynCall_vi"] = (a0, a1) => (dynCall_vi = Module["dynCall_vi"] = wasmExports["dynCall_vi"])(a0, a1);
    var dynCall_iiii = Module["dynCall_iiii"] = (a0, a1, a2, a3) => (dynCall_iiii = Module["dynCall_iiii"] = wasmExports["dynCall_iiii"])(a0, a1, a2, a3);
    var dynCall_iiiii = Module["dynCall_iiiii"] = (a0, a1, a2, a3, a4) => (dynCall_iiiii = Module["dynCall_iiiii"] = wasmExports["dynCall_iiiii"])(a0, a1, a2, a3, a4);
    var dynCall_iiiiii = Module["dynCall_iiiiii"] = (a0, a1, a2, a3, a4, a5) => (dynCall_iiiiii = Module["dynCall_iiiiii"] = wasmExports["dynCall_iiiiii"])(a0, a1, a2, a3, a4, a5);
    var dynCall_vii = Module["dynCall_vii"] = (a0, a1, a2) => (dynCall_vii = Module["dynCall_vii"] = wasmExports["dynCall_vii"])(a0, a1, a2);
    var dynCall_i = Module["dynCall_i"] = a0 => (dynCall_i = Module["dynCall_i"] = wasmExports["dynCall_i"])(a0);
    var dynCall_iij = Module["dynCall_iij"] = (a0, a1, a2, a3) => (dynCall_iij = Module["dynCall_iij"] = wasmExports["dynCall_iij"])(a0, a1, a2, a3);
    var dynCall_viii = Module["dynCall_viii"] = (a0, a1, a2, a3) => (dynCall_viii = Module["dynCall_viii"] = wasmExports["dynCall_viii"])(a0, a1, a2, a3);
    var dynCall_jiijii = Module["dynCall_jiijii"] = (a0, a1, a2, a3, a4, a5, a6) => (dynCall_jiijii = Module["dynCall_jiijii"] = wasmExports["dynCall_jiijii"])(a0, a1, a2, a3, a4, a5, a6);
    var dynCall_vij = Module["dynCall_vij"] = (a0, a1, a2, a3) => (dynCall_vij = Module["dynCall_vij"] = wasmExports["dynCall_vij"])(a0, a1, a2, a3);
    var dynCall_viiijii = Module["dynCall_viiijii"] = (a0, a1, a2, a3, a4, a5, a6, a7) => (dynCall_viiijii = Module["dynCall_viiijii"] = wasmExports["dynCall_viiijii"])(a0, a1, a2, a3, a4, a5, a6, a7);
    var dynCall_v = Module["dynCall_v"] = a0 => (dynCall_v = Module["dynCall_v"] = wasmExports["dynCall_v"])(a0);
    var dynCall_viiii = Module["dynCall_viiii"] = (a0, a1, a2, a3, a4) => (dynCall_viiii = Module["dynCall_viiii"] = wasmExports["dynCall_viiii"])(a0, a1, a2, a3, a4);
    var dynCall_viiiii = Module["dynCall_viiiii"] = (a0, a1, a2, a3, a4, a5) => (dynCall_viiiii = Module["dynCall_viiiii"] = wasmExports["dynCall_viiiii"])(a0, a1, a2, a3, a4, a5);
    var dynCall_iiiiiiii = Module["dynCall_iiiiiiii"] = (a0, a1, a2, a3, a4, a5, a6, a7) => (dynCall_iiiiiiii = Module["dynCall_iiiiiiii"] = wasmExports["dynCall_iiiiiiii"])(a0, a1, a2, a3, a4, a5, a6, a7);
    var dynCall_viiiiiiii = Module["dynCall_viiiiiiii"] = (a0, a1, a2, a3, a4, a5, a6, a7, a8) => (dynCall_viiiiiiii = Module["dynCall_viiiiiiii"] = wasmExports["dynCall_viiiiiiii"])(a0, a1, a2, a3, a4, a5, a6, a7, a8);
    var dynCall_viiiiii = Module["dynCall_viiiiii"] = (a0, a1, a2, a3, a4, a5, a6) => (dynCall_viiiiii = Module["dynCall_viiiiii"] = wasmExports["dynCall_viiiiii"])(a0, a1, a2, a3, a4, a5, a6);
    var dynCall_iiiiiiiiii = Module["dynCall_iiiiiiiiii"] = (a0, a1, a2, a3, a4, a5, a6, a7, a8, a9) => (dynCall_iiiiiiiiii = Module["dynCall_iiiiiiiiii"] = wasmExports["dynCall_iiiiiiiiii"])(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);
    var dynCall_jiji = Module["dynCall_jiji"] = (a0, a1, a2, a3, a4) => (dynCall_jiji = Module["dynCall_jiji"] = wasmExports["dynCall_jiji"])(a0, a1, a2, a3, a4);
    var dynCall_iiiiiii = Module["dynCall_iiiiiii"] = (a0, a1, a2, a3, a4, a5, a6) => (dynCall_iiiiiii = Module["dynCall_iiiiiii"] = wasmExports["dynCall_iiiiiii"])(a0, a1, a2, a3, a4, a5, a6);
    var dynCall_iidiiii = Module["dynCall_iidiiii"] = (a0, a1, a2, a3, a4, a5, a6) => (dynCall_iidiiii = Module["dynCall_iidiiii"] = wasmExports["dynCall_iidiiii"])(a0, a1, a2, a3, a4, a5, a6);
    var dynCall_ji = Module["dynCall_ji"] = (a0, a1) => (dynCall_ji = Module["dynCall_ji"] = wasmExports["dynCall_ji"])(a0, a1);
    var _asyncify_start_unwind = a0 => (_asyncify_start_unwind = wasmExports["asyncify_start_unwind"])(a0);
    var _asyncify_stop_unwind = () => (_asyncify_stop_unwind = wasmExports["asyncify_stop_unwind"])();
    var _asyncify_start_rewind = a0 => (_asyncify_start_rewind = wasmExports["asyncify_start_rewind"])(a0);
    var _asyncify_stop_rewind = () => (_asyncify_stop_rewind = wasmExports["asyncify_stop_rewind"])();
    function invoke_iii(index, a1, a2) {
      var sp = stackSave();
      try {
        return Module["dynCall_iii"](index, a1, a2);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_iiiiiiii(index, a1, a2, a3, a4, a5, a6, a7) {
      var sp = stackSave();
      try {
        return Module["dynCall_iiiiiiii"](index, a1, a2, a3, a4, a5, a6, a7);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_iiii(index, a1, a2, a3) {
      var sp = stackSave();
      try {
        return Module["dynCall_iiii"](index, a1, a2, a3);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_vii(index, a1, a2) {
      var sp = stackSave();
      try {
        Module["dynCall_vii"](index, a1, a2);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_ii(index, a1) {
      var sp = stackSave();
      try {
        return Module["dynCall_ii"](index, a1);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_vi(index, a1) {
      var sp = stackSave();
      try {
        Module["dynCall_vi"](index, a1);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_viiiii(index, a1, a2, a3, a4, a5) {
      var sp = stackSave();
      try {
        Module["dynCall_viiiii"](index, a1, a2, a3, a4, a5);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_iiiii(index, a1, a2, a3, a4) {
      var sp = stackSave();
      try {
        return Module["dynCall_iiiii"](index, a1, a2, a3, a4);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_i(index) {
      var sp = stackSave();
      try {
        return Module["dynCall_i"](index);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_viiii(index, a1, a2, a3, a4) {
      var sp = stackSave();
      try {
        Module["dynCall_viiii"](index, a1, a2, a3, a4);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_v(index) {
      var sp = stackSave();
      try {
        Module["dynCall_v"](index);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_viii(index, a1, a2, a3) {
      var sp = stackSave();
      try {
        Module["dynCall_viii"](index, a1, a2, a3);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_viiiiii(index, a1, a2, a3, a4, a5, a6) {
      var sp = stackSave();
      try {
        Module["dynCall_viiiiii"](index, a1, a2, a3, a4, a5, a6);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_iiiiii(index, a1, a2, a3, a4, a5) {
      var sp = stackSave();
      try {
        return Module["dynCall_iiiiii"](index, a1, a2, a3, a4, a5);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_iiiiiiiiii(index, a1, a2, a3, a4, a5, a6, a7, a8, a9) {
      var sp = stackSave();
      try {
        return Module["dynCall_iiiiiiiiii"](index, a1, a2, a3, a4, a5, a6, a7, a8, a9);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function invoke_iiiiiii(index, a1, a2, a3, a4, a5, a6) {
      var sp = stackSave();
      try {
        return Module["dynCall_iiiiiii"](index, a1, a2, a3, a4, a5, a6);
      } catch (e) {
        stackRestore(sp);
        if (e !== e + 0) throw e;
        _setThrew(1, 0);
      }
    }
    function applySignatureConversions(wasmExports) {
      wasmExports = Object.assign({}, wasmExports);
      var makeWrapper_pp = f => a0 => f(a0) >>> 0;
      var makeWrapper_pppp = f => (a0, a1, a2) => f(a0, a1, a2) >>> 0;
      var makeWrapper_ppp = f => (a0, a1) => f(a0, a1) >>> 0;
      var makeWrapper_p = f => () => f() >>> 0;
      wasmExports["malloc"] = makeWrapper_pp(wasmExports["malloc"]);
      wasmExports["memcpy"] = makeWrapper_pppp(wasmExports["memcpy"]);
      wasmExports["emscripten_builtin_memalign"] = makeWrapper_ppp(wasmExports["emscripten_builtin_memalign"]);
      wasmExports["_emscripten_stack_alloc"] = makeWrapper_pp(wasmExports["_emscripten_stack_alloc"]);
      wasmExports["emscripten_stack_get_current"] = makeWrapper_p(wasmExports["emscripten_stack_get_current"]);
      return wasmExports;
    }
    Module["addRunDependency"] = addRunDependency;
    Module["removeRunDependency"] = removeRunDependency;
    Module["ccall"] = ccall;
    Module["getValue"] = getValue;
    Module["UTF8ToString"] = UTF8ToString;
    Module["lengthBytesUTF8"] = lengthBytesUTF8;
    Module["FS_createPreloadedFile"] = FS_createPreloadedFile;
    Module["FS_unlink"] = FS_unlink;
    Module["FS_createPath"] = FS_createPath;
    Module["FS_createDevice"] = FS_createDevice;
    Module["FS"] = FS;
    Module["FS_createDataFile"] = FS_createDataFile;
    Module["FS_createLazyFile"] = FS_createLazyFile;
    var calledRun;
    dependenciesFulfilled = function runCaller() {
      if (!calledRun) run();
      if (!calledRun) dependenciesFulfilled = runCaller;
    };
    function callMain(args = []) {
      var entryFunction = resolveGlobalSymbol("main").sym;
      if (!entryFunction) return;
      args.unshift(thisProgram);
      var argc = args.length;
      var argv = stackAlloc((argc + 1) * 4);
      var argv_ptr = argv;
      args.forEach(arg => {
        HEAPU32[argv_ptr >>> 2 >>> 0] = stringToUTF8OnStack(arg);
        argv_ptr += 4;
      });
      HEAPU32[argv_ptr >>> 2 >>> 0] = 0;
      try {
        var ret = entryFunction(argc, argv);
        exitJS(ret, true);
        return ret;
      } catch (e) {
        return handleException(e);
      }
    }
    function run(args = arguments_) {
      if (runDependencies > 0) {
        return;
      }
      preRun();
      if (runDependencies > 0) {
        return;
      }
      function doRun() {
        if (calledRun) return;
        calledRun = true;
        Module["calledRun"] = true;
        if (ABORT) return;
        initRuntime();
        preMain();
        readyPromiseResolve(Module);
        if (Module["onRuntimeInitialized"]) Module["onRuntimeInitialized"]();
        if (shouldRunNow) callMain(args);
        postRun();
      }
      if (Module["setStatus"]) {
        Module["setStatus"]("Running...");
        setTimeout(function () {
          setTimeout(function () {
            Module["setStatus"]("");
          }, 1);
          doRun();
        }, 1);
      } else {
        doRun();
      }
    }
    if (Module["preInit"]) {
      if (typeof Module["preInit"] == "function") Module["preInit"] = [Module["preInit"]];
      while (Module["preInit"].length > 0) {
        Module["preInit"].pop()();
      }
    }
    var shouldRunNow = false;
    if (Module["noInitialRun"]) shouldRunNow = false;
    run();
    moduleRtn = readyPromise;
    return moduleRtn;
  };
})();
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (PHP);

/***/ }),

/***/ "../packages/php-cgi-wasm/webTransactions.mjs":
/*!****************************************************!*\
  !*** ../packages/php-cgi-wasm/webTransactions.mjs ***!
  \****************************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   commitTransaction: () => (/* binding */ commitTransaction),
/* harmony export */   startTransaction: () => (/* binding */ startTransaction)
/* harmony export */ });
function startTransaction(wrapper) {
  return wrapper.binary.then(php => {
    if (wrapper.transactionStarted || !php.persist) {
      return Promise.resolve();
    }
    return new Promise((accept, reject) => {
      php.FS.syncfs(true, error => {
        if (error) {
          reject(error);
        } else {
          wrapper.transactionStarted = true;
          accept();
        }
      });
    });
  });
}
function commitTransaction(wrapper) {
  return wrapper.binary.then(php => {
    if (!php.persist) {
      return Promise.resolve();
    }
    if (!wrapper.transactionStarted) {
      throw new Error('No transaction initialized.');
    }
    return new Promise((accept, reject) => {
      php.FS.syncfs(false, error => {
        if (error) {
          reject(error);
        } else {
          wrapper.transactionStarted = false;
          accept();
        }
      });
    });
  });
}

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = __webpack_modules__;
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/global */
/******/ 	(() => {
/******/ 		__webpack_require__.g = (function() {
/******/ 			if (typeof globalThis === 'object') return globalThis;
/******/ 			try {
/******/ 				return this || new Function('return this')();
/******/ 			} catch (e) {
/******/ 				if (typeof window === 'object') return window;
/******/ 			}
/******/ 		})();
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
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
/******/ 	/* webpack/runtime/publicPath */
/******/ 	(() => {
/******/ 		var scriptUrl;
/******/ 		if (__webpack_require__.g.importScripts) scriptUrl = __webpack_require__.g.location + "";
/******/ 		var document = __webpack_require__.g.document;
/******/ 		if (!scriptUrl && document) {
/******/ 			if (document.currentScript)
/******/ 				scriptUrl = document.currentScript.src;
/******/ 			if (!scriptUrl) {
/******/ 				var scripts = document.getElementsByTagName("script");
/******/ 				if(scripts.length) {
/******/ 					var i = scripts.length - 1;
/******/ 					while (i > -1 && (!scriptUrl || !/^http(s?):/.test(scriptUrl))) scriptUrl = scripts[i--].src;
/******/ 				}
/******/ 			}
/******/ 		}
/******/ 		// When supporting browsers where an automatic publicPath is not supported you must specify an output.publicPath manually via configuration
/******/ 		// or pass an empty string ("") and set the __webpack_public_path__ variable from your code to use your own logic.
/******/ 		if (!scriptUrl) throw new Error("Automatic publicPath is not supported in this browser");
/******/ 		scriptUrl = scriptUrl.replace(/#.*$/, "").replace(/\?.*$/, "").replace(/\/[^\/]+$/, "/");
/******/ 		__webpack_require__.p = scriptUrl;
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/importScripts chunk loading */
/******/ 	(() => {
/******/ 		__webpack_require__.b = self.location + "";
/******/ 		
/******/ 		// object to store loaded chunks
/******/ 		// "1" means "already loaded"
/******/ 		var installedChunks = {
/******/ 			"service-worker": 1
/******/ 		};
/******/ 		
/******/ 		// no chunk install function needed
/******/ 		// no chunk loading
/******/ 		
/******/ 		// no HMR
/******/ 		
/******/ 		// no HMR manifest
/******/ 	})();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be in strict mode.
(() => {
"use strict";
/*!****************************!*\
  !*** ./src/cgi-worker.mjs ***!
  \****************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var php_cgi_wasm_PhpCgiWorker_mjs__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! php-cgi-wasm/PhpCgiWorker.mjs */ "../packages/php-cgi-wasm/PhpCgiWorker.mjs");
/* eslint-disable no-restricted-globals */


// Log requests & send lines to all tabs
const onRequest = (request, response) => {
  const url = new URL(request.url);
  const logLine = `[${new Date().toISOString()}]` + `#${php.count} 127.0.0.1 - "${request.method}` + ` ${url.pathname}" - HTTP/1.1 ${response.status}`;
  console.log(logLine);

  // self.clients.matchAll({includeUncontrolled: true}).then(clients => {
  // 	clients.forEach(client => client.postMessage({
  // 		action: 'logRequest',
  // 		params: [logLine, {status: response.status}],
  // 	}))
  // });
};
const notFound = request => {
  return new Response(`<body><h1>404</h1>${request.url} not found</body>`, {
    status: 404,
    headers: {
      'Content-Type': 'text/html'
    }
  });
};

// Spawn the PHP-CGI binary
const php = new php_cgi_wasm_PhpCgiWorker_mjs__WEBPACK_IMPORTED_MODULE_0__.PhpCgiWorker({
  onRequest,
  notFound,
  prefix: '/php-wasm/cgi-bin/',
  docroot: '/persist/www',
  types: {
    jpeg: 'image/jpeg',
    jpg: 'image/jpeg',
    gif: 'image/gif',
    png: 'image/png',
    svg: 'image/svg+xml'
  }
});

// Extras
self.addEventListener('install', event => console.log('Install'));
self.addEventListener('activate', event => console.log('Activate'));

// Set up the event handlers
self.addEventListener('install', event => php.handleInstallEvent(event));
self.addEventListener('activate', event => php.handleActivateEvent(event));
self.addEventListener('fetch', event => php.handleFetchEvent(event));
self.addEventListener('message', event => php.handleMessageEvent(event));
})();

/******/ })()
;
//# sourceMappingURL=cgi-worker.js.map