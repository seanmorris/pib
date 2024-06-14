export default (($) => {
  const init = () => {
    $('.js-toggle-plugin-route').on('click', function togglePluginRoute() {
      const $this = $(this);
      const plugin = $this.attr('data-plugin');

      if ($this.hasClass('is-active')) {
        $this.removeClass('is-active');
        $(`.c-routes-panel__route-entry${plugin}`).removeClass('is-hidden');
      } else {
        $this.addClass('is-active');
        $(`.c-routes-panel__route-entry${plugin}`).addClass('is-hidden');
      }
    });
  };

  const onEvent = () => {
    document.addEventListener('initPanel', (e) => {
      if (e.detail === 'panelroutes') {
        init();
      }
    });
  };

  return {
    onEvent,
  };
})(jQuery);
