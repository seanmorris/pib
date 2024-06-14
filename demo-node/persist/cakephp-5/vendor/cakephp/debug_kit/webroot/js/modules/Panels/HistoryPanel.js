export default (($) => {
  const init = (toolbar) => {
    const $historyPanel = $('.c-history-panel');
    const thisPanel = $historyPanel.attr('data-panel-id');

    if (!$('.c-history-panel > ul').length) {
      $historyPanel.html($('#list-template').html());
    }

    const listItem = $('#list-item-template').html();

    for (let i = 0; i < toolbar.ajaxRequests.length; i++) {
      const element = toolbar.ajaxRequests[i];
      const params = {
        id: element.requestId,
        time: (new Date(element.date)).toLocaleString(),
        method: element.method,
        status: element.status,
        url: element.url,
        type: element.type,
      };
      const content = listItem.replace(/{([^{}]*)}/g, (a, b) => {
        const r = params[b];
        return typeof r === 'string' || typeof r === 'number' ? r : a;
      });
      $('.c-history-panel__list li:first').after(content);
    }

    const links = $('.c-history-panel__link');
    // Highlight the active request.
    links.filter(`[data-request=${toolbar.currentRequest}]`).addClass('is-active');

    links.on('click', function historyLinkClick(e) {
      const el = $(this);
      e.preventDefault();
      links.removeClass('is-active');
      el.addClass('is-active');

      toolbar.currentRequest = el.attr('data-request');

      $.getJSON(el.attr('href'), (response) => {
        if (response.panels[0].request_id === toolbar.originalRequest) {
          $('body').removeClass('is-history-mode');
        } else {
          $('body').addClass('is-history-mode');
        }

        for (let i = 0, len = response.panels.length; i < len; i++) {
          const panel = response.panels[i];
          const button = toolbar.$panelButtons.eq(i);
          const summary = button.find('.c-panel__summary');

          // Don't overwrite the history panel.
          if (button.data('id') !== thisPanel) {
            button.attr('data-id', panel.id);
            summary.text(panel.summary);
          }
        }
      });
    });
  };

  const onEvent = (toolbar) => {
    document.addEventListener('initPanel', (e) => {
      if (e.detail === 'panelhistory') {
        init(toolbar);
      }
    });
  };

  return {
    onEvent,
  };
})(jQuery);
