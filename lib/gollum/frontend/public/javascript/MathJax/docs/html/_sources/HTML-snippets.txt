.. _html-snippets:

************************
Describing HTML snippets
************************

A number of MathJax configuration options allow you to specify an HTML
snippet using a JavaScript object.  This lets you include HTML in your
configutation files even though they are not HTML files themselves.
The format is fairly simple, but flexible enough to let you represent
complicated HTML trees.

An HTML snippet is an array consisting of a series elements that formt
he HTML tree.  Those elements are one of two things: either a string,
which represents text to be included in the snippet, or an array,
which represents an HTML tag to be included.  In the latter case, the
array consists of three items: a string that is the tag name (e.g.,
"img"), an optional object that gives attributes for the tag (as
described below), and an optional HTML snippet array that gives the
contents of the tag.

When attributes are provided, they are given as `name:value` pairs,
with the `name` giving the attribute name, and `value` giving its
value.  For example

.. code-block:: javascript

    [["img",{src:"/images/mypic.jpg"}]]

represents an HTML snippet that includes one element: an ``<img>`` tag
with ``src`` set to ``/images/mypic.jpg``.  That is, this is
equivalent to 

.. code-block:: html

   <img src="/images/mypic.jpg">

Note that the snippet has two sets of square brackets.  The outermost
one is for the array that holds the snippet, and the innermost set is
because the first (and only) element in the snippet is a tag, not
text.  Note that the code ``["img",{src:"/images/mypic.jpg"}]``
is invalid as an HTML snippet.  It would represent a snippet that
starts with "img" as text in the snippet (not a tag), but the second
item is neither a string nor an array, and so is illegal.  This is a
common mistake that should be avoided.

A more complex example is the following:

.. code-block:: javascript

    [
      "Please read the ",
      ["a",{href:"instructions.html"},["instructions"]],
      " carefully before proceeding"
    ]

which is equivalent to

.. code-block:: html

    please read the <a href="instructions.html">instructions</a> carefully
    before proceeding.

A final example shows how to set style attributes on an object:

.. code-block:: javascript

    [["span",
      {
        id:"mySpan",
        style: {color:"red", "font-weight":"bold"}
      },
      [" This is bold text shown in red "]
    ]]

which is equivalent to

.. code-block:: html

    <span id="mySpan" style="color: red; font-weight: bold;">
    This is bold text shown in red
    </span>

