.. _typeset-math:

**************************
Modifying Math on the Page
**************************

If you are writing a dynamic web page where content containing
mathematics may appear after MathJax has already typeset the rest of
the page, then you will need to tell MathJax to look for mathematics
in the page again when that new content is produced.  To do that, you
need to use the :meth:`MathJax.Hub.Typeset()` method.  This will cause
the preprocessors (if any were loaded) to run over the page again, and
then MathJax will look for unprocessed mathematics on the page and
typeset it, leaving unchanged any math that has already been typeset.

You should not simply call this method directly, however.  Because
MathJax operates asynchonously (see :ref:`Synchronizing with MathJax
<synchronization>` for details), you need to be sure that
your call to :meth:`MathJax.Hub.Typeset()` is synchronized with the
other actions that MathJax is taking.  For example, it may already be
typesetting portions of the page, or it may be waiting for an output
jax to load, etc., and so you need to queue to typeset action to be
performed after MathJax has finished whatever else it may be doing.
That may be immediately, but it may not, and there is no way to tell.

To queue the typeset action, use the command

.. code-block:: javascript

   MathJax.Hub.Queue(["Typeset",MathJax.Hub]);

This will cause MathJax to typeset the page when it is next able to do
so.  It guarantees that the typesetting will synchronize properly
with the loading of jax, extensions, fonts, stylesheets, and other
asynchornous activity, and is the only truely safe way to ask MathJax
to process additional material.

The :meth:`MathJax.Hub.Typeset()` command also accepts a parameter
that is a DOM element whose contents is to be typeset.  That could be
a paragraph, or a ``<div>`` element, or even a MathJax math
``<script>`` tag.  It could also be a the DOM `id` of such an object, in
which case, MathJax will look up the DOM element for you.  So

.. code-block:: javascript

   MathJax.Hub.Queue(["Typeset",MathJax.Hub,"MathExample"]);

would typeset the mathematics contained in the element whose `id` is
``MathExample``.  This is equivalent to

.. code-block:: javascript

   var math = document.getElementById("MathExample");
   MathJax.Hub.Queue(["Typeset",MathJax.Hub,math]);

If no element or element `id` is provided, the whole document is
typeset.

Note that the :meth:`MathJax.Hub.Queue()` method will return
immediately, regardless of whether the typesetting has taken place or
not, so you can not assume that the mathematics is visible after you
make this call.  That means that things like the size of the container
for the mathematics may not yet reflect the size of the typeet
mathematics.  If you need to perform actions that depend on the
mathematics being typeset, you should push *those* actions onto the
``MathJax.Hub.queue`` as well.  

This can be quite subtle, so you have to think carefully about the
structure of your code that works with the typeset mathematics.  Also,
the things you push onto the queue should be `Callback` objects that
perform the actions you want when they are called, not the *results*
of calling the functions that do what you want.


Manipulating Individual Math Elements
=====================================

If you are not changing a complete DOM structure, but simply want to
update the contents of a single mathematical equation, you do not need
to use ``innerHTML`` and :meth:`MathJax.Hub.Typeset()` to preprocess
and process an elements new content.  Instead, you can ask MathJax to
find the `element jax` for the math element on the page, and use its
methods to modify and update the mathematics that it displays.

For example, suppose you have the following HTML in your document

.. code-block:: html

    <div id="MathDiv">
      The answer you provided is: ${}$.
    </div>

and MathJax has already preprocessed and typeset the mathematics
within dollar signs (it will be blank).  A student has typed
something elsewhere on the page, and you want to typeset their answer
in the location of the mathematics that is already there.  You could
replace the entire contents of the `MathDiv` element and call
:meth:`MathJax.Hub.Typeset()` as described above, but there is more
efficient approach, which is to ask MathJax for the element jax for
the mathematics, and call its method for replacing the formula shown
by that element.  For example:

.. code-block:: javascript

    var math = MathJax.Hub.getAllJax("MathDiv")[0];
    MathJax.Hub.Queue(["Text",math,"x+1"]);

This looks up the list of math elements in `MathDiv` element (there is
only one) and takes the first one (element 0) and stores it in
``math``.  This is an `element jax` object (see the :ref:`Element Jax
<api-element-jax>` specification for details), which has a
:meth:`Text()` method that can be used to set the input text of the
math element, and retypeset it.

Again, since the typesetting should be synchronized with other actions
of MathJax, the call should be pushed onto the ``MathJax.Hub.queue``,
as shown above, rather than called directly.  The example above
performs the equivalent of ``math.Text("x+1")`` as soon as MathJax is
able to do so.  Any additional actions the rely on the equation
``x+1`` actually showing on screen should also be pushed onto the
queue so that they will not occur before the math is typeset.

The actions you can perform on an element jax include:

    .. describe:: Text(newmath)

        to set the math text of the element to `newmath` and typeset.

    .. describe::  Reprocess()

        to remove the output and reproduce it again (for
        example, if CSS has changed that would alter the spacing of the
        mathematics).

    .. describe:: Remove()

        to remove the output for this math element (but not
        the original ``<script>`` tag).

    .. describe:: SourceElement()

        to obtain a reference to the original
        ``<script>`` object that is assocaited with this element jax.


Note that once you have located an element jax, you can keep using it
and don't have to look it up again.  So for the example above, if the
student is going to be able to type several different answers that you
will want to typeset, you can look up the element jax once at the
beginning after MathJax has processed the page the first time, and
then use that result each time you adjust the mathematics to be
displayed.

To get the element jax the first time, you need to be sure that you
ask MathJax for it **after** MathJax has processed the page the first
time.  This is another sitaution where you want to use the MathJax
queue.  If your startup code performs the commands

.. code-block:: javascript

    var studentDisplay = null;
    MathJax.Hub.Queue(function () {
      studentDisplay = MathJax.Hub.getAllJax("MathDiv");
    });

then you can use 

.. code-block:: javascript

    MathJax.Hub.Queue(["Text",studentDisplay,studentAnswer])

to change the student's answer to be the typeset version of whatever
is in the ``studentAnswer`` variable.

Here is a complete example that illustrates this approach

.. code-block:: html

    <html>
    <head>
    <title>MathJax Dynamic Math Test Page</title>

    <script src="/MathJax/MathJax.js">
      MathJax.Hub.Config({
        extensions: ["tex2jax.js"],
        jax: ["input/TeX","output/HTML-CSS"],
        tex2jax: {inlineMath: [["$","$"],["\\(","\\)"]]}
      });
    </script>

    </head>
    <body>

    <script>
      //
      //  Use a closure to hide the local variables from the
      //  global namespace
      //
      (function () {
        var QUEUE = MathJax.Hub.queue;  // shorthand for the queue
        var math = null;                // the element jax for the math output.

        //
        //  Get the element jax when MathJax has produced it.
        //
        QUEUE.Push(function () {
          math = MathJax.Hub.getAllJax("MathOutput")[0];
        });

        //
        //  The onchange event handler that typesets the
        //  math entered by the user
        //
        window.UpdateMath = function (TeX) {
          QUEUE.Push(["Text",math,"\\displaystyle{"+TeX+"}"]);
        }
      })();
    </script>

    Type some TeX code: 
    <input id="MathInput" size="50" onchange="UpdateMath(this.value)" />
    <p>

    <div id="MathOutput">
    You typed: ${}$
    </div>

    </body>
    </html>
