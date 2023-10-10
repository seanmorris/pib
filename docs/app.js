(function() {
  'use strict';

  var globals = typeof global === 'undefined' ? self : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var aliases = {};
  var has = {}.hasOwnProperty;

  var expRe = /^\.\.?(\/|$)/;
  var expand = function(root, name) {
    var results = [], part;
    var parts = (expRe.test(name) ? root + '/' + name : name).split('/');
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function expanded(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var hot = hmr && hmr.createHot(name);
    var module = {id: name, exports: {}, hot: hot};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var expandAlias = function(name) {
    var val = aliases[name];
    return (val && name !== val) ? expandAlias(val) : name;
  };

  var _resolve = function(name, dep) {
    return expandAlias(expand(dirname(name), dep));
  };

  var require = function(name, loaderPath) {
    if (loaderPath == null) loaderPath = '/';
    var path = expandAlias(name);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    throw new Error("Cannot find module '" + name + "' from '" + loaderPath + "'");
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  var extRe = /\.[^.\/]+$/;
  var indexRe = /\/index(\.[^\/]+)?$/;
  var addExtensions = function(bundle) {
    if (extRe.test(bundle)) {
      var alias = bundle.replace(extRe, '');
      if (!has.call(aliases, alias) || aliases[alias].replace(extRe, '') === alias + '/index') {
        aliases[alias] = bundle;
      }
    }

    if (indexRe.test(bundle)) {
      var iAlias = bundle.replace(indexRe, '');
      if (!has.call(aliases, iAlias)) {
        aliases[iAlias] = bundle;
      }
    }
  };

  require.register = require.define = function(bundle, fn) {
    if (bundle && typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          require.register(key, bundle[key]);
        }
      }
    } else {
      modules[bundle] = fn;
      delete cache[bundle];
      addExtensions(bundle);
    }
  };

  require.list = function() {
    var list = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        list.push(item);
      }
    }
    return list;
  };

  var hmr = globals._hmr && new globals._hmr(_resolve, require, modules, cache);
  require._cache = cache;
  require.hmr = hmr && hmr.wrap;
  require.brunch = true;
  globals.require = require;
})();

(function() {
var global = typeof window === 'undefined' ? this : window;
var __makeRelativeRequire = function(require, mappings, pref) {
  var none = {};
  var tryReq = function(name, pref) {
    var val;
    try {
      val = require(pref + '/node_modules/' + name);
      return val;
    } catch (e) {
      if (e.toString().indexOf('Cannot find module') === -1) {
        throw e;
      }

      if (pref.indexOf('node_modules') !== -1) {
        var s = pref.split('/');
        var i = s.lastIndexOf('node_modules');
        var newPref = s.slice(0, i).join('/');
        return tryReq(name, newPref);
      }
    }
    return none;
  };
  return function(name) {
    if (name in mappings) name = mappings[name];
    if (!name) return;
    if (name[0] !== '.' && pref) {
      var val = tryReq(name, pref);
      if (val !== none) return val;
    }
    return require(name);
  }
};

require.register("php-wasm/PhpBase.js", function(exports, require, module) {
  require = __makeRelativeRequire(require, {}, "php-wasm");
  (function() {
    "use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.PhpBase = void 0;

var _UniqueIndex = require("./UniqueIndex");

function _typeof(obj) { "@babel/helpers - typeof"; if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _createSuper(Derived) { var hasNativeReflectConstruct = _isNativeReflectConstruct(); return function _createSuperInternal() { var Super = _getPrototypeOf(Derived), result; if (hasNativeReflectConstruct) { var NewTarget = _getPrototypeOf(this).constructor; result = Reflect.construct(Super, arguments, NewTarget); } else { result = Super.apply(this, arguments); } return _possibleConstructorReturn(this, result); }; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _wrapNativeSuper(Class) { var _cache = typeof Map === "function" ? new Map() : undefined; _wrapNativeSuper = function _wrapNativeSuper(Class) { if (Class === null || !_isNativeFunction(Class)) return Class; if (typeof Class !== "function") { throw new TypeError("Super expression must either be null or a function"); } if (typeof _cache !== "undefined") { if (_cache.has(Class)) return _cache.get(Class); _cache.set(Class, Wrapper); } function Wrapper() { return _construct(Class, arguments, _getPrototypeOf(this).constructor); } Wrapper.prototype = Object.create(Class.prototype, { constructor: { value: Wrapper, enumerable: false, writable: true, configurable: true } }); return _setPrototypeOf(Wrapper, Class); }; return _wrapNativeSuper(Class); }

function _construct(Parent, args, Class) { if (_isNativeReflectConstruct()) { _construct = Reflect.construct; } else { _construct = function _construct(Parent, args, Class) { var a = [null]; a.push.apply(a, args); var Constructor = Function.bind.apply(Parent, a); var instance = new Constructor(); if (Class) _setPrototypeOf(instance, Class.prototype); return instance; }; } return _construct.apply(null, arguments); }

function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

function _isNativeFunction(fn) { return Function.toString.call(fn).indexOf("[native code]") !== -1; }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

var STR = 'string';
var NUM = 'number';

var PhpBase = /*#__PURE__*/function (_EventTarget) {
  _inherits(PhpBase, _EventTarget);

  var _super = _createSuper(PhpBase);

  function PhpBase(PhpBinary) {
    var _this;

    var args = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

    _classCallCheck(this, PhpBase);

    _this = _super.call(this);
    var FLAGS = {};

    _this.onerror = function () {};

    _this.onoutput = function () {};

    _this.onready = function () {};

    var callbacks = new _UniqueIndex.UniqueIndex();
    var targets = new _UniqueIndex.UniqueIndex();
    var defaults = {
      callbacks: callbacks,
      targets: targets,
      postRun: function postRun() {
        var event = new CustomEvent('ready');

        _this.onready(event);

        _this.dispatchEvent(event);
      },
      print: function print() {
        for (var _len = arguments.length, chunks = new Array(_len), _key = 0; _key < _len; _key++) {
          chunks[_key] = arguments[_key];
        }

        var event = new CustomEvent('output', {
          detail: chunks.map(function (c) {
            return c + "\n";
          })
        });

        _this.onoutput(event);

        _this.dispatchEvent(event);
      },
      printErr: function printErr() {
        for (var _len2 = arguments.length, chunks = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
          chunks[_key2] = arguments[_key2];
        }

        var event = new CustomEvent('error', {
          detail: chunks.map(function (c) {
            return c + "\n";
          })
        });

        _this.onerror(event);

        _this.dispatchEvent(event);
      }
    };
    var phpSettings = window && window.phpSettings ? window.phpSettings : {};
    _this.binary = new PhpBinary(Object.assign({}, defaults, phpSettings, args)).then(function (php) {
      var retVal = php.ccall('pib_init', NUM, [STR], []);
      return php;
    })["catch"](function (error) {
      return console.error(error);
    });
    return _this;
  }

  _createClass(PhpBase, [{
    key: "run",
    value: function run(phpCode) {
      return this.binary.then(function (php) {
        return php.ccall('pib_run', NUM, [STR], ["?>".concat(phpCode)]);
      });
    }
  }, {
    key: "exec",
    value: function exec(phpCode) {
      return this.binary.then(function (php) {
        return php.ccall('pib_exec', STR, [STR], [phpCode]);
      });
    }
  }, {
    key: "refresh",
    value: function refresh() {
      var call = this.binary.then(function (php) {
        return php.ccall('pib_refresh', NUM, [], []);
      });
      call["catch"](function (error) {
        return console.error(error);
      });
      return call;
    }
  }]);

  return PhpBase;
}( /*#__PURE__*/_wrapNativeSuper(EventTarget));

exports.PhpBase = PhpBase;
  })();
});

require.register("php-wasm/PhpWebDrupal.js", function(exports, require, module) {
  require = __makeRelativeRequire(require, {}, "php-wasm");
  (function() {
    "use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.PhpWebDrupal = void 0;

var _PhpBase2 = require("./PhpBase");

function _typeof(obj) { "@babel/helpers - typeof"; if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }

function _createSuper(Derived) { var hasNativeReflectConstruct = _isNativeReflectConstruct(); return function _createSuperInternal() { var Super = _getPrototypeOf(Derived), result; if (hasNativeReflectConstruct) { var NewTarget = _getPrototypeOf(this).constructor; result = Reflect.construct(Super, arguments, NewTarget); } else { result = Super.apply(this, arguments); } return _possibleConstructorReturn(this, result); }; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

var PhpBinary = require('./php-web-drupal');

var PhpWebDrupal = /*#__PURE__*/function (_PhpBase) {
  _inherits(PhpWebDrupal, _PhpBase);

  var _super = _createSuper(PhpWebDrupal);

  function PhpWebDrupal() {
    var args = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};

    _classCallCheck(this, PhpWebDrupal);

    return _super.call(this, PhpBinary, args);
  }

  return PhpWebDrupal;
}(_PhpBase2.PhpBase);

exports.PhpWebDrupal = PhpWebDrupal;

if (window && document) {
  var php = new PhpWebDrupal();

  var runScriptTag = function runScriptTag(element) {
    var src = element.getAttribute('src');

    if (src) {
      fetch(src).then(function (r) {
        return r.text();
      }).then(function (r) {
        php.run(r).then(function (exit) {
          return console.log(exit);
        });
      });
      return;
    }

    var inlineCode = element.innerText.trim();

    if (inlineCode) {
      php.run(inlineCode);
    }
  };

  php.addEventListener('ready', function () {
    var phpSelector = 'script[type="text/php"]';
    var htmlNode = document.body.parentElement;
    var observer = new MutationObserver(function (mutations, observer) {
      var _iterator = _createForOfIteratorHelper(mutations),
          _step;

      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var mutation = _step.value;

          var _iterator2 = _createForOfIteratorHelper(mutation.addedNodes),
              _step2;

          try {
            for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
              var addedNode = _step2.value;

              if (!addedNode.matches || !addedNode.matches(phpSelector)) {
                continue;
              }

              runScriptTag(addedNode);
            }
          } catch (err) {
            _iterator2.e(err);
          } finally {
            _iterator2.f();
          }
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }
    });
    observer.observe(htmlNode, {
      childList: true,
      subtree: true
    });
    var phpNodes = document.querySelectorAll(phpSelector);

    var _iterator3 = _createForOfIteratorHelper(phpNodes),
        _step3;

    try {
      for (_iterator3.s(); !(_step3 = _iterator3.n()).done;) {
        var phpNode = _step3.value;
        var code = phpNode.innerText.trim();
        runScriptTag(phpNode);
      }
    } catch (err) {
      _iterator3.e(err);
    } finally {
      _iterator3.f();
    }
  });
}
  })();
});

require.register("php-wasm/UniqueIndex.js", function(exports, require, module) {
  require = __makeRelativeRequire(require, {}, "php-wasm");
  (function() {
    "use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.UniqueIndex = void 0;

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var UniqueIndex = function UniqueIndex() {
  _classCallCheck(this, UniqueIndex);

  var map = new Map();
  var set = new WeakMap();
  var id = 0;
  Object.defineProperty(this, 'add', {
    configurable: false,
    writable: false,
    value: function value(callback) {
      var existing = set.has(callback);

      if (existing) {
        return existing;
      }

      var newid = ++id;
      set.set(callback, newid);
      map.set(newid, callback);
      return newid;
    }
  });
  Object.defineProperty(this, 'has', {
    configurable: false,
    writable: false,
    value: function value(callback) {
      if (set.has(callback)) {
        return set.get(callback);
      }
    }
  });
  Object.defineProperty(this, 'get', {
    configurable: false,
    writable: false,
    value: function value(id) {
      if (map.has(id)) {
        return map.get(id);
      }
    }
  });
  Object.defineProperty(this, 'remove', {
    configurable: false,
    writable: false,
    value: function value(id) {
      var callback = map.get(id);

      if (callback) {
        set["delete"](callback);
        map["delete"](id);
      }
    }
  });
};

exports.UniqueIndex = UniqueIndex;
  })();
});
require.register("initialize.js", function(exports, require, module) {
"use strict";

var _PhpWebDrupal = require("php-wasm/PhpWebDrupal");
function _createForOfIteratorHelper(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (!it) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = it.call(o); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }
function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }
function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) arr2[i] = arr[i]; return arr2; }
window.PHP = _PhpWebDrupal.PhpWebDrupal;
var php = new _PhpWebDrupal.PhpWebDrupal();
var session_id = '';
var serviceWorker = navigator.serviceWorker;
if (serviceWorker) {
  serviceWorker.register("".concat(location.pathname, "DrupalWorker.js"));
  // .then(result => console.log('Result, ', result))
  // .catch(error => console.log('Error, ', error));
}

document.addEventListener('DOMContentLoaded', function () {
  var input = document.querySelector('.input  textarea');
  var stdout = document.querySelector('.stdout > * > div.scroller');
  var stderr = document.querySelector('.stderr > * > div.scroller');
  var stdret = document.querySelector('.stdret > * > div.scroller');
  var run = document.querySelector('[data-run]');
  var token = document.querySelector('[data-tokenize]');
  var status = document.querySelector('[data-status]');
  var load = document.querySelector('[data-load-demo]');
  var demo = document.querySelector('[data-select-demo]');
  var editor = ace.edit(input);
  var ret = document.querySelector('#ret');
  var stdoutFrame = document.querySelector('.stdout > * > iframe');
  var stderrFrame = document.querySelector('.stderr > * > iframe');
  var stdretFrame = document.querySelector('.stdret > * > iframe');
  var openFile = document.getElementById('openFile');
  var exitBox = document.querySelector('#exit');
  var exitLabel = exitBox.querySelector('span');
  var persistBox = document.getElementById('persist');
  var singleBox = document.getElementById('singleExpression');
  var autorun = document.querySelector('#autorun');
  var renderAs = Array.from(document.querySelectorAll('[name=render-as]'));
  openFile.addEventListener('input', function (event) {
    var reader = new FileReader();
    reader.onload = function (event) {
      editor.setValue(event.target.result);
    };
    reader.readAsText(event.target.files[0]);
  });
  var runCode = function runCode() {
    exitLabel.innerText = '_';
    status.innerText = 'Executing...';
    stdoutFrame.srcdoc = ' ';
    stderrFrame.srcdoc = ' ';
    stdretFrame.srcdoc = ' ';
    while (stdout.firstChild) {
      stdout.firstChild.remove();
    }
    while (stderr.firstChild) {
      stderr.firstChild.remove();
    }
    while (stdret.firstChild) {
      stdret.firstChild.remove();
    }
    var code = editor.session.getValue();
    if (code.length < 1024 * 2) {
      query.set('autorun', autorun.checked ? 1 : 0);
      query.set('persist', persistBox.checked ? 1 : 0);
      query.set('single-expression', singleBox.checked ? 1 : 0);
      query.set('code', encodeURIComponent(code));
      history.replaceState({}, document.title, "?" + query.toString());
    }
    var func = singleBox.checked ? 'exec' : 'run';
    if (singleBox.checked) {
      code = code.replace(/^\s*<\?php/, '');
      code = code.replace(/\?>\s*/, '');
    }
    php[func](code).then(function (ret) {
      status.innerText = 'php-wasm ready!';
      var content = String(ret);
      stdret.innerText = content;
      stdretFrame.srcdoc = content;
      exitLabel.innerText = '_';
      if (!singleBox.checked) {
        setTimeout(function () {
          return exitLabel.innerText = ret;
        }, 100);
      }
    })["finally"](function () {
      if (!persistBox.checked) {
        php.refresh();
      }
    });
  };
  load.addEventListener('click', function (event) {
    if (!demo.value) {
      return;
    }
    fetch("/php-wasm/scripts/".concat(demo.value)).then(function (r) {
      return r.text();
    }).then(function (php) {
      var firstLine = String(php.split(/\n/).shift());
      var settings = JSON.parse(firstLine.split('//').pop());
      if ('autorun' in settings) {
        autorun.checked = !!settings.autorun;
      }
      if ('single-expression' in settings) {
        singleBox.checked = !!settings['single-expression'];
      }
      if ('persist' in settings) {
        persistBox.checked = !!settings.persist;
      }
      if ('render-as' in settings) {
        if (settings['render-as'] === 'text') {
          renderAs[0].checked = true;
          renderAs[0].dispatchEvent(new Event('change'));
          query.set('render-as', 'text');
        } else if (settings['render-as'] === 'html') {
          renderAs[1].checked = true;
          renderAs[1].dispatchEvent(new Event('change'));
          query.set('render-as', 'html');
        }
      }
      persistBox.dispatchEvent(new Event('change'));
      singleBox.dispatchEvent(new Event('input'));
      autorun.dispatchEvent(new Event('change'));
      history.replaceState({}, document.title, "?" + query.toString());
      editor.getSession().setValue(php);
      setTimeout(function () {
        return runCode();
      }, 100);
    });
  });
  var query = new URLSearchParams(location.search);
  editor.setTheme('ace/theme/monokai');
  editor.session.setMode("ace/mode/php");
  status.innerText = 'php-wasm loading...';
  var navigate = function navigate(_ref) {
    var path = _ref.path,
      method = _ref.method,
      _GET = _ref._GET,
      _POST = _ref._POST;
    // console.trace({path, method, _GET, _POST});

    exitLabel.innerText = '_';
    status.innerText = 'Executing...';
    stdoutFrame.srcdoc = ' ';
    stderrFrame.srcdoc = ' ';
    stdretFrame.srcdoc = ' ';
    while (stdout.firstChild) {
      stdout.firstChild.remove();
    }
    while (stderr.firstChild) {
      stderr.firstChild.remove();
    }
    while (stdret.firstChild) {
      stdret.firstChild.remove();
    }
    var code = "<?php\nini_set('session.save_path', '/home/web_user');\n\n$stdErr = fopen('php://stderr', 'w');\n$errors = [];\n\nfwrite($stdErr, isset($_SESSION) && json_encode(['session' => $_SESSION]) . \"\n\");\n\nregister_shutdown_function(function() use($stdErr){\n\tfwrite($stdErr, json_encode(['session_id' => session_id()]) . \"\n\");\n\tfwrite($stdErr, json_encode(['headers'=>headers_list()]) . \"\n\");\n\tfwrite($stdErr, json_encode(['errors' => error_get_last()]) . \"\n\");\n\tfwrite($stdErr, json_encode(['session' => $_SESSION]) . \"\n\");\n});\n\nset_error_handler(function(...$args) use($stdErr, &$errors){\n\tfwrite($stdErr, json_encode($args, JSON_PRETTY_PRINT) . \"\n\" );\n});\n\n$request = (object) json_decode(\n\t'".concat(JSON.stringify({
      path: path,
      method: method,
      _GET: _GET,
      _POST: _POST
    }), "'\n\t, JSON_OBJECT_AS_ARRAY\n);\n\nparse_str(substr($request->_GET, 1), $_GET);\n\n$_POST = $request->_POST;\n\n$origin  = 'http://localhost:3333';\n$docroot = '/preload/drupal-7.59';\n$script  = 'index.php';\n\n$path = $request->path;\n$path = preg_replace('/^\\/php-wasm/', '', $path);\n\n$_SERVER['SERVER_SOFTWARE'] = ").concat(JSON.stringify(navigator.userAgent), ";\n$_SERVER['REQUEST_URI']     = $path;\n$_SERVER['REMOTE_ADDR']     = '127.0.0.1';\n$_SERVER['SERVER_NAME']     = $origin;\n$_SERVER['SERVER_PORT']     = 3333;\n$_SERVER['REQUEST_METHOD']  = $request->method;\n$_SERVER['SCRIPT_FILENAME'] = $docroot . '/' . $script;\n$_SERVER['SCRIPT_NAME']     = $docroot . '/' . $script;\n$_SERVER['PHP_SELF']        = $docroot . '/' . $script;\n$_SERVER['DOCUMENT_ROOT']   = '/';\n$_SERVER['HTTPS']           = '';\n\nchdir($docroot);\n\ndefine('DRUPAL_ROOT', getcwd());\n\nrequire_once DRUPAL_ROOT . '/includes/bootstrap.inc';\ndrupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);\n\n$uid     = 1;\n$user    = user_load($uid);\n$account = array('uid' => $user->uid);\nuser_login_submit(array(), $account);\n\n$itemPath = $path;\n$itemPath = preg_replace('/^\\/preload/', '', $itemPath);\n$itemPath = preg_replace('/^\\/drupal-7.59/', '', $itemPath);\n$itemPath = preg_replace('/^\\//', '', $itemPath);\n\nif($itemPath && (substr($itemPath, 0, 4) !== 'node' || substr($itemPath, -4) === 'edit'))\n{\n    $router_item = menu_get_item($itemPath);\n    $router_item['access_callback'] = true;\n    $router_item['access'] = true;\n\n    if ($router_item['include_file']) {\n      require_once DRUPAL_ROOT . '/' . $router_item['include_file'];\n    }\n\n    $page_callback_result = call_user_func_array(\n    \t$router_item['page_callback']\n    \t, is_string($router_item['page_arguments'])\n    \t\t? unserialize($router_item['page_arguments'])\n    \t\t: $router_item['page_arguments']\n    );\n\n    drupal_deliver_page($page_callback_result);\n}\nelse\n{\n    menu_execute_active_handler();\n}");
    php.run(code).then(function (exitCode) {
      exitLabel.innerText = exitCode;
      status.innerText = 'php-wasm ready!';
    })["finally"](function () {
      if (!persistBox.checked) {
        php.refresh();
      }
    });
  };
  php.addEventListener('ready', function (event) {
    if (serviceWorker) {
      serviceWorker.addEventListener('message', function (event) {
        return navigate(event.data);
      });
    }
    status.innerText = 'php-wasm ready!';
    run.removeAttribute('disabled');
    token && token.addEventListener('click', function () {
      var url = '/drupal-7.59/install.php';
      var options = {
        method: 'GET'
      };
      fetch(url, options).then(function (r) {
        return r.text();
      }).then(function (r) {
        console.log('Done');
      });
    });
    run.addEventListener('click', runCode);
    if (query.get('autorun')) {
      runCode();
    }
  });
  var outputBuffer = [];
  php.addEventListener('output', function (event) {
    var row = document.createElement('div');
    var content = event.detail.join('');
    outputBuffer.push(content);
    setTimeout(function () {
      var chunk = outputBuffer.join('');
      if (!outputBuffer || !chunk) {
        return;
      }
      if (location.hostname.match(/github.io$/)) {
        chunk = chunk.replace(/\/preload/g, '/php-wasm/preload');
      }
      var node = document.createTextNode(chunk);
      stdout.append(node);
      stdoutFrame.srcdoc += chunk;
      while (outputBuffer.pop()) {}
      ;
    }, 500);
  });
  var errorBuffer = [];
  php.addEventListener('error', function (event) {
    var content = event.detail.join(" ");
    try {
      var headers = JSON.parse(content);
      if (headers.session_id) {
        session_id = headers.session_id;
      }
      if (headers.headers) {
        var _iterator = _createForOfIteratorHelper(headers.headers),
          _step;
        try {
          var _loop = function _loop() {
            var header = _step.value;
            var splitAt = header.indexOf(':');
            var _ref2 = [header.substring(0, splitAt), header.substring(splitAt + 2)],
              name = _ref2[0],
              value = _ref2[1];
            if (name === 'Location') {
              console.log(value);
              var redirectUrl = new URL(value);
              setTimeout(function () {
                return navigate({
                  method: 'GET',
                  path: redirectUrl.pathname,
                  _GET: '',
                  _POST: {}
                });
              }, 2000);
            }
          };
          for (_iterator.s(); !(_step = _iterator.n()).done;) {
            _loop();
          }
        } catch (err) {
          _iterator.e(err);
        } finally {
          _iterator.f();
        }
      }
    } catch (error) {}
    var _iterator2 = _createForOfIteratorHelper(content),
      _step2;
    try {
      for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
        var line = _step2.value;
        errorBuffer.push(line);
        setTimeout(function () {
          var chunk = errorBuffer.join('');
          if (!errorBuffer || !chunk) {
            return;
          }
          var node = document.createTextNode(chunk);
          stderr.append(node);
          stderrFrame.srcdoc += chunk;
          while (errorBuffer.pop()) {}
          ;
        }, 500);
      }
    } catch (err) {
      _iterator2.e(err);
    } finally {
      _iterator2.f();
    }
  });
  ret.style.display = 'none';
  singleBox.addEventListener('input', function (event) {
    if (event.target.checked) {
      exitBox.style.display = 'none';
      ret.style.display = 'flex';
    } else {
      exitBox.style.display = 'flex';
      ret.style.display = 'none';
    }
  });
  exitLabel.innerText = '_';
  if (query.has('code')) {
    editor.setValue(decodeURIComponent(query.get('code')));
  }
  if (query.has('render-as')) {
    document.querySelector("[name=render-as][value=".concat(query.get('render-as'), "]")).checked = true;
  }
  autorun.checked = Number(query.get('autorun'));
  persistBox.checked = Number(query.get('persist'));
  singleBox.checked = Number(query.get('single-expression'));
  if (singleBox.checked) {
    exitBox.style.display = 'none';
    ret.style.display = 'flex';
  } else {
    exitBox.style.display = 'flex';
    ret.style.display = 'none';
  }
  setTimeout(function () {
    return editor.selection.moveCursorFileStart();
  }, 150);
  renderAs.map(function (radio) {
    if (query.get('render-as') === 'html') {
      stdout.style.display = 'none';
      stdoutFrame.style.display = 'flex';
      stderr.style.display = 'none';
      stderrFrame.style.display = 'flex';
      stdret.style.display = 'none';
      stdretFrame.style.display = 'flex';
    } else {
      stdout.style.display = 'flex';
      stdoutFrame.style.display = 'none';
      stderr.style.display = 'flex';
      stderrFrame.style.display = 'none';
      stdret.style.display = 'flex';
      stdretFrame.style.display = 'none';
    }
    radio.addEventListener('change', function (event) {
      var type = event.target.value;
      query.set('render-as', type);
      history.replaceState({}, document.title, "?" + query.toString());
      if (type === 'html') {
        stdout.style.display = 'none';
        stdoutFrame.style.display = 'flex';
        stderr.style.display = 'none';
        stderrFrame.style.display = 'flex';
        stdret.style.display = 'none';
        stdretFrame.style.display = 'flex';
      } else {
        stdout.style.display = 'flex';
        stdoutFrame.style.display = 'none';
        stderr.style.display = 'flex';
        stderrFrame.style.display = 'none';
        stdret.style.display = 'flex';
        stdretFrame.style.display = 'none';
      }
    });
  });
});

});

require.register("___globals___", function(exports, require, module) {
  
});})();require('___globals___');

