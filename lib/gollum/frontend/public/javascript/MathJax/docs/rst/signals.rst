.. _using-signals:

*************
Using Signals
*************

Because much of MathJax operates asynchronously, it is important for
MathJax to be able to indicated to other components operating on the
page that certain actions have been taken.  For example, as MathJax is
starting up, it loads external files such as its configuration files
and the various input and output :term:`jax` that are used on the
page.  This means that MathJax may not be ready to run until well
after the ``<script>`` tag that loads ``MathJax.js`` has executed.  If
another component on the page needs to call MathJax to process some
mathematics, it will need to know when MathJax is ready to do that.
Thus MathJax needs a way to signal other components that it is
initialized and ready to process mathematics.  Other events that might
need to be signaled include the appearance of newly processed
mathematics on the web page, the loading of a new extension, and so
on.

The mechanism provided by MathJax for handling this type of
communication is the :term:`Callback Signal`.  The `Callback Signal`
object provides a standardized mechanism for sending and receiving
messages between MathJax and other code on the page.  A signal acts
like a mailbox where MathJax places messages for others to read.
Those interested in seeing the messages can register an interest in
receiving a given signal, and when MathJax posts a message on that
signal, all the interested parties will be notified.  No new posts to
the signal will be allowed until everyone who is listening to the
signal has had a chance to receive the first one.  If a signal causes
a listener to begin an asynchronous operation (such as loading a
file), the listener can indicate that its reply to the signal is going
to be delayed, and MathJax will wait until the asynchronous action is
complete before allowing additional messages to be posted to this
signal.  In this way, posting a signal may itself be an asynchronous
action.

The posts to a signal are cached so that if a new listener expresses
an interest in the signal, it will receive all the past posts as well
as any future ones.  For example, if a component on the page needs to
know when MathJax is set up, it can express an interest in the startup
signal's ``End`` message.  If MathJax is not yet set up, the component
will be signaled when MathJax is ready to begin, but if MathJax is
already set up, the component will receive the ``End`` message
immediately, since that message was cached and is available to any new
listeners.  In this way, signals can be used to pass messages without
worrying about the timing of when the signaler and listener are ready
to send or receive signals:  a listener will receive messages even if
it starts listening after they were sent.

One way that MathJax makes use of this feature is in configuring its
various extensions.  The extension may not be loaded when the user's
configuration code runs, so the configuration code can't modify the
extension because it isn't there yet.  Fortunately, most extensions
signal when they are set up via an ``Extension [name] Ready`` message,
so the configuration code can set up a listener for that message, and
have the listener perform the configuration when the message arrives.
But even if the extension *has* already been loaded, this will still
work, because the listener will receive the ready signal even if it
has already been posted.  In this way, listening for signals is a
robust method of synchonizing code components no matter when they are
loaded and run.

In some cases, it may be inappropriate for a new listener to receive
past messages that were sent to a signal object. There are two ways to
handle this: first, a new listener can indicate that it doesn't want
to hear old messages when it attaches itself to a signal object.  The
sender can also indicate that past messages are not appropriate for
new listeners.  It does this by clearing the message history so that
new listeners have no old posts to hear.

The actual message passed along the signal can be anything, but is
frequently a string constant indicating the message value.  It could
also be a JavaScript array containing data, or an object containing
`key:value` pairs.  All the listeners receive the data as part of the
message, and can act on it in whatever ways they see fit.

Creating a Listener
===================

MathJax maintains two separate signal channels: the `startup signal`
and the `processing signal` (or the `hub signal`).  The startup signal
is where the messages about different components startup up and
becoming ready appear.  The processing signal is where the messages
are sent about processing mathematics, like the ``New Math`` messages
for when newly typeset mathematics appears on the page.  The latter is
cleared when a new processing pass is started (so messages from past
processing runs are not kept).

The easiest way to create a listener is to use either
:meth:`MathJax.Hub.Register.StartupHook()` or
:meth:`MathJax.Hub.Register.MessageHook()`.  The first sets a listener
on the startup signal, and the latter on the hub processing signal.
You specify the message you want to listen for, and a callback to be
called when it arrives.  For example

.. code-block:: javascript

    MathJax.Hub.Register.StartupHook("TeX Jax Ready ",function () {
      alert("The TeX input jax is loaded and ready!");
    });

See the :ref:`MathJax Startup Sequence <startup-sequence>` page for
details of the messages sent during startup.  See also the
``test/sample-signals.html`` file (and its source) for examples of
using signals.  This example lists all the signals that occur while
MathJax is processing that page, so it gives useful information about
the details of the signals produced by variuous components.

In this example, the listener starts loading an extra configuration
file (from the same directory as the web page).  Since it returns
the callback from that request, the signal processing will wait until
that file is completely loaded before it continues; that is, the
configuration process is suspended until the extra configuration file
has loaded.

.. code-block:: javascript

    MathJax.Hub.Register.StartupHook("Begin Config",
      function () {return MathJax.Ajax.Require("myConfig.js")}
    );

Here is an example that produces an alert each time new mathematics
is typeset on the page.  The message includes the DOM `id` of the
element on the page that contains the newly typeset mathematics as its
second element, so this listener locates the ``<script>`` tag
for the math, and displays the original source mathematics for it.

.. code-block:: javascript

    MathJax.Hub.Register.MessageHook("New Math", function (message) {
      var script = MathJax.Hub.getJaxFor(message[1]).SourceElement();
      alert(message.join(" ")+": '"+script.text+"'");
    })


Listening for All Messages
==========================

If you want to process *every* message that passes through a signal
channel, you can do that by registering an interest in the signal
rather than registering a message hook.  You do this by calling the
signal's :meth:`Interest()` method, as in the following example.

.. code-block:: javascript

    MathJax.Hub.Startup.signal.Interest(
      function (message) {alert("Startup: "+message)}
    );
    MathJax.Hub.signal.Interest(
      function (message) {alert("Hub: "+message)}
    );

This will cause an alert for every signal that MathJax produces.  You
probably don't want to try this out, since it will produce a *lot* of
them; instead, use the ``test/sample-signals.html`` file, which
displays them in the web page.

See the :ref:`Signal Object <api-signal>` reference page for details on the
structure and methods of the signal object.
