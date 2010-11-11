.. _api-output-jax:

***************************
The MathJax.OutputJax Class
***************************

Output jax are the components of MathJax that translate
mathematics from the MathJax internal format (an `element jax`)
to whatever output is required to represent the mathematics (e.g.,
MathML elements, or HTML-with-CSS that formats the mathematics on screen).

An output jax is stored as a pair of files in a subdirectory of the
the ``jax/output`` directory, with the subdirectory name being the
name of the output jax.  For example, the NativeMML output jax is
stored in `jax/output/NativeMML`.  The first file, ``config.js``, is
loaded when MathJax is being loaded and configured, and is indicated
by listing the input jax directory in the `jax` array of the MathJax
configuration.  The ``config.js`` file creates a subclass of the
`MathJax.OutputJax` object for the new output jax and registers it
with MathJax, along with the MIME-type of the element jax that it can
process.

The main body of the output jax is stored in the second file, ``jax.js``,
which is loaded when the output jax is first called on to translate
some mathematics.  This file augments the original output jax
subclass with the additional methods needed to produce the output.
MathJax calls the input jax's :meth:`Translate()` method when it needs
the output jax to translate an element jax to produce output.

The `MathJax.OutputJax` class is a subclass of the :ref:`MathJax Jax
<api-jax>` class, and inherits the properties and methods of that
class.  Those listed below are the additional or overridden ones from
that class.


Properties
==========

.. describe:: name

    The name of the jax.

.. describe:: version

    The version number of the jax.

.. describe:: directory

    The directory where the jax files are stored (e.g., ``"[MathJax]/jax/output/HTML-CSS"``);


Methods
=======

.. Method:: Translate(script)
    :noindex:

    This is the main routine called by MathJax when an element jax is
    to be converted to output.  The default :meth:`Translate()`
    method simply loads the ``jax.js`` file and returns that callback
    for that load function so that MathJax will know when to try
    the :meth:`Translate()` action again.  When the ``jax.js`` file
    loads, it should override the default :meth:`Translate()` with its
    own version that does the actual translation; that way, when the
    second Translate call is made, it will be to the actual
    translation routine rather than the default loader.

    You should use ``MathJax.Hub.getJaxFor(script)`` to obtain the
    element jax for the given script.  The translation process may add
    modify the element jax (e.g., if it has data that needs to be
    stored with the jax), and may insert DOM elements into the
    document near the jax's ``<script>`` tag.

    :Parameters:
        - **script**  --- the ``<script>`` element to be translated
    :Returns: the `element jax` resulting from the translation
 
.. Method:: Register(mimetype)
    :noindex:

    This registers the MIME-type for the element jax associated with
    this output jax so that MathJax knows to call this jax when it
    wants to display an element jax of that type.  Several output jax
    may register for the same input jax, in which case the first one
    to register will be the default one for that type.

    :Parameters:
        - **mimetype** --- the MIME-type of the input this jax processes
    :Returns: ``null``

.. Method:: Remove(jax)
    :noindex:

    Removes the output associated with the given element jax.  The
    routine can use ``jax.SourceElement()`` to locate the ``<script>``
    tag associated with the element jax.

    :Parameters:
        - **jax** --- the element jax whose display should be removed
    :Returns: ``null``
