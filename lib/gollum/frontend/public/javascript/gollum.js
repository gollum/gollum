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
    $('#wiki-history td.checkbox input').click(highlightChecked);
  
    $('#wiki-history td.revert-action a').mouseenter(highlightOn);
    $('#wiki-history td.revert-action a').mouseleave(highlightOff);
  };
  
});

var nodeSelector = {
  
  node1: null,
  node2: null,
  
  selectNodeRange: function( n1, n2 ) {
    if ( nodeSelector.node1 && nodeSelector.node2 ) {
      $('#wiki-history td.selected').removeClass('selected');
      nodeSelector.node1.addClass('selected');
      nodeSelector.node2.addClass('selected');
      
      // swap the nodes around if they went in reverse
      if ( nodeSelector.nodeComesAfter( nodeSelector.node1, 
                                        nodeSelector.node2 ) ) {
        var n = nodeSelector.node1;
        nodeSelector.node1 = nodeSelector.node2;
        nodeSelector.node2 = n;
      }
      
      var s = true;
      var $nextNode = nodeSelector.node1.next();
      while ( $nextNode ) {
        $nextNode.addClass('selected');
        if ( $nextNode[0] == nodeSelector.node2[0] ) {
          break;
        }
        $nextNode = $nextNode.next();
      }
    }
  },
  
  nodeComesAfter: function ( n1, n2 ) {
    var s = false;
    $(n1).prevAll().each(function() {
      if ( $(this)[0] == $(n2)[0] ) {
        s = true;
      }
    });
    return s;
  },
  
  checkNode: function( nodeCheckbox ) {
    var $nodeCheckbox = nodeCheckbox;
    var $node = $(nodeCheckbox).parent().parent();
    // if we're unchecking
     if ( !$nodeCheckbox.is(':checked') ) {
    
       // remove the range, since we're breaking it
       $('#wiki-history tr.selected').each(function() {
         if ( $(this).find('td.checkbox input').is(':checked') ) {
           return;
         }
         $(this).removeClass('selected');
       });
       
       // no longer track this
       if ( $node[0] == nodeSelector.node1[0] ) {
         nodeSelector.node1 = null;
         if ( nodeSelector.node2 ) {
           nodeSelector.node1 = nodeSelector.node2;
           nodeSelector.node2 = null;
         }
       } else if ( $node[0] == nodeSelector.node2[0] ) {
         nodeSelector.node2 = null;
       }
       
     } else {
       // not checked, get a range set up
       $node.addClass('selected');
       if ( !nodeSelector.node1 ) {
         nodeSelector.node1 = $node;
       } else if ( !nodeSelector.node2 ) {
         // okay, we don't have a node 2 but have a node1
         nodeSelector.node2 = $node;
         nodeSelector.selectNodeRange( nodeSelector.node1, 
                                       nodeSelector.node2 );
       }
     }
  }
  
};

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
 nodeSelector.checkNode($(this));
}
