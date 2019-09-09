(function($) {

  $.markupSupportsEditableSections = function ( markup ) {
    var supportedFormats = ['markdown', 'textile', 'asciidoc', 'rst'];
    return supportedFormats.includes(markup);
  }

  $.findSection = function ( anchor, languageHelpers ) {
    var titles = {};

    for (i = 0; i < window.ace_editor.getSession().getLength(); i++) {
      var foundLine = null;

      var results = getSectionTokens(i);
      var section = results[0];
      var header  = results[1];

      if (!section) {
        continue; // No section on this line, go to the next
      }

      if (header) {
        header = header['value'];
        foundLine = i; // Header text was found on this line
      } else
      {
        // No header text found on this line. Perhaps the markup language puts section-defining syntax and the title of the section on different lines?
        var header_and_line = getHeader(i, section['value'], languageHelpers);
        if ( header_and_line.length ) {
          header = header_and_line[0];
          foundLine = header_and_line[1];        
        } else {
          continue; // No header text was found again. Skip this line.
        }
      }

      // Now that we have the header text, compare it to the anchor we're looking for.
      header = generateAnchor(header);

      // If we've encountered this header before, add an index to it (e.g. 'bilbo-baggins-1'.
      if (index = titles[header]) {
        header = header + '-' + index.toString();
        titles[header] = index+1;
      } else {
        titles[header] = 1;
      }

      // Compare the final header to the anchor we're looking for
      if (header == anchor) {
        return foundLine;
      }
    }
    return null;  
  }

  function getSectionTokens ( line ) {
    var session = window.ace_editor.getSession();
    tokens = session.getTokens(line);

    // Assume we can't have more than one section heading per line, so take the first section and the first header text
    section = tokens.filter(function (token) {
      return token.type.startsWith('markup.heading');
    })[0];

    header = tokens.filter(function (token) {
      return /^(heading)|(text)$/.test(token.type); 
    })[0];

    return [section, header];
  }

  function getHeader ( section_line, section_token, languageHelpers ) {
    if (!languageHelpers || !languageHelpers['find-header-line']) {
      return [];
    }
    var results  = languageHelpers['find-header-line'](section_line, section_token);
    if ( results == null ) {
      return [];
    } else {
      return [results[0], results[1]];
    }
  }

  function generateAnchor ( header ) {
    return header.trim().replace(/[^a-z0-9_\s]/gi, ' ').replace(/\s\s+/g, ' ').split(/\s/).join('-').replace(/^-/,'').toLowerCase();
  }
})(jQuery);