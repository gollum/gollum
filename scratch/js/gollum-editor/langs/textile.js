/**
 *  Textile Language Definition
 */
(function() {

var Textile = {
  
  'function-bold' :         {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "*$1*$2"
                            },
  
  'function-italic' :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "_$1_$2"
                            },
                            
  'function-hr'     :       {
                              append: "\n***\n"
                            },
  
  'function-code'   :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "<pre><code>$1</code></pre>$2"
                            },
  
  'function-ul'     :       { 
                              search: /(.+)([\n]?)/gi,
                              replace: "* $1$2"
                            },
  
  /* This looks silly but is completely valid Markdown */                     
  'function-ol'   :         {
                              search: /(.+)([\n]?)/gi,
                              replace: "# $1$2"
                            },
                            
  'function-blockquote' :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "bq. $1$2"
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
                                   var h = '';
                                   if ( res['text'] && res['href'] ) {
                                      h = '"' + res['text'] + '":' +
                                          res['href'];
                                   }
                                   $.GollumEditor.replaceSelection( h );
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
                                    if ( res['url'] ) {
                                      var h = '!' + res['url'];
                                      if ( res['alt'] != '' ) {
                                        h += '(' + res['alt'] + ')';
                                      }
                                      h += '!';
                                      %.GollumEditor.replaceSelection( h );
                                    }
                                  }
                                });
                              }
                            }
                            
};

jQuery.GollumEditor.defineLanguage('textile', Textile);

})();
