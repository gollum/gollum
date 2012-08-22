require([ 'ace/undomanager', 'ace/ext/static_highlight', 'ace/theme/github', 'ace/editor', 'ace/virtual_renderer', 'ace/mode/markdown', 'ace/theme/twilight',
'ace/mode/c_cpp', 'ace/mode/clojure', 'ace/mode/coffee', 'ace/mode/coldfusion', 'ace/mode/csharp', 'ace/mode/css', 'ace/mode/diff', 'ace/mode/golang', 'ace/mode/groovy', 'ace/mode/haxe', 'ace/mode/html', 'ace/mode/java', 'ace/mode/javascript', 'ace/mode/json', 'ace/mode/latex', 'ace/mode/less', 'ace/mode/liquid', 'ace/mode/lua', 'ace/mode/markdown', 'ace/mode/ocaml', 'ace/mode/perl', 'ace/mode/pgsql', 'ace/mode/php', 'ace/mode/powershell', 'ace/mode/python', 'ace/mode/ruby', 'ace/mode/scad', 'ace/mode/scala', 'ace/mode/scss', 'ace/mode/sh', 'ace/mode/sql', 'ace/mode/svg', 'ace/mode/textile', 'ace/mode/text', 'ace/mode/xml', 'ace/mode/xquery', 'ace/mode/yaml'
], function() {
var UndoManager = require("ace/undomanager").UndoManager;
var Renderer = require( 'ace/virtual_renderer' ).VirtualRenderer;
var Editor = require( 'ace/editor' ).Editor;
var dom = require( 'ace/lib/dom' );

var win = window;
var location = win.location;
var doc = document;

win.onbeforeunload = function() { return 'Leaving Live Preview will discard all edits!' };

var editor = new Editor( new Renderer( doc.getElementById( 'editor' ) ));//ace.edit( 'editor' );
var editorSession = editor.getSession();
$.editorSession = editorSession; // for testing
var editorContainer = editor.container;
var preview = doc.getElementById( 'previewframe' );
var content = doc.getElementById( 'contentframe' );
var toolPanel = doc.getElementById( 'toolpanel' );
var comment = doc.getElementById( 'comment' );
var commentToolPanel = doc.getElementById( 'commenttoolpanel' );
// dim the page
var darkness = doc.getElementById( 'darkness' );

var leftRight = true;
var jsm = {}; // JavaScript Markdown
win.jsm = jsm;
win.jsm.toggleLeftRight = function() {
  leftRight = leftRight === false ? true : false;
  jsm.resize();
}

var MarkdownMode = require( 'ace/mode/markdown' ).Mode;

function initAce( editor, editorSession ) {
  editorSession.setUndoManager(new UndoManager());
  editor.setTheme( 'ace/theme/twilight' );
  editorSession.setMode( new MarkdownMode() );
  // Gutter shows line numbers
  editor.renderer.setShowGutter( true );
  editor.renderer.setHScrollBarAlwaysVisible( false );
  editorSession.setUseSoftTabs( true );
  editorSession.setTabSize( 2 );
  editorSession.setUseWrapMode( true );
  editor.setShowPrintMargin( false );
  editor.setBehavioursEnabled( true );
}

initAce( editor, editorSession );

// Setup comment ace.
var commentEditor = new Editor( new Renderer( doc.getElementById( 'comment' ) ));//ace.edit( 'comment' );
var commentEditorSession = commentEditor.getSession();
$.commentSession = commentEditorSession; // for testing
var commentEditorContainer = commentEditor.container;

initAce( commentEditor, commentEditorSession );

// Find the app's base url, knowing we are in /livepreview/index.html
var baseUrl = location.pathname.split('/').slice(0,-2).join('/');

// RegExp from http://stackoverflow.com/questions/901115/get-query-string-values-in-javascript
$.key = function( key ) {
    var value = new RegExp( '[\\?&]' + key + '=([^&#]*)' ).exec( location.href );
    return  ( !value ) ? 0 : value[ 1 ] || 0;
}

// True if &create=true
var create = $.key( 'create' );
// The path and name of the page being edited.
var pageName = $.key( 'page' );
var pathName = $.key( 'path' );

if ( pathName === 0 ) {
  pathName = undefined;
}

defaultCommitMessage = function() {
  var msg = pageName + ' (markdown)';

  if (create) {
    return 'Created ' + msg;
  } else {
    return 'Updated ' + msg;
  }
}

// Set comment using the default commit message.
commentEditorSession.setValue( defaultCommitMessage() );

$.save = function( commitMessage ) {
  win.onbeforeunload = null;

  var POST = 'POST';
  var markdown = 'markdown';
  var txt = editorSession.getValue();
  var msg = defaultCommitMessage();
  var newLocation = baseUrl;

  // 'a%2Fb' => a/b
  if (pathName) {
    newLocation += '/' + unescape(pathName);
    pathName = pathName + '/'; // pathName must end with /
  }

  newLocation += '/' + pageName;

  // if &create=true then handle create instead of edit.
  if ( create ) {
    jQuery.ajax( {
      type: POST,
      url: baseUrl + '/create',
      data:  { path: pathName, page: pageName, format: markdown, content: txt, message: commitMessage || msg },
      success: function() {
        win.location = newLocation;
      }
  });
  } else {
    jQuery.ajax( {
      type: POST,
      url: baseUrl + '/edit/' + pageName,
      data:  { path: pathName, page: pageName, format: markdown, content: txt, message:  commitMessage || msg },
      success: function() {
          win.location = newLocation;
      }
    });
  } // end else
}

var elapsedTime;
var oldInputText = '';

// ---- from Markdown.Editor
var timeout;

var nonSuckyBrowserPreviewSet = function( text ) {
  content.innerHTML = text;
}

// IE doesn't let you use innerHTML if the element is contained somewhere in a table
// (which is the case for inline editing) -- in that case, detach the element, set the
// value, and reattach. Yes, that *is* ridiculous.
var ieSafePreviewSet = function( text ) {
  var parent = content.parentNode;
  var sibling = content.nextSibling;
  parent.removeChild( content );
  content.innerHTML = text;
  if ( !sibling )
    parent.appendChild( content );
  else
    parent.insertBefore( content, sibling );
}

var cssTextSet = function( element, css ){
  element.style.cssText = css;
}

var cssAttrSet = function( element, css ){
  element.setAttribute( 'style', css );
}

/*
 Redefine the function based on browser support.
 element - the element to set the css on
 css     - a fully formed css string. ex: 'top: 0; left: 0;'

 Avoid reflow by batching CSS changes.
 http://dev.opera.com/articles/view/efficient-javascript/?page=3#stylechanges
*/
var cssSet = function( element, css ) {
  if( typeof( element.style.cssText ) != 'undefined' ) {
    cssTextSet( element, css );
    cssSet = cssTextSet;
  } else {
    cssAttrSet( element, css );
    cssSet = cssAttrSet;
  }
}

var previewSet = function( text ) {
  try {
    nonSuckyBrowserPreviewSet( text );
    previewSet = nonSuckyBrowserPreviewSet;
  } catch ( e ) {
    ieSafePreviewSet( text );
    previewSet = ieSafePreviewSet;
  }
};

// 'c', 'c++', 'cpp' are github specific and transformed to c_cpp for Ace.
var languages = [ 'c', 'c++', 'cpp', 'clojure', 'coffee', 'coldfusion',
 'csharp', 'css', 'diff', 'golang', 'groovy', 'haxe', 'html',
 'java', 'javascript', 'json', 'latex', 'less', 'liquid',
 'lua', 'markdown', 'ocaml', 'perl', 'pgsql', 'php', 'powershell',
 'python', 'ruby', 'scad', 'scala', 'scss', 'sh', 'sql', 'svg',
 'textile', 'text', 'xml', 'xquery', 'yaml' ];

var staticHighlight = require( 'ace/ext/static_highlight' );
var githubTheme = require( 'ace/theme/github' );
var langModes = {};

(function() {
var languagesLength = languages.length;
for ( var a = 0; a < languagesLength; a++ ) {
  var name = languages[ a ];
  langModes[ name ] = false;
}
})();

function getLang( language ) {
  var mode = langModes[ language ];

  if ( mode ) {
    return mode;
  }

  // require.Mode must be wrapped in parens.
  mode = new ( require( 'ace/mode/' + language ).Mode )();

  return mode;
}

function highlight( element, language ) {
  // Highlighting requires .innerText not
  // .innerHTML. It's the difference between
  // '>' and '&gt;'.
  // Firefox does not support innerText.
  var data = element.innerText || element.textContent;
  data = data.trim();
  var mode = getLang( language );
  // input, mode, theme, lineStart, disableGutter
  var color = staticHighlight.render( data, mode, githubTheme, 1, true );

  var newDiv = doc.createElement('div');
  newDiv.innerHTML = color.html;
  element.parentNode.parentNode.replaceChild( newDiv, element.parentNode );
}

var makePreviewHtml = function () {
  var text = editorSession.getValue();

  if ( text == undefined || text == '' ) {
    previewSet( '' );
    return;
  }

  if (text && text == oldInputText) {
    return; // Input text hasn't changed.
  }
  else {
    oldInputText = text;
  }

  var prevTime = new Date().getTime();
  text = md_to_html( text );

  // Calculate the processing time of the HTML creation.
  // It's used as the delay time in the event listener.
  var currTime = new Date().getTime();
  elapsedTime = currTime - prevTime;

  // Update the text using feature detection to support IE.
  // preview.innerHTML = text; // this doesn't work on IE.
  previewSet( text );
  // MathJax is loaded asynchronously.
  if (typeof MathJax != 'undefined') { MathJax.Hub.Typeset( content ); }

  // highlight code blocks.
  var codeElements = preview.getElementsByTagName( 'pre' );
  var codeElementsLength = codeElements.length;
  var skipped = 0;

  if ( codeElementsLength > 0 ) {
    for ( var idx = 0; idx < codeElementsLength; idx++ ) {
      // highlight removes an element so 0 is always the correct index.
      // Skipped tags are not removed so they must be added.
      var element = codeElements[ 0 + skipped ].firstChild;
      if ( element == undefined ) {
        skipped++;
        continue;
      }
      var codeHTML = element.innerHTML;
      if ( codeHTML == undefined ) {
        skipped++;
        continue;
      }
      var txt = codeHTML.split( /\b/ );
      // the syntax for code highlighting means all code, even one line, contains newlines.
      if ( txt.length > 1 && codeHTML.match( /\n/ ) ) {
        var declaredLanguage = element.className.toLowerCase();
        var aceMode = declaredLanguage;

        // GitHub supports 'c', 'c++', 'cpp'
        // which must trigger the 'c_cpp' mode in Ace.
        if ( declaredLanguage === 'c'   ||
             declaredLanguage === 'c++' ||
             declaredLanguage === 'cpp' ) {
          aceMode = 'c_cpp';
        }

        if ( $.inArray( declaredLanguage, languages ) === -1 ) {
          // Unsupported language.
          skipped++;
          continue;
        }
        // highlight: element
        highlight( element, aceMode );
      } else {
        // Highlighting is not for `code` inline syntax. For example `puts "string"`.
        skipped++;
      }
    }
  }
};

// setTimeout is already used.  Used as an event listener.
var applyTimeout = function () {
  if ( timeout ) {
    clearTimeout(timeout);
    timeout = undefined;
  }

  // 3 second max delay
  if ( elapsedTime > 3000 ) {
    elapsedTime = 3000;
  }

  timeout = setTimeout( makePreviewHtml, elapsedTime );
};

  /* Load markdown from /data/page into the ace editor.
     ~-1 == false; !~-1 == true;
   */
  if ( !~location.host.indexOf('github.com') ) {
    jQuery.ajax( {
      type: 'GET',
      url: baseUrl + '/data/' + $.key( 'page' ),
      success: function( data ) {
         editorSession.setValue( data );
      }
    });
  }

  $( '#save' ).click( function() {
    $.save();
  });

  // Hide dimmer, comment tool panel, and comment.
  $( '#commentcancel' ).click( function() {
    // Restore focus on commentcancel but not on
    // savecommentconfirm because the latter loads
    // a new page.
    hideCommentWindow();
    editor.focus();
  });

  var isCommentHidden = true;

  // var style = darkness.style.visibility will not update visibility.
  var darknessStyle = darkness.style;
  var commentToolPanelStyle = commentToolPanel.style;
  var commentStyle = comment.style;

  function hideCommentWindow() {
    isCommentHidden = true;
    darknessStyle.visibility =
    commentToolPanelStyle.visibility =
    commentStyle.visibility = 'hidden';
  }

  // Show dimmer, comment tool panel, and comment.
  $( '#savecomment' ).click( function() {
    isCommentHidden = false;
    darknessStyle.visibility =
    commentToolPanelStyle.visibility =
    commentStyle.visibility = 'visible';
    // Set focus so typing can begin immediately.
    commentEditor.focus();
  });

  $( '#savecommentconfirm' ).click( function() {
    $.save( commentEditorSession.getValue() );
    hideCommentWindow();
  });

  // onChange calls applyTimeout which rate limits the calling of makePreviewHtml based on render time.
  editor.on( 'change', applyTimeout );
  makePreviewHtml(); // preview default text on load

  function resize() {
    var width = $( win ).width();
    var widthHalf = width / 2;
    var widthFourth = widthHalf / 2;
    var height = $( win ).height();
    var heightHalf = height / 2;

    // height minus 50 so the end of document text doesn't flow off the page.
    var editorContainerStyle = 'width:' + widthHalf + 'px;' +
      'height:' + (height - 50) + 'px;' +
      'left:' + (leftRight === false ? widthHalf + 'px;' : '0px;') +
      'top:' + '40px;'; // use 40px for tool menu
    cssSet( editorContainer, editorContainerStyle );
    editor.resize();

    // width -2 for scroll bar & -10 for left offset
    var previewStyle = 'width:' + (widthHalf - 2 - 10) + 'px;' +
      'height:' + height + 'px;' +
      'left:' + (leftRight === false ? '10px;' : widthHalf + 'px;') +
      'top:' + '0px;';
    cssSet( preview, previewStyle );

     // Resize tool panel
    var toolPanelStyle = 'width:' + widthHalf + 'px;' +
      'left:' + (leftRight === false ? widthHalf + 'px;' : '0px;');
    cssSet( toolPanel, toolPanelStyle );

    // Resize comment related elements.
    var commentHidden = 'visibility:' + ( isCommentHidden === true ? 'hidden;' : 'visible;' );

    // Adjust comment editor
    var commentEditorContainerStyle = 'height:' + heightHalf + 'px;' +
      'width:' + widthHalf + 'px;' +
      'left:' + widthFourth + 'px;' +
      'top:' + (heightHalf / 2) + 'px;' +
      commentHidden;
    cssSet( commentEditorContainer, commentEditorContainerStyle );
    commentEditor.resize();

    // In top subtract height (40px) of comment tool panel.
    var commentToolPanelStyle = 'width:' + widthHalf + 'px;' +
      'left:' + widthFourth + 'px;' +
      'top:' + (height / 4 - 40) + 'px;' +
      commentHidden;
    cssSet( commentToolPanel, commentToolPanelStyle );

    // Resize dimmer.
    var darknessStyle = 'width:' + width + 'px;' +
      'height:' + height + 'px;' +
      commentHidden;
    cssSet( darkness, darknessStyle );
  }

  win.jsm.resize = resize;

  /*
     Resize can be called an absurd amount of times
     and will crash the page without debouncing.
     http://benalman.com/projects/jquery-throttle-debounce-plugin/
     https://github.com/cowboy/jquery-throttle-debounce
     http://unscriptable.com/2009/03/20/debouncing-javascript-methods/
  */
  $( win ).resize( $.debounce( 100, resize ) );

  // resize for the intial page load
  resize();
});
