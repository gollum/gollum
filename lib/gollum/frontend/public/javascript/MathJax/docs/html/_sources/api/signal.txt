.. _api-signal:

*********************************
The MathJax.Callback.Signal Class
*********************************

The ``MathJax.Callback.Signal`` object is one of the key mechanisms
used by MathJax to synchronize its actions with those that occur
asynchronously, like loading files and stylesheets.  A `Signal` object
is used to pulicise the fact that MathJax has performed certain
actions, giving other code running the the web page the chance to
react to those actions.  See :ref:`Synchronizing with MathJax
<synchronization>` for more details, and :ref:`Using Signals
<using-signals>` in particular for examples of how to specify and use
MathJax `Signal` objects.

The `Callback Signal` object is a subclass of the :ref:`Callback Queue
<api-queue>` object.


Properties
----------

.. describe:: name

    The name of the signal.  Each signal is named so that
    various components can access it.  The first one to request a
    particular signal causes it to be created, and other requests for
    the signal return references to the same object.

.. describe:: posted

    Array used internally to stored the post history so that when new
    listeners express interests in this signal, they can be informed
    of the signals that have been posted so far.  This can be cleared
    using the signal's :meth:`Clear()` method.

.. describe:: listeners

    Array of callbacks to the listeners who have expressed interest in
    hearing about posts to this signal.  When a post occurs, the
    listeners are called in each turn, passing them the message that
    was posted.


Methods
-------

.. method:: Post(message[,callback])

    Posts a message to all the listeners for the signal.  The listener
    callbacks are called in turn (with the message as an argument),
    and if any return a `Callback` object, the posting will be
    suspended until the callback is exectured.  In this way, the
    :meth:`Post()` call can operate asynchronously, and so the
    `callback` parameter is used to synchronize with its operation;
    the `callback` will be called when all the listeners have responded
    to the post.
        
    If a :meth:`Post()` to this signal occurs while waiting for the
    response from a listener (either because a listener returned a
    `Callback` object and we are waiting for it to complete when the
    :meth:`Post()` occurred, or because the listener itself called the
    ``Post()`` method), the new message will be queued and will be
    posted after the current message has been sent to all the
    listeners, and they have all responded.  This is another way in
    which posting can be asynchronous; the only sure way to know that
    a posting has occurred is through its `callback`. When the posting
    is complete, the callback is called, passing it the signal object
    that has just completed.
        
    Returns the callback object (or a blank callback object if none
    was provided).

    :Parameters:
        - **message** --- the message to send through the signal
        - **callback** --- called after the message is posted
    :Returns: the callback or a blank callback

.. method:: Clear([callback])
    :noindex:

    This causes the history of past messages to be cleared so new
    listeners will not receive them.  Note that since the signal may
    be operating asynchronously, the :meth:`Clear()` may be queued for
    later.  In this way, the :meth:`Post()` and :meth:`Clear()`
    operations will be performed in the proper order even when they
    are delayed.  The `callback` is called when the :meth:`Clear()`
    operation is completed.
        
    Returns the callback (or a blank callback if none is provided).

    :Parameters:
	- **callback** --- called after the signal history is cleared
    :Returns: the callback or a blank callback

.. method:: Interest(callback[,ignorePast])

    This method registers a new listener on the signal.  It creates a
    `Callback` object from the callback specification, attaches it to
    the signal, and returns that `Callback` object.  When new messages
    are posted to the signal, it runs the callback, passing it the
    message that was posted.  If the callback itself returns a
    `Callback` object, that indicates that the listener has started an
    asynchronous operation and the poster should wait for that
    callback to complete before allowing new posts on the signal.

    If `ignorePast` is ``false`` or not present, then before
    :meth:`Interest()` returns, the callback will be called with all
    the past messages that have been sent to the signal.

    :Parameters:
	- **callback** --- called whenever a message is posted (past or present)
	- **ignorePast** --- ``true`` means ignore previous messages
    :Returns: the callback object
        
.. method:: NoInterest(callback)

    This removes a listener from the signal so that no new messages
    will be sent to it.  The callback should be the one returned by
    the original :meth:`Interest()` call that attached the listener to
    the signal in the first place.  Once removed, the listener will no
    longer receive messages from the signal.

    :Parameters:
	- **callback** --- the listener to be removed from signal
    :Returns: ``null``

.. method:: MessageHook(message, callback)

    This creates a callback that is called whenever the signal posts
    the given message.  This is a little easier than having to write a
    function that must check the message each time it is called.
    Although the `message` here is a string, if a message posted to the
    signal is an array, then only the first element of that array is
    used to match against message.  That way, if a message contains an
    identifier plus arguments, the hook will match the identifier and
    still get called with the complete set of arguments.
        
    Returns the `Callback` object that was produced.

    :Parameters:
        - **message** --- the message to look for from the signal
	- **callback** --- called when the message is posted
    :Returns: the callback object

.. method:: ExecuteHook(message)

    Used internally to call the listeners when a particular
    message is posted to the signal.

    :Parameters:
        - **message** --- the posted message
    :Returns: ``null``
