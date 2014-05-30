(function($) {

	var instances = {};

	var textManipulatorInstance = function(elem){

		var TextManipulator = {

		  editor: null,

		  setEditor: function(editor){
		    TextManipulator.editor = editor;
		  },

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
		      return TextManipulator.selection.getSelectedString().split("\n");
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

		  selected: {
		    isWrapped: function(prefix, suffix) {
		      var selectedString = TextManipulator.selection.getSelectedString();

          var hasPrefix = (selectedString.substring(0, prefix.length) == prefix),
              hasSuffix = (selectedString.substring(selectedString.length - suffix.length) == suffix);

		      return (hasPrefix && hasSuffix);
		    },

		    wrap: function(prefix, suffix) {
		      var currentText = TextManipulator.selection.getSelectedString();

		      var newText = [
		        prefix,
		        currentText,
		        suffix
		      ].join("");

		      TextManipulator.selection.replace(newText);
		    },

		    unwrap: function(prefix, suffix) {
		      var currentText = TextManipulator.selection.getSelectedString();

		      var newText = currentText.substring(prefix.length, currentText.length - suffix.length);

		      TextManipulator.selection.replace(newText);
		    },

		    toggleWrap: function(prefix, suffix) {
		      if (!suffix) suffix = prefix;

		      if (TextManipulator.selected.isWrapped(prefix, suffix)) {
		        TextManipulator.selected.unwrap(prefix, suffix);
		      }
		      else {
		        TextManipulator.selected.wrap(prefix, suffix);
		      }
		    },
		  },

		  lines: {
		    areWrapped: function(prefix, suffix){
		      if (!prefix) prefix = "";
		      if (!suffix) suffix = "";

		      var selectedLines = TextManipulator.selection.getSelectedLines();
		      var hasPrefix = [], hasSuffix = [];

		      for (var i = 0; i < selectedLines.length; i++) {
		        if (selectedLines[i].substring(0, prefix.length) == prefix) {
		          hasPrefix.push(i);
		        }
		        if (selectedLines[i].substring(selectedLines[i].length - suffix.length) == suffix) {
		          hasSuffix.push(i);
		        }
		      }

		      return (
		        (hasPrefix.length == selectedLines.length) && 
		        (hasSuffix.length == selectedLines.length)
		      );
		    },

		    wrap: function(prefix, suffix) {
		      if (!prefix) prefix = "";
		      if (!suffix) suffix = "";

		      var selected = TextManipulator.selection.getSelectedLineNumbers();
		      var selectedLines = TextManipulator.selection.getSelectedLines();

          var newLineContent = [];

		      for (var i = selected.start; i <= selected.end; i++) {
		        var currentLineText = selectedLines[i - selected.start];
            newLineContent.push(prefix + currentLineText + suffix);
		      }

          var range = TextManipulator.selection.currentRange();
          range.start.column = 0;
          range.end.column = selectedLines[selectedLines.length - 1].length;

          TextManipulator.selection.replace(newLineContent.join("\n"), range);
		    },

		    unwrap: function(prefix, suffix) {
		      if (!prefix) prefix = "";
		      if (!suffix) suffix = "";

		      var selected = TextManipulator.selection.getSelectedLineNumbers();
		      var selectedLines = TextManipulator.selection.getSelectedLines();

          var newLineContent = [];

		      for (var i = selected.start; i <= selected.end; i++) {
		        var currentLineText = selectedLines[i - selected.start];
            newLineContent.push(currentLineText.substring(
              prefix.length, 
              currentLineText.length - suffix.length
            ));
		      }

          var range = TextManipulator.selection.currentRange();
          range.start.column = 0;
          range.end.column = selectedLines[selectedLines.length - 1].length;

          TextManipulator.selection.replace(newLineContent.join("\n"), range);
		    },

        toggleWrap: function(prefix, suffix) {
          if (!prefix) prefix = "";
          if (!suffix) suffix = "";

          if (TextManipulator.lines.areWrapped(prefix, suffix)) {
            TextManipulator.lines.unwrap(prefix, suffix);
          }
          else {
            TextManipulator.lines.wrap(prefix, suffix);
          }
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
