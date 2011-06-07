.. _css-style-objects:

*****************
CSS Style Objects
*****************

Many MathJax components allow you to specify CSS styles that control
the look of the elements they create.  These are described using CSS
style objects, which are JavaScript objects that represent standard
CSS declarations.  The main CSS style object is a collection of
`name:value` pairs where the `name` is the CSS selector that is being
defined, and the `value` is an object that gives the style for that
selector.  Most often, the selector will need to be enclosed in
quotation marks, as it will contain special characters, so you would
need to use ``"#myID"`` rather than just ``#myID`` and ``"ul li"``
rather than just ``ul li``.

The value used to define the CSS style can either be a string
containing the CSS definition, or a javascript object that is itself a
collection of `name:value` pairs, where the `name` is the attribute
being defined and `value` is the value that attibute should be given.
Note that, since this is a JavaScript object, the pairs are separated
by commas (not semi-colons) and the values are enclosed in quotation
marks.  If the name contains dashes, it should be enclosed in
quotation marks as well.

For example, ``jax/output/HTML-CSS/config.js`` includes the following
declaration:

.. code-block:: javascript

    styles: {

      ".MathJax .merror": {
        "background-color": "#FFFF88",
        color:   "#CC0000",
        border:  "1px solid #CC0000",
        padding: "1px 3px",
        "font-family": "serif",
        "font-style": "normal",
        "font-size":  "90%"
      },

      ".MathJax_Preview": {color: "#888888"},

    }

This defines two CSS styles, one for the selector ``.MathJax
.merror``, which specifies a background color, foreground color,
border, and so on, and a second for ``.MathJax_Preview`` that sets its
color.

You can add as many such definitions to a ``styles`` object as you
wish.  Note, however, that since this is a JavaScript object, the
selectors must be unique (e.g., you can't use two definitions for
``"img"``, for example, as only the last one would be saved).  If you
need to use more than one entry for a single selector, you can add
comments like ``/* 1 */`` and ``/* 2 */`` to the selector to make them
unique.

It is possible to include selectors like ``"@media print"``, in which
case the value is a CSS style object.  For example:

.. code-block:: javascript

    styles: {
      "@media print": {
        ".MathJax .merror": {
           "background-color": "white",
           border: 0
        }
      }
    }

The various extensions and output processors include more examples of
CSS style objects, so see the code for those files for additional
samples.  In particular, the ``extensions/MathMenu.js``,
``extensions/MathZoom.js``, ``extensions/FontWarnsing.js``, and
``jax/output/HTML-CSS/jax.js`` files include such definitions.
