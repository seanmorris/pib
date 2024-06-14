import Toolbar from './Toolbar.js';
import Helper from './Helper.js';

export default (($) => {
  const init = () => {
    const elem = document.getElementById('__debug_kit_app');
    if (elem) {
      window.debugKitId = elem.getAttribute('data-id');
      window.debugKitBaseUrl = elem.getAttribute('data-url');
      window.debugKitWebroot = elem.getAttribute('data-webroot');
    }

    return new Toolbar({
      body: $('body'),
      container: $('.js-panel-content-container'),
      toggleBtn: $('.js-toolbar-toggle'),
      panelButtons: $('.js-panel-button'),
      currentRequest: window.debugKitId,
      originalRequest: window.debugKitId,
      baseUrl: window.debugKitBaseUrl,
      isLocalStorageAvailable: Helper.isLocalStorageAvailable(),
    });
  };

  return {
    init,
  };
})(jQuery);
