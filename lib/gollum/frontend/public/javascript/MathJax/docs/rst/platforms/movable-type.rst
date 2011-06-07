.. _platform-movable-type:

==========================
Using MathJax in WordPress
==========================

These instructions assume you already have placed the MathJax files on
your server (see :ref:`Installing and Testing MathJax <installation>`).

1. Open Moveable Type Admin interface for the site on which you want to enable
   MathJax.

2. In the dashboard menu on the left, open up the Design menu. This
   should show you the templates you are currently using on the site.
 
     .. image:: ../images/mt_menu.png
 

3. Scroll down to the Template Modules section in the template list
   and open the `HTML Head` template.
 
     .. image:: ../images/mt_templates.png
 
4. At the end of the file, insert

   .. code-block:: html

       <script type="text/javascript"  src="path-to-MathJax/MathJax.js"></script>

   where ``path-to-MathJax`` is replaced by the web-address of the
   main MathJax dorectory on your server.
 
     .. image:: ../images/mt_head.png

5. Save the file.  This should enable MathJax, so you should be able
   to start adding mathematical content to your pages.  Use the
   ``config/MathJas.js`` file in the MathJax directory to configure
   MathJax to your needs (see :ref:`Configuring MathJax
   <configuration>` for details).


