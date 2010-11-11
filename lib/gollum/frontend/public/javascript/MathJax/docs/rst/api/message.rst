.. _api-message:

**************************
The MathJax.Message Object
**************************

The ``MathJax.Message`` object contains the methods used to manage the
small message area that appears at the lower-left corner of the
window.  MathJax uses this area to inform the user of time-consuming
actions, like loading files and fonts, or how far along in the
typesetting process it is.

The page author can customize the look of the message window by
setting styles for the ``#MathJax_Message`` selector (which can be
set via 

.. code-block:: javascript

    MathJax.Hub.Config({
      styles: {
        "#MathJax_Message": {
	  ...
	}
      }
    });

Because of a bug in Internet Explorer, in order to change the side of
the screen where the the message occurs, you must also set the side
for ``#MathJax_MSIE_Frame``, as in

.. code-block:: javascript

    MathJax.Hub.Config({
      styles: {
        "#MathJax_Message": {left: "", right: 0},
	"#MathJax_MSIE_Frame": {left: "", right: 0}
      }
    });


It is possible that a message is already being displayed when another
message needs to be posted.  For this reason, when a message is
displayed on screen, it gets an id number that is used when you want
to remove or change that message.  That way, when a message is
removed, the previous message (if any) can be redisplayed if it hasn't
been removed.  This allows for intermittent messages (like file
loading messages) to obscure longer-term message (like "Processing
Math" messages) temporarily.


Methods
=======

.. method:: Set(message,[n,[delay]])

    This sets the message being displayed to the given `message`
    string.  If `n` is not ``null``, it represents a message id
    number and the text is set for that message id, otherwise a new id
    number is created for this message.  If `delay` is provided, it is
    the time (in milliseconds) to display the message before it is
    cleared.  If `delay` is not provided, the message will not be
    removed automatically; you must call the
    :meth:`MathJax.Messsage.Clear()` method by hand to remove it.

    :Parameters:
        - **message** --- the text to display in the message area
        - **n** --- the message id number
        - **delay** --- amout of time to display the message
    :Returns: the message id nuber for this message.

.. method:: Clear(n[,delay])

    This causes the message with id `n` to be removed after the given
    `delay`, in milliseconds.  The default delay is 600 milliseconds.

    :Parameters:
        - **n** --- the message id number
        - **delay** --- the delay before removing the message
    :Returns: ``null``

.. method:: Log()

    Returns a string of all the messages issued so far, separated by
    newlines.  This is used in debugging MathJax operations.

    :Returns: string of all messages so far
