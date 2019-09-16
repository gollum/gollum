/**
 *  reStructuredText Language Definition
 *  See default.js for documentation
 *
**/
(function($) {


  var headerFunc = function (selText, selectedRange, symbol) {
      var linebreak = '';
      var repText = ''

      if ( !selText.length ) {
        repText = 'Title here'
      } else {
        repText = selText;
      }

      adornment = symbol.repeat(repText.length);
      repText = repText + "\n" + adornment + "\n";
      $.GollumEditor.replaceSelection(repText, false, false, selectedRange);
  };

  // No need to set all the replacements, only those different from the default language (Markdown).
  var reStructuredText = {

    'function-bold' :         {
                                replace: "**$1**$2"
                              },

    'function-italic' :       {
                                replace: "*$1*$2"
                              },

    'function-code'   :       {
                                replace: "``$1``$2"
                              },

    'function-hr'     :       {
                                append: "\n\n----\n\n"
                              },

    'function-blockquote' :   { 
                                exec: function( txt, selText, $field) {
                                  var pfx = "    ";
                                  var lines = selText.split("\n");
                                  for ( var i = 0; i < lines.length; i++ ) {
                                      lines[i] = pfx + lines[i];
                                  }
                                  var repText = lines.join("\n");
                                  $.GollumEditor.replaceSelection(repText);
                                }
                              },
                              
    'function-h1'         :   { 
                                symbol: '=',
                                exec: function( txt, selText, $field, selectedRange) {
                                  headerFunc(selText, selectedRange, this.symbol);
                                }
                              },

    'function-h2'         :   { 
                                symbol: '-',
                                exec: function( txt, selText, $field, selectedRange) {
                                  headerFunc(selText, selectedRange, this.symbol);
                                }

                              },
                              
    'function-h3'         :   { 
                                symbol: '~',
                                exec: function( txt, selText, $field, selectedRange) {
                                  headerFunc(selText, selectedRange, this.symbol);
                                }
                              },

    'function-link'       :   {
                                replace: function( res ) {
                                 var rep = '';
                                 if ( res['text'] && res['href'] ) {
                                    rep = '`' + res['text'] + ' ' + '<' + res['href'] + '>`_';
                                  }
                                  return rep;
                                }
                              },

    'function-image'      :   {
                                replace: function( res ) {
                                  var rep = '';
                                  if ( res['url'] && res['alt'] ) {
                                    rep = '.. image:: ' + res['url'] + "\n" + '    :alt: ' + res['alt'];
                                  }
                                  return rep;
                                }
                              },

    'gollum-helpers'      :   {

                                'find-header-line': function (line, token) {
                                  // For use in sections.js
                                  // Return an array containing the text of the header and the previous line number.
                                  var foundLine = line-1;
                                  var text = window.ace_editor.getSession().getLine(foundLine);
                                  if (foundLine >= 0 && !/^\s+$/.test(text)) { // Sanity check
                                    return [text, foundLine];
                                  }
                                  else {
                                    return null;
                                  }
                              }
                              }

  };

  $.GollumEditor.defineLanguage('rst', $.constructLanguageDefinition(reStructuredText));

  var reStructuredTextHelp = [

    {
      menuName: 'Block Elements',
      content: [
                  {
                    menuName: 'Paragraphs &amp; Breaks',
                    data: '<p>To create a paragraph, simply create a block of text that is not separated by one or more blank lines. Blocks of text separated by one or more blank lines will be parsed as paragraphs.</p>'
                  },
                  {
                    menuName: 'Headers',
                    data: '<p>Rest uses overline/underline adornments to indicate headers. To create a header, underline your header text with adornment characters such as the <code>=, ~, +, ^</code> characters. Make sure that the adornment is of the same length (or longer) as the header text. Use a different adornment character to specify a different heading depth.</p>'
                  },
                  {
                    menuName: 'Blockquotes',
                    data: '<p>Rest creates blockquotes using indentation. This looks best if you use four spaces per level of indentation.</p>'
                  },
                  {
                    menuName: 'Lists',
                    data: '<p>Rest supports both ordered and unordered lists. To create an ordered list, simply prefix each line with a number, or use <code>#</code> for auto enumeration. To create an unordered list, you can prefix each line with <code>*</code>, <code>+</code> or <code>-</code>.</p>'
                  },
                  {
                    menuName: 'Code Blocks',
                    data: '<p>Rest wraps code blocks in pre-formatted tags to preserve indentation in your code blocks. To create a code block, indent the entire block by at least 4 spaces or one tab. Rest will strip the extra indentation you&rsquo;ve added to the code block.</p>'
                  },
                  {
                    menuName: 'Horizontal Rules',
                    data: '<p>Horizontal rules are created by placing four or more hyphens, asterisks or underscores on a line by themselves.</p>'
                  }
                ]
    },

    {
      menuName: 'Span Elements',
      content: [
                  {
                    menuName: 'Links',
                    data: '<p>To create an inline link, create a set of backticks, include the link title first, followed by the url in angled brackets (e.g., <code>`Python <http://www.python.org/>`_</code>).</p>'
                  },

                  {
                    menuName: 'Emphasis',
                    data: '<p>Asterisks (<code>*</code>) are treated as emphasis and are wrapped with an <code>&lt;em&gt;</code> tag, which usually displays as italics in most browsers. Double asterisks (<code>**</code>) are treated as bold using the <code>&lt;strong&gt;</code> tag. To create italic or bold text, simply wrap your words in single/double asterisks. For example, <code>**My double emphasis text**</code> becomes <strong>My double emphasis text</strong>, and <code>*My single emphasis text*</code> becomes <em>My single emphasis text</em>.</p>'
                  },

                  {
                    menuName: 'Code',
                    data: '<p>To create inline spans of code, simply wrap the code in backticks (<code>`</code>). Rest will turn <code>`myFunction`</code> into <code>myFunction</code>.</p>'
                  },

                  {
                    menuName: 'Images',
                    data: '<p>Rest image syntax is two dots, followed by a space, the word "image", two colons, another space, and the url: <code>.. image:: http://image.com/image.png</code>.</p>'
                  }
                ]
    },

    {
      menuName: 'Miscellaneous',
      content: [
                  {
                    menuName: 'Escaping',
                    data: '<p>If you want to use a special Rest character in your document (such as displaying literal asterisks), you can escape the character with the backslash (<code>\\</code>). Rest will ignore the character directly after a backslash.'
                  }
                ]
    }
  ];

  $.GollumEditor.defineHelp('rst', reStructuredTextHelp);

})(jQuery);
