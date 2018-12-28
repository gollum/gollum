/**
 *  Markdown Language Definition
 *
 *  A language definition for string manipulation operations, in this case
 *  for the Markdown, uh, markup language. Uses regexes for various functions
 *  by default. If regexes won't do and you need to do some serious
 *  manipulation, you can declare a function in the object instead.
 *
 *  Code example:
 *  'functionbar-id'  :   {
 *                          exec: function(text, selectedText) {
 *                                   functionStuffHere();
 *                                },
 *                          search: /somesearchregex/gi,
 *                          replace: 'replace text for RegExp.replace',
 *                          append: "just add this where the cursor is"
 *                         }
 *
**/
(function($) {

var RDoc = {

  'function-bold' :         {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "((*$1*))$2"
                            },
  'function-code'   :       {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "(({$1}))$2"
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

  'function-ol'   :         {
                              exec: function( txt, selText, $field ) {
                                var repText = '';
                                var lines = selText.split("\n");
                                for ( var i = 0; i < lines.length; i++ ) {
                                  repText += (i+1).toString() + '. ' +
                                  lines[i] + "\n";
                                }
                                repText = repText.substring(0, repText.length-1)
                                $.GollumEditor.replaceSelection( repText, true, true );
                              },
                            },

  'function-h1'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "= $1$2",
                              break_line: true,
                              whole_line: true
                            },

  'function-h2'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "== $1$2",
                              break_line: true,
                              whole_line: true
                            },

  'function-h3'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "=== $1$2",
                              break_line: true,
                              whole_line: true
                            }

};

$.GollumEditor.defineLanguage('rdoc', RDoc);

})(jQuery);
