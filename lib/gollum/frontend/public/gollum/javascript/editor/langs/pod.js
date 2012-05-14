/**
 *  Pod Language Definition
**/
(function($) {

var Pod = {

  'function-bold' :         {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "B<$1>$2"
                            },

  'function-italic' :       {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "I<$1>$2"
                            },

  'function-code'   :       {
                              search: /(^[\n]+)([\n\s]*)/g,
                              replace: "C<$1>$2"
                            },

  'function-h1'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "=head1 $1$2"
                            },

  'function-h2'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "=head2 $1$2"
                            },

  'function-h3'         :   {
                              search: /(.+)([\n]?)/gi,
                              replace: "=head3 $1$2"
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
                                      rep = 'L<' + res['text'] + '|' +
                                             res['href'] + '>';
                                    }
                                    $.GollumEditor.replaceSelection( rep );
                                  }
                                });
                              }
                            }

};

$.GollumEditor.defineLanguage('pod', Pod);


var PodHelp = [
                {
                  menuName: 'Command Paragraphs',
                  content: [
                    {
                      menuName: 'Headings',
                      data: '<p>All command paragraphs start with <code>=</code> (equals sign).</p><p>To create headings 1 through 4, begin your command paragraph with <code>=headN</code>, where <code>N</code> is the number of the heading 1 through 4. For example, to make a first-order heading (the largest possible,) write <code>=head1</code>, then on the next line begin your paragraph that you want under the heading.</p>'
                    },
                    {
                      menuName: 'Beginning &amp; Ending',
                      data: '<p>Perl pod blocks should begin with <code>=pod</code> and end with <code>=cut</code>, signifying to Pod parsers that the pod block has begun and ended. These command paragraphs only signal the beginning and end of a pod block.</p>'
                    },
                    {
                      menuName: 'Other Formats',
                      data: '<p>pod also allows blocks in other formats, such as HTML or plain text. To create one of these blocks, use the <code>=format SYNTAX</code> command paragraph, where <code>SYNTAX</code> is the syntax of the block (e.g. <code>html</code> or <code>txt</code>). At the end of your block, use the <code>=end SYNTAX</code> block.</p>'
                    },
                    {
                      menuName: 'Encoding',
                      data: '<p>If you are having encoding troubles, use the <code>=encoding ENC_TYPE</code> command, where <code>ENC_TYPE</code> is the encoding type (e.g. <code>utf8</code>, <code>koi8-r</code>). This will affect the entire document, not just the block below the command.</p>'
                    }
                  ]
                },
                {
                  menuName: 'Formatting',
                  content: [
                    {
                      menuName: 'Text',
                      data: '<p>Formatting text as <strong>bold</strong>, <em>italic</em> or <code>code</code> works in the <code>S&lt;word&gt;</code> syntax, where <code>S</code> is an abbreviation for the type of text you are trying to create. For example, <code>B&lt;my bold text&gt;</code> becomes <strong>my bold text</strong>,  <code>I&lt;italic text&gt;</code> becomes <em>italic text</em> and <code>C&lt;code here()&gt;</code> becomes <code>code here()</code>.</p>'
                    },
                    {
                      menuName: 'Hyperlinks',
                      data: '<p>Writing hyperlinks in pod is much like formatting text, using the same <code>S&lt;&gt;</code> syntax. Instead of <code>B</code>, <code>I</code> or <code>C</code>, use <code>L</code> to begin a hyperlink.</p><p>pod allows you to hyperlink to a <code>man</code> page, a Perl documentation page, or another web page. To link to a <code>man</code> or Perl documentation page, simply include the page name in the link (e.g. <code>L&lt;perl(1)&gt;</code> or <code>L&lt;Net::Ping&gt;</code>). If you want to link to a web page, separate the URL and the link text with a pipe (e.g. to link to github.com, write <code>L&lt;GitHub|http://github.com/&gt;</code>).'
                    }
                  ]
                }
];

$.GollumEditor.defineHelp('pod', PodHelp);

})(jQuery);
