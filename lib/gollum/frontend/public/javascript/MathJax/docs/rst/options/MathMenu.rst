.. _configure-MathMenu:

**********************
The MathMenu extension
**********************

The options below control the operation of the contextual menu that is
available on mathematics that is typeset by MathJax.
They are listed with their default values.  To set any of these
options, include a ``MathMenu`` section in your
:meth:`MathJax.Hub.Config()` call.  For example

.. code-block:: javascript

    MathJax.Hub.Config({
      MathMenu: {
        delay: 600
      }
    });

would set the ``delay`` option to 600 milliseconds.

.. describe:: delay: 400

    This is the hover delay for the display (in milliseconds) for
    submenus in the contextual menu:  when the mouse is over a submenu
    label for this long, the menu will appear.  (The submenu also will
    appear if you click on its label.)

.. describe:: helpURL: "http://www.mathjax.org/help/user/"

    This is the URL for the MathJax Help menu item.  When the user
    selects that item, the browser opens a new window with this URL.

.. describe:: showRenderer: true

   This controls whether the "Math Renderer" item will be displayed in
   the the "Settings" submenu of the mathematics contextual menu.  It
   allows the user to change between the `HTML-CSS` and `NativeMML`
   output processors for the mathematics on the page.  Set to
   ``false`` to prevent this menu item from showing.
   
.. describe:: showContext: false

   This controls whether the "Contextual Menu" item will be displayed
   in the the "Settings" submenu of the mathematics contextual menu.
   It allows the user to decide whether the MathJax menu or the
   browser's default contextual manu will be shown when the context
   menu click occurs over mathematics typeset by MathJax.  (The main
   reason to allow pass-through to the browser's menu is to gain
   access to the MathPlayer contextual menu when the NativeMML output
   processor is used in Internet Explorer with the `MathPlayer plugin
   <http://www.dessci.com/en/products/mathplayer/>`_.)  Set to
   ``false`` to prevent this menu item from showing.
   
.. describe:: showFontMenu: false

   This controls whether the "Font Preference" item will be displayed
   in the the "Settings" submenu of the mathematics contextual menu.
   This submenu lets the user select what font to use in the
   mathematics produced by the `HTML-CSS` output processor.  Note that
   changing the selection in the font menu will cause the page to
   reload.  Set to ``false`` to prevent this menu item from showing.
   
.. describe:: windowSettings: { ... }

    These are the settings for the ``window.open()`` call that
    creates the `Show Source` window.  The initial width and height
    will be reset after the source is shown in an attempt to make the
    window fit the output better.

.. describe:: styles: {}

    This is a list of CSS declarations for styling the menu
    components.  See the definitions in ``extensions/MathMenu.js`` for
    details of what are defined by default.  See :ref:`CSS Style
    Objects <css-style-objects>` for details on how to specify CSS
    style in a JavaScript object.

