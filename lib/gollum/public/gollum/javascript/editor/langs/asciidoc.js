/**
 *  AsciiDoc Language Definition
 *
 */

(function($) {

var AsciiDoc = {

  'function-bold' :         {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "*$1*$2"
                            },

  'function-italic' :       {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "_$1_$2"
                            },

  'function-code'   :       {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "`$1`$2"
                            },

  'function-ul'     :       {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "* $1$2"
                            },

  'function-ol'   :         {
                              search: /(.+)([\n]?)/g,
                              replace: ". $1$2"
                            },

  'function-blockquote' :   {
                              search: /(.+)([\n]?)/g,
                              replace: "----\n$1$2\n----\n"
                            },

  'function-h1' :           {
                              search: /(.+)([\n]?)/g,
                              replace: "= $1$2"
                            },

  'function-h2' :           {
                              search: /(.+)([\n]?)/g,
                              replace: "== $1$2"
                            },

  'function-h3' :           {
                              search: /(.+)([\n]?)/g,
                              replace: "=== $1$2"
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
                                      h = res['href'] + '[' +
                                          res['text'] + ']';
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
                                    var h = '';
                                    if ( res['url'] && res['alt'] ) {
                                      h = 'image::' + res['url'] +
                                          '[' + res['alt'] + ']';
                                    }
                                    $.GollumEditor.replaceSelection( h );
                                  }
                                });
                              }
                            }

};

$.GollumEditor.defineLanguage('asciidoc', AsciiDoc);


var AsciiDocHelp = [
  {
    menuName: 'Text Formatting',
    content: [
      {
        menuName: 'Headers',
        data: '<p>AsciiDoc headers can be written in two ways: with differing underlines or with different indentation using <code>=</code> (equals sign). AsciiDoc supports headings 1-4. The editor will automatically use the <code>=</code> notation. To create a level one header, prefix your line with one <code>=</code>. Level two headers are created with <code>==</code> and so on.</p>'
      },
      {
        menuName: 'Bold / Italic',
        data: '<p>To display text as <strong>bold</strong>, wrap the text in <code>*</code> (asterisks). To display text as <em>italic</em>, wrap the text in <code>_</code> (underscores). To create <code>monospace</code> text, wrap the text in <code>`</code> (backtick).'
      },
      {
        menuName: 'Scripts',
        data: '<p>Superscript and subscript is created the same way as other inline formats. To create superscript text, wrap your text in <code>^</code> (carats). To create subscript text, wrap your text in <code>~</code> (tildes).</p>'
      },
      {
        menuName: 'Special Characters',
        data: '<p>AsciiDoc will automatically convert textual representations of commonly-used special characters. For example, <code>(R)</code> becomes &reg;, <code>(C)</code> becomes &copy; and <code>(TM)</code> becomes &trade;.</p>'
      }
    ]
  },
  {
    menuName: 'Blocks',
    content: [
      {
        menuName: 'Paragraphs',
        data: '<p>AsciiDoc allows paragraphs to have optional titles or icons to denote special sections. To make a normal paragraph, simply add a line between blocks and a new paragraph will start. If you want to title your paragraphs, adda line prefixed by <code>.</code> (full stop). An example paragraph with optional title is displayed below:<br><br><code>.Optional Title<br><br>This is my paragraph. It is two sentences long.</code></p>'
      },
      {
        menuName: 'Source Blocks',
        data: '<p>To create source blocks (long blocks of code), follow the same syntax as above but with an extra line denoting the inline source and lines of four dashes (<code>----</code>) delimiting the source block.. An example of Python source is below:<br><br><code>.python.py<br>[source,python]<br>----<br># i just wrote a comment in python<br># and maybe one more<br>----</code></p>'
      },
      {
        menuName: 'Comment Blocks',
        data: '<p>Comment blocks are useful if you want to keep notes for yourself inline but do not want them displayed to the public. To create a comment block, simply wrap the paragraph in dividers with four slashes (<code>////</code>). An example comment block is below:<br><br><code>////<br>My comment block is here now<br><br>It can be multiple paragraphs. Really.<br>////</p>'
      },
      {
        menuName: 'Quote Blocks',
        data: '<p>Quote blocks work much like comment blocks &mdash; simply create dividers using four underscores (<code>____</code>) around your quote. An example quote block is displayed below:<br><code>____<br>This is my quote block. Quote something nice here, otherwise there is no point in quoting.<br>____</code></p>'
      }
    ]
  },
  {
    menuName: 'Macros',
    content: [
      {
        menuName: 'Links',
        data: '<p>To create links to external pages, you can simply write the URI if you want the URI to link to itself. (i.e., <code>http://github.com/</code> will automatically be parsed to <a href="javascript:void(0);">http://github.com/</a>. If you want different text to be displayed, simply append it to the end of the URI in between <code>[</code> (brackets.) For example, <code>http://github.com/[GitHub]</code> will be parsed as <a href="javascript:void(0);">GitHub</a>, with the URI pointing to <code>http://github.com</code>.</p>'
      },
      {
        menuName: 'Images',
        data: '<p>Images in AsciiDoc work much like hyperlinks, but image URLs are prefixed with <code>image:</code>. For example, to link to an image at <code>images/icons/home.png</code>, write <code>image:images/icons/home.png</code>. Alt text can be added by appending the text to the URI in <code>[</code> (brackets).</p>'
      }
    ]
  }
];

$.GollumEditor.defineHelp('asciidoc', AsciiDocHelp);

})(jQuery);
