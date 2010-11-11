.. _api-ajax:

***********************
The MathJax.Ajax Object
***********************

The `MathJax.Ajax` structure holds the data and functions for handling
loading of external modules.  Modules are loaded only once, even if
called for in several places.  The loading of files is asynchronous,
and so the code that requests an external module will continue to run
even when that module has not completed loading, so it is important to
be aware of the timing issues this may cause.  Similarly, creating or
loading stylesheets is an asynchronous action.  In particular, all
actions that rely on the file or stylesheet having been loaded must be
delayed until after the file has been downloaded completely.  This is
the reason for the large number of routines that take callback
functions.

Any operation that could cause the loading of a file or stylesheet
must be synchronized with the rest of the code via such callbacks.
Since processing any mathematics might cause files to be loaded (e.g.,
little-used markup might be implemented in an extension that is loaded
only when that markup is used), any code that dynamically typesets
mathematics will need to be structured to use callbacks to guarantee
that the mathematics has been completely processed before the code
tries to use it.  See the :ref:`Synchronizing with MathJax <synchronization>`
documentation for details on how to do this properly.


Properties
==========

.. describe:: timeout

    Number of milliseconds to wait for a file to load before
    it is considered to have failed to load.
        
    *Default:* 20 seconds

.. describe:: STATUS.OK

    The value used to indicate that a file load has occurred
    successfully.

.. describe:: STATUS.ERROR

    The value used to indicate that a file load has caused an error or
    a timeout to occur.

.. describe:: loaded

    An object containing the names of the files that have been loaded (or
    requested) so far.  ``MathJax.Ajax.loaded["file"]`` will be
    non-``null`` when the file has been loaded, with the value being
    the ``MathJax.Ajax.STATUS`` value of the load attempt.

.. describe:: loading

    An object containing the files that are currently loading, the
    callbacks that are to be run when they load or timeout, and
    additional internal data.


Methods
=======

.. method:: Require(file[,callback])

    Loads the given file if it hasn't been already. The file must be a
    JavaScript file or a CSS stylesheet; i.e., it must end in ``.js``
    or ``.css``.  Alternatively, it can be an object with a single
    `key:value` pair where the `key` is one of ``js`` or ``css`` and
    the `value` is the file of that type to be loaded (this makes it
    possible to have the file be created by a CGI script, for example,
    or to use a ``data::`` URL).  The file must be relative to the
    MathJax home directory and can not contain ``../`` file path
    components.
        
    When the file is completely loaded and run, the `callback`, if
    provided, will be executed passing it the status of the file load.
    If there was an error while loading the file, or if the file fails
    to load within the time limit given by ``MathJax.Ajax.timout``,
    the status will be ``MathJax.Ajax.STATUS.ERROR`` otherwise it
    will be ``MathJax.Ajax.STATUS.OK``.  If the file is already
    loaded, the callback will be called immediately and the file will
    not be loaded again.
        
    :Parameters:
        - **file** --- name of the file to be loaded
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: Load(file[,callback])

    Used internally to load a given file without checking if it
    already has been loaded, or where it is to be found.

    :Parameters:
        - **file** --- name of the file to be loaded
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: loadComplete(file)

    Called from within the loaded files to inform MathJax that the
    file has been completely loaded and initialized.  The `file`
    parameter is the name of the file that has been loaded.  This
    routine will cause any callback functions registered for the file
    or included in the :meth:``MathJax.Ajax.Require()`` calls to be
    executed, passing them the status or the load
    (`MathJax.Ajax.STATUS.OK`` or ``MathJax.Ajax.STATUS.ERROR``) as
    their last parameter.

    :Parameters:
        - **file** --- name of the file that has been loaded
    :Returns: ``null``

.. method:: loadTimeout(file)

    Called when the timeout period is over and the file hasn't loaded.
    This indicates an error condition, and the
    :meth:`MathJax.Ajax.loadError()` method will be executed, then the
    file's callback will be run with ``MathJax.Ajax.STATUS.ERROR`` as
    its parameter.

    :Parameters:
        - **file** --- name of the file that timed out
    :Returns: ``null``

.. method:: loadError(file)

    The default error handler called when a file fails to load.  It
    puts a warning message into the MathJax message box on screen.

    :Parameters:
        - **file** --- the name of the file that failed to load
    :Returns: ``null``

.. method:: loadHook(file,callback)

    Registers a callback to be executed when the given file is
    loaded.  The file load operation need to be started when this
    method is called, so it can be used to register a hook for a file
    that may be loaded in the future.

    :Parameters:
        - **file** --- the name of the file to wait for
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: Styles(styles[,callback])

    Creates a stylesheet from the given style data. `styles` can
    either be a string containing a stylesheet definition, or an
    object containing a :ref:`CSS Style Object <css-style-objects>`.
    For example:

    .. code-block:: javascript

        MathJax.Ajax.Styles("body {font-family: serif; font-style: italic}");

    and

    .. code-block:: javascript

        MathJax.Ajax.Styles({
          body: {
            "font-family": "serif",
            "font-style":  "italic"
          }
        });

    both set the body font family and style.

    The callback routine is called when the stylesheet has been
    created and is available for use.
        
    :Parameters:
        - **styles** --- CSS style object for the styles to set
        - **callback** --- the callback specification
    :Returns: the callback object

    .. note::
        
        Internet Explorer has a limit of 32 dynamically created
        stylesheets, so it is best to combine your styles into one
        large group rather than making several smaller calls.

.. method:: fileURL(file)

    Returns a complete URL to a file (replacing ``[MathJax]`` with the
    actual root URL location).

    :Parameters:
        - **file** --- the file name possibly including ``[MathJax]``
    :Returns: the full URL for the file
