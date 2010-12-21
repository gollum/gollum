.. _api-input-jax:

**************************
The MathJax.InputJax Class
**************************

Input jax are the components of MathJax that translate
mathematics from its original format (like :term:`TeX` or
:term:`MathML`) to the MathJax internal format (an `element jax`).

An input jax is stored as a pair of files in a subdirectory of the
``jax/input`` directory, with the subdirectory name being the name of
the input jax.  For example, the TeX input jax is stored in
`jax/input/TeX`.  The first file, ``config.js``, is loaded when
MathJax is being loaded and configured, and is indicated by listing
the input jax directory in the `jax` array of the MathJax
configuration.  The ``config.js`` file creates a subclass of the
`MathJax.InputJax` object for the new input jax and registers that
with MathJax, along with the MIME-type that will be used to indicate
the mathematics that is to be processed by the input jax.

The main body of the input jax is stored in the second file,
``jax.js``, which is loaded when the input jax is first called on to
translate some mathematics.  This file augments the original input jax
subclass with the additional methods needed to do the translation.
MathJax calls the input jax's :meth:`Translate()` method when it needs
the input jax to translate the contents of a math ``<script>`` tag.

The `MathJax.InputJax` class is a subclass of the :ref:`MathJax Jax
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

    The directory where the jax files are stored (e.g., ``"[MathJax]/jax/input/TeX"``);


Methods
=======

.. Method:: Translate(script)
    :noindex:

    This is the main routine called by MathJax when a ``<script>`` of
    the appropriate type is found.  The default :meth:`Translate()`
    method simply loads the ``jax.js`` file and returns that callback
    for that load function so that MathJax will know when to try
    the :meth:`Translate()` action again.  When the ``jax.js`` file
    loads, it should override the default :meth:`Translate()` with its
    own version that does the actual translation; that way, when the
    second Translate call is made, it will be to the actual
    translation routine rather than the default loader.

    The translation process should include the creation of an
    :ref:`Element Jax <api-element-jax>` that stores the data needed
    for this element.

    :Parameters:
        - **script**  --- the ``<script>`` element to be translated
    :Returns: the `element jax` resulting from the translation
 
.. Method:: Register(mimetype)
    :noindex:

    This registers the MIME-type associated with this input jax so
    that MathJax knows to call this input jax when it sees a
    ``<script>`` of that type.  An input jax can register more than
    one type, but it will be responsible for distinguishing elements
    of the various types from one another.

    :Parameters:
        - **mimetype** --- the MIME-type of the input this jax processes
    :Returns: ``null``
