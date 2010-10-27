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

var MarkDown = {
  
  'function-bold' :         {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "**$1**$2"
                            },
  
  'function-italic' :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "_$1_$2"
                            },
  
  'function-code'   :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "`$1`$2"
                            },
                            
  'function-hr'     :       {
                              append: "\n***\n"
                            },
  
  'function-ul'   :         { 
                              search: /(.+)([\n]?)/gi,
                              replace: "* $1$2"
                            }

};

// this is necessary for GollumEditor to pick this up
jQuery.GollumEditor.defineLanguage('markdown', MarkDown);