(function($) {

  var instances = {};

  var textManipulatorInstance = function(elem){

    var TextManipulator = {

      editor: null,

      setEditor: function(editor){
        TextManipulator.editor = editor;
      },

      callEditor: function(options){
        var namespace = options.shift();
        var method    = options.shift();

        if (TextManipulator[namespace] && TextManipulator[namespace][method]) {
          return TextManipulator[namespace][method].apply(null, options);
        }
      },

      // Defines and translates positions in the editor
      // Textarea content traditionally works on index only
      // xy positions allow us to work out where we are in the textarea in terms of row and column

      position: {
        xy: function(position){
          if (!!position.isXY) return position;

          var bits = TextManipulator.editor.value.substr(0, position).split("\n");
          return {
            row: bits.length - 1,
            column: bits[bits.length - 1].length,
            toIndex: function(){
              return TextManipulator.position.index(this);
            },
            toString: function(){
              return "TextManipulator.Position.xy [" + this.row + ", " + this.column + "]";
            },
            isXY: true
          };
        },

        index: function(position){
          var bits = TextManipulator.editor.value.split("\n");
          bits = bits.slice(0, position.row + 1);
          var last = bits[bits.length - 1];
          bits[bits.length - 1] = last.substr(0, position.column);
          return bits.join("\n").length;
        }
      },

      // Used for manipulating the selection

      selection: {
        ieGetSelectionRange: function() {
          // Because IE is horrible.
          // Sourced from http://stackoverflow.com/questions/3622818/ies-document-selection-createrange-doesnt-include-leading-or-trailing-blank-li
          var el = TextManipulator.editor;
          var start = 0, end = 0, normalizedValue, range, textInputRange, len, endRange;

          if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") {
            start = el.selectionStart;
            end = el.selectionEnd;
          } else {
            range = document.selection.createRange();

            if (range && range.parentElement() == el) {
              len = el.value.length;
              normalizedValue = el.value.replace(/\r\n/g, "\n");

              // Create a working TextRange that lives only in the input
              textInputRange = el.createTextRange();
              textInputRange.moveToBookmark(range.getBookmark());

              // Check if the start and end of the selection are at the very end
              // of the input, since moveStart/moveEnd doesn't return what we want
              // in those cases
              endRange = el.createTextRange();
              endRange.collapse(false);

              if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
                start = end = len;
              } else {
                start = -textInputRange.moveStart("character", -len);
                start += normalizedValue.slice(0, start).split("\n").length - 1;

                if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) {
                  end = len;
                } else {
                  end = -textInputRange.moveEnd("character", -len);
                  end += normalizedValue.slice(0, end).split("\n").length - 1;
                }
              }
            }
          }

          return {
            start: start,
            end: end
          };
        },

        currentRange: function(){
          if (document.selection != undefined) {
            TextManipulator.editor.focus();
            return TextManipulator.selection.ieGetSelectionRange();
          }
          else if (TextManipulator.editor.selectionStart != undefined) {
            return {
              start: TextManipulator.position.xy(
                TextManipulator.editor.selectionStart
              ),
              end: TextManipulator.position.xy(
                TextManipulator.editor.selectionEnd
              )
            };
          }
          else {
            var l = TextManipulator.editor.value.length;
            return {
              start: TextManipulator.position.xy(l),
              end: TextManipulator.position.xy(l)
            };
          }
        },

        getSelectedLineNumbers: function(){
          var range = TextManipulator.selection.currentRange();
          return {
            start: range.start.row,
            end: range.end.row
          };
        },

        getSelectedString: function(){
          var range = TextManipulator.selection.currentRange();
          if (document.selection != undefined) {
            return range.text;
          }
          else if (TextManipulator.editor.selectionStart != undefined) {
            var start = range.start;
            if (!!start.isXY) start = start.toIndex();

            var end = range.end;
            if (!!end.isXY) end = end.toIndex();

            return TextManipulator.editor.value.substring(start, end);
          }
        },

        getSelectedLines: function(){
          var selectedLines = TextManipulator.selection.getSelectedLineNumbers();
          return TextManipulator.selection.getContentLines(selectedLines.start, selectedLines.end);
        },

        getContentLines: function(start, end){
          var lines = [];
          if (!end) end = start;

          var allLines = TextManipulator.editor.value.split("\n");

          for (var i = start; i <= end; i++) {
            if (!!allLines[i]) {
              lines.push(allLines[i]);
            }
          }

          return lines;
        },

        insertAtPosition: function(text, pos, dontFocus) {
          var currentText = TextManipulator.editor.value;

          if (!!pos.isXY) pos = +( pos.toIndex() );

          TextManipulator.selection.textInputEvent(text, [
            currentText.substring(0, pos),
            text,
            currentText.substring(pos)
          ].join(""));

          if (!dontFocus) {
            var focusPos = +( text.length ) + pos;
            TextManipulator.selection.select(focusPos);
          }
        },

        insert: function(text, pos, dontFocus) {
          if (!!pos) {
            if (!!pos.row && !!pos.column) {
              pos = TextManipulator.position.xy(pos);
            }
          }
          else {
            pos = TextManipulator.position.xy(
              TextManipulator.selection.currentRange().end
            );
          }

          TextManipulator.selection.insertAtPosition(text, pos, dontFocus);

          $(TextManipulator.editor).trigger('change');
        },

        select: function(range) {
          // Select end by default
          var startPos = endPos = TextManipulator.editor.value.length;

          if (range == "start") {
            startPos = endPos = 0;
          }
          else if (range == "end") {
            startPos = endPos = TextManipulator.editor.value.length;
          }
          else if ($.isNumeric(range)) {
            startPos = endPos = range;
          }
          else if (!!range.isXY) {
            startPos = endPos = range.toIndex();
          }
          else {
            startPos = range.start.toIndex();
            endPos   = range.end.toIndex();
          }

          if (TextManipulator.editor.createTextRange) {
            var sel = TextManipulator.editor.createTextRange();
            sel.collapse(true);
            sel.moveStart('character', startPos);
            sel.moveEnd('character', endPos);
            sel.select();
            TextManipulator.editor.focus();
          }
          else if (TextManipulator.editor.setSelectionRange) {
            TextManipulator.editor.focus();
            TextManipulator.editor.setSelectionRange(startPos, endPos);
          }
          else if (typeof TextManipulator.editor.selectionStart != 'undefined') {
            TextManipulator.editor.selectionStart = startPos;
            TextManipulator.editor.selectionEnd = endPos;
            TextManipulator.editor.focus();
          }
        },

        textInputEvent: function(text, entireText) {
          var runOK = false;

          if (!runOK && !!document.createEvent) {
            var e = document.createEvent('TextEvent');

            if (!!e.initTextEvent) {
              e.initTextEvent('textInput', true, true, null, text);
              TextManipulator.editor.dispatchEvent(e);
              runOK = true;
            }
          }
          
          if (!runOK) {
            TextManipulator.editor.value = entireText;
          }
        },

        replace: function(newText, range, dontSelect) {
          if (!dontSelect) dontSelect = false;

          if (!range) {
            range = TextManipulator.selection.currentRange();
          }

          var start = TextManipulator.position.index(range.start),
              end = TextManipulator.position.index(range.end);

          TextManipulator.selection.select(range);

          var prefix = TextManipulator.editor.value.substring(0, start);
          var suffix = TextManipulator.editor.value.substring(end);
          var newLen = ([prefix, newText].join("")).length;

          TextManipulator.selection.textInputEvent(newText, [
            prefix,
            newText,
            suffix
          ].join(""));

          var newEnd = TextManipulator.position.xy(newLen);
          var newRange = range;
          newRange.end = newEnd;

          if (dontSelect) {
            TextManipulator.editor.focus();
          }
          else {
            TextManipulator.selection.select(newRange);
          }

          $(TextManipulator.editor).trigger('change');
        },

        range: function(row1, col1, row2, col2){
          return {
            start: {
              row: row1,
              column: col1,
            },
            end: {
              row: row2,
              column: col2,
            }
          }
        }
      },

      // Used for wrapping selected strings
      // eg. Bold, italic

      selected: {
        _isWrapped: function(prefix, suffix) {
          var selectedString = TextManipulator.selection.getSelectedString();

          var hasPrefix = (selectedString.substring(0, prefix.length) == prefix),
              hasSuffix = (selectedString.substring(selectedString.length - suffix.length) == suffix);

          return (hasPrefix && hasSuffix);
        },

        _wrap: function(prefix, suffix) {
          var currentText = TextManipulator.selection.getSelectedString();

          var newText = [
            prefix,
            currentText,
            suffix
          ].join("");

          TextManipulator.selection.replace(newText);
        },

        _unwrap: function(prefix, suffix) {
          var currentText = TextManipulator.selection.getSelectedString();

          var newText = currentText.substring(prefix.length, currentText.length - suffix.length);

          TextManipulator.selection.replace(newText);
        },

        toggleWrap: function(prefix, suffix) {
          if (!suffix) suffix = prefix;

          if (TextManipulator.selected._isWrapped(prefix, suffix)) {
            TextManipulator.selected._unwrap(prefix, suffix);
          }
          else {
            TextManipulator.selected._wrap(prefix, suffix);
          }
        },

        replace: function(text) {
          TextManipulator.selection.replace(text);
        },

        _replaceRegex: function(match, replacement) {
          var text = TextManipulator.selection.getSelectedString();
          var newText = text.replace(match, replacement);
          TextManipulator.selection.replace(newText);
        }
      },

      // Used for wrapping each line in a selection
      // eg. Blockquotes, lists

      lines: {
        _formatPrefixAndSuffix: function(prefix, suffix, lineNum, lineLength) {
          return {
            prefix: prefix.getString(lineNum, lineLength),
            suffix: suffix.getString(lineNum, lineLength)
          }
        },

        _areWrapped: function(prefix, suffix){
          var selected = TextManipulator.selection.getSelectedLineNumbers();
          var selectedLines = TextManipulator.selection.getSelectedLines();
          var hasPrefix = [], hasSuffix = [];

          var lineLength = selected.end - selected.start;

          for (var i = 0; i < selectedLines.length; i++) {
            var lineNum = i + 1;

            var lineWraps = TextManipulator.lines._formatPrefixAndSuffix(
              prefix, suffix,
              lineNum, lineLength
            );

            var foundPrefix = selectedLines[i].substring(0, lineWraps.prefix.length);
            var foundSuffix = selectedLines[i].substring(selectedLines[i].length - lineWraps.suffix.length);

            if (prefix.match(foundPrefix, lineWraps.prefix)) {
              hasPrefix.push(i);
            }
            if (suffix.match(foundSuffix, lineWraps.suffix)) {
              hasSuffix.push(i);
            }
          }

          return (
            (hasPrefix.length == selectedLines.length) && 
            (hasSuffix.length == selectedLines.length)
          );
        },

        _wrap: function(prefix, suffix) {
          var selected = TextManipulator.selection.getSelectedLineNumbers();
          var selectedLines = TextManipulator.selection.getSelectedLines();

          var newLineContent = [];

          var lineLength = selected.end - selected.start;

          for (var i = selected.start; i <= selected.end; i++) {
            var lineNum = (i - selected.start) + 1;

            var lineWraps = TextManipulator.lines._formatPrefixAndSuffix(
              prefix, suffix,
              lineNum, lineLength
            );

            var currentLineText = selectedLines[i - selected.start];
            newLineContent.push(
              lineWraps.prefix + 
              currentLineText + 
              lineWraps.suffix
            );
          }

          var range = TextManipulator.selection.currentRange();
          range.start.column = 0;
          range.end.column = selectedLines[selectedLines.length - 1].length;

          TextManipulator.selection.replace(newLineContent.join("\n"), range);
        },

        _unwrap: function(prefix, suffix) {
          var selected = TextManipulator.selection.getSelectedLineNumbers();
          var selectedLines = TextManipulator.selection.getSelectedLines();

          var newLineContent = [];

          var lineLength = selected.end - selected.start;

          for (var i = selected.start; i <= selected.end; i++) {
            var lineNum = (i - selected.start) + 1;

            var lineWraps = TextManipulator.lines._formatPrefixAndSuffix(
              prefix, suffix,
              lineNum, lineLength
            );

            var currentLineText = selectedLines[i - selected.start];
            newLineContent.push(currentLineText.substring(
              lineWraps.prefix.length, 
              currentLineText.length - lineWraps.suffix.length
            ));
          }

          var range = TextManipulator.selection.currentRange();
          range.start.column = 0;
          range.end.column = selectedLines[selectedLines.length - 1].length;

          TextManipulator.selection.replace(newLineContent.join("\n"), range);
        },

        wrap: function(prefix, suffix) {
          if (!prefix) prefix = "";
          if (!suffix) suffix = "";

          var preFrag = TextManipulator.fragment.generate(prefix);
          var sufFrag = TextManipulator.fragment.generate(suffix);

          TextManipulator.lines._wrap(preFrag, sufFrag);
        },

        unwrap: function(prefix, suffix) {
          if (!prefix) prefix = "";
          if (!suffix) suffix = "";

          var preFrag = TextManipulator.fragment.generate(prefix);
          var sufFrag = TextManipulator.fragment.generate(suffix);

          TextManipulator.lines._unwrap(preFrag, sufFrag);
        },

        toggleWrap: function(prefix, suffix) {
          if (!prefix) prefix = "";
          if (!suffix) suffix = "";

          var preFrag = TextManipulator.fragment.generate(prefix);
          var sufFrag = TextManipulator.fragment.generate(suffix);

          if (TextManipulator.lines._areWrapped(preFrag, sufFrag)) {
            TextManipulator.lines._unwrap(preFrag, sufFrag);
          }
          else {
            TextManipulator.lines._wrap(preFrag, sufFrag);
          }
        },

        _replaceRegex: function(match, replacement) {
          var selectedLines = TextManipulator.selection.getSelectedLines();
          var newLines = [];

          for (var i = 0; i < selectedLines.length; i++) {
            newLines.push(selectedLines[i].replace(match, replacement));
          }

          var range = TextManipulator.selection.currentRange();
          range.start.column = 0;
          range.end.column = selectedLines[selectedLines.length - 1].length;

          TextManipulator.selection.replace(newLines.join("\n"), range);
        }
      },

      // Used for wrapping blocks of stuff as one discrete entity
      // eg. Code blocks, pre blocks

      block: {
        _formatPrefixAndSuffix: function(prefix, suffix, text) {
          var preMatch = prefix.search(text);
          var sufMatch = suffix.search(text);

          return {
            prefixMatch: (preMatch && preMatch.length > 0 ? preMatch[0] : null),
            suffixMatch: (sufMatch && sufMatch.length > 0 ? sufMatch[sufMatch.length - 1] : null),
            prefix: prefix.getString(0, 0),
            suffix: suffix.getString(0, 0)
          }
        },

        _isWrapped: function(prefix, suffix){
          var selected = TextManipulator.selection.getSelectedLineNumbers();
          var selectedLines = TextManipulator.selection.getSelectedLines();

          var prefixLine = TextManipulator.selection.getContentLines(selected.start);
          var suffixLine = TextManipulator.selection.getContentLines(selected.end);

          var lineWraps = TextManipulator.block._formatPrefixAndSuffix(prefix, suffix, selectedLines.join("\n"));

          return (
            (prefixLine.length > 0 && prefix.match(prefixLine[0], lineWraps.prefixMatch)) &&
            (suffixLine.length > 0 && suffix.match(suffixLine[0], lineWraps.suffixMatch))
          );
        },

        _wrap: function(prefix, suffix) {
          var currentText = TextManipulator.selection.getSelectedString();

          var lineWraps = TextManipulator.block._formatPrefixAndSuffix(prefix, suffix, currentText);

          var newText = [
            lineWraps.prefix,
            currentText,
            lineWraps.suffix
          ].join("");

          TextManipulator.selection.replace(newText);
        },

        _unwrap: function(prefix, suffix) {
          var currentText = TextManipulator.selection.getSelectedString();

          var lineWraps = TextManipulator.block._formatPrefixAndSuffix(prefix, suffix, currentText);

          var p = !!lineWraps.prefixMatch ? lineWraps.prefixMatch : lineWraps.prefix;
          var s = !!lineWraps.suffixMatch ? lineWraps.suffixMatch : lineWraps.suffix;

          var newText = currentText.substring(
            p.length,
            currentText.length - s.length
          );

          TextManipulator.selection.replace(newText);
        },

        toggleWrap: function(prefix, suffix) {
          if (!prefix) prefix = "";
          if (!suffix) suffix = "";

          var preFrag = TextManipulator.fragment.generate(prefix);
          var sufFrag = TextManipulator.fragment.generate(suffix);

          if (TextManipulator.block._isWrapped(preFrag, sufFrag)) {
            TextManipulator.block._unwrap(preFrag, sufFrag);
          }
          else {
            TextManipulator.block._wrap(preFrag, sufFrag);
          }
        },

        _replaceRegex: function(match, replacement) {
          var text = TextManipulator.selection.getSelectedString();
          var newText = text.replace(match, replacement);
          TextManipulator.selection.replace(newText);
        }
      },

      // Allows behaviour to vary depending on what is selected

      conditional: {

        // Switching condition: whether selection is single line or multiple.
        multiLine: function(behaviour){
          var selectedLines = TextManipulator.selection.getSelectedLineNumbers();

          if (selectedLines.start == selectedLines.end) {
            var target = "selected";
            if (!!behaviour.single.target) target = behaviour.single.target

            TextManipulator[target].toggleWrap(
              behaviour.single.prefix,
              behaviour.single.suffix
            );
          }
          else {
            var target = "lines";
            if (!!behaviour.multi.target) target = behaviour.multi.target

            TextManipulator[target].toggleWrap(
              behaviour.multi.prefix,
              behaviour.multi.suffix
            );
          }
        },

        // Switching condition: what the selection matches.
        selectionMatch: function(behaviour) {

        },

        // Switching condition: what the selected lines match.
        linesMatch: function(behaviour) {

        },

        // Switching condition: what the selected block matches.
        linesMatch: function(behaviour) {

        },

        _matchBehaviour: function(matchOn, match) {
          var matches = false, _text = null;

          if (matchOn == "selection") {
            _text = TextManipulator.selection.getSelectedString();
            matches = _text.match(match);
          }

          else if (matchOn == "lines") {
            _text = TextManipulator.selection.getSelectedLines();
            var matchingLines = 0;

            for (var i = 0; i < _text.length; i++) {
              var _matches = _text[i].match(match);
              if (!!_matches && _matches.length > 0) matchingLines++;
            }

            matches = _text.length == matchingLines;
          }

          else if (matchOn == "block") {
            _text = TextManipulator.selection.getSelectedLines().join("\n");
            matches = _text.match(match);
          }

          return matches;
        },

        matching: function(behaviour) {
          var action = null;

          if (behaviour.default) action = behaviour.default.action.slice();

          for (var i in behaviour) {
            var _behaviour = behaviour[i];

            if (_behaviour.matchOn && _behaviour.match) {
              var matchFound = TextManipulator.conditional._matchBehaviour(
                _behaviour.matchOn,
                _behaviour.match
              );

              if (matchFound) {
                action = _behaviour.action.slice();
                break;
              }
            }
          }

          if (!!action) {
            TextManipulator.callEditor(action);
          }
        }
      },

      // Used for programatically generating strings that can be used as the prefix or suffix
      // type: string just prints a string
      // type: pattern can generate a string from a pattern that is passed in
      //   %d = current line number from start of selection
      //   %sp = number of spaces needed to left-side-pad the string out

      fragment: {
        generate: function(definition){
          if ($.isPlainObject(definition)) {
            // Special matcher type
            return TextManipulator.fragment._create.call(null, definition);
          }
          else {
            // It's a string, let's just do a normal string matcher.
            return TextManipulator.fragment._create.call(null, {
              type: "string",
              pattern: definition
            });
          }
        },

        _arrayOf: function(length, filling){
          return Array.apply(
            null, new Array(length)
          ).map(
            String.prototype.valueOf, filling.toString()
          );
        },

        _create: function(definition) {
          var args = Array.prototype.slice.call(arguments);

          var type    = definition.type;
          var pattern = definition.pattern;
          var matcher = definition.pattern;
          if (!!definition.matcher) {
            matcher = definition.matcher;
          }

          var frag = {
            type:    type,
            pattern: pattern,
            matcher: matcher,

            getString: function(lineNum, maxLines){
              if (this.type == "lineiter") {
                var maxSpaces = maxLines.toString().length;
                var spacesToRender = maxSpaces - lineNum.toString().length;
                var spaces = TextManipulator.fragment._arrayOf(spacesToRender, " ");

                return this.pattern.replace('%d', lineNum).replace('%sp', spaces.join(""));
              }
              else if (this.type == "string") {
                return this.pattern;
              }
              else {
                return this.pattern;
              }
            },

            length: function(lineNum, maxLines){
              return this.getString(lineNum, maxLines).length;
            },

            match: function(string, rendered){
              var renderedIsString = false;
              try {
                renderedIsString = (rendered.length >= 0);  
              }
              catch (e)
              {}
              
              return (
                (renderedIsString && string == rendered.replace("\n", "")) ||
                this.search(string)
              );
            },

            _matcherIsRegexp: function(){
              return !!this.matcher.exec;
            },

            search: function(string){
              if (this._matcherIsRegexp()) {
                return string.match(this.matcher);
              }
              else {
                string == (this.matcher + "");
              }
            }
          };

          return frag;
        }
      }
    };

    TextManipulator.setEditor(elem);
    return TextManipulator;
  };

  $.textManipulator = function() {
    var args = Array.prototype.slice.call(arguments);

    var instance  = args.shift();
    var namespace = args.shift();
    var method    = args.shift();
    var options   = args;

    if (instances[instance]) {
      var inst = instances[instance];

      if (inst[namespace] && inst[namespace][method]) {
        return inst[namespace][method].apply(null, options);
      }

      if (namespace == "destroy") {
        delete instances[instance];
        return true;
      }
    }
    
    $.error('Method ' + [namespace, method].join(".") + ' does not exist on instance ' + instance + ' of jQuery.textManipulator');
  };

  $.fn.textManipulator = function(){
    console.log("Called jQuery.textManipulator");

    $(this).each(function(){
      instances[this.id] = new textManipulatorInstance(this);
      console.log("Added textManipulator instance " + this.id);
    });

    return this;
  };
 
}(jQuery));
