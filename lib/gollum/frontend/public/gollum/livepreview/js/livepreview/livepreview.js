(function () {
window.onbeforeunload = function(){ return "Leaving Live Preview will discard all edits!" };

var converter = Markdown.getSanitizingConverter();
var editor = ace.edit("editor");
var editorSession = editor.getSession();
var editorContainer = editor.container;
var preview = document.getElementById("previewframe");
var content = document.getElementById("contentframe");
var toolPanel = document.getElementById("toolpanel");
var comment = document.getElementById("comment");
var commentToolPanel = document.getElementById("commenttoolpanel");
// dim the page
var darkness = document.getElementById("darkness");

var leftRight = true;
var jsm = {}; // JavaScript Markdown
window.jsm = jsm;
window.jsm.toggleLeftRight = function() {
  leftRight = leftRight === false ? true : false;
  jsm.resize();
}

var MarkdownMode = require("ace/mode/markdown").Mode;

function initAce(editor, editorSession) {
  editor.setTheme("ace/theme/twilight");
  editorSession.setMode(new MarkdownMode());
  // Gutter shows line numbers
  editor.renderer.setShowGutter(true);
  editor.renderer.setHScrollBarAlwaysVisible(false);
  editorSession.setUseSoftTabs(true);
  editorSession.setTabSize(2);
  editorSession.setUseWrapMode(true);
  editor.setShowPrintMargin(false);
  editor.setBehavioursEnabled(true);
}

initAce(editor, editorSession);

// Setup comment ace.
var commentEditor = ace.edit("comment");
var commentEditorSession = commentEditor.getSession();
var commentEditorContainer = commentEditor.container;

initAce(commentEditor, commentEditorSession);

// RegExp from http://stackoverflow.com/questions/901115/get-query-string-values-in-javascript
$.key = function(key){
    var value = new RegExp('[\\?&]' + key + '=([^&#]*)').exec(window.location.href);
    return  (!value) ? 0 : value[1] || 0;
}

// True if &create=true
var create = $.key("create");
// The name of the page being edited.
var pageName = $.key("page");

defaultCommitMessage = function() {
  var msg = pageName + " (markdown)";

  if (create) {
    return "Created " + msg;
  } else {
    return "Updated " + msg;
  }
}

// Set comment using the default commit message.
commentEditorSession.setValue( defaultCommitMessage() );

$.save = function( commitMessage ) {
  window.onbeforeunload = null;

  var POST = "POST";
  var markdown = "markdown";
  var txt = editorSession.getValue();
  var msg = defaultCommitMessage();
  var newLocation = window.location.protocol + "//" + window.location.host + "/" + pageName;

  // if &create=true then handle create instead of edit.
  if (create) {
    jQuery.ajax({
      type: POST,
      url: "/create",
      data:  { page: pageName, format: markdown, content: txt, message: commitMessage || msg },
      success: function() {
        window.location = newLocation;
      }
  });
  } else {
    jQuery.ajax({
      type: POST,
      url: "/edit/" + pageName,
      data:  { format: markdown, content: txt, message:  commitMessage || msg },
      success: function() {
          window.location = newLocation;
      }
    });
  } // end else
}

var elapsedTime;
var oldInputText = "";

// ---- from Markdown.Editor
var timeout;

var nonSuckyBrowserPreviewSet = function (text) {
  content.innerHTML = text;
}

// IE doesn't let you use innerHTML if the element is contained somewhere in a table
// (which is the case for inline editing) -- in that case, detach the element, set the
// value, and reattach. Yes, that *is* ridiculous.
var ieSafePreviewSet = function (text) {
  var parent = content.parentNode;
  var sibling = content.nextSibling;
  parent.removeChild(content);
  content.innerHTML = text;
  if (!sibling)
    parent.appendChild(content);
  else
    parent.insertBefore(content, sibling);
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
 css     - a fully formed css string. ex: "top: 0; left: 0;"

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
  } catch (e) {
    ieSafePreviewSet( text );
    previewSet = ieSafePreviewSet;
  }
};

var languages = [ "1c", "actionscript", "apache", "avrasm", "axapta",
"bash", "cmake", "coffeescript", "cpp", "cs", "css", "delphi", "diff",
"django", "d", "dos", "erlang", "erlang-repl", "go", "haskell", "ini",
"java", "javascript", "languages", "lisp", "lua", "markdown", "matlab",
"mel", "nginx", "objectivec", "parser3", "perl", "php", "profile",
"python", "renderman", "ruby", "rust", "scala", "smalltalk", "sql",
"tex", "vala", "vbscript", "vhdl", "xml" ];

var makePreviewHtml = function () {
  var text = editorSession.getValue();

  if (text && text == oldInputText) {
    return; // Input text hasn't changed.
  }
  else {
    oldInputText = text;
  }

  var prevTime = new Date().getTime();

  text = converter.makeHtml(text);

  // Calculate the processing time of the HTML creation.
  // It's used as the delay time in the event listener.
  var currTime = new Date().getTime();
  elapsedTime = currTime - prevTime;

  // Update the text using feature detection to support IE.
  // preview.innerHTML = text; // this doesn't work on IE.
  previewSet(text);

  // highlight code blocks.
  var codeElements = preview.getElementsByTagName("pre");
  var codeElementsLength = codeElements.length;
  var hlSpace = "  ";
  if (codeElementsLength > 0) {
    for (var idx = 0; idx < codeElementsLength; idx++) {
      var element = codeElements[idx];
      var codeHTML = element.innerHTML;

       // Only use pre tags marked containing code.
      if (codeHTML[0] !== "`")
       continue;

      var txt = codeHTML.split(/\b/);
      // the syntax for code highlighting means all code, even one line, contains newlines.
      if (txt.length > 1 && codeHTML.match(/\n/)) {
        // txt[0] must be "`"
        // txt[0] = "`"; txt[1] = "ruby"
        if (txt[0] !== "`" || $.inArray(txt[1], languages) === -1) {
          element.innerHTML = codeHTML.substring(1).trim();
          hljs.highlightBlock(element, hlSpace);
          continue;
        }

        element.className = txt[1] + " highlight";
        // length + 1 for the marker character.
        element.innerHTML = codeHTML.substring(txt[1].length+1).trim();
        hljs.highlightBlock(element, hlSpace);
      } else {
        element.innerHTML = codeHTML.substring(1).trim();
        hljs.highlightBlock(element, hlSpace);
      }
    }
  }
};

// setTimeout is already used.  Used as an event listener.
var applyTimeout = function () {
  if (timeout) {
    clearTimeout(timeout);
    timeout = undefined;
  }

  // 3 second max delay
  if (elapsedTime > 3000) {
    elapsedTime = 3000;
  }

  timeout = setTimeout(makePreviewHtml, elapsedTime);
};

  /* Load markdown from /data/page into the ace editor. */
  jQuery.ajax({
    type: "GET",
    url: "/data/" + $.key("page"),
    success: function(data) {
       editorSession.setValue(data);
    }
  });
 
  $("#save").click(function() {
    $.save();
  });

  // Hide dimmer, comment tool panel, and comment.
  $("#commentcancel").click(function() {
    // Restore focus on commentcancel but not on
    // savecommentconfirm because the latter loads
    // a new page.
    hideCommentWindow();
    editor.focus();
  });

  var isCommentHidden = true;

  function hideCommentWindow() {
    isCommentHidden = true;
    darkness.style.visibility = "hidden";
    commentToolPanel.style.visibility = "hidden";
    comment.style.visibility = "hidden";
  }

  // Show dimmer, comment tool panel, and comment.
  $("#savecomment").click(function() {
    isCommentHidden = false;
    darkness.style.visibility = "visible";
    commentToolPanel.style.visibility = "visible";
    comment.style.visibility = "visible";
    // Set focus so typing can begin immediately.
    commentEditor.focus();
  });

  $("#savecommentconfirm").click(function() {
    $.save(commentEditorSession.getValue());
    hideCommentWindow();
  });

  // onChange calls applyTimeout which rate limits the calling of makePreviewHtml based on render time.
  editor.on('change', applyTimeout);
  makePreviewHtml(); // preview default text on load

  function resize() {
    var width = $(window).width();
    var widthHalf = width / 2;
    var widthFourth = widthHalf / 2;
    var height = $(window).height();
    var heightHalf = height / 2;
 
    // height minus 50 so the end of document text doesn't flow off the page.
    var editorContainerStyle = "width:" + widthHalf + "px;" +
      "height:" + (height - 50) + "px;" + 
      "left:" + (leftRight === false ? widthHalf + "px;" : "0px;") +
      "top:" + "40px;"; // use 40px for tool menu
    cssSet( editorContainer, editorContainerStyle );
    editor.resize();

    // width -2 for scroll bar & -10 for left offset
    var previewStyle = "width:" + (widthHalf - 2 - 10) + "px;" +
      "height:" + height + "px;" +
      "left:" + (leftRight === false ? "10px;" : widthHalf + "px;") +
      "top:" + "0px;";
    cssSet( preview, previewStyle );

     // Resize tool panel
    var toolPanelStyle = "width:" + widthHalf + "px;" +
      "left:" + (leftRight === false ? widthHalf + "px;" : "0px;");
    cssSet( toolPanel, toolPanelStyle );

    // Resize comment related elements.
    var commentHidden = "visibility:" + ( isCommentHidden === true ? "hidden;" : "visible;" );

    // Adjust comment editor
    var commentEditorContainerStyle = "height:" + heightHalf + "px;" +
      "width:" + widthHalf + "px;" +
      "left:" + widthFourth + "px;" +
      "top:" + (heightHalf / 2) + "px;" +
      commentHidden;
    cssSet( commentEditorContainer, commentEditorContainerStyle );
    commentEditor.resize();

    // In top subtract height (40px) of comment tool panel.
    var commentToolPanelStyle = "width:" + widthHalf + "px;" +
      "left:" + widthFourth + "px;" +
      "top:" + (height / 4 - 40) + "px;" +
      commentHidden;
    cssSet( commentToolPanel, commentToolPanelStyle );

    // Resize dimmer.
    var darknessStyle = "width:" + width + "px;" +
      "height:" + height + "px;" +
      commentHidden;
    cssSet(darkness, darknessStyle);
  }

  window.jsm.resize = resize;

  /*
     Resize can be called an absurd amount of times
     and will crash the page without debouncing.
     http://benalman.com/projects/jquery-throttle-debounce-plugin/
     https://github.com/cowboy/jquery-throttle-debounce
     http://unscriptable.com/2009/03/20/debouncing-javascript-methods/
  */
  $(window).resize( $.debounce( 100, resize ) );

  // resize for the intial page load
  resize();
})();
