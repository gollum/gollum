.. _ajax-mathjax:

***************************
Loading MathJax Dynamically
***************************

MathJax is designed to be included via a ``<script>`` tag in the
``<head>`` section of your HTML document, and it does rely on being
part of the original document in that it uses an ``onload`` event
handler to synchronize its actions with the loading of the page.
If you wish to insert MathJax into a document after it has
been loaded, that will normally occur *after* the page's ``onload``
handler has fired, and so MathJax will not be able to tell if it is
safe for it to process the contents of the page.  Indeed, it will wait
forever for its ``onload`` handler to fire, and so will never process
the page.

To solve this problem, you will need to call MathJax's ``onload``
handler yourself, to let it know that it is OK to typeset the
mathematics on the page.  You accomplish this by calling the
:meth:`MathJax.Hub.Startup.onload()` method as part of your MathJax
startup script.  To do this, you will need to give MathJax an in-line
configuration, so you will not be able to use the
``config/MathJax.js`` file (though you can add it to your in-line
configuration's `config` array).

Here is an example of how to load and configure MathJax dynamically:

.. code-block:: javascript

    (function () {
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "/MathJax/MathJax.js";   // use the location of your MathJax

      var config = 'MathJax.Hub.Config({' +
                     'extensions: ["tex2jax.js"],' +
                     'jax: ["input/TeX","output/HTML-CSS"]' +
                   '});' +
                   'MathJax.Hub.Startup.onload();';

      if (window.opera) {script.innerHTML = config}
                   else {script.text = config}

      document.getElementsByTagName("head")[0].appendChild(script);
    })();

Be sure to set the ``src`` to the correct URL for your copy of
MathJax.  You can adjust the ``config`` variable to your needs, but be
careful to get the commas right.  The ``window.opera`` test is because
Opera doesn't handle setting ``script.text`` properly, while Internet
Explorer doesn't handle setting the ``innerHTML`` of a script tag.

Here is a version that uses the ``config/MathJax.js`` file to
configure MathJax:

.. code-block:: javascript

    (function () {
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "/MathJax/MathJax.js";   // use the location of your MathJax

      var config = 'MathJax.Hub.Config({ config: "MathJax.js" }); ' +
                   'MathJax.Hub.Startup.onload();';

      if (window.opera) {script.innerHTML = config}
                   else {script.text = config}

      document.getElementsByTagName("head")[0].appendChild(script);
    })();

Note that the **only** reliable way to configure MathJax is to use an
in-line configuration of the type discussed above.  You should **not**
call :meth:`MathJax.Hub.Config()` directly in your code, as it will
not run at the correct time --- it will either run too soon, in which
case ``MathJax`` may not be defined and the function will throw an
error, or it will run too late, after MathJax has already finished its
configuration process, so your changes will not have the desired
effect.


MathJax and GreaseMonkey
========================

You can use techniques like the ones discussed above to good effect in
GreaseMonkey scripts.  There are GreaseMonkey work-alikes for all the
major browsers:

- Firefox: `GreaseMonkey <http://addons.mozilla.org/firefox/addon/748>`_
- Safari: `GreaseKit <http://8-p.info/greasekit/>`_ (also requires `SIMBL <http://www.culater.net/software/SIMBL/SIMBL.php>`_)
- Opera: Built-in (`instructions <http://www.ghacks.net/2008/08/10/greasemonkey-in-opera/>`_)
- Internet Explorer: `IEPro7 <http://www.ie7pro.com/>`_
- Chrome: Built-in for recent releases

Note, however, that most browsers don't allow you to insert a script
that loads a ``file://`` URL into a page that comes from the web (for
security reasons).  That means that you can't have your GreaseMonkey
script load a local copy of MathJax, so you have to refer to a
server-based copy.  In the scripts below, you need to insert the URL
of a copy of MathJax from your own server.

----

Here is a script that runs MathJax in any document that contains
MathML (whether its includes MathJax or not).  That allows 
browsers that don't have native MathML support to view any web pages
with MathML, even if they say it only works in Forefox and
IE+MathPlayer.

.. code-block:: javascript

    // ==UserScript==
    // @name           MathJax MathML
    // @namespace      http://www.mathjax.org/
    // @description    Insert MathJax into pages containing MathML
    // @include        *
    // ==/UserScript==

    if ((window.unsafeWindow == null ? window : unsafeWindow).MathJax == null) {
      if ((document.getElementsByTagName("math").length > 0) ||
          (document.getElementsByTagNameNS == null ? false : 
          (document.getElementsByTagNameNS("http://www.w3.org/1998/Math/MathML","math").length > 0))) {
        var script = document.createElement("script");
        script.src = "http://www.yoursite.edu/MathJax/MathJax.js";  // put your URL here
        var config = 'MathJax.Hub.Config({' +
                       'extensions:["mml2jax.js"],' +
                       'jax:["input/MathML","output/HTML-CSS"]' +
                     '});' +
                     'MathJax.Hub.Startup.onload()';
        if (window.opera) {script.innerHTML = config} else {script.text = config}
        document.getElementsByTagName("head")[0].appendChild(script);
      }
    }

**Source**: `mathjax_mathml.user.js <_statis/mathjax_mathml.user.js>`_

----

Here is a script that runs MathJax in Wikipedia pages after first
converting the math images to their original TeX code.  

.. code-block:: javascript

    // ==UserScript==
    // @name           MathJax in Wikipedia
    // @namespace      http://www.mathjax.org/
    // @description    Insert MathJax into Wikipedia pages
    // @include        http://en.wikipedia.org/wiki/*
    // ==/UserScript==

    if ((window.unsafeWindow == null ? window : unsafeWindow).MathJax == null) {
      //
      //  Replace the images with MathJax scripts of type math/tex
      //
      var images = document.getElementsByTagName('img');
      for (var i = images.length - 1; i >= 0; i--) {
        var img = images[i];
        if (img.className === "tex") {
          var script = document.createElement("script"); script.type = "math/tex";
          if (window.opera) {script.innerHTML = img.alt} else {script.text = img.alt}
          img.parentNode.replaceChild(script,img);
        }
      }
      //
      //  Load MathJax and have it process the page
      //
      var script = document.createElement("script");
      script.src = "http://www.yoursite.edu/MathJax/MathJax.js";  // put your URL here
      var config = 'MathJax.Hub.Config({' +
                     'config: ["MMLorHTML.js"],' +
                     'extensions:["TeX/noErrors.js","TeX/noUndefined.js",' +
                                 '"TeX/AMSmath.js","TeX/AMSsymbols.js"],' +
                     'jax:["input/TeX"]' +
                   '});' +
                   'MathJax.Hub.Startup.onload()';
      if (window.opera) {script.innerHTML = config} else {script.text = config}
      document.getElementsByTagName("head")[0].appendChild(script);
    }

**Source**: `mathjax_wikipedia.user.js <_statis/mathjax_wikipedia.user.js>`_
