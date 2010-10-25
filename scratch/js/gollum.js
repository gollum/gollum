// ua
$(document).ready(function() {
  
  // ua detection
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
  
  // no widows in wiki body
  if ($('#wiki-wrapper').hasClass('page')) {
    $('#template h1, #template h2, #template h3, #template h4, #template h5, #template h6, #template li, #template p').each(
        function(){
            $(this).html($(this).html().replace(/\s([^\s<]+)\s*$/,'&nbsp;$1'));
        }
    );
  }
  
});