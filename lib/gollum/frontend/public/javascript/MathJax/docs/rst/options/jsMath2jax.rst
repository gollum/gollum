.. _configure-jsMath2jax:

***************************
The jsMath2jax Preprocessor
***************************

The options below control the operation of the `jsMath2jax`
preprocessor that is run when you include ``"jsMath2jax.js"`` in the
`extensions` array of your configuration.  They are listed with their
default values.  To set any of these options, include a ``jsMath2jax``
section in your :meth:`MathJax.Hub.Config()` call.  For example

.. code-block:: javascript

    MathJax.Hub.Config({
      jsMath2jax: {
        preview: "none"
      }
    });

would set the ``preview`` parameter to ``"none"``.


.. describe:: element: null

    The id name of the element that should be processed by `jsMath2jax`.
    The default is the whole document.

.. describe:: preview: "TeX"

    This controls whether `jsMath2jax` inserts ``MathJax_Preview`` spans
    to make a preview available, and what preview to use, when it
    locates in-line or display mathematics in the page.  The default
    is ``"TeX"``, which means use the TeX code as the preview (which
    will be visible until it is processed by MathJax).  Set to
    ``"none"`` to prevent previews from being inserted (the math
    will simply disappear until it is typeset).  Set to an array
    containing the description of an HTML snippet in order to use the
    same preview for all equations on the page.

    Examples:

    .. code-block:: javascript

        preview: ["[math]"],     //  insert the text "[math]" as the preview

    .. code-block:: javascript

        preview: [["img",{src: "/images/mypic.jpg"}]],  // insert an image as the preview

    See the :ref:`description of HTML snippets <html-snippets>` for
    details on how to represent HTML code in this way.

