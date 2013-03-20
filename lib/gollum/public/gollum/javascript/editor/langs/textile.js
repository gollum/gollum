/**
 *  Textile Language Definition
 */
(function($) {

var Textile = {

  'function-bold' :         {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "*$1*$2"
                            },

  'function-italic' :       {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "_$1_$2"
                            },

  'function-hr'     :       {
                              append: "\n***\n"
                            },

  'function-code'   :       {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "<pre><code>$1</code></pre>$2"
                            },

  'function-ul'     :       {
                              search: /(.+)([\n]?)/gi,
                              replace: "* $1$2"
                            },

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
                                      $.GollumEditor.replaceSelection( h );
                                    }
                                  }
                                });
                              }
                            }

};

$.GollumEditor.defineLanguage('textile', Textile);


var TextileHelp = [
  {
    menuName: 'Phrase Modifiers',
    content: [
                {
                  menuName: 'Emphasis / Strength',
                  data: '<p>To place emphasis or strength on inline text, simply place <code>_</code> (underscores) around the text for emphasis or <code>*</code> (asterisks) around the text for strength. In most browsers, <code>_mytext_</code> will appear as italics and <code>*mytext*</code> will appear as bold.</p><p>To force italics or bold, simply double the characters: <code>__mytext__</code> will appear italic and <code>**mytext**</code> will appear as bold text.</p>'
                },
                {
                  menuName: 'Citations / Editing',
                  data: '<p>To display citations, wrap your text in <code>??</code> (two question marks).</p><p>To display edit marks such as deleted text (strikethrough) or inserted text (underlined text), wrap your text in <code>-</code> (minuses) or <code>+</code> (pluses). For example <code>-mytext-</code> will be rendered as <span style="text-decoration: line-through;">mytext</span> and <code>+mytext+</code> will be rendered as <span style="text-decoration: underline;">mytext</span></p>'
                },
                {
                  menuName: 'Superscript / Subscript',
                  data: '<p>To display superscript, wrap your text in <code>^</code> (carets). To display subscript, wrap your text in <code>~</code> (tildes).</p>'
                },
                {
                  menuName: 'Code',
                  data: '<p>To display monospace code, wrap your text in <code>@</code> (at symbol). For example, <code>@mytext@</code> will appear as <code>mytext</code>.</p>'
                },
                {
                  menuName: 'Acronyms',
                  data: '<p>To create an acronym, suffix the acronym with the definition in parentheses. For example, <code>JS(JavaScript)</code> will be displayed as <abbr title="JavaScript">JS</abbr>.</p>'
                }
              ]
  },
  {
    menuName: 'Block Modifiers',
    content: [
                {
                  menuName: 'Headings',
                  data: '<p>To display a heading in Textile, prefix your line of text with <code>hn.</code>, where <code>n</code> equals the heading size you want (1 is largest, 6 is smallest).</p>'
                },
                {
                  menuName: 'Paragraphs / Quotes',
                  data: '<p>To create a new paragraph, prefix your first line of a block of text with <code>p.</code>.</p><p>To create a blockquote, make sure at least one blank line exists between your text and any surrounding text, and then prefix that block with <code>bq.</code> If you need to extend a blockquote to more than one text block, write <code>bq..</code> (note the two periods) and prefix your next normal paragraph with <code>p.</code></p>'
                },
                {
                  menuName: 'Code Blocks',
                  data: '<p>Code blocks in textile are simply prefixed like any other block. To create a code block, place the beginning of the block on a separate line and prefix it with <code>bc.</code></p><p>To display a preformatted block, prefix the block with <code>pre.</code></p>'
                },
                {
                  menuName: 'Lists',
                  data: '<p>To create ordered lists, prefix each line with <code>#</code>. To create unordered lists, prefix each line with <code>*</code>.</p>'
                }
             ]
  },
  {
    menuName: 'Links / Images',
    content: [
               {
                 menuName: 'Links',
                 data: '<p>To display a link, put the text you want to display in quotes, then a colon (<code>:</code>), then the URL after the colon. For example <code>&quot;GitHub&quot;:http://github.com/</code> will appear as <a href="javascript:void(0);">GitHub</a>.</p>'
               },
               {
                 menuName: 'Images',
                 data: '<p>To display an image, simply wrap the image&rsquo;s URL in <code>!</code> (exclamation points). If you want to link the image to a URL, you can blend the image and link syntax: place your image URL in the exclamation points and suffix that with a colon and your URL. For example, an image at <code>http://myurl/image.png</code> that should link to <code>http://myurl/</code> should be written as <code>!http://myurl/image.png!:http://myurl/</code>.</p>'
               }
             ]
  }
];

$.GollumEditor.defineHelp('textile', TextileHelp);

})(jQuery);
