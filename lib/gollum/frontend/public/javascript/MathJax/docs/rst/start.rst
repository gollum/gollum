.. _getting-started:

***************
Getting Started
***************

MathJax allows you to include mathematics in your web pages, either
using TeX and LaTeX notation, or as MathML.  To use MathJax, you will
need to do the following things:

1.  Obtain a copy of MathJax and make it available on your server.

2.  Configure MathJax to suit the needs of your site.

3.  Link MathJax into the web pages that are to include mathematics.

4.  Put mathematics into your web pages so that MathJax can display
    it.

Each of these steps is described briefly below, with links to more
detailed explanations.  This page gives the quickest and easiest ways
to get MathJax up and running on your web site, but you may want to
read the details in order to customize the setup for your pages.


Obtaining and Installing MathJax
================================

The easiest way to set up MathJax is to obtain the
``MathJax-v1.0.zip`` archive from the `MathJax download page
<http://www.mathjax.org/download/>`_.  This includes both the MathJax code
and the MathJax webfonts, so this is the only file you need.  (This is
different from the beta releases, which had the fonts separate from
the rest of the code).

Unpack the ``MathJax-v1.0.zip`` archive and place the
resulting MathJax folder onto your web server at a convenient
location where you can include it into your web pages.  For example,
making ``MathJax`` a top-level directory on your server would be
one natural way to do this.  That would let you refer to the main
MathJax file via the URL ``/MathJax/MathJax.js`` from within any page
on your server.

Note: While this is the easiest way to set up MathJax initially, there
is a better way to do it if you want to be able to keep your copy of
MathJax up-to-date easily.  That uses the `subversion
<http://subversion.apache.org/>`_ program, and is described in the
:ref:`Installing MathJax <getting-mathjax-svn>` document.

Once you have MathJax set up on your server, you can test it using the
files in the ``MathJax/test`` directory.  Load them in your browser
using its web address rather than opening them locally (i.e., use an
``http://`` URL rather than a ``file://`` URL).  When you view the
``index.html`` file, after a few moments you should see a message that
MathJax appears to be working.  If not, check that the files have been
transferred to the server completely and that the permissions allow
the server to access the files and folders that are part of the
MathJax directory.  (Be sure to verify the MathJax folder's permissions
as well.)  Check the server log files for any errors that pertain to
the MathJax installation; this may help locate problems in the
permission or locations of files.


Configuring MathJax
===================

When you include MathJax into your web pages as described below, it
will load the file ``config/MathJax.js`` (i.e., the file named
``MathJax.js`` in the ``config`` folder of the main ``MathJax``
folder).  This file contains the configuration parameters that
control how MathJax operates.  There are comments in it that
explain each of the parameters, and you can edit the file to suit
your needs.

The default settings are appropriate for pages that use TeX as the
input language, but you might still want to adjust some settings; for
example, you might want to include some additional extensions such as
the ``AMSmath`` and ``AMSsymbols`` extensions.  The comments in the
file should help you do this, but more detailed instructions are
included in the :ref:`Configuring MathJax <configuration>` document.
There are also ways to configure MathJax other than by using the
``config/MathJax.js`` file; these are descibed on that page as well.


Linking MathJax into a web page
===============================

You can include MathJax in your web page by putting

.. code-block:: html

    <script type="text/javascript" src="path-to-MathJax/MathJax.js"></script>

in your document's ``<head>`` block.  Here, ``path-to-MathJax`` should
be replaced by the URL for the main MathJax directory, so if you have
put the ``MathJax`` directory at the top level of you server's web
site, you could use

.. code-block:: html

    <script type="text/javascript" src="/MathJax/MathJax.js"></script>

to load MathJax in your page.  For example, your page could look like

.. code-block:: html

    <html>
        <head>
            ...
            <script type="text/javascript" src="/MathJax/MathJax.js"></script>
        </head>
        <body>
            ...
        </body>
    </html>

Although it is possible to load MathJax from a site other than your
own web server, there are issues involved in doing so that you need to
take into consideration.  See the :ref:`Notes About Shared Servers
<cross-domain-linking>` for more details.  Please do **not** link to
the copy of MathJax at ``www.mathjax.org``, as we do not have the
resources to act as a web service for all the sites on the web that
would like to display mathematics.  If you are able to run MathJax
from your own server, please do so (this will probably give you better
response time in any case).


Putting mathematics in a web page
=================================

To put mathematics in your web page, you can use either TeX and LaTeX
notation, or MathML notation (or both); the configuration file tells
MathJax which you want to use, and how you plan to indicate the
mathematics when you are using TeX notation.  The following sections
tell you how to use each of these formats.


.. _tex-and-latex-input:

TeX and LaTeX input
-------------------

To process mathematics that is written in :term:`TeX` or :term:`LaTeX`
format, include ``"input/TeX"`` in your configuration's `jax` array,
and add ``"tex2jax.js"`` to the `extensions` array so that MathJax
will look for TeX-style math delimiters to identify the mathematics on
the page.

.. code-block:: javascript

    extensions: ["tex2math.js"],
    jax: ["input/TeX", "output/HTML-CSS"]

Note that the default math delimiters are ``$$...$$`` and ``\[...\]``
for displayed mathematics, and ``\(...\)`` for in-line mathematics.
In particular, the ``$...$`` in-line delimiters are **not** used by
default.  That is because dollar signs appear too often in
non-mathematical settings, which could cause some text to be treated
as mathematics unexpectedly.  For example, with single-dollar
delimiters, "... the cost is $2.50 for the first one, and $2.00 for
each additional one ..." would cause the phrase "2.50 for the first
one, and" to be treated as mathematics since it falls between dollar
signs.  For this reason, if you want to use single-dollars for in-line
math mode, you must enable that explicitly in your configuration:

.. code-block:: javascript

    tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}

See the ``config/MathJax.js`` file, or the :ref:`tex2jax configuration
options <configure-tex2jax>` page, for additional configuration
parameters that you can specify for the ``tex2jax`` preprocessor.

Here is a complete sample page containing TeX mathematics (which
assumes that ``config/MathJax.js`` is configured as described above):

.. code-block:: html

    <html>
    <head>
    <title>MathJax TeX Test Page</title>
    <script type="text/javascript" src="/MathJax/MathJax.js"></script>
    </head>
    <body>
    When \(a \ne 0\), there are two solutions to \(ax^2 + bx + c = 0\) and they are
    $$x = {-b \pm \sqrt{b^2-4ac} \over 2a}.$$
    </body>
    </html>

There are a number of extensions for the TeX input processor that you
might want to add to the `extensions` array.  These include:

- `TeX/AMSmath.js`, which defines the AMS math environments and
  macros,

- `TeX/AMSsymbols.js`, which defines the macros for the symbols in
  the msam10 and msbm10 fonts,

- `TeX/noErrors.js`, which shows the original TeX code rather than
  an error message when there is a problem processing the TeX, and

- `TeX/noUndefined.js`, which prevents undefined macros from
  producing an error message, and instead shows the macro name in red.

For example,

.. code-block:: javascript

    extensions: ["tex2math.js","TeX/noErrors.js","TeX/noUndefined.js",
                 "TeX/AMSmath.js","TeX/AMSsymbols.js"]

loads all four extensions, in addition to the ``tex2math``
preprocessor.


MathML input
------------

To process mathematics written in :term:`MathML`, include
``"input/MathML"`` in your configuration's `jax` array, and add
``"mml2jax.js"`` to the `extensions` array so that MathJax will
locate the ``<math>`` elements in the page automatically.

.. code-block:: javascript

    extensions: ["mml2jax.js"],
    jax: ["input/MathML", "output/HTML-CSS"]

With this configuration, you would mark your mathematics using
standard ``<math>`` tags, where ``<math display="block">`` represents
displayed mathematics and ``<math display="inline">`` or just
``<math>`` represents in-line mathematics.

Note that this will work in HTML files, not just XHTML files (MathJax
works with both), and that the web page need not be served with any
special MIME-type.  Also note that, unless you are using XHTML rather
than HTML, you should not include a namespace prefix for your
``<math>`` tags; for example, you should not use ``<m:math>`` except
in a file where you have tied the ``m`` namespace to the MathML DTD.

Here is a complete sample page containing MathML mathematics (which
assumes that ``config/MathJax.js`` is configured as described above):

.. code-block:: html

    <html>
    <head>
    <title>MathJax MathML Test Page</title>
    <script type="text/javascript" src="/MathJax/MathJax.js"></script>
    </head>
    <body>

    When <math><mi>a</mi><mo>&#x2260;</mo><mn>0</mn></math>,
    there are two solutions to <math>
      <mi>a</mi><msup><mi>x</mi><mn>2</mn></msup>
      <mo>+</mo> <mi>b</mi><mi>x</mi>
      <mo>+</mo> <mi>c</mi> <mo>=</mo> <mn>0</mn>
    </math> and they are
    <math mode="display">
      <mi>x</mi> <mo>=</mo> 
      <mrow>
        <mfrac>
          <mrow>
            <mo>&#x2212;</mo>
            <mi>b</mi>
            <mo>&#x00B1;</mo>
            <msqrt>
              <msup><mi>b</mi><mn>2</mn></msup>
              <mo>&#x2212;</mo>
              <mn>4</mn><mi>a</mi><mi>c</mi>
            </msqrt>
          </mrow>
          <mrow> <mn>2</mn><mi>a</mi> </mrow>
        </mfrac>
      </mrow>
      <mtext>.</mtext>
    </math>
    
    </body>
    </html>

The ``mml2jax`` has only a few configuration options; see the
``config/MathJax.js`` file or the :ref:`mml2jax configuration options
<configure-mml2jax>` page for more details.


Where to go from here?
======================

If you have followed the instructions above, you should now have
MathJax installed and configured on your web server, and you should be
able to use it to write web pages that include mathematics.  At this
point, you can start making pages that contain mathematical content!

You could also read more about the details of how to :ref:`customize
MathJax <configuration>`.

If you are trying to use MathJax in blog or wiki software or in some
other content-management system, you might want to read about :ref:`using
MathJax in popular platforms <platforms>`.

If you are working on dynamic pages that include mathematics, you
might want to read about the :ref:`MathJax Application Programming
Interface <mathjax-api>` (its API), so you know how to include
mathematics in your interactive pages.

If you are having trouble getting MathJax to work, you can read more
about :ref:`installing MathJax <installation>`, or :ref:`loading and
configuring MathJax <loading>`.

Finally, if you have questions or comments, or want to help support
MathJax, you could visit the :ref:`MathJax community forums
<community-forums>` or the :ref:`MathJax bug tracker
<community-tracker>`.
