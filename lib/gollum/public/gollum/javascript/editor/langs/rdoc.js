/**
 *  Rdoc Language Definition
 *  See default.js for documentation
 *
**/
(function($) {

// No need to set all the replacements, only those different from the default language (Markdown).
// RDoc is pretty bare bones, so we only need to unset some functions.
var RDoc = {
  'function-code'       :   undefined,
  'function-h1'         :   undefined,
  'function-h2'         :   undefined,
  'function-h3'         :   undefined,
  'function-link'       :   undefined,
  'function-image'      :   undefined,
  'function-hr'         :   undefined,
  'function-blockquote' :   undefined,
};

$.GollumEditor.defineLanguage('rdoc', $.constructLanguageDefinition(RDoc));

})(jQuery);
