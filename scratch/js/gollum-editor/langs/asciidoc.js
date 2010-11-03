/**
 *  ASCIIDoc Language Definition
 *
 */

(function() {

var ASCIIDoc = {
  
  'function-bold' :         {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "*$1*$2"
                            },
  
  'function-italic' :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "_$1_$2"
                            },
  
  'function-code'   :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "+$1+$2"
                            },
  
  'function-ul'     :       { 
                              search: /(.+)([\n]?)/gi,
                              replace: "* $1$2"
                            },
  
  /* This looks silly but is completely valid Markdown */                     
  'function-ol'   :         {
                              search: /(.+)([\n]?)/gi,
                              replace: ". $1$2"
                            },
                            
  'function-blockquote' :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "----\n$1$2\n----\n"
                            },
                            
  'function-link'       :   {
                              exec: function( txt, selText, $field ) {
                                var results = null;
                                $.GollumEditor.Dialog({
                                  title: 'Insert Link',
                                  fields: [
                                    {
                                      id:   'text',
                                      name: 'Link Text',
                                      type: 'text',
                                      help: 'The text to display to the user.'
                                    },
                                    {
                                      id:   'href',
                                      name: 'URL',
                                      type: 'text',
                                      help: 'The URL to link to.'
                                    }
                                  ],
                                  OK: function( res ) {
                                   if ( res['text'] && res['href'] ) {
                                      return res['href'] + '[' + 
                                             res['text'] + ']';
                                    }
                                    else
                                      return '';
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
                                      type: 'text'
                                    },
                                    {
                                      id: 'alt',
                                      name: 'Alt Text',
                                      type: 'text'
                                    }
                                  ],
                                  OK: function( res ) {
                                    if ( res['url'] && res['alt'] ) {
                                      return 'image::' + res['url'] +
                                             '[' + res['alt'] + ']';
                                    } else
                                      return '';
                                  }
                                });
                              }
                            }
                            
};


// this is necessary for GollumEditor to pick this up
jQuery.GollumEditor.defineLanguage('markdown', ASCIIDoc);

})();
