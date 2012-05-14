/**
 *  Org-mode Language Definition
**/
(function($) {

var OrgMode = {

  'function-bold' :         {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "*$1*$2"
                            },

  'function-italic' :       {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "/$1/$2"
                            },

  'function-code'   :       {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "=$1=$2"
                            },

  'function-ul'     :       {
                              search: /(.+)([\n]?)/g,
                              replace: "* $1$2"
                            },

  /* This works, just like it works for Markdown */
  'function-ol'   :         {
                              search: /(.+)([\n]?)/g,
                              replace: "1. $1$2"
                            },

  'function-blockquote' :   {
                              search: /(.+)([\n]?)/g,
                              replace: "#+BEGIN_QUOTE\n$1$2\n#+END_QUOTE\n"
                            },

  'function-h1'         :   {
                              search: /(.+)([\n]?)/g,
                              replace: "* $1$2"
                            },

  'function-h2'         :   {
                              search: /(.+)([\n]?)/g,
                              replace: "** $1$2"
                            },

  'function-h3'         :   {
                              search: /(.+)([\n]?)/g,
                              replace: "*** $1$2"
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
                                      defaultValue: selText
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
                                      rep = '[[' + res['href'] + '][' +
                                             res['text'] + ']]';
                                    }
                                    else if ( res['href'] ) {
                                      rep = '[[' + res['href'] + ']]';
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
                                      type: 'text'
                                    }
                                  ],
                                  OK: function( res ) {
                                    var rep = '';
                                    if ( res['url'] ) {
                                      rep = '[[' + res['url'] + ']]';
                                    }
                                    $.GollumEditor.replaceSelection( rep );
                                  }
                                });
                              }
                            }

};

var OrgModeHelp = [

  {
    menuName: 'Block Elements',
    content: [
                {
                  menuName: 'Paragraphs &amp; Breaks',
                  data: '<p>To create a paragraph, simply create a block of text that is not separated by one or more blank lines. Blocks of text separated by one or more blank lines will be parsed as paragraphs.</p>'
                },
                {
                  menuName: 'Headers',
                  data: '<p>Simply prefix your header text with the number of <code>*</code> characters to specify heading depth. For example: <code>* Header 1</code>, <code>** Header 2</code> and <code>*** Header 3</code> will be progressively smaller headers.</p>'
                },
                {
                  menuName: 'Blockquotes',
                  data: '<p>To create a blockquote, simple embed the text between <code>#+BEGIN_QUOTE</code> and <code>#+END_QUOTE</code>. An example quote block is displayed below:<br><code>#+BEGIN_QUOTE<br>This is my quote block. Quote something nice here, otherwise there is no point in quoting.<br>#+END_QUOTE</code></p>'
                },
                {
                  menuName: 'Lists',
                  data: '<p>Org-mode supports both ordered and unordered lists. To create an ordered list, simply prefix each line with a number (any number will do &mdash; this is why the editor only uses one number.) To create an unordered list, you can prefix each line with <code>+</code> or <code>-</code>.</p>'
                },
                {
                  menuName: 'Code Blocks',
                  data: '<p>Code Blocks are similar to blockquote, except that <code>#+BEGIN_EXAMPLE</code> and <code>#+END_EXAMPLE</code> are used.</p>'
                },
                {
                  menuName: 'Tables',
                  data: '<p>Org-mode supports simple tables (tables with equal number of cells in each row). To create a simple table, just separate the contents of each cell with a <code>|</code> character. For example, <br><br><code>|one|two|three|<br>|four|five|six|</code><br><br> will appear as a table with two rows and three columns.  Additionally, <br><br><code>|one|two|three|<br>|---+---+-----|<br>|four|five|six|</code><br><br> will also appear as a table, but the first row will be interpreted as a header row and the <code>&lt;th&gt;</code> tag will be used to render it. </p>'
                }
              ]
  },

  {
    menuName: 'Span Elements',
    content: [
                {
                  menuName: 'Links',
                  data: '<p>To create links to external pages, you need to enclose the URI in double square brackets. (i.e., <code>[[http://github.com/]]</code> will automatically be parsed to <a href="javascript:void(0);">http://github.com/</a>)If you want to add text, to be displayed to the user, you write the URI and the text next to each other, both enclosed in square brackets and both of them together enclosed in another pair of square brackets. For example, if you want your link to display the text &ldquo;GitHub&rdquo;, you write <code>[[http://github.com][GitHub]]</code>.</p>'
                },

                {
                  menuName: 'Emphasis',
                  data: '<p>Forward slashes (<code>/</code>) are treated as emphasis and are wrapped with an <code>&lt;i&gt;</code> tag. Asterisks (<code>*</code>) are treated as bold using the <code>&lt;b&gt;</code> tag.</p>'
                },

                {
                  menuName: 'Code',
                  data: '<p>To create inline spans of code, simply wrap the code in equal signs (<code>=</code>). Orgmode will turn <code>=myFunction=</code> into <code>myFunction</code>.</p>'
                },

                {
                  menuName: 'Images',
                  data: "<p>Org-mode image syntax is exactly same as the syntax that you would use for a URI to link to itself. The image URI is enclosed in double square brackets. Alt text on images is not currently supported by Gollum's Org-mode parser.</p>"
                }
              ]
  }
];


$.GollumEditor.defineLanguage('org', OrgMode);
$.GollumEditor.defineHelp('org', OrgModeHelp);

})(jQuery);
