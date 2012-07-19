// Define one global function that renders markdown.
(function() {
  // Grab functions from emscripten
  var Pointer_stringify = Module.Pointer_stringify;
  var _str_to_html = Module._str_to_html;
  var malloc = Module._malloc;
  var realloc = Module._realloc;
  var writeStringToMemory = Module.writeStringToMemory;
  var allocSize = 2048;
  var pointer = malloc( allocSize ) ;

  window.md_to_html = function( text ) {
    var textLength = text.length;
    while ( textLength > allocSize ) {
      allocSize <<= 1; // double
      pointer = realloc( pointer, allocSize );
    }

    writeStringToMemory( text, pointer );
    return Pointer_stringify( _str_to_html( pointer ) );
  };
})();
