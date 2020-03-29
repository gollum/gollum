/**
 *  Creole Language Definition
 *  See default.js for documentation
 *
 */
(function($) {

  // No need to set all the replacements, only those different from the default language (Markdown).
  var Creole = {

    'function-italic':                {
                                        'replace': "//$1//$2"
                                      },

    'function-code':                  {
                                        'replace': "{{{$1}}}$2"
                                      },

    'function-hr':                    {
                                        'append': "\n\n----\n\n"
                                      },

    'function-blockquote':            undefined,

    'function-ol':                    {
                                        'line': function ( index, line) {
                                          return '# ' + line + "\n";
                                        } 
                                      },

    'function-h1':                    {
                                        'replace': "== $1$2"
                                      },

    'function-h2':                    {
                                        'replace': "=== $1$2"
                                      },

    'function-h3':                    {
                                        'replace': "==== $1$2"
                                      },

    'function-link':                  {
                                        'replace': function ( res ) {
                                          var rep = '';
                                          if ( res['text'] && res['href'] ) {
                                            rep = '[[' + res['href'] + '|' + res['text'] + ']]';
                                          }
                                          return rep;
                                        }
                                      },

    'function-image':                 {
                                        'replace': function ( res ) {
                                          var rep = '';
                                          if ( res['url'] && res['alt'] ) {
                                            rep = '{{' + res['url'];
                                            if ( res['alt'] != '' ) {
                                              rep += '|' + res['alt'];
                                            }
                                            rep = rep + '}}';
                                          }
                                          return rep;
                                        }
                                      }
  };

$.GollumEditor.defineLanguage('creole', $.constructLanguageDefinition(Creole));

})(jQuery);