Gollum = {
  encloseStrategy: function(prefix, content, suffix) {
    return {
      type: 'enclose',
      content: content,
      prefix: prefix,
      suffix: suffix
    }
  },

  enclose: function(el, format, kind) {
    var cfg = Gollum.Formats[format][kind]
    var sel = el.getSelectionRange()
    if (sel.start == sel.end) {
      el.insertText(cfg.prefix + cfg.content + cfg.suffix, sel.start, sel.start, false)
      el.setSelectionRange(sel.start + cfg.prefix.length, sel.start + cfg.prefix.length + cfg.content.length)
    } else {
      el.insertText(cfg.prefix + el.getSelectedText() + cfg.suffix, sel.start, sel.end, false)
    }
  }
}

Gollum.Formats = {
  asciidoc: {
    bold: Gollum.encloseStrategy('*', 'bold text', '*'),
    italic: Gollum.encloseStrategy('_', 'italic text', '_')
  },
  creole: {
    bold: Gollum.encloseStrategy('**', 'bold text', '**'),
    italic: Gollum.encloseStrategy('//', 'italic text', '//')
  },
  markdown: {
    bold: Gollum.encloseStrategy('**', 'bold text', '**'),
    italic: Gollum.encloseStrategy('*', 'italic text', '*')
  },
  org: {
    bold: Gollum.encloseStrategy('*', 'bold text', '*'),
    italic: Gollum.encloseStrategy('/', 'italic text', '/')
  },
  pod: {
    bold: Gollum.encloseStrategy('B<', 'bold text', '>'),
    italic: Gollum.encloseStrategy('I<', 'italic text', '>')
  },
  rest: {
    bold: Gollum.encloseStrategy('**', 'bold text', '**'),
    italic: Gollum.encloseStrategy('*', 'italic text', '*')
  },
  rdoc: {
    bold: Gollum.encloseStrategy('*', 'bold text', '*'),
    italic: Gollum.encloseStrategy('_', 'italic text', '_')
  },
  roff: {
    bold: Gollum.encloseStrategy('\\fB', 'bold text', '\\fP'),
    italic: Gollum.encloseStrategy('\\fI', 'italic text', '\\fP')
  },
  textile: {
    bold: Gollum.encloseStrategy('*', 'bold text', '*'),
    italic: Gollum.encloseStrategy('_', 'italic text', '_')
  }
}

$(function(){
  /* Version selector */

  $('#versions_select').change(function() {
    location.href = this.value
  })

  /* EditBar */

  $('#editbar .bold').click(function() {
    var el = $('#guides .write textarea')
    var format = $('#guides .write select[name=format] option:selected').attr('value')
    Gollum.enclose(el, format, 'bold')
  })

  $('#editbar .italic').click(function() {
    var el = $('#guides .write textarea')
    var format = $('#guides .write select[name=format] option:selected').attr('value')
    Gollum.enclose(el, format, 'italic')
  })
})
