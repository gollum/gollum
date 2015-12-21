/*
 * Template for writing editor-function tests for your favorite
 * markup language. 
 *
 * Replace "YOUR_FAVORITE_MARKUP" below with the name Gollum uses
 * to identify your markup (e.g., "rest" for "reStructuredText", etc.).
 *
 * Then implement tests for whichever editor functions Gollum supports
 * for your markup language.
 */
var expected_markup = "YOUR_FAVORITE_MARKUP";

QUnit.test( "Editor environment", function( assert ) {
        assert.equal( typeof $.GollumEditor, "function",
                      "GollumEditor should be a function");
        assert.equal( default_markup, expected_markup, 
                      "default_markup should be " + expected_markup);
});

var funcTest = gollumEditorTests.editorFunctionTest;

QUnit.test( "Bold function", function( assert ) {
    var func = "bold";

    // Leave the `expect(0);` line, and go on to the next
    // `Qunit.test()` call if your markup language doesn't 
    // have syntax for the kind of markup that's the subject
    // of the test, or the Gollum editor doesn't yet have an
    // editor function for that syntax. 

    expect(0);

    // Otherwise, delete the `expect(0);` line and write your 
    // tests.

    // See harness.js for a useful helper function,
    // `gollumEditorTests.editorFunctionTest()`.
});

QUnit.test( "Italic function", function( assert ) {
    var func = "italic";

    expect(0);    
});

QUnit.test( "Code function", function( assert ) {
    var func = "code";

    expect(0);
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


