// ua
$(document).ready(function() {
  $('#delete-link').click( function(e) {
    var ok = confirm($(this).data('confirm'));
    if ( ok ) {
      var loc = window.location;
      loc = baseUrl + '/delete' + loc.pathname.replace(baseUrl,'');
      window.location = loc;
    }
    // Don't navigate on cancel.
    e.preventDefault();
  } );

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
        if ( !nodeSelector.node1 ) {
          nodeSelector.node1 = $node;
          nodeSelector.node1.addClass('selected');
        } else if ( !nodeSelector.node2 ) {
          // okay, we don't have a node 2 but have a node1
          nodeSelector.node2 = $node;
          nodeSelector.node2.addClass('selected');
          nodeSelector.selectNodeRange( nodeSelector.node1,
                                        nodeSelector.node2 );
        } else {
          // we have two selected already
          $nodeCheckbox[0].checked = false;
        }
      }
    }
  };

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

  if ($('#minibutton-rename-page').length) {
    $('#minibutton-rename-page').removeClass('jaws');
    $('#minibutton-rename-page').click(function(e) {
      e.preventDefault();

      // Path name without the leading slash.
      var pathname = window.location.pathname.substr(1);
      var slashIndex = pathname.lastIndexOf('/');
      var oldName = pathname.substr(slashIndex + 1)
      var path = pathname.substr(0, slashIndex);

      $.GollumDialog.init({
        title: 'Rename Page',
        fields: [
          {
            id:   'name',
            name: 'Rename to',
            type: 'text',
            defaultValue: oldName || ''
          }
        ],
        OK: function( res ) {
          var newName = 'Rename Page';
          if ( res['name'] ) {
            newName = res['name'];
          }

          var msg = 'Renamed ' + oldName + ' to ' + newName;
          jQuery.ajax( {
            type: 'POST',
            url: baseUrl + '/edit/' + oldName,
            data:  { path: path, rename: newName, page: oldName, message: msg },
            success: function() {
                window.location = baseUrl + encodeURIComponent(newName);
            }
          });
        }
      });
    });
  }

  if ($('#minibutton-new-page').length) {
    $('#minibutton-new-page').removeClass('jaws');
    $('#minibutton-new-page').click(function(e) {
      e.preventDefault();

      $.GollumDialog.init({
        title: 'Create New Page',
        fields: [
          {
            id:   'name',
            name: 'Page Name',
            type: 'text',
            defaultValue: ''
          }
        ],
        OK: function( res ) {
          var name = 'New Page';
          if ( res['name'] ) {
            name = res['name'];
          }
          window.location = baseUrl + '/' + encodeURIComponent(name);
        }
      });
    });
  }

  if ($('#wiki-wrapper').hasClass('history')) {
    $('#wiki-history td.checkbox input').each(function() {
      $(this).click(function() {
        nodeSelector.checkNode($(this));
      });
      if ( $(this).is(':checked') ) {
        nodeSelector.checkNode($(this));
      }
    });

    if ($('.history a.action-compare-revision').length) {
      $('.history a.action-compare-revision').click(function() {
        $("#version-form").submit();
      });
    }
  }

  if ($('#searchbar a#search-submit').length) {
    $.GollumPlaceholder.add($('#searchbar #search-query'));
    $('#searchbar a#search-submit').click(function(e) {
      e.preventDefault();
      $('#searchbar #search-form')[0].submit();
    });
    $('#searchbar #search-form').submit(function(e) {
      $.GollumPlaceholder.clearAll();
      $(this).unbind('submit');
      $(this).submit();
    });
  }

  if ($('#gollum-revert-form').length &&
      $('.gollum-revert-button').length ) {
    $('a.gollum-revert-button').click(function(e) {
      e.preventDefault();
      $('#gollum-revert-form').submit();
    });
  }
});
