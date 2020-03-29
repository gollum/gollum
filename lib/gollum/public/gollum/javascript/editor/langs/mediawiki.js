/**
 *  MediaWiki Language Definition
 *  See default.js for documentation
 *
 */

(function($) {

// No need to set all the replacements, only those different from the default language (Markdown).
var MediaWiki = {

  'function-bold' :         {
                              replace: "'''$1'''$2"
                            },

  'function-italic' :       {
                              replace: "''$1''$2"
                            },
  'function-hr'     :       {
                              append: "\n---\n"
                            },

  'function-code'   :       {
                              replace: "<code>$1</code>$2"
                            },
  'function-ol'   :         {
                              link: function ( index, line) {
                                return '# ' + line + "\n";
                              } 
                            },
  'function-blockquote' :   {
                              replace: "<blockquote>\n$1$2\n</blockquote>",
                            },

  'function-h1' :           {
                              replace: "= $1$2 =",
                            },

  'function-h2' :           {
                              replace: "== $1$2 ==",
                            },

  'function-h3' :           {
                              replace: "=== $1$2 ===",
                            },

  'function-link' :         {
                              replace: function( res ) {
                                var rep = '';
                                if ( res['text'] && res['href'] ) {
                                  rep = '[' + res['href'] + ' | ' + res['text'] + ']';
                                }
                                return rep;
                              }
                            }
};

$.GollumEditor.defineLanguage('mediawiki', $.constructLanguageDefinition(MediaWiki));


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
