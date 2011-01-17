.. _using-callbacks:

***************
Using Callbacks
***************

A "callback" is a function that MathJax calls when it completes an
action that may occur asynchronously (like loading a file).  Many of
MathJax's functions operate asynchronously, and MathJax uses callbacks
to allow you to synchronize your code with the action of those
functions.  The `MathJax.Callback` structure manages these callbacks.
Callbacks can include not only a function to call, but also data to be
passed to the function, and an object to act as the JavaScript `this`
value in the resulting call (i.e., the object on which the callback is
to execute).

Callbacks can be collected into :ref:`Queues <using-queues>` where the
callbacks will be processed in order, with later callbacks waiting
until previous ones have completed before they are called.  They are
also used with :ref:`Signals <using-signals>` as the means of
receiving information about the signals as they occur.  

A number of methods in `MathJax.Hub` and `MathJax.Ajax` accept
callback specifications as arguments and return callback structures.
These routines always will return a callback even when none was
specified in the arguments, and in that case, the callback is a "do
nothing" callback.  The reason for this is so that the resulting
callback can be used can be used in a `MathJax.Callback.Queue` for
synchronization purposes, so that the actions following it in the
queue will not be performed until after the callback has been fired.

For example, the :meth:`MathJax.Ajax.Require()` method can be used to
load external files, and it returns a callback that is called when the
file has been loaded and executed.  If you want to load several files
and wait for them all to be loaded before performing some action, you
can create a `Queue` into which you push the results of the
:meth:`MathJax.Ajax.Require()` calls, and then push a callback for the
action.  The final action will not be performed until all the
file-load callbacks (which preceed it int he queue) have been called;
i.e., the action will not occur until all the files are loaded.


Specifying a Callback
---------------------

Callbacks can be specified in a number of different ways, depending on
the functionality that is required of the callback.  The easiest case
is to simply provide a function to be called, but it is also possible
to include data to pass to the function when it is called, and to
specify the object that will be used as `this` when the function is
called.

For example, the :meth:`MathJax.Ajax.Require()` method can accept a
callback as its second argument (it will be called when the file given
as the first argument is loaded and executed).  So you can call

.. code-block:: javascript

    MathJax.Ajax.Require("[MathJax]/config/myConfig.js",function () {
      alert("My configuration file is loaded");
    });

and an alert will appear when the file is loaded.  An example of
passing arguments to the callback function includes the following:

.. code-block:: javascript

    function loadHook (x) {alert("loadHook: "+x)}
    MathJax.Ajax.Require("[MathJax]/config/myConfig.js",[loadHook,"myConfig"]);

Here, the ``loadHook()`` function accepts one argument and generates
an alert that includes the value passed to it.  The callback in the
:meth:`MathJax.Ajax.Require()` call is ``[loadHook,"myConfig"]``,
which means that (the equivalent of) ``loadHook("myConfig")`` will be
performed when the file is loaded.  The result should be an alert with
the text `loadHook: myConfig`.

The callback for the :meth:`MathJax.Ajax.Require()` method actually
gets called with a status value, in addition to any parameters already
included in the callback specification, that indicates whether the
file loaded successfully, or failed for some reason (perhaps the file
couldn't be found, or it failed to compile and run).  So you could use

.. code-block:: javascript

    MathJax.Ajax.Require("[MathJax]/config/myConfig.js",function (status) {
      if (status === MathJax.Ajax.STATUS.OK) {
        alert("My configuration file is loaded");
      } else {
        alert("My configuration file failed to load!");
      }
    });

to check if the file loaded properly.  With additional parameters, the
example might be

.. code-block:: javascript

    function loadHook (x,status) {alert("loadHook: "+x+" has status "+status)}
    MathJax.Ajax.Require("[MathJax]/config/myConfig.js",[loadHook,"myConfig"]);

Note that the parameters given in the callback specification are used
first, and then additional parameters from the call to the callback
come afterward.


Callbacks to Object Methods
===========================

When you use a method of a JavaScript object, a special variable
called `this` is defined that refers to the object whose method is
being called.  It allows you to access other methods or properties of
the object without knowing explicitly where the object is stored.

For example,

.. code-block:: javascript

    var aPerson = {
      firstname: "John",
      lastname: "Smith",
      showName: function () {alert(this.firstname+" "+this.lastname)}
    };

creates an object that contains three items, a `firstname`, and
`lastname`, and a method that shows the person's full name in an
alert.  So ``aPerson.fullName()`` would cause an alert with the text
``John Smith`` to appear.  Note, however that this only works if the
method is called as ``aPerson.showName()``; if instead you did

.. code-block:: javascript

    var f = aPerson.showName;  // assign f the function from aPerson
    f();                       // and call the function

the association of the function with the data in ``aPerson`` is lost,
and the alert will probably show ``undefined undefined``.  (In this
case, ``f`` will be called with ``this`` set to the ``window``
variable, and so ``this.firstname`` and ``this.lastname`` will refer
to undefined values.)

Because of this, it is difficult to use an object's method as a
callback if you refer to it as a function directly.  For example,

.. code-block:: javascript

    var aFile = {
      name: "[MathJax]/config/myConfig.js",
      onload: function (status) {
        alert(this.name+" is loaded with status "+status);
      }
    };

    MathJax.Ajax.Require(aFile.name,aFile.onload);

would produce an alert indicating that "undefined" was loaded with a
particular status.  That is because ``aFile.onload`` is a reference to
the `onload` method, which is just a function, and the association
with the `aFile` object is lost.  One could do 

.. code-block:: javascript

    MathJax.Ajax.Require(aFile.name,function (status) {aFile.onload(status)});

but that seems needlessly verbose, and it produces a closure when one
is not really needed.  Instead, MathJax provides an alternative
specification for a callback that allows you to specify both the
method and the object it comes from:

.. code-block:: javascript

    MathJax.Ajax.Require(aFile.name,["onload",aFile]);

This requests that the callback should call ``aFile.onload`` as the
function, which will maintain the connection between ``aFile`` and its
method, thus preserving the correct value for `this` within the method.

As in the previous cases, you can pass parameters to the method as
well by including them in the array that specifies the callback:

.. code-block:: javascript

    MathJax.Ajax.Require("filename",["method",object,arg1,arg2,...]);

This approach is useful when you are pushing a callback for one one
MathJax's Hub routines into the MathJax processing queue.  For example,

.. code-block:: javascript

    MathJax.Hub.Queue(["Typeset",MathJax.Hub,"MathDiv"]);

pushes the equivalent of ``MathJax.Hub.Typeset("MathDiv")`` into the
processing queue.

See the :ref:`Callback Object <api-callback>` reference pages for more
information about the valid methods of specifying a callback.


Creating a Callback Explicitly
==============================

When you call a method that accpets a callback, you usually pass it a
callback specification (like in the examples above), which *describes*
a callback (the method will create the actual `Callback` object, and
return that to you as its return value).  You don't usually create
`Callback` objects directly yourself.

There are times, however, when you may wish to create a callback
object for use with functions that don't create callbacks for you.
For example, the ``setTimeout()`` function can take a function as its
argument, and you may want that function to be a method of an object,
and would run into the problem described in the previous section if
you simply passed the object's method to ``setTimeout()``.  Or you
might want to pass an argument to the function called by
``setTimeout()``.  (Altough the ``setTimeout()`` function can accept
additional arguements that are supposed to be passed on to the code
when it is called, Internet Explorer does not implement that feature,
so you can't rely on it.)  You can use a `Callback` object to
do this, and the :meth:`MathJax.Callback()` method will create one for
you.  For example,

.. code-block:: javascript

    function myTimer (x) {alert("x = "+x)}
    setTimeout(MathJax.Callback([f,"Hello World!"]),500);

would create a callback that calls ``f("Hello World!")``, and
schedules it to be called in half a second.
