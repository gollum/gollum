// ua
$(document).ready(function() {
  if ($.browser.mozilla) {
    $('body').addClass('ff');
  } else if ($.browser.webkit) {
    $('body').addClass('webkit');
  } else if ($.browser.msie) {
    $('body').addClass('ie');
    if ($.browser.version == "7.0") {
      $('body').addClass('ie7');
    } else if ($.browser.version == "8.0") {
      $('body').addClass('ie8');
    }
  }
});