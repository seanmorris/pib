(self["webpackChunkdemo_source"] = self["webpackChunkdemo_source"] || []).push([["software_pglite_packages_pglite_dist_fs_nodefs_js"],{

/***/ "?41ec":
/*!********************!*\
  !*** fs (ignored) ***!
  \********************/
/***/ (() => {

/* (ignored) */

/***/ }),

/***/ "?d515":
/*!**********************!*\
  !*** path (ignored) ***!
  \**********************/
/***/ (() => {

/* (ignored) */

/***/ }),

/***/ "../../../software/pglite/packages/pglite/dist/fs/nodefs.js":
/*!******************************************************************!*\
  !*** ../../../software/pglite/packages/pglite/dist/fs/nodefs.js ***!
  \******************************************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   NodeFS: () => (/* binding */ a)
/* harmony export */ });
/* harmony import */ var _chunk_SJVDOE3S_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../chunk-SJVDOE3S.js */ "../../../software/pglite/packages/pglite/dist/chunk-SJVDOE3S.js");
/* harmony import */ var _chunk_Y3AVQXKT_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../chunk-Y3AVQXKT.js */ "../../../software/pglite/packages/pglite/dist/chunk-Y3AVQXKT.js");
/* harmony import */ var fs__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! fs */ "?41ec");
/* harmony import */ var path__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! path */ "?d515");
(0,_chunk_Y3AVQXKT_js__WEBPACK_IMPORTED_MODULE_1__.i)();var a=class extends _chunk_SJVDOE3S_js__WEBPACK_IMPORTED_MODULE_0__.a{constructor(r){super(r),this.rootDir=path__WEBPACK_IMPORTED_MODULE_3__.resolve(r),fs__WEBPACK_IMPORTED_MODULE_2__.existsSync(path__WEBPACK_IMPORTED_MODULE_3__.join(this.rootDir))||fs__WEBPACK_IMPORTED_MODULE_2__.mkdirSync(this.rootDir)}async emscriptenOpts(r){return{...r,preRun:[...r.preRun||[],s=>{let c=s.FS.filesystems.NODEFS;s.FS.mkdir(_chunk_SJVDOE3S_js__WEBPACK_IMPORTED_MODULE_0__.h),s.FS.mount(c,{root:this.rootDir},_chunk_SJVDOE3S_js__WEBPACK_IMPORTED_MODULE_0__.h)}]}}async dumpTar(r,e,s){return (0,_chunk_SJVDOE3S_js__WEBPACK_IMPORTED_MODULE_0__.c)(r,e,s)}async close(r){r.quit()}};
//# sourceMappingURL=nodefs.js.map

/***/ })

}]);
//# sourceMappingURL=software_pglite_packages_pglite_dist_fs_nodefs_js.cgi-worker.js.map