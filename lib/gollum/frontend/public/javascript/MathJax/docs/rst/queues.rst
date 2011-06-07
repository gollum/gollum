.. _using-queues:

************
Using Queues
************

The `callback queue` is one of MathJax's main tools for synchronizing
its actions, both internally, and with external programs, like
javascript code that you may write as part of dynamic web pages.
Because many actions in MathJax (like loading files) operate
asynchornously, MathJax needs a way to coordinate those actions so
that they occur in the right order.  The
`MathJax.Callback.Queue` object provides that mechanism.

A `callback queue` is a list of commands that will be performed one at
a time, in order.  If the return value of one of the commands is a
`Callback` object, processing is suspended until that callback is
called, and then processing of the commands is resumed.  In this way,
if a command starts an asynchronous operation like loading a file, it
can return the callback for that file-load operation and the queue
will wait until the file has loaded before continuing.  Thus a queue
can be used to guarantee that commands don't get performed until other
ones are known to be finished, even if those commands usually operate
asynchronously.


Constructing Queues
===================

A queue is created via the :meth:`MathJax.Callback.Queue()` command,
which returns a `MathJax.Callback.Queue` object. The queue
itself consists of a series of commands given as callback
specifications (see :ref:`Using Callbacks <using-callbacks>` for
details on callbacks), which allow you to provide functions (together
with their arguments) to be executed.  You can provide the collection
of callback specifications when the queue is created by passing them
as arguments to :meth:`MathJax.Callback.Queue()`, or you can create an
empty queue to which commands are added later.  Once a
`MathJax.Callback.Queue` object is created, you can push
additional callbacks on the end of the queue; if the queue is empty,
the command will be performed immediately, while if the queue is
waiting for another command to complete, the new command will be
queued for later processing.

For example,

.. code-block:: javascript

    function f(x) {alert(x)}
    var queue = MathJax.Callback.Queue([f, 15], [f, 10], [f, 5]);
    queue.Push([f, 0]);

would create a queue containing three commands, each calling the
function ``f`` with a different input, that are performed in order.  A
fourth command is then added to the queue, to be performed after the
other three.  In this case, the result will be four alerts, the first
with the number 15, the second with 10, the third with 5 and the
fourth with 0.  Of course ``f`` is not a function that operates
asynchronously, so it would have been easier to just call ``f`` four
times directly.  The power of the queue comes from calling commands
that could operate asynchronously.  For example:

.. code-block:: javascript

    function f(x) {alert(x)}
    MathJax.Callback.Queue(
      [f, 1],
      ["Require", MathJax.Ajax, "[MathJax]/extensions/AMSmath.js"],
      [f, 2]
    );

Here, the command ``MathJax.Ajax.require("extensions/AMSmath.js")`` is
queued between two calls to ``f``.  The first call to ``f(1)`` will be
made immediately, then the :meth:`MathJax.Ajax.Require` statement will
be performed.  Since the ``Require`` method loads a file, it operates
asynchronously, and its return value is a `MathJax.Callback`
object that will be called when the file is loaded.  The call to
``f(2)`` will not be made until that callback is performed,
effectively synchronizing the second call to ``f`` with the completion
of the file loading.  This is equivalent to

.. code-block:: javascript

    f(1);
    MathJax.Ajax.Require("[MathJax]/extensions/AMSmath.js", [f, 2]);

since the ``Require()`` command allows you to specify a (single)
callback to be performed on the completion of the file load.  Note,
however, that the queue could be used to synchronize several file
loads along with multiple function calls, so is more flexible.

For example,

.. code-block:: javascript

    MathJax.Callback.Queue(
      ["Require", MathJax.Ajax, "[MathJax]/extensions/AMSmath.js"],
      [f, 1],
      ["Require", MathJax.Ajax, "[MathJax]/config/local/AMSmathAdditions.js"],
      [f, 2]
    );

would load the AMSmath extension, then call ``f(1)`` then load the
local AMSmath modifications, and then call ``f(2)``, with each action
waiting for the previous one to complete before being performed
itself.


Callbacks versus Callback Specifications
========================================

If one of the callback specifications is an actual callback object
itself, then the queue will wait for that action to be performed
before proceeding.  For example,

.. code-block:: javascript

    MathJax.Callback.Queue(
        [f, 1],
        MathJax.Ajax.Require("[MathJax]/extensions/AMSmath.js"),
        [f, 2],
   );

starts the loading of the AMSmath extension before the queue is
created, and then creates the queue containing the call to ``f``, the
callback for the file load, and the second call to ``f``.  The queue
performs ``f(1)``, waits for the file load callback to be called, and
then calls ``f(2)``.  The difference between this and the second
example above is that, in this example the file load is started before
the queue is even created, so the file is potentially loaded and
executed before the call to ``f(1)``, while in the example above, the
file load is guaranteed not to begin until after ``f(1)`` is executed.

As a further example, consider

.. code-block:: javascript

    MathJax.Callback.Queue(
      MathJax.Ajax.Require("[MathJax]/extensions/AMSmath.js"),
      [f, 1],
      MathJax.Ajax.Require("[MathJax]/config/local/AMSmathAdditions.js"),
      [f, 2]
    );

in comparison to the example above that uses ``["Require",
MathJax.Ajax, "[MathJax]/extensions/AMSmath.js"]`` and ``["Require",
MathJax.Ajax, "[MathJax]/config/local/AMSmathAdditions.js"]`` instead.  In that
example, ``AMSmath.js`` is loaded, then ``f(1)`` is called, then the
local additions are loaded, then ``f(2)`` is called.

Here, however, both file loads are started before the queue is
created, and are operating in parallel (rather than sequentially as in
the earlier example).  It is possible for the loading of the local
additions to complete before the AMSmath extension is loaded in this
case, which was guaranteed **not** to happen in the other example.
Note, however, that ``f(1)`` is guaranteed not to be performed until
after the AMSmath extensions load, and ``f(2)`` will not occur until
after both files are loaded.

In this way, it is possible to start asynchronous loading of several
files simultaneously, and wait until all of them are loaded (in
whatever order) to perform some command.  For instance,

.. code-block:: javascript

    MathJax.Callback.Queue(
        MathJax.Ajax.Require("file1.js"),
        MathJax.Ajax.Require("file2.js"),
        MathJax.Ajax.Require("file3.js"),
        MathJax.Ajax.Require("file4.js"),
        [f, "all done"]
    );

starts four files loading all at once, and waits for all four to
complete before calling ``f("all done")``. The order in which they
complete is immaterial, and they all are being requested
simultaneously.


The MathJax Processing Queue
============================

MathJax uses a queue stored as ``MathJax.Hub.queue`` to regulate its
own actions so that they operate in the right order even when some
of them include asynchronous operations.  You can take advantage of
that queue when you make calls to MathJax methods that need to be
synchronized with the other actions taken by MathJax.  It may not
always be apparent, however, which methods fall into that category.

The main source of asynchronous actions in MathJax is the loading of
external files, so any action that may cause a file to be loaded may
act asynchronously.  Many important actions do so, including some that
you might not expect; e.g., typesetting mathematics can cause files to
be loaded.  This is because some TeX commands, for example, are rare
enough that they are not included in the core TeX input processor, but
instead are defined in extensions that are loaded automatically when
needed.  The typesetting of an expression containing one of these TeX
commands can cause the typesetting process to be suspended while the
file is loaded, and then restarted when the extension has become
evailable.

As a result, any call to :meth:`MathJax.Hub.Typeset()` (or
:meth:`MathJax.Hub.Process()`, or :meth:`MathJax.Hub.Update()`, etc.)
could return long before the mathematics is actually typeset, and the
rest of your code may run before the mathematics is available.  If you
have code that relys on the mathematics being visible on screen, you
will need to break that out into a separate operation that is
synchronized with the typesetting via the MathJax queue.

Furthermore, your own typesetting calls may need to wait for file loading
to occur that is already underway, so even if you don't need to access
the mathematics after it is typeset, you may still need to queue the
typeset command in order to make sure it is properly synchronized with
*previous* typeset calls.  For instance, if an earlier call
started loading an extension and you start another typeset call before
that extension is fully loaded, MathJax's internal state may be in
flux, and it may not be prepared to handle another typeset operation
yet.  This is even more important if you are using other libraries
that may call MathJax, in which case your code may not be aware of the
state that MathJax is in.

For these reasons, it is always best to perform typesetting operations
through the MathJax queue, and the same goes for any other action
that could cause files to load.  A good rule of thumb is that, if a
MathJax function includes a callback argument, that function may operate
asynchronously; you should use the MathJax queue to perform it and
any actions that rely on its results.

To place an action in the MathJax queue, use the
:meth:`MathJax.Hub.Queue()` command.  For example

.. code-block:: javascript

    MathJax.Hub.Queue(["Typeset",MathJax.Hub,"MathDiv"]);

would queue the command ``MathJax.Hub.Typeset("MathDiv")``, causing
the contents of the DOM element with `id` equal to ``MathDiv`` to be
typeset.

One of the uses of the MathJax queue is to allow you to synchronize an
action with the startup process for MathJax.  If you want to have a
function performed after MathJax has become completely set up (and
performed its initial typesetting of the page), you can push it onto
the ``MathJax.Hub.queue`` so that it won't be performed until MathJax
finishes everything it has queued when it was loaded.  For example,

.. code-block:: html

    <script type="text/javascript" src="/MathJax/MathJax.js"></script>
    <script>
      MathJax.Hub.Queue(function () {
        // ... your startup commands here ...
      });
    </script>
