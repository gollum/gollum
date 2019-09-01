/**
 *  Creole Language Definition
 *
 */
(function($) {
  var Creole = $.extend(true, {}, $.DefaultLang); // Use default language definition (markdown) as a base, and modify where necessary

  Creole['function-italic']['replace'] = "//$1//$2";
  Creole['function-code']['replace'] = "{{{$1}}}$2";
  Creole['function-hr']['append'] = "\n\n----\n\n";
  Creole['function-blockquote'] = undefined;

  // Set h1-h3 functions
  for (var i=1; i < 4; i++) {
    Creole['function-h' + i.toString()]['replace'] = "=" + "=".repeat(i) + " $1$2";
  }

  Creole['function-ol']['line'] = function ( index, line) {
    return '# ' + line + "\n";
  }

  Creole['function-link']['replace'] = function ( res ) {
    var rep = '';
    if ( res['text'] && res['href'] ) {
      rep = '[[' + res['href'] + '|' + res['text'] + ']]';
    }
    return rep;
  };
  
  Creole['function-image']['replace'] = function ( res ) {
    var rep = '';
    if ( res['url'] && res['alt'] ) {
      rep = '{{' + res['url'];
      if ( res['alt'] != '' ) {
        rep += '|' + res['alt'];
      }
      rep = rep + '}}';
    }
    return rep;
  };

  $.GollumEditor.defineLanguage('creole', Creole);
})(jQuery);