.. _platform-wordpress:

===============================
Installing MathJax in WordPress
===============================

These instructions assume you already have placed the MathJax files on
your server (see :ref:`Installing MathJax <installation>`).

1. Open the WordPress admin interface.

2. In the administration menu on the left, open up the `Appearance`
   menu and click on the `Editor` submenu option.
 
     .. image:: ../images/wp_menu.png
 
   When you click on the editor option, WordPress should open up the
   first stylesheet in the current theme.
 
3. In the template list on the right side of the page, click on the
   header file (it should be ``header.php``).
 
     .. image:: ../images/wp_templates.png
 
   This part depends slightly on how your current theme is written.
   In the ``header.php`` file, look for the end-of-head tag,
   ``</head>``. If you find it, insert

   .. code-block:: html

       <script type="text/javascript" src="path-to-MathJax/MathJax.js"></script>

   just before that.  Otherwise, insert the same code at the very
   bottom of the file.  Here, ``path-to-MathJax`` should be replaced
   by the web-address of the main MathJax directory on your server,
   e.g., ``src="/mathjax/MathJax.js"``.
 
4. Save the file.  This should enable MathJax, so you should be able to
   start adding mathematical content to your pages.  Use the
   ``config/MathJas.js`` file in the MathJax directory to configure
   MathJax to your needs (see :ref:`Configuring MathJax
   <configuration>` for details).
