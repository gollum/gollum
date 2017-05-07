/**
 *	BBcode Language Definition
 *
 */
(function() {

var BBcode = {

	'function-bold':				 {
								search: /([^\n]+)([\n]*)/gi,
								replace: "[b]$1[/b]$2"
							},

	'function-italic':			 {
								search: /([^\n]+)([\n]*)/gi,
								replace: "[i]$1[/i]$2"
							},

	'function-code':			 {
								search: /([^\n]+)([\n]*)/gi,
								replace: "[code]$1[/code]$2"
							},

	'function-blockquote' :   {
								search: /(.+)([\n]?)/g,
								replace: "[quote]$1[/quote]$2"
							},

	'function-ul':			 {
								search: /(.+)([\n]?)/gi,
								replace: "[*]$1$2[/list]",
								append: "[list]"
							},

	'function-ol':				 {
								search: /(.+)([\n]?)/gi,
								replace: "[*]$1$2[/list]"
								append: "[list=1]"
							},

	'function-link':	 {
								exec: function( txt, selText, $field ) {
								var results = null;
								$.GollumEditor.Dialog.init({
									title: 'Insert Link',
									fields: [
									{
										id:	 'text',
										name: 'Link Text',
										type: 'text',
										help: 'The text to display to the user.'
									},
									{
										id:	 'href',
										name: 'URL',
										type: 'text',
										help: 'The URL to link to.'
									}
									],
									OK: function( res ) {
									 var h = '[url=' + res['href'] + ']' + 
											 res['text'] + '[/url]';
									 $.GollumEditor.replaceSelection( h );
									}
								});


								}
							},

	'function-image':	 {
								exec: function( txt, selText, $field ) {
								var results = null;
								$.GollumEditor.Dialog.init({
									title: 'Insert Image',
									fields: [
									{
										id: 'url',
										name: 'Image URL',
										type: 'text'
									}],
									OK: function( res ) {
									if ( res['url'] && res['alt'] ) {
										var h = '[img]' + res['url'] + '[/img]';
									}
									$.GollumEditor.replaceSelection( h );
									}
								});
								}
							}

};

jQuery.GollumEditor.defineLanguage('bbcode', BBcode);

})();