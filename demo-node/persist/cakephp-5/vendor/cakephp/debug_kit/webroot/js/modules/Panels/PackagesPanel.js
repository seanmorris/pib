export default (($) => {
  const buildSuccessfulMessage = (response) => {
    let html = '';
    if (response.packages.bcBreaks === undefined && response.packages.semverCompatible === undefined) {
      return '<pre class="c-packages-panel__up2date">All dependencies are up to date</pre>';
    }
    if (response.packages.bcBreaks !== undefined) {
      html += '<h4 class="c-packages-panel__section-header">Update with potential BC break</h4>';
      html += `<pre>${response.packages.bcBreaks}</pre>`;
    }
    if (response.packages.semverCompatible !== undefined) {
      html += '<h4 class="c-packages-panel__section-header">Update semver compatible</h4>';
      html += `<pre>${response.packages.semverCompatible}</pre>`;
    }
    return html;
  };

  const showMessage = (el, html) => {
    el.show().html(html);
    $('.o-loader').removeClass('is-loading');
  };

  const buildErrorMessage = (response) => `<pre class="c-packages-panel__warning-message">${JSON.parse(response.responseText).message}</pre>`;

  const init = () => {
    const $panel = $('.c-packages-panel');
    const baseUrl = $panel.attr('data-base-url');
    const csrfToken = $panel.attr('data-csrf-token');
    const $terminal = $('.c-packages-panel__terminal');

    $('.c-packages-panel__check-update button').on('click', (e) => {
      $('.o-loader').addClass('is-loading');

      const direct = $('.c-packages-panel__check-update input')[0].checked;
      $.ajax({
        headers: { 'X-CSRF-TOKEN': csrfToken },
        url: baseUrl,
        data: { direct },
        dataType: 'json',
        type: 'POST',
        success(data) {
          showMessage($terminal, buildSuccessfulMessage(data));
        },
        error(jqXHR, textStatus) {
          showMessage($terminal, buildErrorMessage(textStatus));
        },
      });
      e.preventDefault();
    });
  };

  const onEvent = () => {
    document.addEventListener('initPanel', (e) => {
      if (e.detail === 'panelpackages') {
        init();
      }
    });
  };

  return {
    onEvent,
  };
})(jQuery);
