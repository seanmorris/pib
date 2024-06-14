export default (($) => {
  const init = (toolbar) => {
    $(document).on('keydown', (event) => {
      if (event.key === 'Escape') {
        // Close active panel
        if (toolbar.isExpanded()) {
          return toolbar.hide();
        }
        // Collapse the toolbar
        if (toolbar.state() === 'toolbar') {
          return toolbar.toggle();
        }
      }
      if (event.key === 'ArrowLeft' && toolbar.isExpanded()) {
        toolbar.$panelButtons.removeClass('is-active');
        const prevPanel = toolbar.currentPanelButton().prev();
        if (prevPanel.hasClass('c-panel')) {
          prevPanel.addClass('is-active');
          const id = prevPanel.attr('data-id');
          const panelType = prevPanel.attr('data-panel-type');
          return toolbar.loadPanel(id, panelType);
        }
      }
      if (event.key === 'ArrowRight' && toolbar.isExpanded()) {
        toolbar.$panelButtons.removeClass('is-active');
        const nextPanel = toolbar.currentPanelButton().next();
        if (nextPanel.hasClass('c-panel')) {
          nextPanel.addClass('is-active');
          const id = nextPanel.attr('data-id');
          const panelType = nextPanel.attr('data-panel-type');
          return toolbar.loadPanel(id, panelType);
        }
      }
      return;
    });
  };

  return {
    init,
  };
})(jQuery);
