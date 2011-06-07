********************
The MathJax variable
********************

MathJax has a single global variable, ``MathJax``, in which all its
data, and the data for loaded components, are stored.  The MathJax
variable is a nested structure, with its top-level properties being
objects themselves.


Main MathJax Components
=======================

.. describe:: MathJax.Hub

    Contains the MathJax hub code and variables, including the startup
    code, the onload handler, the browser data, and so forth.
    
.. describe:: MathJax.Ajax

    Contains the code for loading external modules and creating
    stylesheets.  Most of the code that causes most of MathJax to
    operate asynchronously is handled here.

.. describe:: MathJax.Message

   Contains the code to handle the intermittant message window that
   periodically appears in the lower left-hand corner of the window.

.. describe:: MathJax.HTML

   Contains support code for creating HTML elements dynamically from
   descriptions stored in JavaScript objects.
    
.. describe:: MathJax.CallBack

    Contains the code for managing MathJax callbacks, queues and
    signals.

.. describe:: MathJax.Extensions

    Initially empty, this is where extensions can load their code.
    For example, the `tex2jax` preprocessor creates
    ``MathJax.Extensions.tex2jax`` for its code and variables.

.. describe:: MathJax.Object

    Contains the code for the MathJax object-oriented programming model.


.. describe:: MathJax.InputJax

    The base class for all input `jax` objects.  Subclasses for
    specific input jax are created as sub-objects of
    ``MathJax.InputJax``. For example, the TeX input jax loads itself
    as ``MathJax.InputJax.TeX``.

.. describe:: MathJax.OutputJax

    The base class for all output `jax` objects.  Subclasses for
    specific output jax are created as sub-objects of
    ``MathJax.OutputJax``.  For example, the HTML-CSS output jax loads
    itself as ``MathJax.OutputJax["HTML-CSS"]``.

.. describe:: MathJax.ElementJax

    The base class for all element `jax` objects.  Subclasses for
    specific element jax are creates as sub-objects of
    ``MathJax.ElementJax``.  For example, the mml element jax loads
    itself as ``MathJax.ElementJax.mml``.


Properties
==========

.. describe:: MathJax.version

    The version number of the MathJax library.

.. describe:: MathJax.isReady

    This is set to ``true`` when MathJax is set up and ready to
    perform typesetting actions (and is ``null`` otherwise).
