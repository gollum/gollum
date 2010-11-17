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
(function() {

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
  
  'function-ul'     :       { 
                              search: /(.+)([\n]?)/gi,
                              replace: "* $1$2"
                            },
  
  /* This looks silly but is completely valid Markdown */                     
  'function-ol'   :         {
                              search: /(.+)([\n]?)/gi,
                              replace: "1. $1$2"
                            },
                            
  'function-blockquote' :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "> $1$2"
                            }, 
                            
  'function-h1'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "# $1$2"
                            },
                            
  'function-h2'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "## $1$2"
                            },
                            
  'function-h3'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "### $1$2"
                            },
                            
  'function-link'       :   {
                              exec: function( txt, selText, $field ) {
                                var results = null;
                                $.GollumEditor.Dialog.init({
                                  title: 'Insert Link',
                                  fields: [
                                    {
                                      id:   'text',
                                      name: 'Link Text',
                                      type: 'text'
                                    },
                                    {
                                      id:   'href',
                                      name: 'URL',
                                      type: 'text'
                                    }
                                  ],
                                  OK: function( res ) {
                                   var rep = '';
                                   if ( res['text'] && res['href'] ) {
                                      rep = '[' + res['text'] + '](' 
                                             + res['href'] + ')';
                                    }
                                    $.GollumEditor.replaceSelection( rep );
                                  }
                                }); 
                              }
                            },
                     
  'function-image'      :   {
                              exec: function( txt, selText, $field ) {
                                var results = null;
                                $.GollumEditor.Dialog.init({
                                  title: 'Insert Image',
                                  fields: [
                                    {
                                      id: 'url',
                                      name: 'Image URL',
                                      type: 'code'
                                    },
                                    {
                                      id: 'alt',
                                      name: 'Alt Text',
                                      type: 'text'
                                    }
                                  ],
                                  OK: function( res ) {
                                    var rep = '';
                                    if ( res['url'] && res['alt'] ) {
                                      rep = '![' + res['alt'] + ']' +
                                            '(' + res['url'] + ')';
                                    }
                                    $.GollumEditor.replaceSelection( rep );
                                  }
                                });
                              }
                            }
                            
};

var MarkDownHelp = [

  {
    menuName: 'Formatting',
    content: [
                {
                  menuName: 'Inline Text',
                  data: '<p>Inline Text goes here</p>;'
                }
              ]
  },
  
  {
    menuName: 'Links and Images',
    content: [
                {
                  menuName: 'Links',
                  data: '<p>Links and Images go here</p>'
                }
              ]
  }

];


jQuery.GollumEditor.defineLanguage('markdown', MarkDown);
jQuery.GollumEditor.defineHelp('markdown', MarkDownHelp);

})();
