// Helpers
function pageName(){
  // "my/dir/file" => "file"
  return typeof(pageFullPath) == 'undefined' ? undefined : pageFullPath.split('/').pop();
}
function pagePath(){
  // "my/dir/file" => "my/dir"
  return typeof(pageFullPath) == 'undefined' ? undefined : pageFullPath.split('/').slice(0,-1).join('/');
}

// Generic HTML escape function
function htmlEscape( str ) {
  // The (slower) alternative is: return $('<div/>').text(str).html();
  // http://stackoverflow.com/questions/1219860/javascript-jquery-html-encoding/7124052#7124052
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

// Given a page name and a current path, returns a fully qualified path.
function abspath(path, name){
  // Make sure the given path starts at the root.
  if(name[0] != '/'){
    name = '/' + name;
    if (path) {
      name = '/' + path + name;
    }
  }
  var name_parts = name.split('/');
  var newPath = name_parts.slice(0, -1).join('/');
  var newName = name_parts.pop();
  // return array of [path, name]
  return [newPath, newName];
}

// ua
$(document).ready(function() {
  $('#delete-link').click( function(e) {
    var ok = confirm($(this).data('confirm'));
    if ( ok ) {
      var loc = baseUrl + '/delete/' + pageFullPath;
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

  if ($('#minibutton-upload-page').length) {
    $('#minibutton-upload-page').parent().removeClass('jaws');
    $('#minibutton-upload-page').click(function(e) {
      e.preventDefault();

      $.GollumDialog.init({
        title: 'Upload File',
        fields: [
          {
            type:   'file',
            context: 'Your uploaded file will be accessible at<br>/'+uploadDest+'/[filename]',
            action: baseUrl + '/uploadFile'
          }
        ],
        OK: function( res ) {
          $('#upload').submit();
        }
      });
    });
  }

  if ($('#minibutton-rename-page').length) {
    $('#minibutton-rename-page').parent().removeClass('jaws');
    $('#minibutton-rename-page').click(function(e) {
      e.preventDefault();

      var path = pagePath();
      var oldName = pageName();
      var context_blurb =
        "Renamed page will be under " +
        "<span class='path'>" + htmlEscape('/' + path) + "</span>" +
        " unless an absolute path is given."

      $.GollumDialog.init({
        title: 'Rename Page',
        fields: [
          {
            id:   'name',
            name: 'Rename to',
            type: 'text',
            defaultValue: oldName || '',
            context: context_blurb
          }
        ],
        OK: function( res ) {
          var newName = 'Rename Page';
          if ( res['name'] ) {
            newName = res['name'];
          }
          var name_parts = abspath(path, newName);
          var newPath = name_parts[0];

          var msg = '/' + path == newPath ? 'Renamed ' + oldName + ' to ' + newName
                                          : 'Renamed ' + oldName + ' to ' + name_parts.join('/');
          // Fill in the rename form
          // This is preferable to AJAX so that we automatically follow the 302 response.
          var rename_form = $("form[name=rename]");
          rename_form.children("input[name=rename]").val(name_parts.join('/'));
          rename_form.children("input[name=message]").val(msg);
          rename_form.submit();
        }
      });
    });
  }

  if ($('#minibutton-new-page').length) {
    $('#minibutton-new-page').parent().removeClass('jaws');
    $('#minibutton-new-page').click(function(e) {
      e.preventDefault();

      var path = pagePath();
      if( path === undefined && $('#file-browser').length != 0 ){
        // In the pages view, pageFullPath isn't defined.
        // The new button will still expect a value however.
        // So we try to figure one out from window.location
        path = baseUrl == '' ? window.location.pathname.substr(1)
                             : window.location.pathname.substr(baseUrl.length + 1);
        // Remove the page viewer part of the url.
        path = path.replace(/^pages\/?/,'')
        // For consistency remove the trailing /
        path = path.replace(/\/$/,'')
      }
      var context_blurb =
        "Page will be created under " +
        "<span class='path'>" + htmlEscape('/' + path) + "</span>" +
        " unless an absolute path is given."

      $.GollumDialog.init({
        title: 'Create New Page',
        fields: [
          {
            id:   'name',
            name: 'Page Name',
            type: 'text',
            defaultValue: '',
            context: context_blurb
          }
        ],
        OK: function( res ) {
          var name = 'New Page';
          if ( res['name'] ) {
            name = res['name'];
          }
          var name_encoded = [];
          var name_parts = abspath(path, name).join('/').split('/');
          // Split and encode each component individually.
          for( var i=0; i < name_parts.length; i++ ){
            name_encoded.push(encodeURIComponent(name_parts[i]));
          }
          window.location = baseUrl + name_encoded.join('/');
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

  if( $('#wiki-wrapper.edit').length ){
    $("#gollum-editor-submit").click( function() { window.onbeforeunload = null; } );
    $("#gollum-editor-body").one('change', function(){
      window.onbeforeunload = function(){ return "Leaving will discard all edits!" };
    });
    $.GollumEditor();
  }

  if( $('#wiki-wrapper.create').length ){
    $("#gollum-editor-submit").click( function() { window.onbeforeunload = null; } );
    $("#gollum-editor-body").one('change', function(){
      window.onbeforeunload = function(){ return "Leaving will not create a new page!" };
    });
    $.GollumEditor({ NewFile: true, MarkupType: default_markup });
  }

  if( $('#wiki-history').length ){
    var lookup = {};
    $('img.identicon').each(function(index, element){
      var $item   = $(element);
      var code    = parseInt($item.data('identicon'), 10);
      var img_bin = lookup[code];
      if( img_bin === undefined ){
        var size = 16;
        var canvas = $('<canvas width=16 height=16/>').get(0);
        render_identicon(canvas, code, 16);
        img_bin = canvas.toDataURL("image/png");
        lookup[code] = img_bin;
      }
      $item.attr('src', img_bin);
    });
  }
});
