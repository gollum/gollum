.. _configure-NativeMML:

******************************
The NativeMML output processor
******************************

The options below control the operation of the NativeMML output
processor that is run when you include ``"output/NativeMML"`` in the
`jax` array of your configuration.  They are listed with their default
values.  To set any of these options, include a ``NativeMML`` section
in your :meth:`MathJax.Hub.Config()` call.  For example

.. code-block:: javascript

    MathJax.Hub.Config({
      NativeMML: {
        scale: 105
      }
    });

would set the ``sale`` option to 105 percent.

.. describe:: scale: 100

    The scaling factor (as a percentage) of math with respect to the
    surrounding text.  Since the `NativeMML` output relies on the
    browser's natiove MathML support, MathJax does not control the
    font size used in the mathematics.  You may need to set this value
    to compensate for the size selected by the browser.  The user can
    also adjust this value using the contextual menu item associated
    with the typeset mathematics.

.. describe:: showMathMath: true

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

.. describe:: showMathMenuMSIE: true

    There is a separate menu setting for MSIE since the code to handle
    that is a bit delicate; if it turns out to have unexpected
    consequences, you can turn it off without turing off other the
    menu support in other browsers.
   
.. describe:: styles: {}

    This is a list of CSS declarations for styling the HTML-CSS
    output.  See the definitions in ``jax/output/NativeMML/config.js``
    for some examples of what are defined by default.  See :ref:`CSS
    Style Objects <css-style-objects>` for details on how to specify
    CSS style in a JavaScript object.
