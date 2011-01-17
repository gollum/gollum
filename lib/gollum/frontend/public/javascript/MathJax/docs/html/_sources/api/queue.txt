.. _api-queue:

********************************
The MathJax.Callback.Queue Class
********************************

The ``MathJax.Callback.Queue`` object is one of the key mechanisms
used by MathJax to synchronize its actions with those that occur
asynchronously, like loading files and stylesheets.  A `Queue` obejct
is used to coordinate a sequence of actions so that they are performed
one after another, even when one action has to wait for an
asynchronous process to complete.  This guarantees that operations are
performed in the right order even when the code must wait for some
other action to occur.  See :ref:`Synchronizing with MathJax
<synchronization>` for more details, and :ref:`Using Queues
<using-queues>` in particular for examples of how to specify and use
MathJax `Queue` objects.


Properties
----------

.. describe:: pending
        
    This is non-zero when the queue is waiting for a command to
    complete, i.e. a command being processed returns a `Callback`
    object, indicating that the queue should wait for that action to
    complete before processing additional commands.
        
.. describe:: running

    This is non-zero when the queue is executing one of the commands in
    the queue.

.. describe:: queue

    An array containing the queued commands that are yet to be performed.


Methods
-------

.. method:: Push(callback,...)

    Adds commands to the queue and runs them (if the queue is not
    pending or running another command).  If one of the callbacks is
    an actual `Callback` object rather than a callback specification,
    then the command queued is an internal command to wait for the
    given callback to complete.  That is, that callback is not itself
    queued to be executed, but a wait for that callback is queued.
    The :meth:`Push()` method returns the last callback that was
    added to the queue (so that it can be used for further
    synchronization, say as an entry in some other queue).
        
    :Parameters:
        - **callback** --- the callback specifications to be added to the queue
    :Returns: the last callback object added to the queue

.. method:: Process()
   :noindex:

    Process the commands in the queue, provided the queue is not
    waiting for another command to complete.  This method is used
    internally; you should not need to call it yourself.

.. method:: Suspend()

    Increments the `running` property, indicating that any commands that
    are added the queue should not be executed immediately, but should
    be queued for later execution (when its :meth:`Resume()` is
    called).  This method is used internally; you should not need to
    call it yourself.

.. method:: Resume()

    Decrements the `running` property, if it is positive.  When it is
    zero, commands can be processed, but that is not done
    automatically --- you would need to call :meth:`Process()` to make
    that happen.  This method is used internally; you should not need
    to call it yourself.

.. method:: wait(callback)

    Used internally when an entry in the queue is a `Callback` object
    rather than a callback specification.  A callback to this function
    (passing it the original callback) is queued instead, and it
    simply returns the callback it was passed. Since the queue will
    wait for a callback if it is the return value of one of the
    commands it executes, this effectively make the queue wait for the
    original callback at that point in the command queue.

    :Parameters:
        - **callback** --- the function to complete before returning to the queue
    :Returns: the passed callback function

.. method:: call()

    An internal function used to restart processing of the queue after
    it has been waiting for a command to complete.
