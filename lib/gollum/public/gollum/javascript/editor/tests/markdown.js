var expected_markup = "markdown";

QUnit.test( "Editor environment", function( assert ) {
        assert.equal( typeof $.GollumEditor, "function",
                      "GollumEditor should be a function");
        assert.equal( default_markup, expected_markup, 
                      "default_markup should be " + expected_markup);
});

var funcTest = gollumEditorTests.editorFunctionTest;

QUnit.test( "Bold function", function( assert ) {
    var func = "bold";

    funcTest(assert, func, 
	     "Some test text", 5, 9,
             "Some **test** text", 5, 13);

    funcTest(assert, func,
	     "Make these four\nwords bold, and \nthe rest not.",
	     "these", ",",
	     "Make **these four**\n**words bold**, and \nthe rest not.",
	     "**", ",");

    var t = "Bold the following text: ";
    funcTest(assert, func, 
	     t, t.length, t.length,
             t + "****", t.length + 2, t.length + 2);

});

QUnit.test( "Italic function", function( assert ) {
    var func = "italic";

    funcTest(assert, func, 
	     "Some test text", 5, 9,
             "Some _test_ text", 5, 11);

    funcTest(assert, func,
	     "Make these four\nwords italic, and \nthe rest not.",
	     "these", ",",
	     "Make _these four_\n_words italic_, and \nthe rest not.",
	     "_", ",");

    var t = "Italicize the following text: ";
    funcTest(assert, func, 
	     t, t.length, t.length,
             t + "__", t.length + 1, t.length + 1);
});

QUnit.test( "Code function", function( assert ) {
    var func = "code";

    funcTest(assert, func, 
	     "Set the word function in code font.", "function", " in",
	     "Set the word `function` in code font.", "`", " in");
});

QUnit.test( "HR function", function( assert ) {
    var func = "hr";
    expect(0);
});

QUnit.test( "UL function", function( assert ) {
    var func = "ul";
    expect(0);
});

QUnit.test( "OL function", function( assert ) {
    var func = "ol";
    expect(0);
});

QUnit.test( "Blockquote function", function( assert ) {
    var func = "blockquote";
    expect(0);
});

QUnit.test( "H1 function", function( assert ) {
    var func = "h1";
    expect(0);
});

QUnit.test( "H2 function", function( assert ) {
    var func = "h2";
    expect(0);
});

QUnit.test( "H3 function", function( assert ) {
    var func = "h3";
    expect(0);
});

QUnit.test( "Link function", function( assert ) {
    var func = "link";
    expect(0);
});

QUnit.test( "Image function", function( assert ) {
    var func = "image";
    expect(0);
});


