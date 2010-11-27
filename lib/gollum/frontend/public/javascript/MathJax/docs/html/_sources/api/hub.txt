.. _api-hub:

**********************
The MathJax.Hub Object
**********************

The MathJax Hub, `MathJax.Hub`, is the main control structure for
MathJax.  It is where input and output :term:`jax` are tied together,
and it is what handles processing of the MathJax ``<script>`` tags.
Processing of the mathematics on the page may require external files
to be loaded (when the mathematics includes less common functionality,
for example, that is defined in an extension file), and since file
loading is asynchronous, a number of the methods below may return
before their actions are completed.  For this reason, they include
callback functions that are called when the action completes.  These
can be used to synchronize actions that require the mathematics to be
completed before those action occur. See the :ref:`Using Callbacks
<using-callbacks>` documentation for more details.


Properties
==========

.. describe:: config: { ... }

    This holds the configuration parameters for MathJax.  Set these
    values using :meth:`MathJax.Hub.Config()` described below.  The
    options and their default values are given in the :ref:`Core
    Options <configure-hub>` reference page.

.. describe:: processUpdateTime: 500

    The minimum time (in milliseconds) between updates of the
    "Processing Math" message.

.. describe:: signal

    The hub processing signal (tied to the
    :meth:`MathJax.Hub.Register.MessageHook()` method).

.. describe:: Browser

    The name of the browser as determined by MathJax.  It will be one
    of ``Firefox``, ``Safari``, ``Chrome``, ``Opera``, ``MSIE``,
    ``Konqueror``, or ``unkown``.  This is actually an object with
    additional properties and methods concerning the browser:

    .. describe:: version

        The browser version number, e.g., ``"4.0"``

    .. describe:: isMac and isPC

        These are boolean values that indicate whether the browser is
        running on a Macintosh computer or a Windows computer.  They
        will both be ``false`` for a Linux computer

    .. describe:: isForefox, isSafari, isChrome, isOpera, isMSIE, isKonqueror

        These are ``true`` when the browser is the indicated one, and
        ``false`` otherwise.

    .. describe:: versionAtLeast(version)

        This tests whether the browser version is at least that given
        in the `version` string.  Note that you can not simply do a
        numeric comparison, as version 4.10 should be considered later
        than 4.9, for example.  Similarly, 4.10 is different from 4.1,
        for instance.

    .. describe:: Select(choices) 

        This lets you perform browser-specific functions.  Here,
        `choices` is an object whose properties are the names of the
        browsers and whose values are the functions to be performed.
        Each function is passed one parameter, which is the
        ``MathJax.Hub.Browser`` object.  You do not need to include
        every browser as one of your choices (only those for which you
        need to do special processing.  For example:

	.. code-block:: javascript

	    MathJax.Hub.Browser.Select(
	      MSIE: function (browser) {
	        if (browser.versionAtLeast("8.0")) {... do version 8 stuff ... }
		... do general MSIE stuff ...
	      },

	      Firefox: function (browser) {
	        if (browser.isMac) {... do Mac stuff ... }
		... do general Firefox stuff
	      }
	    );

Methods
=======

.. Method:: Config(options)

    Sets the configuration options (stored in ``MathJax.Hub.config``)
    to the values stored in the `options` object.  See
    :ref:`Configuring MathJax <configuration>` for details on how this
    is used and the options that you can set.

    :Parameters:
        - **options** --- object containing options to be set
    :Returns: ``null``

.. describe:: Register.PreProcessor(callback)

    Used by preprocessors to register themselves with MathJax so that
    they will be called during the :meth:`MathJax.Hub.PreProcess()`
    action.

    :Parameters:
        - **callback** ---  the callback specification for the preprocessor
    :Returns: ``null``

.. describe:: Register.MessageHook(type,callback)

    Registers a listener for a particular message being sent to the
    hub processing signal (where `PreProcessing`, `Processing`, and
    `New Math` messages are sent).  When the message equals the
    `type`, the `callback` will be called with the message as its
    parameter.

    :Parameters:
        - **type** --- a string indicating the message to look for
        - **callback** --- a callback specification
    :Returns: ``null``

.. describe:: Register.StartupHook(type,callback)

    Registers a listener for a particular message being sent to the
    startup signal (where initialization and component startup
    messages are sent).  When the message equals the `type`, the
    `callback will be called with the message as its parameter.
    See the :ref:`Using Signals <using-signals>` dcocumentation for
    more details.

    :Parameters:
        - **type** --- a string indicating the message to look for
        - **callback** --- a callback specification
    :Returns: ``null``

.. describe:: Register.LoadHook(file,callback)

    Registers a callback to be called when a particular file is
    completely loaded and processed.  (The callback is called when the
    file makes its :meth:`MathJax.Ajax.loadComplete()` call.) The
    `file` should be the complete file name, e.g.,
    ``"[MathJax]/config/MathJax.js"``.

    :Parameters:
        - **file** --- the name of the file to wait for
        - **callback** --- a callback specification
    :Returns: the callback object

.. Method:: Queue(callback,...)
    :noindex:

    Pushes the given callbacks onto the main MathJax command queue.
    This synchronizes the commands with MathJax so that they will be
    performed in the proper order even when some run asynchronously.
    See :ref:`Using Queues <using-queues>` for more details about how
    to use queues, and the MathJax queue in particular.  You may
    supply as many `callback` specifications in one call to the
    :meth:`Queue()` method as you wish.

    :Parameters:
        - **callback** --- a callback specification
    :Returns: the callback object for the last callback added to the queue

.. Method:: Typeset([element[,callback]])

    Calls the preprocessors on the given element, and then typesets
    any math elements within the element.  If no `element` is
    provided, the whole document is processed.  The `element` is
    either the DOM `id` of the element, or a reference to the DOM
    element itself.  The `callback` is called when the process is
    complete.  See the :ref:`Modifying Math <typeset-math>` section
    for details of how to use this method properly.

    :Parameters:
        - **element** --- the element whose math is to be typeset
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: PreProcess([element[,callback]])

    Calls the loaded preprocessors on the entire document, or on the
    given DOM element.  The `element` is either the DOM `id` of the
    element, or a reference to the DOM element itself.  The `callback`
    is called when the processing is complete.
        
    :Parameters:
        - **element** --- the element to be preprocessed
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: Process([element[,callback]])

    Scans either the entire document or a given DOM `element` for
    MathJax ``<script>`` tags and processes the math those tags
    contain.  The `element` is either the DOM `id` of the element to
    scan, or a reference to the DOM element itself.  The `callback` is
    called when the processing is complete.
        
    :Parameters:
        - **element** --- the element to be processed
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: Update([element[,callback]])

    Scans either the entire document or a given DOM element for
    mathematics that has changed since the last time it was processed,
    or is new, and typesets the mathematics they contain.  The
    `element` is either the DOM `id` of the element to scan, or a
    reference to the DOM element itself.  The `callback` is called
    when the processing is complete.
        
    :Parameters:
        - **element** --- the element to be updated
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: Reprocess([element[,callback]])

    Removes any typeset mathematics from the document or DOM
    element, and then processes the mathematics again,
    re-typesetting everything.  This may be necessary, for example, if
    the CSS styles have changed and those changes would affect the
    mathematics.  The `element` is either the DOM `id` of the element
    to scan, or a reference to the DOM element itself.  The `callback`
    is called when the processing is complete.
        
    :Parameters:
        - **element** --- the element to be reprocessed
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: getAllJax([element])

    Returns a list of all the element jax in the document or a
    specific DOM element.  The `element` is either the DOM `id` of the
    element, or a reference to the DOM element itself.
        
    :Parameters:
        - **element** --- the element to be searched
    :Returns: array of `element jax` objects

.. method:: getJaxByType(type[,element])

    Returns a list of all the element jax of a given MIME-type in the
    document or a specific DOM element.  The `element` is either the
    DOM `id` of the element to search, or a reference to the DOM
    element itself.
        
    :Parameters:
        - **type** --- MIME-type of `element jax` to find
        - **element** --- the element to be searched
    :Returns: array of `element jax` objects

.. method:: getJaxByInputType(type[,element])

    Returns a list of all the element jax associated with input
    ``<script>`` tags with the given MIME-type within the given DOM
    element or the whole document.  The `element` is either the DOM
    `id` of the element to search, or a reference to the DOM element
    itself.
        
    :Parameters:
        - **type** --- MIME-type of input (e.g., ``"math/tex"``)
        - **element** --- the element to be searched
    :Returns: array  of `element jax` objects

.. method:: getJaxFor(element)

    Returns the element jax associated with a given DOM
    element.  If the element does not have an associated element jax,
    ``null`` is returned.  The `element` is either the DOM `id` of the
    element, or a reference to the DOM element itself.
        
    :Parameters:
        - **element** --- the element whose element jax is required
    :Returns: `element jax` object or ``null``

.. method:: isJax(element)

    Returns ``0`` if the element is not a ``<script>`` that can be
    processed by MathJax or the result of an output jax, returns ``-1``
    if element is an unprocessed ``<script>`` tag that could be
    handled by MathJax, and returns ``1`` if element is a processed
    ``<script>`` tag or an element that is the result of an output jax.
        
    :Parameters:
        - **element** --- the element to inspect
    :Returns: integer (-1, 0, 1)

.. Method:: Insert(dst,src)

    Inserts data from the `src` object into the `dst` object.  The
    `key:value` pairs in `src` are (recursively) copied into `dst`, so
    that if `value` is itself an object, its contents is copied into
    the corresponding object in `dst`.  That is, objects within `src`
    are merged into the corresponding objects in `dst` (they don't
    replace them).

    :Parameters:
        - **dst** --- the destination object
        - **src** --- the source object
    :Returns: the modified destination object

.. Method:: formatError(script,error)

    This is called when an internal error occurs during the processing
    of a math element (i.e., an error in the MathJax code itself).
    The `script` is a reference to the ``<script>`` tag where the
    error occurred, and `error` is the ``Error`` object for the error.
    The default action is to insert an HTML snippet at the location of
    the script, but this routine can be overriden durring MathJax
    configuration in order to perform some other action.
    ``MathJax.Hub.lastError`` holds the ``error`` value of the last
    error on the page.

    :Parameters:
        - **script** --- the ``<script>`` tag causing the error
        - **error** --- the ``Error`` object for the error
    :Returns: ``null``
