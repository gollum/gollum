Gollum = {
  encloseStrategy: function(prefix, content, suffix) {
    return {
      type: 'enclose',
      content: content,
      prefix: prefix,
      suffix: suffix
    }
  },

  prefixStrategy: function(prefix, content, newline) {
    return {
      type: 'prefixLine',
      prefix: prefix,
      content: content,
      newline: newline
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
  },

  prefix: function(el, format, kind) {
    var cfg = Gollum.Formats[format][kind]
    var sel = el.getSelectionRange()
    var cnt = el.getSelectedText()
    var prefix = cfg.prefix
    if (cfg.newline) {
      el.setSelectionRange(sel.start - 1, sel.start)
      var before = el.getSelectedText()
      if (before != '\n') {
        prefix = '\n' + prefix
      }
    }
    if (sel.start == sel.end) {
      el.insertText(prefix + cfg.content, sel.start, sel.start, false)
      el.setSelectionRange(sel.start + prefix.length, sel.start + prefix.length + cfg.content.length)
    } else {
      el.insertText(prefix + cnt + '\n', sel.start, sel.end, false)
    }
  }
}

Gollum.Formats = {
  asciidoc: {
    bold: Gollum.encloseStrategy('*', 'bold text', '*'),
    italic: Gollum.encloseStrategy('_', 'italic text', '_'),
    ul: Gollum.prefixStrategy('* ', 'Bullet list item', true),
    ol: Gollum.prefixStrategy('. ', 'Numbered list item', true)
  },
  creole: {
    bold: Gollum.encloseStrategy('**', 'bold text', '**'),
    italic: Gollum.encloseStrategy('//', 'italic text', '//'),
    ul: Gollum.prefixStrategy('* ', 'Bullet list item', true),
    ol: Gollum.prefixStrategy('# ', 'Numbered list item', true)
  },
  gollum: {
    link: Gollum.encloseStrategy('[[', 'Page Name', ']]'),
    image: Gollum.encloseStrategy('[[', '/path/to/image.png', ']]')
  },
  markdown: {
    bold: Gollum.encloseStrategy('**', 'bold text', '**'),
    italic: Gollum.encloseStrategy('*', 'italic text', '*'),
    ul: Gollum.prefixStrategy('* ', 'Bullet list item', true),
    ol: Gollum.prefixStrategy('1. ', 'Numbered list item', true)
  },
  org: {
    bold: Gollum.encloseStrategy('*', 'bold text', '*'),
    italic: Gollum.encloseStrategy('/', 'italic text', '/'),
    ul: Gollum.prefixStrategy('- ', 'Bullet list item', true),
    ol: Gollum.prefixStrategy('1. ', 'Numbered list item', true)
  },
  pod: {
    bold: Gollum.encloseStrategy('B<', 'bold text', '>'),
    italic: Gollum.encloseStrategy('I<', 'italic text', '>'),
    ul: Gollum.prefixStrategy('=item * ', 'Bullet list item', true),
    ol: Gollum.prefixStrategy('=item 1. ', 'Numbered list item', true)
  },
  rest: {
    bold: Gollum.encloseStrategy('**', 'bold text', '**'),
    italic: Gollum.encloseStrategy('*', 'italic text', '*'),
    ul: Gollum.prefixStrategy('* ', 'Bullet list item', true),
    ol: Gollum.prefixStrategy('1. ', 'Numbered list item', true)
  },
  rdoc: {
    bold: Gollum.encloseStrategy('*', 'bold text', '*'),
    italic: Gollum.encloseStrategy('_', 'italic text', '_'),
    ul: Gollum.prefixStrategy('* ', 'Bullet list item', true),
    ol: Gollum.prefixStrategy('1. ', 'Numbered list item', true)
  },
  textile: {
    bold: Gollum.encloseStrategy('*', 'bold text', '*'),
    italic: Gollum.encloseStrategy('_', 'italic text', '_'),
    ul: Gollum.prefixStrategy('* ', 'Bullet list item', true),
    ol: Gollum.prefixStrategy('# ', 'Numbered list item', true)
  }
}

$(function(){
  /* Version selector */

  $('#versions_select').change(function() {
    location.href = this.value
  })

  /* EditBar */

  $('#editbar .link').click(function() {
    var el = $('#guides .write textarea')
    var format = $('#guides .write select[name=format] option:selected').attr('value')
    Gollum.enclose(el, 'gollum', 'link')
  })

  $('#editbar .image').click(function() {
    var el = $('#guides .write textarea')
    var format = $('#guides .write select[name=format] option:selected').attr('value')
    Gollum.enclose(el, 'gollum', 'image')
  })

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

  $('#editbar .ul').click(function() {
    var el = $('#guides .write textarea')
    var format = $('#guides .write select[name=format] option:selected').attr('value')
    Gollum.prefix(el, format, 'ul')
  })

  $('#editbar .ol').click(function() {
    var el = $('#guides .write textarea')
    var format = $('#guides .write select[name=format] option:selected').attr('value')
    Gollum.prefix(el, format, 'ol')
  })

  $('#editbar .tab.help a').click(function() {
    if ($(this).hasClass("open")) {
      $(this).removeClass("open")
      $('#editbar .sections').slideUp()
    } else {
      $(this).addClass("open")
      if (!$('#editbar .sections .toc .current').get(0)) {
        var target = $('#editbar .sections .toc .headers').get(0)
        sectionItemClick.call(target)
      }
      $('#editbar .sections').slideDown()
    }
  })

  $('#wiki_format').change(function() {
    var target = $('#editbar .sections .toc div.current').get(0)
    if (target != undefined) {
      sectionItemClick.call(target)
    }
  })

  var sectionItemClick = function() {
    $('#editbar .sections .toc div').removeClass('current')
    $(this).addClass('current')
    $('#editbar .sections .page').removeClass('current')
    var classes = $(this).attr('class').split(' ')
    var name = classes[0]
    var format = $('#wiki_format option:selected').attr('value')
    if (classes.indexOf('gollum') == -1) {
      $('#editbar .sections .page.' + name + '.' + format).addClass('current')
    } else {
      $('#editbar .sections .page.' + name).addClass('current')
    }
    return false;
  }

  $('#editbar .sections .toc div').click(sectionItemClick)

  var whichType = function(){
    return $('#wiki_format').val()
  }

  $('#wiki-form').previewableCommentForm({
    previewUrl: "/preview",
    previewOptions: {'wiki_format': whichType},
    onSuccess: function() {
      MathJax.Hub.Typeset(this[0])
      $('#wiki_format option').each(function() {
        $('#preview_bucket').removeClass($(this).val())
      })
      $('#preview_bucket').addClass(whichType)
    }
  })

  $('ul.inline-tabs').tabs();

  var selectedRevisions = [];

  // disable submit button js for accessiblity
  $('form#history input[type=submit]').attr('disabled', true);

  $('form#history input[type=checkbox]').change(function() {
    var id = $(this).val()
    var i = selectedRevisions.indexOf(id)

    if (i > -1) {
      selectedRevisions.splice(i, 1)
    } else {
      selectedRevisions.push(id)
      if (selectedRevisions.length > 2) {
        var shiftedId = selectedRevisions.shift()
        $('input[value=' + shiftedId + ']').attr('checked', false)
      }
    }

    $('form#history tr.commit').removeClass("selected")
    $('form#history input[type=submit]').attr('disabled', true)

    if (selectedRevisions.length == 2) {
      $('form#history input[type=submit]').attr('disabled', false)
      var on = false
      $('form#history tr.commit').each(function() {
        if (on) { $(this).addClass("selected") }

        if ($(this).find('input:checked').length > 0) {
          on = !on
        }

        if (on) { $(this).addClass("selected") }
      })
    }
  })
})
