.. _configure-MathML:

**************************
The MathML input processor
**************************

The options below control the operation of the MathML input processor
that is run when you include ``"input/MathML"`` in the `jax` array of
your configuration.  They are listed with their default values.  To
set any of these options, include a ``MathML`` section in your
:meth:`MathJax.Hub.Config()` call.  For example

.. code-block:: javascript

    MathJax.Hub.Config({
      MathML: {
        useMathMLspacing: true
      }
    });

would set the ``useMathMLspacing`` option so that the MathML rules for
spacing would be used (rather than TeX spacing rules).

.. describe:: useMathMLspacing: false

    Specifies whether to use TeX spacing or MathML spacing when the
    `HTML-CSS` output jax is used.
