/**
 *  Default Language Definition
 *
 *  A language definition for string manipulation operations which can be used
 *  to customize others. The default rules describe the Markdown markup
 *  language (so the Markdown defintion is just a clone of $DefaultLanguage).
 *  Language definitions use regexes for various functions by default.
 *  If regexes won't do and you need to do some serious manipulation,
 *  you can declare a function in the object instead.
 *
 *
**/
(function($) {

  var initDialog = function( title, fields, onResult) {
    var results = null;
    $.GollumEditor.Dialog.init({
      title: title,
      fields: fields,
      OK: function( res ) {
        $.GollumEditor.replaceSelection( onResult(res) );
      }
    });
  };

  $.DefaultLang = {

    'function-bold' :         {
                                search: /([^\n]+)([\n\s]*)/g,
                                replace: "**$1**$2"
                              },

    'function-italic' :       {
                                search: /([^\n]+)([\n\s]*)/g,
                                replace: "_$1_$2"
                              },

    'function-code'   :       {
                                search: /([^\n]+)([\n\s]*)/g,
                                replace: "`$1`$2"
                              },

    'function-hr'     :       {
                                append: "\n***\n"
                              },

    'function-ul'     :       {
                                exec: function( txt, selText, $field ) {
                                  var repText = '';
                                  var lines = selText.split("\n");
                                  for ( var i = 0; i < lines.length; i++ ) {
                                    repText += '* ' + lines[i] + "\n";
                                  }
                                  repText = repText.substring(0, repText.length-1)
                                  $.GollumEditor.replaceSelection( repText, true, true );
                                },
                              },
    /* based on rdoc.js */
    'function-ol'   :         {
                                line: function ( index, line) {
                                  // This function generates the markup for a line of the ol, based on the line number (index) and the content of the line (line).
                                  // Override this function for alternative markups when needed.
                                  return index.toString() + '. ' + line + "\n"; // result e.g. "1. Previously existing text\n"
                                },
                                exec: function( txt, selText, $field ) {
                                  var repText = '';
                                  var lines = selText.split("\n");
                                  for ( var i = 0; i < lines.length; i++ ) {
                                    repText += this.line(i+1, lines[i]);
                                  }
                                  repText = repText.substring(0, repText.length-1)
                                  $.GollumEditor.replaceSelection( repText, true, true );
                                },
                              },

    'function-blockquote' :   {
                                search: /(.+)([\n]?)/g,
                                replace: "> $1$2",
                                break_line: true,
                              },

    'function-h1'         :   {
                                search: /(.+)([\n]?)/g,
                                replace: "# $1$2",
                                break_line: true,
                                whole_line: true
                              },

    'function-h2'         :   {
                                search: /(.+)([\n]?)/g,
                                replace: "## $1$2",
                                break_line: true,
                                whole_line: true
                              },

    'function-h3'         :   {
                                search: /(.+)([\n]?)/g,
                                replace: "### $1$2",
                                break_line: true,
                                whole_line: true
                              },

    'function-link'       :   {
                                replace: function ( res ) {
                                  // The replace function generates the markup to be inserted from the result of the Dialog (res).
                                  // Set a different replace function if your markup requires it.
                                  var rep = '';
                                  if ( res['text'] && res['href'] ) {
                                    rep = '[' + res['text'] + '](' + res['href'] + ')';
                                  }
                                  return rep;
                                },
                                exec: function (txt, selText, $field) {
                                  initDialog('Insert Link', [
                                      {
                                        id:   'text',
                                        name: 'Link Text',
                                        type: 'text',
                                        defaultValue: selText
                                      },
                                      {
                                        id:   'href',
                                        name: 'URL',
                                        type: 'text'
                                      }
                                    ], this.replace)
                                }
                              },
    'function-image'      :   {
                                replace: function( res ) {
                                  // The replace function generates the markup to be inserted from the result of the Dialog (res).
                                  // Set a different replace function if your markup requires it.
                                  var rep = '';
                                  if ( res['url'] && res['alt'] ) {
                                    rep = '![' + res['alt'] + ']' + '(' + res['url'] + ')';
                                  }
                                  return rep;
                                },
                                exec: function (txt, selText, $field) {
                                  initDialog('Insert Image', [
                                      {
                                        id:   'url',
                                        name: 'Image Url',
                                        type: 'text',
                                        defaultValue: selText
                                      },
                                      {
                                        id:   'alt',
                                        name: 'Alt Text',
                                        type: 'text'
                                      }
                                    ], this.replace)
                                }
                              },
    'function-critic-accept' : {
                                  exec: function( txt, selText, $field) {
                                    var toReplace = selText.
                                      replace(/\{\+\+(.*?)\+\+[ \t]*(\[(.*?)\])?[ \t]*\}/gm, "$1").
                                      replace(/\{--(.*?)--[ \t]*(\[(.*?)\])?[ \t]*\}/gm, "").
                                      replace(/\{~~(.*?)~>(.*?)~~\}/gm, "$2").
                                      replace(/\{\=\=(.*?)[ \t]*(\[(.*?)\])?[ \t]*\=\=\}{>>(.*?)<<\}/gm, "$1").
                                      replace(/\{>>(.*?)<<\}/gm, "")
                                    $.GollumEditor.replaceSelection( toReplace );
                                  }
        
                              },
    
    'function-critic-reject' : {
                                  exec: function( txt, selText, $field) {
                                    var toReplace = selText.
                                      replace(/\{\+\+(.*?)\+\+[ \t]*(\[(.*?)\])?[ \t]*\}/gm, "").
                                      replace(/\{--(.*?)--[ \t]*(\[(.*?)\])?[ \t]*\}/gm, "$1").
                                      replace(/\{~~(.*?)~>(.*?)~~\}/gm, "$1").
                                      replace(/\{\=\=(.*?)[ \t]*(\[(.*?)\])?[ \t]*\=\=\}{>>(.*?)<<\}/gm, "$1").
                                      replace(/\{>>(.*?)<<\}/gm, "")
                                    $.GollumEditor.replaceSelection( toReplace );
                                  }
        
                               }

  };

})(jQuery);
