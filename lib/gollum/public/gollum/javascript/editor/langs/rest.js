/**
 *  reStructuredText Language Definition
 *
 *  A language definition for string manipulation operations, in this case
 *  for the reStructuredText markup language. Uses regexes for various 
 *  functions by default. If regexes won't do and you need to do some serious
 *  manipulation, you can declare a function in the object instead.
 *
 *  Code example:
 *  'functionbar-id'  :   {
 *                          exec: function(text, selectedText) {
 *                                   functionStuffHere();
 *                                },
 *                          search: /somesearchregex/gi,
 *                          replace: 'replace text for RegExp.replace',
 *                          append: "just add this where the cursor is"
 *                         }
 *
**/
(function($) {

var reStructuredText = {

  'function-bold' :         {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "**$1**$2"
                            },

  'function-italic' :       {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "*$1*$2"
                            },

  'function-code'   :       {
                              search: /([^\n]+)([\n\s]*)/g,
                              replace: "``$1``$2"
                            },

  'function-hr'     :       {
                              append: "\n\n----\n\n"
                            },

  'function-ul'     :       {
			                        exec: function(txt, selText, $field) {
	                              var pfx = "* ";
                                var lines = selText.split("\n");
                                  for ( var i = 0; i < lines.length; i++ ) {
                                      lines[i] = pfx + lines[i];
				  }
                                  var repText = lines.join("\n");
                                  $.GollumEditor.replaceSelection(repText);
                                }
                            },

  'function-ol'   :         {
                              exec: function( txt, selText, $field) {
                                var lines = selText.split("\n");
                                for ( var i = 0; i < lines.length; i++ ) {
                                    pfx = (i + 1).toString() + ". ";
                                    lines[i] = pfx + lines[i];
                                }
                                var repText = lines.join("\n");
                                $.GollumEditor.replaceSelection(repText);
                              }
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
                              exec: function( txt, selText, $field) {
                                var lines = selText.split("\n");
                                title = lines.shift();
                                subtitle = lines.join(' ');
                                title_adornment = "=".repeat(title.length);
                                subtitle_adornment = "~".repeat(subtitle.length);

                                if (title != "" && subtitle != "") {
                                  repText = title_adornment + "\n" + title + "\n" + title_adornment + "\n" +
                                            subtitle_adornment + "\n" + subtitle + "\n" + subtitle_adornment;
                                } else if (title != ""){
                                  repText = title_adornment + "\n" + title + "\n" + title_adornment;
                                }
                                $.GollumEditor.replaceSelection(repText);
                              }
                            },
                            
  'function-h2'         :   {
                              exec: function( txt, selText, $field) {
                                var lines = selText.split("\n");
                                header = lines.shift();
                                tail = lines.join("\n");
                                adornment = "=".repeat(header.length);
                                repText = header + "\n" + adornment + "\n" + tail;
                                $.GollumEditor.replaceSelection(repText);
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
                                      rep = '`' + res['text'] + ' ' +
                                             '<' + res['href'] + '>`_';
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
                                    },
                                    {
                                      id: 'alt',
                                      name: 'Alt Text',
                                      type: 'text'
                                    }
                                  ],
                                  OK: function( res ) {
                                    var rep = "";
                                    if ( res['url'] && res['alt'] ) {
                                      rep = ".. image:: " + res['url'] + "\n" +
                                            '    :alt: ' + res['alt'];
                                    }
                                    $.GollumEditor.replaceSelection( rep );
                                  }
                                });
                              }
                            }

};

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


$.GollumEditor.defineLanguage('rest', reStructuredText);
$.GollumEditor.defineHelp('rest', reStructuredTextHelp);

})(jQuery);
