.. _configure-HTML-CSS:

*****************************
The HTML-CSS output processor
*****************************

The options below control the operation of the HTML-CSS output
processor that is run when you include ``"output/HTML-CSS"`` in the
`jax` array of your configuration.  They are listed with their default
values.  To set any of these options, include a ``"HTML-CSS"`` section
in your :meth:`MathJax.Hub.Config()` call.  Note that, because of the
dash, you need to enclose the name in quotes.  For example

.. code-block:: javascript

    MathJax.Hub.Config({
      "HTML-CSS": {
        preferredFont: "STIX"
      }
    });

would set the ``preferredFont`` option to the :term:`STIX` fonts.

.. describe:: scale: 100

    The scaling factor (as a percentage) of math with respect to the
    surrounding text.  The `HTML-CSS` output processor tries to match
    the en-size of the mathematics with that of the text where it is
    placed, but you may want to adjust the results using this scaling
    factor.  The user can also adjust this value using the contextual
    menu item associated with the typeset mathematics.

.. describe:: availableFonts: ["STIX","TeX"]

    This is a list of the fonts to look for on a user's computer in
    preference to using MathJax's web-based fonts.  These must
    correspond to directories available in the
    ``jax/output/HTML-CSS/fonts`` directory, where MathJax stores data
    about the characters available in the fonts.  Set this to
    ``["TeX"]``, for example, to prevent the use of the :term:`STIX`
    fonts, or set it to an empty list, `[]`, if you want to force
    MathJax to use web-based or image fonts.

.. describe:: preferredFont: "TeX"

    Which font to prefer out of the ``availableFonts`` list, when more
    than one is available on the user's computer.

.. describe:: webFont: "TeX"

    This is the web-based font to use when none of the fonts listed
    above are available on the user's computer.  Note that currently
    only the `TeX` font is available in a web-based form (they are
    stored in the ``fonts/HTML-CSS`` folder in the MathJax directory.
    Set this to ``null`` to disable web fonts.
    
.. describe:: imageFont: "TeX"

    This is the font to use for image fallback mode (when none of the
    fonts listed above are available and the browser doesn't support
    web-fonts via the ``@font-face`` CSS directive).  Note that currently
    only the TeX font is available as an image font (they are stores
    in the ``fonts/HTML-CSS`` directory).

    Set this to ``null`` if you want to prevent the use of image fonts
    (e.g., you have deleted or not installed the image fonts on your
    server).  In this case, only browsers that support web-based fonts
    will be able to view your pages without having the fonts installed
    on the client computer.  The browsers that support web-based fonts
    include: IE6 and later, Chrome, Safari3.1 and above, Firefox3.5
    and later, and Opera10 and later.  Note that Firefox3.0 is **not**
    on this list.

.. describe:: styles: {}

    This is a list of CSS declarations for styling the HTML-CSS
    output.  See the definitions in ``jax/output/HTML-CSS/config.js``
    for some examples of what are defined by default.  See :ref:`CSS
    Style Objects <css-style-objects>` for details on how to specify
    CSS style in a JavaScript object.

.. describe:: showMathMenu: true

    This controls whether the MathJax contextual menu will be
    available on the mathematics in the page.  If true, then
    right-clicking (on the PC) or control-clicking (on the Mac) will
    produce a MathJax menu that allows you to get the source of the
    mathematics in various formats, change the size of the mathematics
    relative to the surrounding text, get information about
    MathJax, and configure other MathJax settings.
     
    Set this to ``false`` to disable the menu.  When ``true``, the
    ``MathMenu`` configuration block determines the operation of the
    menu.  See :ref:`the MathMenu options <configure-MathMenu>` for
    more details.

.. describe:: tooltip: { ... }

    This sets the configuration options for ``<maction>`` elements
    with ``actiontype="tooltip"``.  (See also the ``#MathJax_Tooltip``
    style setting in ``jax/output/HTML-CSS/config.js``, which can be
    overridden using the ``styles`` option above.)

    The ``tooltip`` section can contain the following options:

    .. describe:: delayPost: 600

        The delay (in milliseconds) before the tooltip is posted after
        the mouse is moved over the ``maction`` element.

    .. describe:: delayClear: 600

        The delay (in milliseconds) before the tooltop is cleared
        after the mouse moves out of the ``maction`` element.

    .. describe:: offsetX: 10 and offsetY: 5

        These are the offset from the mouse position (in pixels) 
	where the tooltip will be placed.
