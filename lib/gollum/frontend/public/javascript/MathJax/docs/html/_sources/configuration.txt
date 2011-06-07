.. _loading:

*******************************
Loading and Configuring MathJax
*******************************

You load MathJax into a web page by including its main JavaScript file
into the page.  That is done via a ``<script>`` tag that links to the
``MathJax.js`` file.  Place the following line in the ``<head>``
section of your document:

.. code-block:: html

    <script type="text/javascript" src="path-to-MathJax/MathJax.js"></script>

where ``path-to-MathJax`` is replaced by the URL of the MathJax
directory on your server, or (if you are using MathJax locally rather
than through a server) the location of that directory on your hard
disk.  For example, if the MathJax directory is at the top level of
your web server's directory hierarchy, you might use

.. code-block:: html

    <script type="text/javascript" src="/MathJax/MathJax.js"></script>

to load MathJax.

Although it is possible to load MathJax from a site other than your
own web server, there are issues involved in doing so that you need to
take into consideration.  See the :ref:`Notes About Shared Servers
<cross-domain-linking>` for more details.  Please do **not** link to
the copy of MathJax at ``www.mathjax.org``, as we do not have the
resources to act as a web service for all the sites on the web that
would like to display mathematics.  If you are able to run MathJax
from your own server, please do so (this will probably give you better
response time in any case).

It is best to load MathJax in the document's ``<head>`` block, but it
is also possible to load MathJax into the ``<body>`` section, if
needed.  If you do this, load it as early as possible, as
MathJax will begin to load its components as soon as it is included in
the page, and that will help speed up the processing of the
mathematics on your page.  MathJax does expect there to be a
``<head>`` section to the document, however, so be sure there is one
if you are loading MathJax in the ``<body>``.

It is also possible to load MathJax dynamically after the page has
been prepared, for example, via a `GreaseMonkey
<http://www.greasespot.net/>`_ script, or using a specially prepared
`bookmarklet <http://en.wikipedia.org/wiki/Bookmarklet>`_.  This is an
advanced topic, however; see :ref:`Loading MathJax Dynamically
<ajax-mathjax>` for more details.


Configuring MathJax
===================

There are several ways to configure MathJax, but the easiest is to use
the ``config/MathJax.js`` file that comes with MathJax.  See the
comments in that file, or the :ref:`configuration details
<configuration>` section, for explanations of the meanings of the various
configuration options.  You can edit the ``config/MathJax.js`` file to
change any of the settings that you want to customize.  When you
include MathJax in your page via

.. code-block:: html

    <script type="text/javascript" src="path-to-MathJax/MathJax.js"></script>

it will load ``config/MathJax.js`` automatically as one of its
first actions.

Alternatively, you can configure MathJax efficiently by calling
:meth:`MathJax.Hub.Config()` when you include MathJax in your page, as
follows:

.. code-block:: html

    <script type="text/javascript" src="path-to-MathJax/MathJax.js">
        MathJax.Hub.Config({
            extensions: ["tex2jax.js"],
            jax: ["input/TeX", "output/HTML-CSS"],
            tex2jax: {
                inlineMath: [ ['$','$'], ["\\(","\\)"] ],
                displayMath: [ ['$$','$$'], ["\\[","\\]"] ],
            },
            "HTML-CSS": { availableFonts: ["TeX"] }
        });
    </script>

This example includes the ``tex2jax`` preprocessor and configures it
to use both the standard TeX and LaTeX math delimiters.  It uses the
TeX input processor and the HTML-CSS output processor, and forces the
HTML-CSS processor to use the TeX fonts rather that other locally
installed fonts (e.g., :term:`STIX` fonts).  See the
:ref:`configuration options <configuration>` section (or the comments
in the ``config/MathJax.js`` file) for more information about the
configuration options that you can include in the
:meth:`MathJax.Hub.Config()` call.  Note that if you configure MathJax
using this in-line approach, the ``config/MathJax.js`` file is **not**
loaded.

Finally, if you would like to use several different configuration
files (like ``config/MathJax.js``, but with different settings in each
one), you can copy ``config/MathJax.js`` to ``config/MathJax-2.js``,
or some other convenient name, and use

.. code-block:: html

    <script type="text/javascript" src="path-to-MathJax/MathJax.js">
        MathJax.Hub.Config({ config: "MathJax-2.js" });
    </script>

to load the alternative configuration file ``config/MathJax-2.js``
from the MathJax ``config`` directory.  In this way, you can have as
many distinct configuration files as you need.


.. _common-configurations:

Common Configurations
=====================

The following examples show configurations that are useful for some
common situations.  This is certainly not an exhaustive list, and
there are variations possible for any of them.  Again, the comments in
the ``config/MathJax.js`` file can help you decide what settings to
include, even if you are using the in-line configuration method.

The TeX setup
-------------

This example calls the ``tex2jax`` preprocessor to identify
mathematics in the page by looking for TeX and LaTeX math delimiters.
It uses ``$...$`` and ``\(...\)`` for in-line mathematics, while
``$$...$$`` and ``\[...\]`` mark displayed equations.  Because dollar
signs are used to mark mathematics, if you want to produce an actual
dollar sign in your document, you must "escape" it using a slash:
``\$``.  This configuration also loads the ``AMSmath`` and
``AMSsymbols`` extensions so that the macros and environments they
provide are defined for use on the page.

.. code-block:: javascript
    
    MathJax.Hub.config({
        extensions: ["tex2jax.js","TeX/AMSmath.js","TeX/AMSsymbols.js"],
        jax: ["input/TeX","output/HTML-CSS"],
        tex2jax: {
            inlineMath: [['$','$'],["\\(","\\)"]],
            processEscapes: true,
        },
    });

Other extensions that you may consider adding to the `extensions`
array include:  ``TeX/noErrors.js``, which shows the original TeX code
if an error occurs while processing the mathematics (rather than an
error message), ``TeX/noUndefined.js``, which shows undefined
macros names in red (rather than producing an error), and
``TeX/autobold.js``, which automatically inserts ``\boldsymbol{...}``
around your mathematics when it appears in a section of your page that
is in bold.  Most of the other TeX extensions are loaded automatically
when needed, and so do not need to be included explicitly in your
`extensions` array.

See the :ref:`tex2jax configuration <configure-tex2jax>` section for
other configuration options for the ``tex2jax`` preprocessor, and the
:ref:`TeX input jax configuration <configure-TeX>` section for options
that control the TeX input processor.


The MathML setup
----------------

This example calls the ``mml2jax`` preprocessor to identify
mathematics in the page that is in :term:`MathML` format, which uses
``<math display="block">`` to indicate displayed equations, and
``<math display="inline">`` or simply ``<math>`` to mark in-line
formulas.

.. code-block:: javascript

    MathJax.Hub.config({
        extensions: ["mml2jax.js"],
        jax: ["input/MathML","output/HTML-CSS"]
    });

Note that this will work in HTML files, not just XHTML files (MathJax
works with both), and that the web page need not be served with any
special MIME-type.  Also note that, unless you are using XHTML rather
than HTML, you should not include a namespace prefix for your
``<math>`` tags; for example, you should not use ``<m:math>`` except
in a file where you have tied the ``m`` namespace to the MathML DTD.

See the :ref:`mml2jax configuration <configure-mml2jax>` section for
other configuration options for the ``mml2jax`` preprocessor, and the
:ref:`MathML input jax configuration <configure-MathML>` section for
options that control the MathML input processor.


Both TeX and MathML
-------------------

This example provides for both TeX and MathML input in the same file.
It calls on both the ``tex2jax`` and ``mml2jax`` preprocessors and the
TeX and MathML input jax to do the job.

.. code-block:: javascript

    MathJax.Hub.config({
        extensions: ["tex2jax.js", "mml2jax.js"],
        jax: ["input/TeX", "input/MathML", "output/HTML-CSS"],
    });

Notice that no ``tex2jax`` configuration section is included, so it
uses its default options (no single dollar signs for in-line math).

The majority of the code for the TeX and MathML input processors are
not loaded until they are actually needed by the mathematics on the
page, so if this configuration is used on a page that include only
MathML, the TeX input processor will not be loaded.  Thus it is
reasonably efficient to specify both input processors even if only one
(or neither one) is used.


TeX input with MathML output
----------------------------

This example configures MathJax to use the ``tex2jax`` preprocessor
and TeX input processor, but the choice of output format is determined
by MathJax depending on the capabilities of the users's browser.  The
is performed by the ``MMLorHTML.js`` configuration file that is loaded
in the `config`` array.

.. code-block:: javascript

    MathJax.Hub.Config({
        config: ["MMLorHTML.js"],
        extensions: ["tex2jax.js"],
        jax: ["input/TeX"]
    });

With this setup, Firefox or Internet Explorer with the `MathPlayer
plugin <http://www.dessci.com/en/products/mathplayer/>`_ installed
will use the NativeMML output processor, while all other browsers will
use the HTML-CSS output processor.  Since native MathML support is
faster than MathJax's HTML-CSS processor, this will mean that the web
pages will display faster for Firefox and IE than they woudl
otherwise.  This speed comes at the cost, however, as you are now
relying on the native MathML support to render the mathematics, and
that is outside of MathJax's control.  There may be spacing or other
display differences (compared to MathJax's HTML-CSS output) when the
NativeMML output processor is used.

See :ref:`MathJax Output Formats <output-formats>` for more
information on the NativeMML and HTML-CSS output processors.  See the
:ref:`MMLorHTML configuration <configure-MMLorHTML>` section for
details on the options that control the ``MMLorHTML`` configuration.


MathML input and output in all browsers
---------------------------------------

This example configures MathJax to look for MathML within your page,
and to display it using the browser's native MathML support, if
possible, or its HTML-CSS output if not.

.. code-block:: javascript

    MathJax.Hub.Config({
        config: ["MMLorHTML.js"],
        extensions: ["mml2jax.js"],
        jax: ["input/MathML"]
    });

Using this configuration, MathJax finally makes MathML available in
all modern browsers.

See the :ref:`MMLorHTML configuration <configure-MMLorHTML>` section
for details on the options that control the ``MMLorHTML``
configuration file, the :ref:`MathML configuration <configure-MathML>`
section for the options that control the MathML output processor, and
the :ref:`mml2jax configuration <configure-mml2jax>` section for the
options that control the ``mml2jax`` preprocessor.


.. _configuration:

Configuration Objects
=====================

The various components of MathJax, including its input and output
processors, its preprocessors, its extensions, and the MathJax core,
all can be configured through the ``config/MathJax.js`` file, or via a
:meth:`MathJax.Hub.Config()` call (indeed, if you look closely, you
will see that ``config/MathJax.js`` is itself one big call to
:meth:`MathJax.Hub.Config()`).  Anything that is in
``config/MathJax.js`` can be included in-line to configure MathJax.

The structure that you pass to :meth:`MathJax.Hub.Config()` is a
JavaScript object that includes name-value pairs giving the names of
parameters and their values, with pairs separated by commas.  Be
careful not to include a comma after the last value, however, as some
browsers (namely Internet Explorer) will fail to process the
configuration if you do.

The MathJax components, like the TeX input processor, have their own
sections in the configuration object, labeled by the component name,
and using an configuration object as its value.  The object is itself
a configuration object made up of name-value pairs that give the
configuration options for the component.

For example,

.. code-block:: javascript

    MathJax.Hub.Config({
      showProcessingMessages: false,
      jax: ["input/TeX", "output/HTML-CSS"],
      TeX: {
        TagSide: "left",
        Macros: {
	  RR: '{\\bf R}',
	  bold: ['{\\bf #1}',1]
	}
      }
    });

is a configration that includes two settings for the MathJax Hub (one
for `showProcessingMessages` and one of the `jax` array), and a
configuration object for the TeX input processor.  The latter includes
a setting for the TeX input processor's `TagSide` option (to set tags
on the left rather than the right) and a setting for `Macros`, which
defines new TeX macros (in this case, two macros, one called ``\RR``
that produces a bold "R", and one called ``\bold`` that puts is
argument in bold face).

The ``config/MathJax.js`` file is another example that shows nearly
all the configuration options for all of MathJax's components.


Configuration Options by Component
==================================

The individual options are explained in the following sections, which
are categorized by the component they affect.

.. toctree::
    :maxdepth: 1

    The core options <options/hub>

.. toctree::
    :maxdepth: 1

    The tex2jax preprocessor options <options/tex2jax>
    The mml2jax preprocessor options <options/mml2jax>
    The jsMath2jax preprocessor options <options/jsMath2jax>

.. toctree::
    :maxdepth: 1

    The TeX input processor options <options/TeX>
    The MathML input processor options <options/MathML>
    The HTML-CSS output processor options <options/HTML-CSS>
    The NativeMML output processor options <options/NativeMML>
    The MMLorHTML configuration options <options/MMLorHTML>
    
.. toctree::
    :maxdepth: 1

    The MathMenu options <options/MathMenu>
    The MathZoom options <options/MathZoom>
    The FontWarnings options <options/FontWarnings>

    
