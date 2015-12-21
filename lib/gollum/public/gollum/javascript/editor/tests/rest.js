var expected_markup = "rest";

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
             "Some *test* text", 5, 11);

    funcTest(assert, func,
	     "Make these four\nwords italic, and \nthe rest not.",
	     "these", ",",
	     "Make *these four*\n*words italic*, and \nthe rest not.",
	     "*", ",");

    var t = "Italicize the following text: ";
    funcTest(assert, func, 
	     t, t.length, t.length,
             t + "**", t.length + 1, t.length + 1);
});

QUnit.test( "Code function", function( assert ) {
    var func = "code";

    funcTest(assert, func, 
	     "Set the word function in code font.", "function", " in",
	     "Set the word ``function`` in code font.", "`", " in");
});

QUnit.test( "HR function", function( assert ) {
    var func = "hr";

    var t = "Horizontal rule should follow this line.";
    var th = t + "\n\n----\n\n";
    funcTest(assert, func, 
	     t, t.length, t.length,
	     th, th.length, th.length);

});

QUnit.test( "UL function", function( assert ) {
    var func = "ul";

    var t0 = "Some list items:\nFoo\nBar\nBaz\nNot part of the list.";
    var t1 = "Some list items:\n* Foo\n* Bar\n* Baz\nNot part of the list.";
    funcTest( assert, func,
              t0, "Foo", "\nNot",
              t1, "*", "\nNot" );
});

QUnit.test( "OL function", function( assert ) {
    var func = "ol";

    var t0 = "Some list items:\nUno\nDue\nTre\nNot part of the list.";
    var t1 = "Some list items:\n1. Uno\n2. Due\n3. Tre\nNot part of the list.";

    funcTest( assert, func,
              t0, "Uno", "\nNot",
              t1, "1.", "\nNot" );
});

QUnit.test( "Blockquote function", function( assert ) {
    var func = "blockquote";

    t0 = "All this text should be blockquoted.";
    indent = "    ";
    funcTest( assert, func,
              t0, 0, 0,
              indent + t0, 0, indent.length);
});

QUnit.test( "H1 function", function( assert ) {
    var func = "h1";

    t = "Heading 1";
    funcTest(assert, func,
             t, 0, t.length,
	     t + "\n" + "=".repeat(t.length) + "\n", 0, 2 * (t.length + 1))
});

QUnit.test( "H2 function", function( assert ) {
    var func = "h2";

    t = "Heading 2";
    funcTest(assert, func,
             t, 0, t.length,
	     t + "\n" + "-".repeat(t.length) + "\n", 0, 2 * (t.length + 1))
});

QUnit.test( "H3 function", function( assert ) {
    var func = "h3";

    t = "Heading 3";
    funcTest(assert, func,
             t, 0, t.length,
	     t + "\n" + "~".repeat(t.length) + "\n", 0, 2 * (t.length + 1))
});

QUnit.test( "Link function", function( assert ) {
    var func = "link";

    expect(0);
});

QUnit.test( "Image function", function( assert ) {
    var func = "image";

    expect(0);
});


