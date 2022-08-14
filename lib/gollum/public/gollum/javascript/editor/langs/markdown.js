/**
 *  Markdown Language Definition
 *  See default.js for documentation
 *
**/

(function($) {

// The default language definition (in default.js) is markdown, so we only need to set the special helper functions.
var MarkDown = {

  'gollum-helpers': {

    'find-header-line': function (line, token) {
      // For use in sections.js
      // Checks if token matches alternative-syntax markdown headers. These are of the form '===' or '---'.
      // If so, returns an array containing the text of the header and the previous line number.
      // If not, returns null.
      if ( token.match(/(^[=]+$)/) || token.match(/(^[-]+$)/) ){
        var foundLine = line-1
        var text = window.ace_editor.getSession().getLine(foundLine);
        if (foundLine >= 0 && !/^\s+$/.test(text)) { // Sanity check
          return [text, foundLine];
        }
        else {
          return null;
        }
      } else {
        return null;
      }
    }

  }

};

$.GollumEditor.defineLanguage('markdown', $.constructLanguageDefinition(MarkDown));

var MarkDownHelp = [

  {
    menuName: 'Block Elements',
    content: [
                {
                  menuName: 'Paragraphs &amp; Breaks',
                  data: '<p>To create a paragraph, simply create a block of text that is not separated by one or more blank lines. Blocks of text separated by one or more blank lines will be parsed as paragraphs.</p><p>If you want to create a line break, end a line with two or more spaces, then hit Return/Enter.</p>'
                },
                {
                  menuName: 'Headers',
                  data: '<p>Markdown supports two header formats. The wiki editor uses the &ldquo;atx&rsquo;-style headers. Simply prefix your header text with the number of <code>#</code> characters to specify heading depth. For example: <code># Header 1</code>, <code>## Header 2</code> and <code>### Header 3</code> will be progressively smaller headers. You may end your headers with any number of hashes.</p>'
                },
                {
                  menuName: 'Blockquotes',
                  data: '<p>Markdown creates blockquotes email-style by prefixing each line with the <code>&gt;</code>. This looks best if you decide to hard-wrap text and prefix each line with a <code>&gt;</code> character, but Markdown supports just putting <code>&gt;</code> before your paragraph.</p>'
                },
                {
                  menuName: 'Lists',
                  data: '<p>Markdown supports both ordered and unordered lists. To create an ordered list, simply prefix each line with a number (any number will do &mdash; this is why the editor only uses one number.) To create an unordered list, you can prefix each line with <code>*</code>, <code>+</code> or <code>-</code>.</p> List items can contain multiple paragraphs, however each paragraph must be indented by at least 4 spaces or a tab.'
                },
                {
                  menuName: 'Code Blocks',
                  data: '<p>Markdown wraps code blocks in pre-formatted tags to preserve indentation in your code blocks. To create a code block, indent the entire block by at least 4 spaces or one tab. Markdown will strip the extra indentation you&rsquo;ve added to the code block.</p>'
                },
                {
                  menuName: 'Horizontal Rules',
                  data: 'Horizontal rules are created by placing three or more hyphens, asterisks or underscores on a line by themselves. Spaces are allowed between the hyphens, asterisks or underscores.'
                }
              ]
  },

  {
    menuName: 'Span Elements',
    content: [
                {
                  menuName: 'Links',
                  data: '<p>Markdown has two types of links: <strong>inline</strong> and <strong>reference</strong>. For both types of links, the text you want to display to the user is placed in square brackets. For example, if you want your link to display the text &ldquo;GitHub&rdquo;, you write <code>[GitHub]</code>.</p><p>To create an inline link, create a set of parentheses immediately after the brackets and write your URL within the parentheses. (e.g., <code>[GitHub](http://github.com/)</code>). Relative paths are allowed in inline links.</p><p>To create a reference link, use two sets of square brackets. <code>[my internal link][internal-ref]</code> will link to the internal reference <code>internal-ref</code>.</p>'
                },

                {
                  menuName: 'Emphasis',
                  data: '<p>Asterisks (<code>*</code>) and underscores (<code>_</code>) are treated as emphasis and are wrapped with an <code>&lt;em&gt;</code> tag, which usually displays as italics in most browsers. Double asterisks (<code>**</code>) or double underscores (<code>__</code>) are treated as bold using the <code>&lt;strong&gt;</code> tag. To create italic or bold text, simply wrap your words in single/double asterisks/underscores. For example, <code>**My double emphasis text**</code> becomes <strong>My double emphasis text</strong>, and <code>*My single emphasis text*</code> becomes <em>My single emphasis text</em>.</p>'
                },

                {
                  menuName: 'Code',
                  data: '<p>To create inline spans of code, simply wrap the code in backticks (<code>`</code>). Markdown will turn <code>`myFunction`</code> into <code>myFunction</code>.</p>'
                },

                {
                  menuName: 'Images',
                  data: '<p>Markdown image syntax looks a lot like the syntax for links; it is essentially the same syntax preceded by an exclamation point (<code>!</code>). For example, if you want to link to an image at <code>http://github.com/unicorn.png</code> with the alternate text <code>My Unicorn</code>, you would write <code>![My Unicorn](http://github.com/unicorn.png)</code>.</p>'
                }
              ]
  },

  {
    menuName: 'Miscellaneous',
    content: [
                {
                  menuName: 'Automatic Links',
                  data: '<p>If you want to create a link that displays the actual URL, markdown allows you to quickly wrap the URL in <code>&lt;</code> and <code>&gt;</code> to do so. For example, the link <a href="javascript:void(0);">http://github.com/</a> is easily produced by writing <code>&lt;http://github.com/&gt;</code>.</p>'
                },

                {
                  menuName: 'Escaping',
                  data: '<p>If you want to use a special Markdown character in your document (such as displaying literal asterisks), you can escape the character with the backslash (<code>\\</code>). Markdown will ignore the character directly after a backslash.'
                },

                {
                  menuName: 'Emoji',
                  data: '<p>Gollum uses <a href="https://joypixels.com/emoji/v4" target="_blank">JoyPixels 4</a> for its emoji. To include one, wrap the emoji name in colons and use underscores instead of spaces (e.g. :heart: or :point_up:).</p>'
                }
              ]
  }
];

$.GollumEditor.defineHelp('markdown', MarkDownHelp);

})(jQuery);
