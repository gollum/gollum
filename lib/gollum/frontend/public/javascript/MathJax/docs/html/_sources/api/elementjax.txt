.. _api-element-jax:

****************************
The MathJax.ElementJax Class
****************************

The element jax is the bridge between the input and output jax, and
contains the data produced by the input jax needed by the output jax
to display the results.  It is tied to the individual ``<script>`` tag
that produced it, and is the object used by JavaScript programs to
interact with the mathematics on the page.

An element jax is stored in the ``jax.js`` file in a subdirectory of
the ``jax/element`` directory, with the subdirectory name being the
name of the element jax.  Currently, there is only one element jax
class, the `mml` element jax, and it is stored in ``jax/element/mml``.

The `MathJax.ElementJax` class is a subclass of the :ref:`MathJax Jax
<api-jax>` class, and inherits the properties and methods of that
class.  Those listed below are the additional or overridden ones from
that class.


Class Properties
================

.. describe:: name

    The name of the jax.

.. describe:: version

    The version number of the jax.

.. describe:: directory

    The directory where the jax files are stored (e.g., ``"[MathJax]/jax/element/mml"``);


Instance Properties
===================

.. describe:: inputJax

    A reference to the input jax that created the element.
 
.. describe:: outputJax

    A reference to the output jax that has processed this element.
 
.. describe:: inputID

    The DOM `id` of the ``<script>`` tag that generated this element
    (if it doesn't have one initially, the MathJax hub will supply
    one).  Note that this is not a reference to the element itself;
    that element will have a reference to this element jax, and if
    `inputID` were a reference back, that would cause a reference
    loop, which some browsers would not free properly during trash
    collection, thus causing a memory leak.
 
.. describe:: originalText

    A string indicating the original input text that was processed for
    this element.

.. describe:: mimeType

    The MIME-type of the element jax (`jax/mml` in the case of an
    `mml` element jax).

Other data specific to the element jax subclass may also appear here.


Methods
=======

.. Method:: Text(text[,callback])

    Sets the input text for this element to the given text and
    reprocesses the mathematics.  (I.e., update the equation to the
    new one given by `text`).  When the processing is complete, the
    `callback`, if any, is called.

    :Parameters:
        - **text** --- the new mathematic source string for the element
	- **callback** --- the callback specification
    :Returns: the callback object
 
.. Method:: Reprocess([callback])
    :noindex:

    Remove the output and produce it again.  This may be necessary if
    there are changes to the CSS styles that would affect the layout
    of the mathematics, for example.  The `callback`, if any, is
    called when the process completes.
 
    :Parameters:
	- **callback** --- the callback specification
    :Returns: the callback object

.. Method:: Remove()
    :noindex:

    Removes the output for this element from the web page (but does
    not remove the original ``<script>``).  The ``<script>`` will be
    considered unprocessed, and the next call to
    :meth:`MathJax.hub.Typeset()` will re-display it.

    :Returns: ``null``
 
.. Method:: SourceElement()

    Returns a reference to the original ``<script>`` DOM element
    associated to this element jax.

    :Returns: the ``<script>`` element

Output jax may add new methods to the base element jax class to
perform exporting to other formats.  For example, a MathML output jax
could add ``toMathML()``, or an accessibility output jax could add
``toAudible()``.  These could be made available via the MathJax
contextual menu.
