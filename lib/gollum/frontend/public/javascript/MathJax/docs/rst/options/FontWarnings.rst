.. _configure-FontWarnings:

**************************
The FontWarnings extension
**************************

The options below control the operation of the `FontWarnings`
extension that is run when you include ``"FontWarnings.js"`` in the
`extensions` array of your configuration.  They are listed with their
default values.  To set any of these options, include a
``FontWarnings`` section in your :meth:`MathJax.Hub.Config()` call.
For example

.. code-block:: javascript

    MathJax.Hub.Config({
      FontWarnings: {
        fadeoutTime: 2*1000
      }
    });

would set the ``fadeoutTime`` option to 2000 milliseconds (2 seconds).

.. describe:: messageStyle: { ... }

   This sets the CSS styles to be used for the font warning message
   window.  See the ``extensions/FontWarnings.js`` file for details of
   what are set by default.  See the :ref:`CSS style objects
   <css-style-objects>` for details about how to specify CSS styles
   via javascript objects.

.. describe:: Message: { ... }

   This block contains HTML snippets to be used for the various
   messages that the FontWarning extension can produce.  There are
   three messages that you can redefine to suit your needs:

   .. describe:: webFont: [ ... ]

       The message used for when MathJax uses web-based fonts (rather
       than local fonts installed on the user's system).

   .. describe:: imageFonts: [ ... ]

       The message used for when MathJax must use image fonts rather
       than local or web-based fonts (for those browsers that don't
       handle the ``@font-face`` CSS directive).

   .. describe:: noFonts: [ ... ]

       The message used when MathJax is unable to find any font to use
       (i.e., neither local nor web-based nor image-based fonts are
       available).

   Any message that is set to ``null`` rather than an HTML snippet
   array will not be presented to the user, so you can set, for
   example, the ``webFont`` message to ``null`` in order to have the
   ``imageFonts`` and ``noFonts`` messages, but no message if MathJax
   uses web-based fonts.

   See the description of :ref:`HTML snippets <html-snippets>` for
   details about how to describe the messages using HTML snippets.
   Note that in addition to the usual rules for defining such
   snippets, the FontWarnings snippets can include references to
   pre-defined snippets (that represent elements common to all three
   messages).  These are defined below in the ``HTML`` block, and are
   referenced using ``["name"]`` within the snippet, where `name` is
   the name of one of the snippets defined in the ``HTML``
   configuration block.  For example

   .. code-block:: javascript

       Message: {
         noFonts: [
           ["closeBox"],
           "MathJax is unable to locate a font to use to display ",
           "its mathematics, and image fonts are not available, so it ",
           "is falling back on generic unicode characters in hopes that ",
           "your browser will be able to display them.  Some characters ",
           "may not show up properly, or possibly not at all.",
           ["fonts"],
           ["webfonts"]
	 ]
       }

    refers to the ``closeBox``, ``fonts`` and ``webfonts`` snippets in
    declared in the ``HTML`` section.

.. describe:: HTML: { ... }

    This object defines HTML snippets that are common to more than one
    message in the ``Message`` section above.  They can be called in
    by using ``["name"]`` in an HTML snippet, where `name` refers to
    the name of the snippet in the ``HTML`` block.  The pre-defined
    snippets are:

    .. describe:: closeBox

        The HTML for the close box in the FontWarning message.

    .. describe:: webfonts

        The HTML for a paragraph suggesting an upgrade to a more
        modern browser that supports web fonts.

    .. describe:: fonts

        HTML that includes links to the MathJax and STIX font download
        pages.

    .. describe:: STIXfonts

        HTML that gives the download link for the STIX fonts only.
        (Used in place of `fonts` when the `HTML-CSS` option for
        `availableFonts` only includes the :term:`STIX` fonts.)

    .. describe:: TeXfonts

        HTML that gives the download link for the MathJax TeX fonts
        only.  (Used in place of `fonts` when the `HTML-CSS` option
        for `availableFonts` only includes the `TeX` fonts.)

    You can add your own pre-defined HTML snippets to this object, or
    override the ones that are there with your own text.

.. describe:: removeAfter: 12*1000

    This is the amount of time to show the FontWarning message, in
    milliseconds.  The default is 12 seconds.

.. describe:: fadeoutSteps: 10

    This is the number of steps to take while fading out the
    FontWarning message.  More steps make for a smoother fade-out.

.. describe:: fadeoutTime: 1.5*1000

    This is the time used to perform the fade-out, in milliseconds.
    The default is 1.5 seconds.

