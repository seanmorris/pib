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
require.register("DrupalWorker.js", function(exports, require, module) {
"use strict";

// import { process } from 'process/browser';
self.addEventListener('install', function (event) {
  console.log('Install');
  self.skipWaiting();
});
self.addEventListener('activate', function (event) {
  console.log('Activate');
  event.waitUntil(clients.claim());
});
self.addEventListener('fetch', function (event) {
  return event.respondWith(new Promise(function (accept) {
    var url = new URL(event.request.url);
    var pathname = url.pathname.replace(/^\//, '');
    var path = pathname.split('/');
    var _path = path.slice(0);
    if (_path[0] === 'php-wasm') {
      _path.shift();
    }
    if (!_path[_path.length - 1].match(/\.\w+$/) && _path[1] === 'drupal-7.95') {
      var getPost = event.request.method !== 'POST' ? Promise.resolve() : event.request.formData();
      return getPost.then(function (post) {
        accept(new Response("<script>window.parent.postMessage({\n\t\t\t\taction: 'respond'\n\t\t\t\t, method:  '".concat(event.request.method, "'\n\t\t\t\t, path:  '").concat('/' + path.join('/'), "'\n\t\t\t\t, _GET:  '").concat(url.search, "'\n\t\t\t\t, _POST: '").concat(event.request.method === 'POST' ? '?' + String(new URLSearchParams(post)) : '', "'\n\t\t\t});</script>"), {
          headers: {
            'Content-Type': 'text/html'
          }
        }));
      });
    } else {
      accept(fetch(event.request));
    }
  }));
});
self.addEventListener('message', function (event) {});
self.addEventListener('push', function (event) {
  console.log(event);
});
});

require.register("___globals___", function(exports, require, module) {
  
});})();require('___globals___');

require('DrupalWorker');
//# sourceMappingURL=DrupalWorker.js.map