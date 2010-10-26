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
  
  if ($('#wiki-wrapper').hasClass('history')) {
    $('#wiki-history td.checkbox input').each(highlightChecked);
    $('#wiki-history td.checkbox input').click(highlightChecked);
  
    $('#wiki-history td.revert-action a').mouseenter(highlightOn);
    $('#wiki-history td.revert-action a').mouseleave(highlightOff);
  };
  
});

function highlightOn() {
  $(this).parent().parent().animate({
                                      backgroundColor: '#ffffea',
                                      duration: 400
                                    });
}

function highlightOff() {
  var color = '#ebf2f6';
  if ($(this).parent().parent().hasClass('alt-row')) {
    color = '#f3f7fa';
  }
  $(this).parent().parent().animate({
                                      backgroundColor: color,
                                      duration: 400
                                    });
}

function highlightChecked() {
 if ($(this).is(':checked')) {
    $(this).parent().parent().addClass('selected');
  } else {
    $(this).parent().parent().removeClass('selected');
 }
}