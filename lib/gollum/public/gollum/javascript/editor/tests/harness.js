var gollumEditorTests = {
    Text: function(text, sel_start, sel_end) {
        this.text = text;

        if ( typeof sel_start == "number" )
            this.selStart = sel_start;
        else
            this.selStart = this.text.indexOf(sel_start);

        if ( typeof sel_end == "number" )
            this.selEnd = sel_end;
        else
            this.selEnd = this.text.indexOf(sel_end);
    },    

    editorFunctionTest: function(assert, func, 
				 text, sel_start, sel_end,
				 expected, exp_start, exp_end) {

        // Append some text to the buffer.
        // Select a portion (possibly empty) of the text appended.
        // Apply an editor function to the selected text, or at point.
        // Check that the applied function had the expected effect,
        // i.e., that the resulting text is the same as `expected`,
        // and that the resulting selection has the expected start
        // and end indexes (`exp_start` and `exp_end`).


	var $editorBody = $("#gollum-editor-body"); // JQuery object
        var editorBody = $editorBody[0];            // DOM object
        var content = $editorBody.val();
        var start = content.length;
        $editorBody.val(content + text + "\n\n");

        var t0 = new gollumEditorTests.Text(text, sel_start, sel_end);
        var t1 = new gollumEditorTests.Text(expected, exp_start, exp_end);

	editorBody.focus();
	editorBody.select();
	editorBody.setSelectionRange(start + t0.selStart, 
                                     start + t0.selEnd);
        $("#function-"+func).click();

        assert.equal( $editorBody.val().slice(start, -2), t1.text, 
                      "expected markup" );
        assert.equal( editorBody.selectionStart, start + t1.selStart, 
                      "selection start should be " + (start + t1.selStart) );
	assert.equal( editorBody.selectionEnd, start + t1.selEnd, 
                      "selection end should be " + (start + t1.selEnd) );
    }
};
