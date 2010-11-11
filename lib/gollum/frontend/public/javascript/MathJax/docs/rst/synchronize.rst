.. _synchronization:

************************************
Synchronizing your code with MathJax
************************************

MathJax performs much of its activity asynchronously, meaning that
the calls that you make to initiate these actions will return before
the actions are completed, and your code will continue to run even
though the actions have not been finished (and may not even be started
yet).  Actions such as loading files, loading web-based fonts, and
creating stylesheets all happen asynchronously within the browser, and
since JavaScript has no method of halting a program while waiting for
an action to complete, synchronizing your code with these types of
actions is made much more difficult.  MathJax used three mechanisms to
overcome this language shortcoming: callbacks, queues, and signals.

**Callbacks** are functions that are called when an action is
completed, so that your code can continue where it left off when the
action was initiated.  Rather than have a single routine that
initiates an action, waits for it to complete, and then goes on, you
break the function into two parts: a first part that sets up and
initiates the action, and a second that runs after the action is
finished.  Callbacks are similar to event handlers that you attach to
DOM elements, and are called when an certain action occurs.  See the
:ref:`Callback Object <api-callback>` reference page for details of
how to specify a callback.

**Queues** are MathJax's means of synchronizing actions that must be
performed sequentially, even when they involve asynchronous events
like loading files or dynamically creating stylesheets.  The actions
that you put in the queue are `Callback` objects that will be perfomed
in sequence, with MathJax handling the linking of one action to the
next.  MathJax maintains a master queue that you can use to
synchronize with MathJax, but you can also create your own private
queues for actions that need to be synchronized with each other, but
not to MathJax as a whole.  See the :ref:`Queue Object <api-queue>`
reference page for more details.

**Signals** are another means of synchronizing your own code with
MathJax.  Many of the important actions that MathJax takes (like
typesetting new math on the page, or loading an external component)
are "announced" by posting a message to a special object called a
`Signal`.  Your code can register an interest in receiving one or more
of these signals by providing a callback to be called when the signal
is posted.  When the signal arrives, MathJax will call your code.
This works somewhat like an event handler, except that many different
types of events can go through the same signal, and the signals have a
"memory", meaning that if you register an interest in a particular
type of signal and that signal has already occurred, you will be told
about the past occurrances as well as any future ones.  See the
:ref:`Signal Object <api-signal>` reference page for more details.
See also the ``test/sample-signals.html`` file in the MathJax ``test``
directory for a working example of using signals.

Each of these is explained in more detail in the links below:

.. toctree::
    :maxdepth: 1

    Using Callbacks <callbacks>
    Using Queues <queues>
    Using Signals <signals>


