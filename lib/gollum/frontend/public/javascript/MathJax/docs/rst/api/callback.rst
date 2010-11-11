.. _api-callback:

**************************
The MathJax.Callback Class
**************************

The ``MathJax.Callback`` object is one of the key mechanisms used by
MathJax to synchronize its actions with those that occur
asynchronously, like loading files and stylesheets.  A `Callback`
object is used to tie the execution of a function to the completion of
an asynchronous action.  See :ref:`Synchronizing with MathJax
<synchronization>` for more details, and :ref:`Using Callbacks
<using-callbacks>` in particular for examples of how to specify and
use MathJax `Callback` objects.


Specifying a callback
---------------------

When a method includes a callback as one of its arguments, that
callback can be specified in a number of different ways, depending on
the functionality that is required of the callback.  The easiest case
is to simply provide a function to be called, but it is also possible
to include data to pass to the function when it is executed, and even
the object that will be used as the javascript `this` object when the
function is called.  

Most functions that take callbacks as arguments accept a `callback
specification` rather than an actual callback object, though you can
use the :meth:`MathJax.Callback` function to convert a callback
specification into a Callback object if needed.

A callback specification is any one of the following:

    .. describe:: fn

        A function that is to be called when the callback is executed.
        No additional data is passed to it (other that what it is
        called with at the time the callback is executed), and `this`
        will be the window object.

    .. describe:: [fn]

        An array containing a function to be called when the callback
        is executed (as above).

    .. describe:: [fn, data...]

        An array containing a function together with data to be passed
        to that function when the callback is executed; `this` is still
        the window object. For example,

	.. code-block:: javascript

	    [function (x,y) {return x+y}, 2, 3]

        would specify a callback that would pass ``2`` and ``3`` to
        the given function, and it would return their sum, ``5``, when
        the callback is executed.

	.. describe:: [object, fn]

        An array containing an object to use as `this` and a function to
        call for the callback.  For example,

	.. code-block:: javascript

	    [{x:'foo', y:'bar'}, function () {this.x}]

	would produce a callback that returns the string ``"foo"``
	when it is called.

    .. describe:: [object, fn, data...]

	Similar to the previous case, but with data that is passed to
	the function as well.

    ..describe:: ["method", object]

        Here, `object` is an object that has a method called `method`, and
        the callback will execute that method (with the object as
        `this`) when it is called.  For example,

	.. code-block:: javascript

	    ["length",[1,2,3,4]]

        would call the `length` method on the array ``[1,2,3,4]`` when
        the callback is called, returning ``4``.

    .. describe:: ["method", object, data...]

        Similar to the previous case, but with data that is passed to
        the method. E.g.,

	.. code-block:: javascript

	    ["slice",[1,2,3,4],1,3]

        would perform the equivalent of ``[1,2,3,4].slice(1,3)``,
        which returns the array ``[2,3]`` as a result.

    .. describe:: {hook: fn, data: [...], object: this}

        Here the data for the callback are given in an associative
        array of `key:value` pairs.  The value of `hook` is the
        function to call, the value of `data` is an array of the
        arguments to pass to the function, and the value of `object`
        is the object to use as `this` in the function call.  The
        specification need not include all three `key:value` pairs; any
        that are missing get default values (a function that does
        nothing, an empty array, and the window object, respectively).

    .. describe:: "string"

        This specifies a callback where the string is executed via an
        ``eval()`` statement.  The code is run in the global context,
        so any variables or functions created by the string become
        part of the global namespace.  The return value is the value of
        the last statement executed in the string.


Executing a Callback Object
===========================

The `Callback` object is itself a function, and calling that function
executes the callback.  You can pass the callback additional
parameters, just as you can any function, and these will be added to
the callback function's argument list following any data that was
supplied at the time the callback was created.  For example

.. code-block:: javascript

    var f = function (x,y) {return x + " and " +y}
    var cb = MathJax.Callback([f, "foo"]);
    var result = cb("bar");  // sets result to "foo and bar"

Usually, the callback is not executed by the code that creates it (as
it is in the example above), but by some other code that runs at a
later time at the completion of some other activity (say the loading
of a file), or in response to a user action.  For example:

.. code-block:: javascript

    function f(x) {alert("x contains "+x)};
    function DelayedX(time) {
        var x = "hi";
        setTimeout(MathJax.Callback([f, x], time);
    }

The ``DelayedX`` function arranges for the function ``f`` to be called at
a later time, passing it the value of a local variable, ``x``. Normally,
this would require the use of a closure, but that is not needed when a
`MathJax.Callback` object is used.


Callback Object Properties
--------------------------

.. describe:: hook

    The function to be called when the callback is executed.

.. describe:: data

    An array containing the arguments to pass to the callback
    function when it is executed.

.. describe:: object

    The object to use as `this` during the call to the callback
    function.

.. describe:: called

    Set to ``true`` after the callback has been called, and undefined
    otherwise.  A callback will not be exectued a second time unless
    the callback's :meth:`reset()` method is called first, or its
    ``autoReset`` property is set to ``true``.

.. describe:: autoReset

    Set this to ``true`` if you want to be able to call the callback
    more than once.  (This is the case for signal listeners, for example).

.. describe:: isCallback

    Always set to ``true`` (used to detect if an object is a callback
    or not).


Callback Object Methods
-----------------------

.. method:: reset()

    Clears the callback's `called` property.


MathJax.Callback Methods
------------------------

.. method:: Delay(time[, callback])
        
    Waits for the specified time (given in milliseconds) and then
    performs the callback.  It returns the Callback object (or a blank
    one if none was supplied).  The returned callback structure has a
    `timeout` property set to the result of the ``setTimeout()`` call
    that was used to perform the wait so that you can cancel the wait,
    if needed.  Thus :meth:`MathJax.Callback.Delay()` can be used to
    start a timeout delay that executes the callback if an action
    doesn't occur within the given time (and if the action does occur,
    the timeout can be canceled).  Since
    :meth:`MathJax.Callback.Delay()` returns a callback structure, it
    can be used in a callback queue to insert a delay between queued
    commands.
        
    :Parameters:
        - **time** --- the amount of time to wait
        - **callback** --- the callback specification
    :Returns: the callback object

.. method:: executeHooks(hooks[, data[,reset]])

    Calls each callback in the `hooks` array (or the single hook if it
    is not an array), passing it the arguments stored in the data
    array.  It `reset` is ``true``, then the callback's
    :meth:`reset()` method will be called before each hook is
    executed.  If any of the hooks returns a `Callback` object, then
    it collects those callbacks and returns a new callback that will
    execute when all the ones returned by the hooks have been
    completed.  Otherwise, :meth:`MathJax.Callback.executeHooks()`
    returns ``null``.
        
    :Parameters:
        - **hooks** --- array of hooks to be called, or a hook
        - **data** --- array of arguments to pass to each hook in turn
        - **reset** --- ``true`` if the :meth:`reset()` method should be called
    :Returns: callback that waits for all the hooks to complete, or ``null``

.. method:: Queue([callback,...])

    Creates a `MathJax.CallBack.Queue` object and pushes the given
    callbacks into the queue.  See :ref:`Using Queues <using-queues>`
    for more details about MathJax queues.

    :Parameters:
        - **callback** --- one or more callback specifications
    :Returns: the `Queue` object

.. method:: Signal(name)
        
    Looks for a named signal, creates it if it doesn't already exist,
    and returns the signal object.  See
    :ref:`Using Signals <using-signals>` for more details.
        
    :Parameters:
        - **name** --- name of the signal to get or create
    :Returns: the `Signal` object
