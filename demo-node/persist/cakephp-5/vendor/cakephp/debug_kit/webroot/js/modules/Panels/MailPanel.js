export default (($) => {
  function init() {
    $('.js-debugkit-load-sent-email').on('click', function loadSentEmail() {
      const $elem = $(this);
      const idx = $elem.attr('data-mail-idx');
      const iframe = $('.c-mail-panel__iframe');
      const current = iframe[0].contentWindow.location.href;
      const newLocation = current.replace(/\/\d+$/, `/${idx}`);
      iframe[0].contentWindow.location.href = newLocation;

      $elem.siblings().removeClass('highlighted');
      $elem.addClass('highlighted');
    });
  }

  const onEvent = () => {
    document.addEventListener('initPanel', (e) => {
      if (e.detail === 'panelmail') {
        init();
      }
    });
  };

  return {
    onEvent,
  };
})(jQuery);
