.. _api-object:

*********************************************
The MathJax Object-Oriented Programming Model
*********************************************

MathJax uses an object-oriented programming model for its main
components, such as the `Input jax`, `Output jax`, and `Element jax`.
The model is intended to be light-weight and is based on JavaScript's
prototype inheritance mechanism.  Object classes are created by making
subclasses of `MathJax.Object` or one of its subclasses, and are
instantiated by calling the object class as you would a function.

For example:

.. code-block:: javascript

      MathJax.Object.Foo = MathJax.Object.Subclass({
        Init: function (x) {this.SetX(x)},
        getX: function () {return this.x},
        setX: function (x) {this.x = x}
      });
      var foo = MathJax.Object.Foo("bar");
      foo.getX();                // returns "bar"
      foo.setX("foobar");
      foo.getX();                // returns "foobar"

Object classes can have static properties and methods, which are
accessed via the object class variable. E.g.,
``MathJax.Object.Foo.SUPER`` or ``MathJax.Object.Foo.Augment()`` for
the object in the example above.  Static values are not inherited by
subclasses.


Static Properties
=================

.. describe:: SUPER

   Pointer to the super class for this subclass.  (It is a reference to
   `MathJax.Object` in the example above.)


Static Methods
==============

.. method:: Subclass(def[,static])

    Creates a subclass of the given class using the contents of the
    `def` object to define new methods and properties of the object
    class, and the contents of the optional `static` object to define
    new static methods and properties.

    :Parameters:
        - **def** --- object that defines the properties and methods
	- **static** --- object that defines static properties and methods
    :Returns: the new object class
 
.. method:: Augment(def[,static])

    Adds new properties and methods to the class prototype.  All
    instances of the object already in existence will receive the new
    properties and methods automatically.

    :Parameters:
        - **def** --- object that defines the properties and methods
	- **static** --- object that defines static properties and methods
    :Returns: the object class itself


Properties
==========

.. describe:: constructor

    Pointer to the constructor function for this class. E.g.,
    ``foo.constructor`` would be a reference to ``MathJax.Object.Foo``
    in the example above.

Methods
=======

.. method:: Init([data])

    An optional function that is called when an instance of the class
    is created.  When called, the `this` variable is set to the newly
    instantiated object, and the `data` is whatever was passed to the
    object constructor.  For instance, in the example above, the
    variable ``foo`` is created by calling
    ``MathJax.Object.Foo("bar")``, which calls the
    ``MathJax.Object.Foo`` object's :meth:`Init()` method with `data`
    equal to ``"bar"``.  If desired, the :meth:`Init()` method can
    create a *different* object, and return that, in which case this
    becomes the return value for the object constructor.

    :Parameters:
        - **data** --- the data from the constructor call
    :Returns: ``null`` or the object to be returned by the constructor

 
.. method:: isa(class)

    Returns ``true`` if the object is an instance of the given class,
    or of a subclass of the given class, and ``false`` otherwise.  So
    using the ``foo`` value defined above,

    .. code-block:: javascript

      foo.isa(MathJax.Object);      // returns true
      foo.isa(MathJax.Object.Foo);  // returns true
      foo.isa(MathJax.InputJax);    // returns false

.. method:: can(method)

    Checks if the object has the given `method` and returns ``true``
    if so, otherwise returns ``false``.  This allows you to test if an
    object has a particular function available before trying to call
    it (i.e., if an object implements a particular feature).  For example:

    .. code-block:: javascript

        foo.can("getX");  // returns true
	foo.can("bar");   // returns false

.. method:: has(property)

    Checks if the object has the given `property` and returns ``true``
    if so, otherwise returns ``false``.  This allows you to test if an
    object has a particular property available before trying to use
    it.  For example:

    .. code-block:: javascript

        foo.has("getX");  // returns true
  	foo.has("x");     // returns true
  	foo.has("bar");   // returns false

 
Accessing the Super Class
=========================

If a subclass overrides a method of its parent class, it may want to
call the original function as part of its replacement method.  The
semantics for this are a bit awkward, but work efficiently.  Within a
method, the value ``arguments.callee.SUPER`` refers to the super
class, so you can access any method of the superclass using that.  In
order to have `this` refer to the current object when you call the
super class, however, you need to use ``call()`` or
``apply()`` to access the given method.

For example, ``arguments.callee.SUPER.method.call(this,data)`` would
call the superclass' `method` and pass it `data` as its argument,
properly passing the current object as `this`.  Alternatively, you can
use ``this.SUPER(arguments)`` in place of ``arguments.callee.SUPER``.
It is also possible to refer to the super class explicitly rather than
through ``arguments.callee.SUPER``, as in the following example:

.. code-block:: javascript

      MathJax.Class1 = MathJax.Object.Subclass({
	Init: function(x) {this.x = x},
	XandY: function(y) {return "Class1: x and y = " + this.x + " and " + y} 
      });

      MathJax.Class2 = MathJax.Class1.Subclass({
	XandY: function (y) {return "Class2: "+arguments.callee.SUPER.XandY.call(this,y)}
      });

      MathJax.Class3 = MathJax.Class2.Subclass({
	XandY: function (y) {return "Class3: "+MathJax.Class2.prototype.XandY.call(this,y)}
      });

      MathJax.Class4 = MathJax.Class1.Subclass({
	XandY: function (y) {return "Class4: "+this.SUPER(arguments).XandY.call(this,y)}
      });

      var foo = MathJax.Class2("foo");
      foo.XandY("bar");   // returns "Class2: Class1: x and y = foo and bar"
      var bar = MathJax.Class3("bar");
      bar.XandY("foo");   // returns "Class3: Class2: Class1: x and y = bar and foo"
      var moo = MathJax.Class4("moo");
      moo.XandY("cow");   // returns "Class4: Class1: x and y = moo and cow"

Since both of these mechanisms are rather awkward, MathJax provides an
alternative syntax that is easier on the programmer, but at the cost
of some inefficiency in creating the subclass and in calling methods
that access the super class.

Since most calls to the super class are to the overridden method, not
to some other method, the method name and the ``call()`` are
essentially redundant.  You can get a more convenient syntax by
wrapping the `def` for the :meth:`Subclass()` call in a call to
``MathJax.Object.SimpleSUPER()``, as in the following example:

.. code-block:: javascript

      MathJax.Class1 = MathJax.Object.Subclass({
	Init: function (x) {this.x = x},
	XandY: function (y) {return "Class1: x and y = " + this.x + " and " + y} 
      });

      MathJax.Class2 = MathJax.Class1.Subclass(
	MathJax.Object.SimpleSUPER({
	  XandY: function (y) {return "Class2: "+this.SUPER(y)},
	  AnotherMethod: function () {return this.x}              // it's OK if a method doesn't use SUPER
	})
      );

      var foo = MathJax.Class2("foo");
      foo.XandY("bar");     // returns "Class2: Class1: x and y = foo and bar"
