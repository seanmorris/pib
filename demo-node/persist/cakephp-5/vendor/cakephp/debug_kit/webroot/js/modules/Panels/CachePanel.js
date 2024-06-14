export default (($) => {
  const addMessage = (text) => {
    $(`<p>${text}</p>`)
      .appendTo('.c-cache-panel__messages')
      .fadeOut(2000);
  };

  const init = () => {
    $('.js-clear-cache').on('click', function triggerCacheClear(e) {
      const el = $(this);
      const name = el.attr('data-name');
      const baseUrl = el.attr('data-url');
      const csrf = el.attr('data-csrf');

      $.ajax({
        headers: { 'X-CSRF-TOKEN': csrf },
        url: baseUrl,
        data: { name },
        dataType: 'json',
        type: 'POST',
        success(data) {
          addMessage(data.message);
        },
        error(jqXHR, textStatus, errorThrown) {
          addMessage(errorThrown);
        },
      });
      e.preventDefault();
    });
  };

  const onEvent = () => {
    document.addEventListener('initPanel', (e) => {
      if (e.detail === 'panelcache') {
        init();
      }
    });
  };

  return {
    onEvent,
  };
})(jQuery);
