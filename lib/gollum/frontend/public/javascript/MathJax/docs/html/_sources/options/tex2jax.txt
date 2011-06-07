.. _configure-tex2jax:

************************
The tex2jax Preprocessor
************************

The options below control the operation of the `tex2jax` preprocessor
that is run when you include ``"tex2jax.js"`` in the `extensions` array
of your configuration.  They are listed with their default values.  To
set any of these options, include a ``tex2jax`` section in your
:meth:`MathJax.Hub.Config()` call.  For example

.. code-block:: javascript

    MathJax.Hub.Config({
      tex2jax: {
        inlineMath: [ ['$','$'], ['\\(','\\)'] ]
      }
    });

would set the ``inlineMath`` delimiters for the `tex2jax`
preprocessor.


.. describe:: element: null

    The id name of the element that should be processed by `tex2jax`.
    The default is the whole document.

.. describe:: inlineMath: [['\\(','\\)']]

    Array of pairs of strings that are to be used as in-line math
    delimters.  The first in each pair is the initial delimiter and
    the second is the terminal delimiter.  You can have as many pairs
    as you want.  For example,

    .. code-block:: javascript

        inlineMath: [ ['$','$'], ['\\(','\\)'] ]

    would cause `tex2jax` to look for ``$...$`` and ``\(...\)`` as
    delimiters for inline mathematics.  (Note that the single dollar
    signs are not enabled by default because they are used too
    frequently in normal text, so if you want to use them for math
    delimiters, you must specify them explicitly.)

    Note that the delimiters can't look like HTML tags (i.e., can't
    include the less-than sign), as these would be turned into tags by
    the browser before MathJax has the chance to run.  You can only
    include text, not tags, as your math delimiters.

.. describe:: displayMath: [ ['$$','$$'], ['\\[','\\]'] ]

    Array of pairs of strings that are to be used as delimters for
    displayed equations.  The first in each pair is the initial
    delimiter and the second is the terminal delimiter.  You can have
    as many pairs as you want.

    Note that the delimiters can't look like HTML tags (i.e., can't
    include the less-than sign), as these would be turned into tags by
    the browser before MathJax has the chance to run.  You can only
    include text, not tags, as your math delimiters.

.. describe:: processEscapes: false

    When set to ``true``, you may use ``\$`` to represent a literal
    dollar sign, rather than using it as a math delimiter.  When
    ``false``, ``\$`` will not be altered, and the dollar sign may be
    considered part of a math delimiter.  Typically this is set to
    ``true`` if you enable the ``$ ... $`` in-line delimiters, so you
    can type ``\$`` and `tex2jax` will convert it to a regular dollar
    sign in the rendered document.

.. describe:: processEnvironments: true

    When ``true``, `tex2jax` looks not only for the in-line and
    display math delimters, but also for LaTeX environments 
    (``\begin{something}...\end{something}``) and marks them for
    processing by MathJax.  When ``false``, LaTeX environments will
    not be processed outside of math mode.

.. describe:: preview: "TeX"

    This controls whether `tex2jax` inserts ``MathJax_Preview`` spans
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

.. describe:: skipTags: ["script","noscript","style","textarea","pre","code"]

    This array lists the names of the tags whose contents should not
    be processed by `tex2jax` (other than to look for ignore/process
    classes as listed below).  You can add to (or remove from) this
    list to prevent MathJax from processing mathematics in specific
    contexts.

.. describe:: ignoreClass: "tex2jax_ignore"

    This is the class name used to mark elements whose contents should
    not be processed by tex2jax (other than to look for the
    ``processClass`` pattern below).  Note that this is a regular
    expression, and so you need to be sure to quote any `regexp`
    special characters.  The pattern is automatically preceeded by
    ``'(^| )('`` and followed by ``')( |$)'``, so your pattern will
    have to match full words in the class name.  Assigning an element
    this class name will prevent `tex2jax` from processing its
    contents.

.. describe:: processClass: "tex2jax_process"

    This is the class name used to mark elements whose contents
    *should* be processed by `tex2jax`.  This is used to turn on
    processing within tags that have been marked as ignored or skipped
    above.  Note that this is a regular expression, and so you need to
    be sure to quote any `regexp` special characters.  The pattern is
    automatically preceeded by ``'(^| )('`` and followed by ``')(
    |$)'``, so your pattern will have to match full words in the class
    name.  Use this to restart processing within an element that has
    been marked as ignored above.
