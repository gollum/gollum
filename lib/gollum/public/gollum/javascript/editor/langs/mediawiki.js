/**
 *  MediaWiki Language Definition
 *
 */

(function($) {

var MediaWiki = {

  'function-bold' :         {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "'''$1'''$2"
                            },

  'function-italic' :       {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "''$1''$2"
                            },
  'function-hr'     :       {
                              append: "\n---\n"
                            },

  'function-code'   :       {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "<code>$1</code>$2"
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

  'function-blockquote' :   {
                              search: /(.+)([\n]?)/g,
                              replace: "<blockquote>\n$1$2\n</blockquote>",
                              break_line: true,
                            },

  'function-h1' :           {
                              search: /(.+)([\n]?)/g,
                              replace: "= $1$2 =",
                              break_line: true,
                              whole_line: true
                            },

  'function-h2' :           {
                              search: /(.+)([\n]?)/g,
                              replace: "== $1$2 ==",
                              break_line: true,
                              whole_line: true
                            },

  'function-h3' :           {
                              search: /(.+)([\n]?)/g,
                              replace: "=== $1$2 ===",
                              break_line: true,
                              whole_line: true
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
                                      h = '[' + res['href'] + ' | ' +
                                             res['text'] + ']';
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

$.GollumEditor.defineLanguage('mediawiki', MediaWiki);


var MediaWikiHelp = [
  {
    menuName: 'Text Formatting',
    content: [
      {
        menuName: 'Headers',
        data: '<p>MediaWiki headers are written with different indentation using <code>= Title =</code> (equals sign). MediaWiki supports headings 1-6.</p>'
      },
      {
        menuName: 'Bold / Italic',
        data: "<p>To display text as <strong>bold</strong>, wrap the text in <code>'''</code>. To display text as <em>italic</em>, wrap the text in <code>''</code>. To create <code>monospace</code> text, wrap the text in <code>&lt;code&gt;&lt;/code&gt;</code>."
      },
      {
        menuName: 'Special Characters',
        data: '<p>Use HTML special characters, e.g. <code>&copy;</code> or <code>&euro;</code></p>'
      }
    ]
  },
  {
    menuName: 'Blocks',
    content: [
      {
        menuName: 'Paragraphs',
        data: '<p>MediaWiki ignores single line breaks. To start a new paragraph, leave an empty line. You can force a line break within a paragraph with the HTML tag <code><br /></code>.</p>'
      },
      {
        menuName: 'Tables',
        data: '<p>Tables may be authored in wiki pages using either XHTML table elements directly, or using wikicode formatting to define the table. Wikitable syntax overview: ' +
'<table cellpadding="5" cellspacing="0" border="1">' +
'<tr><td><pre> <code>{|</code></pre>' + 
'</td><td><b>table start</b></td></tr>' +
'<tr><td><pre> <code>|+</code></pre></td>' +
'<td>table <b>caption,</b> <i>optional;</i> only between <b>table start</b> and first <b>table row</b></td></tr>' +
'<tr><td><pre> <code>|-</code></pre></td>' +
'<td><b>table row,</b> <i>optional on first row</i> -- wiki engine assumes the first row</td></tr>' + 
'<tr><td><pre> <code>!</code></pre></td>' + 
'<td><b>table header</b> cell, <i>optional.</i> Consecutive <b>table header</b> cells may be added on same line separated by double marks (<code>!!</code>) or start on new lines, each with its own single mark (<code>!</code>).</td></tr>' +
'<tr><td><pre> <code>|</code></pre></td>' +
'<td><b>table data</b> cell, <i>required!</i> Consecutive <b>table data</b> cells may be added on same line separated by double marks (<code>||</code>) or start on new lines, each with its own single mark (<code>|</code>).</td></tr>' +
'<tr><td><pre> <code>|}</code></pre></td>' +
'<td><b>table end</b></td></tr></table></p>'
      }
    ]
  },
  {
    menuName: 'Macros',
    content: [
      {
        menuName: 'Links',
        data: '<p>To create links to external pages, use single brackets, e.g. <code>[https://mediawiki.org MediaWiki]</code>. Internal links use double brackets: <code>[[Main Page]]</code>. To define the link text, use <code>[[Main Page | this is displayed]]</code> (note: the order of the URL/Page Name and the link text is reversed compared to Gollum pages in other markups).</p>'
      },
      {
        menuName: 'Images',
        data: '<p>Use Gollum internal links, e.g. <code>[[sauron.jpg]]<code>, to insert images.'
      }
    ]
  }
];

$.GollumEditor.defineHelp('mediawiki', MediaWikiHelp);

})(jQuery);
