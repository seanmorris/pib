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
require.register("initialize.js", function(exports, require, module) {
"use strict";

var _PhpWebDrupal = require("php-wasm/PhpWebDrupal");
function _createForOfIteratorHelper(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (!it) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = it.call(o); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }
function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }
function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) arr2[i] = arr[i]; return arr2; }
var session_id = '';
var serviceWorker = navigator.serviceWorker;
serviceWorker.register("".concat(location.pathname, "DrupalWorker.js"));
if (serviceWorker && !serviceWorker.controller) {
  // location.reload();
}
var php = new _PhpWebDrupal.PhpWebDrupal({
  persist: {
    mountPath: '/persist'
  }
});
window.php = php;
document.addEventListener('DOMContentLoaded', function () {
  var input = document.querySelector('.input  textarea');
  var stdout = document.querySelector('.stdout > * > div.scroller');
  var stderr = document.querySelector('.stderr > * > div.scroller');
  var stdret = document.querySelector('.stdret > * > div.scroller');
  var run = document.querySelector('[data-run]');
  var reset = document.querySelector('[data-reset-storage]');
  var refresh = document.querySelector('[data-refresh]');
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
  var outputBuffer = [];
  var errorBuffer = [];
  var outputTimer;
  var errorTimer;
  reset.addEventListener('click', function (event) {
    var openDb = indexedDB.open("/persist", 21);
    openDb.onsuccess = function (event) {
      var db = openDb.result;
      var transaction = db.transaction(["FILE_DATA"], "readwrite");
      var objectStore = transaction.objectStore("FILE_DATA");
      var objectStoreRequest = objectStore.clear();
      objectStoreRequest.onsuccess = function (event) {
        location.reload();
      };
    };
  });
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
    if (1 || code.length < 1024 * 2) {
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
    var refresh = Promise.resolve();
    if (!persistBox.checked) {
      refresh = refreshPhp();
    }
    run.setAttribute('disabled', 'disabled');
    refresh.then(function () {
      return php[func](code);
    }).then(function (ret) {
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
      return run.removeAttribute('disabled');
    });
  };
  demo.addEventListener('change', function (event) {
    if (!demo.value) {
      return;
    }
    if (demo.value === 'drupal.php') {
      reset.style.display = '';
    } else {
      reset.style.display = 'none';
    }
  });
  var loadDemo = function loadDemo() {
    document.querySelector('#example').innerHTML = '';
    refreshPhp(2).then(function () {
      if (!demo.value) {
        return;
      }
      var scriptPath = '/php-wasm/scripts';
      if (window.location.hostname === 'localhost' || window.location.hostname.substr(0, 4) === '192.') {
        scriptPath = '/scripts';
      }
      fetch("".concat(scriptPath, "/").concat(demo.value)).then(function (r) {
        return r.text();
      }).then(function (phpCode) {
        var firstLine = String(phpCode.split(/\n/).shift());
        var settings = JSON.parse(firstLine.split('//').pop());
        query.set('demo', demo.value);
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
        editor.getSession().setValue(phpCode);
        refreshPhp().then(function () {
          return runCode();
        });
      });
    });
  };
  load.addEventListener('click', function (event) {
    return loadDemo();
  });
  var query = new URLSearchParams(location.search);
  editor.setTheme('ace/theme/monokai');
  editor.session.setMode("ace/mode/php");
  status.innerText = 'php-wasm loading...';
  var cookieJar = new Map();
  var navigate = function navigate(_ref) {
    var action = _ref.action,
      clientId = _ref.clientId,
      path = _ref.path,
      method = _ref.method,
      _GET = _ref._GET,
      _POST = _ref._POST;
    if (action !== 'respond') {
      return;
    }

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
    var code = "<?php\nini_set('session.save_path', '/persist');\nini_set('display_errors', 0);\n\n$stdErr = fopen('php://stderr', 'w');\n$errors = [];\n\n$request = (object) json_decode(\n\t'".concat(JSON.stringify({
      path: path,
      method: method,
      _GET: _GET,
      _POST: _POST,
      _COOKIE: Object.fromEntries(cookieJar.entries())
    }), "'\n\t, JSON_OBJECT_AS_ARRAY\n);\n\nparse_str(substr($request->_GET, 1), $_GET);\nparse_str(substr($request->_POST, 1), $_POST);\n\n$_COOKIE = $request->_COOKIE;\n\nfwrite($stdErr, json_encode(['_GET' => $_GET]) . PHP_EOL);\nfwrite($stdErr, json_encode(['_POST' => $_POST]) . PHP_EOL);\n\n$docroot = '/persist/drupal-7.95';\n$script  = 'index.php';\n\n$path = $request->path;\n$path = preg_replace('/^\\/php-wasm/', '', $path);\n$path = preg_replace('/^\\/persist/', '', $path);\n$path = preg_replace('/^\\/drupal-7.95/', '', $path);\n$path = preg_replace('/^\\//', '', $path);\n$path = $path ?: \"node\";\n\n$_SERVER['SERVER_SOFTWARE'] = ").concat(JSON.stringify(navigator.userAgent), ";\n$_SERVER['REQUEST_URI']     = '/php-wasm' . $docroot . '/' . $path;\n$_SERVER['QUERY_STRING']    = $request->_GET;\n$_SERVER['REMOTE_ADDR']     = '127.0.0.1';\n$_SERVER['SERVER_NAME']     = 'localhost';\n$_SERVER['SERVER_PORT']     = 3333;\n$_SERVER['REQUEST_METHOD']  = $request->method;\n$_SERVER['SCRIPT_FILENAME'] = $docroot . '/' . $script;\n$_SERVER['SCRIPT_NAME']     = $docroot . '/' . $script;\n$_SERVER['PHP_SELF']        = $docroot . '/' . $script;\n\nchdir($docroot);\n\nif(!defined('DRUPAL_ROOT')) define('DRUPAL_ROOT', getcwd());\n\nrequire_once DRUPAL_ROOT . '/includes/bootstrap.inc';\ndrupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);\ndrupal_session_start();\n\nfwrite($stdErr, json_encode(['session_id' => session_id()]) . \"\n\");\n\nglobal $user;\n\n$uid     = 1;\n$user    = user_load($uid);\n$account = array('uid' => $user->uid);\n\n$session_name = session_name();\nif(!$_COOKIE || !$_COOKIE[$session_name])\n{\n\tuser_login_submit(array(), $account);\n}\n\nfwrite($stdErr, json_encode(['PATH' => $path, \"ORIGINAL\" => $request->path]) . PHP_EOL);\n\n$GLOBALS['base_path'] = '/php-wasm' . $docroot . '/';\n$base_url = '/php-wasm' . $docroot;\n\n$_GET['q'] = $path;\n\nmenu_execute_active_handler();\n\nfwrite($stdErr, json_encode(['HEADERS' =>headers_list()]) . \"\n\");\nfwrite($stdErr, json_encode(['COOKIE'  => $_COOKIE]) . PHP_EOL);\nfwrite($stdErr, json_encode(['errors'  => error_get_last()]) . \"\n\");\n");
    refreshPhp().then(function () {
      return php.run(code);
    }).then(function (exitCode) {
      exitLabel.innerText = exitCode;
      status.innerText = 'php-wasm ready!';
    })["catch"](function (error) {
      return console.error(error);
    });
  };
  var _init = true;
  var ready = function ready(event) {
    document.body.classList.remove('loading');
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

    // refresh.addEventListener('click', () => void php.refresh());

    if (_init && _init !== 2 && query.get('autorun')) {
      runCode();
    }
  };
  var output = function output(event) {
    var content = event.detail.join('');
    outputBuffer.push(content);
    if (outputTimer) {
      clearTimeout(outputTimer);
      outputTimer = null;
    }
    outputTimer = setTimeout(function () {
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
      outputBuffer.splice(0);
    }, 50);
  };
  var error = function error(event) {
    var content = event.detail.join('');
    var packet = {};
    try {
      Object.assign(packet, JSON.parse(content));
    } catch (error) {/*console.error(error);*/}
    if (packet.HEADERS) {
      var raw = packet.HEADERS;
      var headers = {};
      var _iterator = _createForOfIteratorHelper(raw),
        _step;
      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var line = _step.value;
          line = String(line);
          var colon = line.indexOf(':');
          if (colon >= 0) {
            headers[line.substr(0, colon)] = line.substr(2 + colon);
          } else {
            headers[line] = true;
          }
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }
      if ((headers[302] || headers[303]) && headers.Location) {
        var redirectUrl = headers.Location;
        var _GET = redirectUrl.search;
        navigate({
          method: 'GET',
          path: redirectUrl.pathname,
          _GET: '',
          _POST: ''
        });
      }
      if (headers['Set-Cookie']) {
        var _raw = headers['Set-Cookie'];
        var semi = _raw.indexOf(';');
        var equal = _raw.indexOf('=');
        var key = _raw.substr(0, equal);
        var value = _raw.substr(equal, semi - equal);
        cookieJar.set(key, value);
      }
    }
    errorBuffer.push(content);
    if (errorTimer) {
      clearTimeout(errorTimer);
      errorTimer = null;
    }
    errorTimer = setTimeout(function () {
      errorTimer = null;
      var chunk = errorBuffer.join('');
      if (!errorBuffer || !chunk) {
        return;
      }
      var node = document.createTextNode(chunk);
      stderr.append(node);
      stderrFrame.srcdoc += chunk;
      errorBuffer.splice(0);
    }, 50);
  };
  var onNavigate = function onNavigate(event) {
    return navigate(event.data);
  };
  var refreshPhp = function refreshPhp() {
    var init = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : false;
    _init = init;
    if (init) {
      window.addEventListener('message', onNavigate);
      if (php) {
        php.removeEventListener('ready', ready);
        php.removeEventListener('output', output);
        php.removeEventListener('error', error);
      }
      window.php = php = new _PhpWebDrupal.PhpWebDrupal({
        persist: {
          mountPath: '/persist'
        }
      });
      php.addEventListener('ready', ready);
      php.addEventListener('output', output);
      php.addEventListener('error', error);
      return php.binary;
    } else {
      return php.refresh();
    }
  };
  refreshPhp(true);
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
  var rewriteDemo = "%3C%3Fphp%0Aini_set('session.save_path'%2C%20'%2Fhome%2Fweb_user')%3B%0A%0A%24stdErr%20%3D%20fopen('php%3A%2F%2Fstderr'%2C%20'w')%3B%0A%24errors%20%3D%20%5B%5D%3B%0A%0Aregister_shutdown_function(function()%20use(%24stdErr%2C%20%26%24errors)%7B%0A%20%20%20%20fwrite(%24stdErr%2C%20json_encode(%5B'session_id'%20%3D%3E%20session_id()%5D)%20.%20%22%5Cn%22)%3B%0A%20%20%20%20fwrite(%24stdErr%2C%20json_encode(%5B'headers'%3D%3Eheaders_list()%5D)%20.%20%22%5Cn%22)%3B%0A%20%20%20%20fwrite(%24stdErr%2C%20json_encode(%5B'errors'%20%3D%3E%20error_get_last()%5D)%20.%20%22%5Cn%22)%3B%0A%7D)%3B%0A%0Aset_error_handler(function(...%24args)%20use(%24stdErr%2C%20%26%24errors)%7B%0A%09fwrite(%24stdErr%2C%20print_r(%24args%2C1))%3B%0A%7D)%3B%0A%0A%24docroot%20%3D%20'%2Fpreload%2Fdrupal-7.59'%3B%0A%24path%20%20%20%20%3D%20'%2F'%3B%0A%24script%20%20%3D%20'index.php'%3B%0A%0A%24_SERVER%5B'REQUEST_URI'%5D%20%20%20%20%20%3D%20%24docroot%20.%20%24path%3B%0A%24_SERVER%5B'REMOTE_ADDR'%5D%20%20%20%20%20%3D%20'127.0.0.1'%3B%0A%24_SERVER%5B'SERVER_NAME'%5D%20%20%20%20%20%3D%20'localhost'%3B%0A%24_SERVER%5B'SERVER_PORT'%5D%20%20%20%20%20%3D%203333%3B%0A%24_SERVER%5B'REQUEST_METHOD'%5D%20%20%3D%20'GET'%3B%0A%24_SERVER%5B'SCRIPT_FILENAME'%5D%20%3D%20%24docroot%20.%20'%2F'%20.%20%24script%3B%0A%24_SERVER%5B'SCRIPT_NAME'%5D%20%20%20%20%20%3D%20%24docroot%20.%20'%2F'%20.%20%24script%3B%0A%24_SERVER%5B'PHP_SELF'%5D%20%20%20%20%20%20%20%20%3D%20%24docroot%20.%20'%2F'%20.%20%24script%3B%0A%0Achdir(%24docroot)%3B%0A%0Aob_start()%3B%0A%0Adefine('DRUPAL_ROOT'%2C%20getcwd())%3B%0A%0Arequire_once%20DRUPAL_ROOT%20.%20'%2Fincludes%2Fbootstrap.inc'%3B%0Adrupal_bootstrap(DRUPAL_BOOTSTRAP_FULL)%3B%0A%0A%24uid%20%20%20%20%20%3D%201%3B%0A%24user%20%20%20%20%3D%20user_load(%24uid)%3B%0A%24account%20%3D%20array('uid'%20%3D%3E%20%24user-%3Euid)%3B%0Auser_login_submit(array()%2C%20%24account)%3B%0A%0A%24itemPath%20%3D%20%24path%3B%0A%24itemPath%20%3D%20preg_replace('%2F%5E%5C%5C%2Fpreload%2F'%2C%20''%2C%20%24itemPath)%3B%0A%24itemPath%20%3D%20preg_replace('%2F%5E%5C%5C%2Fdrupal-7.59%2F'%2C%20''%2C%20%24itemPath)%3B%0A%24itemPath%20%3D%20preg_replace('%2F%5E%5C%2F%2F'%2C%20''%2C%20%24itemPath)%3B%0A%0Aif(%24itemPath)%0A%7B%0A%20%20%20%20%0A%20%20%20%20%24router_item%20%3D%20menu_get_item(%24itemPath)%3B%0A%20%20%20%20%24router_item%5B'access_callback'%5D%20%3D%20true%3B%0A%20%20%20%20%24router_item%5B'access'%5D%20%3D%20true%3B%0A%20%20%20%20%0A%20%20%20%20if%20(%24router_item%5B'include_file'%5D)%20%7B%0A%20%20%20%20%20%20require_once%20DRUPAL_ROOT%20.%20'%2F'%20.%20%24router_item%5B'include_file'%5D%3B%0A%20%20%20%20%7D%0A%20%20%20%20%0A%20%20%20%20%24page_callback_result%20%3D%20call_user_func_array(%24router_item%5B'page_callback'%5D%2C%20unserialize(%24router_item%5B'page_arguments'%5D))%3B%0A%20%20%20%20%0A%20%20%20%20drupal_deliver_page(%24page_callback_result)%3B%0A%7D%0Aelse%0A%7B%0A%20%20%20%20menu_execute_active_handler()%3B%0A%7D";
  if (query.has('code')) {
    if (query.get('code') === rewriteDemo) {
      query["delete"]('code');
      query.set('demo', 'drupal.php');
    }
  }
  if (query.has('demo')) {
    demo.value = String(query.get('demo'));
    loadDemo();
  }
  if (demo.value !== 'drupal.php') {
    reset.style.display = 'none';
  }
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


//# sourceMappingURL=app.js.map