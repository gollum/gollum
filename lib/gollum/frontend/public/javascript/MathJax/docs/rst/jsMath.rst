.. _jsMath-support:

*********************************
Converting to MathJax from jsMath
*********************************

MathJax is the successor to the popular `jsMath
<http://www.math.union.edu/locate/jsMath/>`_ package for rendering
mathematics in web pages.  Like jsMath, MathJax works by locating and
processing the mathematics within the webpage once it has been loaded
in the browser by a user viewing your web pages.  If you are using
jsMath with its ``tex2math`` preprocessor, then switching to MathJax
should be easy, and is simply a matter of configuring MathJax
appropriately.  See the section on :ref:`Configuring MathJax
<configuration>` for details about loading and configuring MathJax.

On the other hand, if you are using jsMath's ``<span
class="math">...</span>`` and ``<div class="math">...</div>`` tags to
mark the mathematics in your document, then you should use MathJax's
``jsMath2jax`` preprocessor when you switch to MathJax.  To do this,
include ``"jsMath2jax.js"`` in the `extensions` array of your
configuration, with the `jax` array set to include ``"input/TeX"``.

.. code-block:: javascript

    extensions: ["jsMath2jax.js"],
    jax: ["input/TeX", ...]

There are a few configuration options for ``jsMath2jax``, which you
can find in the ``config/MathJax.js`` file, or in the :ref:`jsMath
configuration options <configure-jsMath2jax>` section.
