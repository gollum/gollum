.. _MathML-support:

**********************
MathJax MathML Support
**********************

The support for :term:`MathML` in MathJax consists of three parts:  the
`mml2jax` preprocessor, the MathML input processor, and the NativeMML
output processor.  The first of these looks for ``<math>`` tags within
your document and marks them for later processing by MathJax.  The
second converts the MathML to the internal format used by MathJax, and
the third turns the internal format into MathML within the page so
that it can be displayed by the browser's native MathML support.

Because of MathJax's modular design, you do not need to use all three
of these components.  For example, you could use the `tex2jax`
preprocessor and the TeX input processor, but the NativeMML output
processor, so that your mathematics is entered in TeX format, but
displayed as MathML.  Or you could use the `mml2jax` reprocessor and
MathML input processor with the HTML-CSS output processor to make
MathML available in browsers that don't have native MathML support.
It is also possible to have MathJax select the output processor for
you so that MathML is used in those browsers that support it, while
HTML-CSS is used for those that don't.  See the :ref:`common
configurations <common-configurations>` section for details and
examples.

Of course it is also possible to use all three components together.
It may seem strange to go through an internal format just to return to
MathML in the end, but this is actually what makes it possible to view
MathML within an HTML page (rather than an XHTML page), without
the complications of handling special MIME-types for the document, or
any of the other setup issues that make using native MathML
difficult.  MathJax handles the setup and properly marks the
mathematics so that the browser will render it as MathML.  In
addition, MathJax provides its contextual menu for the MathML, which
lets the user zoom the mathematics for easier reading, get the copy
the source markup, and so on, so there is added value to using MathJax
even whith a pure MathML workflow.


MathML in HTML pages
====================

For MathML that is handled via the pre-processor, you should not use
the named MathML entities, but rather use the numeric entities like
``&#x221A;`` or unicode characters embedded in the page itself.  The
reason is that entities are replaced by the browser before MathJax
runs, and some browsers report errors for unknown entities.  For
browsers that are not MathML-aware, that will cause errors to be
displayed for the MathML entities.  While that might not occur in the
browser you are using to compose your pages, it can happen with other
browsers, so you should avoid the named entities whenever possible.
If you must use named entities, you may need to declare them in the
`DOCTYPE` declaration by hand.

When you use MathML in an HTML document rather than an XHTML one
(MathJax will work woth both), you should not use the "self-closing"
form for tags with no content, but should use separate open and close
tags.  That is, use

.. code-block:: html

    <mspace width="thinmathspace"></mspace>

rather than ``<mspace width="thinmathspace />``.  This is because HTML
does not have self-closing tags, and some browsers will get the
nesting of tags wrong if you attempt to use them.  For example, with
``<mspace width="1em" />``, since there is no closing tag, the rest of
the mathematics will become the content of the ``<mspace>`` tag; but
since ``<mspace>`` should have no content, the rest of the mathematics
will not be displayed.  This is a common error that should be avoided.


Supported MathML commands
=========================

MathJax supports the `MathML3.0 <http://www.w3.org/TR/MathML3/>`_
presentation mathematics tags, with some limitations.  The MathML
support is still under active development, so some tags are not yet
implemented, and some features are not fully developed, but are
coming.

The deficiencies include:

- No support for the elementary math tags: ``mstack``, ``mlongdiv``,
  ``msgroup``, ``msrow``, ``mscarries``, and ``mscarry``.

- Limited support for line breaking (they are only allowed in direct
  children of ``mrow`` or implied ``mrow`` elements.

- No support for alignment groups in table.

- No support for right-to-left rendering.

See the `results of the MathML3.0 test suite
<http://www.w3.org/Math/testsuite/results/tests.html>`_ for details.
