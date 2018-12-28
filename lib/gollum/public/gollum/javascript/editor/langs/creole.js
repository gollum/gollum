/**
 *  Creole Language Definition
 *
 */
(function($) {

var Creole = {

  'function-bold' :         {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "**$1**$2"
                            },

  'function-italic' :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "//$1//$2"
                            },

  'function-code'   :       {
                              search: /([^\n]+)([\n]*)/gi,
                              replace: "{{{$1}}}$2"
                            },

  'function-hr'     :       {
                              append: "\n\n----\n\n"
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

  /* This looks silly but is completely valid Markdown */
  'function-ol'   :         {
                              exec: function( txt, selText, $field ) {
                                var repText = '';
                                var lines = selText.split("\n");
                                for ( var i = 0; i < lines.length; i++ ) {
                                  repText += '# ' + lines[i] + "\n";
                                }
                                repText = repText.substring(0, repText.length-1)
                                $.GollumEditor.replaceSelection( repText, true, true );
                              },
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
                                      help: 'The text to display to the user.',
                                      defaultValue: selText
                                    },
                                    {
                                      id:   'href',
                                      name: 'URL',
                                      type: 'text',
                                      help: 'The URL to link to.'
                                    }
                                  ],
                                  OK: function( res ) {
                                   var h = '[[' + res['href'] + '|' +
                                           res['text'] + ']]';
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
                                    var h = '';
                                    if ( res['url'] && res['alt'] ) {
                                      h = '{{' + res['url'];
                                      if ( res['alt'] != '' ) {
                                        h += '|' + res['alt'] + '}}';
                                      }
                                    }
                                    $.GollumEditor.replaceSelection( h );
                                  }
                                });
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

$.GollumEditor.defineLanguage('creole', Creole);

})(jQuery);
