export default class Toolbar {
  constructor(options) {
    this.$body = options.body;
    this.$container = options.container;
    this.$toggleBtn = options.toggleBtn;
    this.$panelButtons = options.panelButtons;
    this.currentRequest = options.currentRequest;
    this.originalRequest = options.originalRequest;
    this.baseUrl = options.baseUrl;
    this.isLocalStorageAvailable = options.isLocalStorageAvailable;

    this.currentPanelId = 0;
    this.currentState = 0;
    this.states = [
      'collapse',
      'toolbar',
    ];

    this.ajaxRequests = [];
  }

  initialize() {
    this.mouseListeners();
    this.loadState();

    const self = this;
    window.addEventListener('message', (event) => {
      self.onMessage(event);
    }, false);
  }

  toggle() {
    const state = this.nextState();
    this.updateButtons(state);
    this.updateToolbarState(state);
    window.parent.postMessage(state, window.location.origin);
  }

  hide() {
    this.$container.removeClass('is-active');
    this.currentPanelButton().removeClass('is-active');
    const that = this;

    // Shrink the iframe back to 40px height
    setTimeout(() => {
      window.parent.postMessage(that.state(), window.location.origin);
    }, 250);
  }

  isExpanded() {
    return this.$container.hasClass('is-active');
  }

  // ========== STATES ==========

  state() {
    return this.states[this.currentState];
  }

  nextState() {
    this.currentState++;
    if (this.currentState === this.states.length) {
      this.currentState = 0;
    }
    this.saveState();
    return this.state();
  }

  saveState() {
    if (!this.isLocalStorageAvailable) {
      return;
    }
    window.localStorage.setItem('toolbar_state', this.currentState);
  }

  loadState() {
    if (this.isLocalStorageAvailable) {
      let old = window.localStorage.getItem('toolbar_state');
      if (!old) {
        old = '0';
      }
      if (old === '0') {
        this.hide();
      }
      if (old === '1') {
        this.toggle();
      }
    }
  }

  // ========== UPDATE ELEMENTES DEPENDING ON STATE ==========

  updateToolbarState(state) {
    if (state === 'toolbar') {
      this.$body.addClass('is-active');
    }
    if (state === 'collapse') {
      this.$body.removeClass('is-active');
    }
  }

  updateButtons(state) {
    if (state === 'toolbar') {
      this.$panelButtons.show();
    }
    if (state === 'collapse') {
      this.$panelButtons.hide();
    }
  }

  // ========== PANELS ==========

  currentPanelButton() {
    return this.$body.find(`[data-id="${this.currentPanel()}"]`);
  }

  currentPanel() {
    return this.currentPanelId;
  }

  /**
     * Responsible for loading a specific panel
     *
     * @param id The panel id
     * @param panelType The panel type used for global custom events
     */
  loadPanel(id, panelType) {
    if (id === undefined) {
      return;
    }

    const url = `${this.baseUrl}debug-kit/panels/view/${id}`;
    const contentArea = this.$container.find('.c-panel-content-container__content');
    const that = this;
    const loader = $('.o-loader');

    const timer = setTimeout(() => {
      loader.addClass('is-loading');
    }, 500);

    this.currentPanelId = id;
    window.parent.postMessage('expand', window.location.origin);

    $.get(url, (response) => {
      clearTimeout(timer);
      loader.removeClass('is-loading');

      // Slide panel into place
      that.$container.addClass('is-active');
      contentArea.html(response);

      // This initializes the panel specific JS logic (if there is any)
      document.dispatchEvent(new CustomEvent('initPanel', { detail: `panel${panelType}` }));
      that.bindDebugBlock();
    })
      .fail((response) => {
        clearTimeout(timer);
        contentArea.html(response.responseText);
        $('.o-loader').removeClass('is-loading');
        $('.c-panel-content-container').addClass('is-active');
        window.parent.postMessage('error', window.location.origin);
      });
  }

  // This re-inits the collapsible Debugger::exportVar() content of the Variables tab
  bindDebugBlock() {
    if (window.__cakeDebugBlockInit) {
      window.__cakeDebugBlockInit();
    }
  }

  // ========== LISTENERS ==========

  mouseListeners() {
    const that = this;

    $(document).on('click', '.js-toolbar-scroll-left', () => {
      that.scroll('left');
    });
    $(document).on('click', '.js-toolbar-scroll-right', () => {
      that.scroll('right');
    });
    $(document).on('click', '.js-toolbar-load-panel', function () {
      const panelId = $(this).attr('data-panel-id');
      that.loadPanel(panelId, 'history');
    });
    $(document).on('click', '.js-panel-close', () => {
      that.hide();
    });

    this.$panelButtons.on('click', function onClick(e) {
      that.$panelButtons.removeClass('is-active');
      e.preventDefault();
      e.stopPropagation();
      const id = $(this).attr('data-id');
      const samePanel = that.currentPanel() === id;

      // If the current panel is open and its tab has been clicked => close it
      if (that.isExpanded() && samePanel) {
        that.hide();
        return false;
      }

      $(this).addClass('is-active');
      const panelType = $(this).attr('data-panel-type');
      that.loadPanel(id, panelType);
      return true;
    });

    this.$toggleBtn.on('click', () => {
      that.toggle();
    });
  }

  scroll(direction) {
    const scrollValue = 300;
    const operator = direction === 'left' ? '-=' : '+=';
    const buttons = this.$panelButtons;
    const firstButton = buttons.first();
    const lastButton = buttons.last();

    // If the toolbar is scrolled to the left, don't go farther.
    if (direction === 'right' && firstButton.position().left === 0) {
      return;
    }

    const buttonWidth = lastButton.width();
    // If the last button's right side is left of the cake button, don't scroll further.
    if (direction === 'left' && lastButton.offset().left + buttonWidth < this.$toggleBtn.offset().left) {
      return;
    }
    const css = { left: operator + scrollValue };
    $(this.$panelButtons).animate(css);
  }

  // ========== AJAX related functionality ==========

  onMessage(event) {
    if (typeof (event.data) === 'string' && event.data.indexOf('ajax-completed$$') === 0) {
      this.onRequest(JSON.parse(event.data.split('$$')[1]));
    }
  }

  onRequest(request) {
    this.ajaxRequests.push(request);
    $('.c-panel__summary:contains(xhr)').text(`${this.ajaxRequests.length} xhr`);
  }
}
