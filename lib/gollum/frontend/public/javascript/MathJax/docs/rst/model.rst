****************************
The MathJax Processing Model
****************************

The purpose of MathJax is to bring the ability to include mathematics
easily in web pages to as wide a range of browsers as possible.
Authors can specify mathematics in a variety of formats (e.g.,
:term:`MathML` or :term:`LaTeX`), and MathJax provides high-quality
mathematical typesetting even in those browsers that do not have
native MathML support.  This all happens without the need for special
downloads or plugins, but rendering will be enhanced if high-quality
math fonts (e.g., :term:`STIX`) are available to the browser.

MathJax is broken into several different kinds of components: page
preprocessors, input processors, output processors, and the MathJax
Hub that organizes and connects the others.  The input and output
processors are called :term:`jax`, and are described in more detail
below.

When MathJax runs, it looks through the page for special tags that
hold mathematics; for each such tag, it locates an appropriate input
jax which it uses to convert the mathematics into an internal form
(called an element jax), and then calls an output jax to transform the
internal format into HTML content that displays the mathematics within
the page.  The page author configures MathJax by indicating which
input and output jax are to be used.

Often, and especially with pages that are authored by hand, the
mathematics is not stored (initially) within the special tags needed
by MathJax, as that would require more notation than the average page
author is willing to type.  Instead, it is entered in a form that is
more natural to the page author, for example, using the standard TeX
math delimiters ``$...$`` and ``$$...$$`` to indicate what part of the
document is to be typeset as mathematics.  In this case, MathJax can
run a preprocessor to locate the math delimiters and replace them by
the special tags that it uses to mark the formulas.  There are
preprocessors for :ref:`TeX notation <TeX-support>`, :ref:`MathML
notation <MathML-support>`, and the :ref:`jsMath notation
<jsMath-support>` that uses `span` and `div` tags.

For pages that are constructed programatically, such as HTML
pages that result from running a processor on text in some other
format (e.g., pages produced from Markdown documents, or via programs
like `tex4ht`), it would be best to use MathJax's special tags
directly, as described below, rather than having MathJax run
another preprocessor.  This will speed up the final display of the
mathematics, since the extra preprocessing step would not be needed,
and it also avoids the conflict between the use of the less-than sign,
``<``, in mathematics and asn an HTML special character (that starts
an HTML tag).


How mathematics is stored in the page
=====================================

In order to identify mathematics in the page, MathJax uses special
``<script>`` tags to enclose the mathematics.  This is done because
such tags can be located easily, and because their content is not
further processed by the browser; for example, less-than signs can be
used as they are in mathematics, without worrying about them being
mistaken for the beginnings of HTML tags.  One may also consider the
math notation as a form of "script" for the mathematics, so a
``<script>`` tag makes at least some sense for storing the math.

Each ``<script>`` tag has a ``type`` attribute that identifies the
kind of script that the tag contains.  The usual (and default) value
is ``type="text/javascript"``, and when a script has this type, the
browser executes the script as a javascript program.  MathJax,
however, uses the type `math/tex` to identify mathematics in the TeX
and LaTeX notation, and `math/mml` for mathematics in MathML
notation.  When the `tex2jax` or `mml2jax` preprocessors run, they
create ``<script>`` tags with these types so that MathJax can process
them when it runs its main typesetting pass.

For example, 

.. code-block:: html

    <script type="math/tex">x+\sqrt{1-x^2}</script>

represents an in-line equation in TeX notation, and 

.. code-block:: html

    <script type="math/tex; mode=display">
      \sum_{n=1}^\infty {1\over n^2} = {\pi^2\over 6}
    </script>

is a displayed TeX equation.

Alternatively, using MathML notation, you could use

.. code-block:: html

    <script type="math/mml">
      <math>
        <mi>x</mi>
        <mo>+</mo>
        <msqrt>
          <mn>1</mn>
          <mo>&#x2212;<!-- − --></mo>
          <msup>
            <mi>x</mi>
            <mn>2</mn>
          </msup>
        </msqrt>
      </math>
    </script>

for in-line math, or

.. code-block:: html

    <script type="math/mml">
      <math display="block">
        <mrow>
          <munderover>
            <mo>&#x2211;<!-- ∑ --></mo>
            <mrow>
              <mi>n</mi>
              <mo>=</mo>
              <mn>1</mn>
            </mrow>
            <mi mathvariant="normal">&#x221E;<!-- ∞ --></mi>
          </munderover>
        </mrow>
        <mrow>
          <mfrac>
            <mn>1</mn>
            <msup>
              <mi>n</mi>
              <mn>2</mn>
            </msup>
          </mfrac>
        </mrow>
        <mo>=</mo>
        <mrow>
          <mfrac>
            <msup>
              <mi>&#x03C0;<!-- π --></mi>
              <mn>2</mn>
            </msup>
            <mn>6</mn>
          </mfrac>
        </mrow>
      </math>
    </script>

for displayed equations in MathML notation.
As other input jax are created, they will use other types to identify
the mathematics they can process.

Page authors can use one of MathJax's preprocessors to convert from
math delimiters that are more natural for the author to type (e.g.,
TeX math delimiters like ``$$...$$``) to MathJax's ``<script>``
format.  Blog and wiki software could extend from their own markup
languages to include math delimiters, which they could convert to
MathJax's ``<script>`` format automatically.

Note, however, that Internet Explorer has a bug that causes it to
remove the space before a ``<script>`` tag if there is also a space
after it, which can cause serious spacing problems with in-line math
in Internet Explorer.  There are three possible solutions to this in
MathJax.  The recommended way is to use a math preview (an element
with class ``MathJax_Preview``) that is non-empty and comes right
before the ``<script>`` tag.  Its contents can be just the word
``[math]``, so it does not have to be specific to the mathematics
script that follows; it just has to be non-empty (though it could have
its style set to ``display:none``).  See also the ``preJax`` and
``postJax`` options in the :ref:`Core Configuration Options
<configure-hub>` document for another approach.


The components of MathJax
=========================

The main components of MathJax are its preprocessors, its input and
output jax, and the MathJax Hub, which coordinates the actions of the
other components.

**Input jax** are associated with the different script types (like
:mimetype:`math/tex` or :mimetype:`math/mml`) and the mapping of a
particular type to a particular jax is made when the various jax
register their abilities with the MathJax Hub at configuration time.
For example, the MathML input jax registers the :mimetype:`math/mml`
type, so MathJax will know to call the MathML input jax when it sees
math elements of that type.  The role of the input jax is to convert
the math notation entered by the author into the internal format used
by MathJax (called an `element jax`).  This internal format is
essentially MathML (represented as JavaScript objects), so an input
jax acts as a translator into MathML.

**Output jax** convert that internal element jax format into a specific
output format.  For example, the NativeMML output jax inserts MathML
tags into the page to represent the mathematics, while the HTML-CSS
output jax uses HTML with CSS styling to lay out the mathematics so
that it can be displayed even in browsers that dont understand
MathML.  Output jax could be produced that render the mathematics
using SVG, for example, or that speak an equation for the blind
users.  The MathJax contextual menu can be used to switch between the
output jax that are available.

Each input and output jax has a small configuration file that is
loaded when that input jax is included in the `jax` array in the
MathJax configuration, and a larger file that implements the core
functionality of that particular jax.  The latter file is loaded
when the first time the jax is needed by MathJax to process some
mathematics.

The **MathJax Hub** keeps track of the internal representations of the
various mathematical equations on the page, and can be queried to
obtain information about those equations.  For example, one can obtain
a list of all the math elements on the page, or look up a particular
one, or find all the elements with a given input format, and so on.
In a dynamically generated web page, an equation where the source
mathematics has changed can be asked to re-render itself, or if a new
paragraph is generated that might include mathematics, MathJax can be
asked to process the equations it contains.

The Hub also manages issues concerning mouse events and other user
interaction with the equation itself.  Parts of equations can be made
active so that mouse clicks cause event handlers to run, or activate
hyperlinks to other pages, and so on, making the mathematics as
dynamic as the rest of the page.
