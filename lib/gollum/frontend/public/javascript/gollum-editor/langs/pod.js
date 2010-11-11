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

var Pod = {
  
  'function-bold' :         {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "B<$1>$2"
                            },
  
  'function-italic' :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "I<$1>$2"
                            },
  
  'function-code'   :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "C<$1>$2"
                            },
                            
  'function-h1'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "=head1 $1$2"
                            },
                            
  'function-h2'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "=head2 $1$2"
                            },
                            
  'function-h3'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "=head3 $1$2"
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
                                      rep = 'L<' + res['text'] + '|' 
                                             + res['href'] + '>';
                                    }
                                    $.GollumEditor.replaceSelection( rep );
                                  }
                                }); 
                              }
                            }
                            
};

jQuery.GollumEditor.defineLanguage('pod', Pod);

})();
