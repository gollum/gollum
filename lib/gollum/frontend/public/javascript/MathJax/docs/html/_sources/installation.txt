.. _installation:

******************************
Installing and Testing MathJax
******************************

MathJax can be loaded from a public web server or privately from your
hard drive or other local media.  To use MathJax in either way, you
will need to obtain a copy of MathJax and its font package.  There are
two main ways to do this:  via ``svn`` or via a pre-packaged archive.
We recommend the former, as it is easier to keep your installation up
to date using ``svn``.


.. _getting-mathjax-svn:

Obtaining MathJax via SVN
=========================

The easiest way to get MathJax and keep it up to date is to use the
`subversion <http://subversion.apache.org/>`_  source control system,
``svn``.  Use the commands

.. code-block:: sh

    svn co http://mathjax.svn.sourceforge.net/svnroot/mathjax/trunk/mathjax mathjax
    cd mathjax
    unzip fonts.zip

to obtain and set up a copy of MathJax.  (The `SourceForge development
page <http://sourceforge.net/projects/mathjax/develop>`_ also shows
how to do this.)

Whenever you want to update MathJax, you can now use

.. code-block:: sh

    cd mathjax
    svn status

to check if there are updates to MathJax.  If MathJax needs updating,
use

.. code-block:: sh

    cd mathjax
    svn update
    #  if fonts.zip is updated, do the following as well:
    rm -rf fonts
    unzip fonts.zip

to udpate your copy of MathJax to the current release version.  If the
``fonts.zip`` file has been updated, you will need to remove the old
fonts directory and unpack the new one bring your installation up to
date.  If you keep MathJax updated in this way, you will be sure that
you have the latest bug fixes and new features as they become
available.

This gets you the current development copy of MathJax, which is the
"bleeding-edge" version that contains all the latest changes to
MathJax.  At times, however, these may be less stable than the
"release" version.  If you prefer to use the most stable version (that
may not include all the latest patches and features), use

.. code-block:: sh

    svn co http://mathjax.svn.sourcesforge.net/svnroot/mathjax/tags/mathjax-1.0 mathajx
    cd mathjax
    unzip fonts.zip

to obtain the version 1.0 release.  When you wish to update to a new
release, you will need to check out a new copy of MathJax with the new
release number.


.. _getting-mathjax-zip:

Obtaining MathJax via an archive
================================

Release versions of MathJax are available in archive files from the
`MathJax download page <http://www.mathjax.org/download/>`_ or the
`SourceForge files page
<http://sourceforge.net/projects/mathjax/files/>`_, where you can
download the archives that you need. 

You should download the ``MathJax-v1.0.zip`` file, then simply unzip
it. Once the MathJax directory is unpacked, you should move it to the
desired location on your server (or your hard disk, if you are using
it locally rather then through a web server).  One natural location is
to put it at the top level of your web server's hierarchy.  That would
let you refer to the main MathJax file as ``/MathJax/MathJax.js`` from
within any page on your server.


Testing your installation
=========================

Use the HTML files in the ``test`` directory to see if your
installation is working properly::

    test/
        index.html          # Tests default configuration
        index-images.html   # Tests image-font fallback display
        sample.html         # Sample page with lots of pretty equations

Open these files in your browser to see that they appear to be working
properly.  If you have installed MathJax on a server, use the web
address for those files rather than opening them locally.  When you
view the ``index.html`` file, you should see (after a few moments) a
message that MathJax appears to be working.  If not, you should check
that the files have been transferred to the server completely, that
the fonts archive has been unpacked in the correct location, and that
the permissions allow the server to access the files and folders that
are part of the MathJax directory (be sure to verify the MathJax
folder's permissions as well).  Checking the server logs may help
locate problems with the installation.


.. _cross-domain-linking:

Notes about shared installations
================================

Typically, you want to have MathJax installed on the same server as
your web pages that use MathJax.  There are times, however, when that
may be impractical, or when you want to use a MathJax installation at
a different site.  For example, a departmental server at
``www.math.yourcollege.edu`` might like to use a college-wide
installation at ``www.yourcollege.edu`` rather than installing a
separate copy on the departmental machine.  MathJax can certainly
be loaded from another server, but there is one imporant caveat ---
Firefox's same-origin security policy for cross-domain scripting.

Firefox’s interpretation of the same-origin policy is more strict than
most other browsers, and it affects how fonts are loaded with the
`@font-face` CSS directive.  MathJax uses this directory to load
web-based math fonts into a page when the user doesn't have them
installed locally on their own computer.  Firefox's security policy,
however, only allows this when the fonts come from the same server as
the web page itself, so if you load MathJax (and hence its web fonts)
from a different server, Firefox won't be able to access those web
fonts.  In this case, MathJax will pause while waiting for the font to
download (which will never happen) and will time out after about 15
seconds for each font it tries to access.  Typically that is three or
four fonts, so your Foirefox users will experience a minute or so
delay before mathematics is displayed, and then it will probably
display incorrectly because the browser doesn't have access to the
correct fonts.

There is a solution to this, however, if you manage the server where
MathJax is installed, and if that server is running the `Apache web
server <http://www.apache.org/>`_.  In the remote server's
``MathJax/fonts/HTML-CSS/TeX/otf`` folder, create a file called
``.htaccess`` that contains the following lines: ::

   <FilesMatch "\.(ttf|otf|eot)$">
   <IfModule mod_headers.c>
   Header set Access-Control-Allow-Origin "*"
   </IfModule>
   </FilesMatch>

and make sure the permissions allow the server to read this file.
(The file's name starts with a period, which causes it to be an
"invisible" file on unix-based operating systems.  Some systems,
particularly graphic user interfaces, may not allow you to create such
files, so you might need to use the command-line interface to
accomplish this.)

This file should make it possible for pages at other sites to load
MathJax from this server in such a way that Firefox will be able to
download the web-based fonts.  If you want to restrict the sites that
can access the web fonts, change the ``Access-Control-Allow-Origin``
line to something like::

   Header set Access-Control-Allow-Origin "http://www.math.yourcollege.edu"

so that only pages at ``www.math.yourcollege.edu`` will be able to
download the fonts from this site.  See the open font library
discussion of `web-font linking
<http://openfontlibrary.org/wiki/Web_Font_linking_and_Cross-Origin_Resource_Sharing>`_
for more details.


