.. _api-html:

***********************
The MathJax.HTML Object
***********************

The ``MathJax.HTML`` object provides routines for creating HTML
elements and adding them to the page, and int particular, it contains
the code that processes MathJax's :ref:`HTML snippets <html-snippets>`
and turns them into actual DOM objects.  It also implements the
methods used to manage the cookies used by MathJax.


Properties
==========

.. describe:: Cookie.prefix: "mjx"

    The prefix used for names of cookies stored by MathJax.

.. describe:: Cookie.expires: 365

    The expiration time (in days) for cookies created by MathJax.


Methods
=======

.. method:: Element(type[,attributes[,contents]])

    Creates a DOM element of the given type.  If `attributes` is
    non-``null``, it is an object that contains `key:value` pairs of
    attributes to set for the newly created element.  If `contents` is
    non-``null``, it is an :ref:`HTML snippet <html-snippets>` that
    describes the contents to create for the element.  For example

    .. code-block:: javascript

        var div = MathJax.HTML.Element(
	  "div",
	  {id: "MathDiv", style:{border:"1px solid", padding:"5px"}},
	  ["Here is math: $x+1$",["br"],"and a display $$x+1\\over x-1$$"]
	);

    :Parameters:
        - **type** --- node type to be created
        - **attributes** --- object specifying attributes to set
        - **contents** --- HTML snippet representing contents of node
    :Returns: the DOM element created    

.. method:: addElement(parent,type[,attributes[,content]])

    Creates a DOM element and appends it to the `parent` node
    provided.  It is equivalent to

    .. code-block:: javascript

        parent.appendChild(MathJax.HTML.Element(type,attributes,content))

    :Parameters:
        - **parent** --- the node where the element will be added
        - **attributes** --- object specifying attributes to set
        - **contents** --- HTML snippet representing contents of node
    :Returns: the DOM element created    

.. method:: TextNode(text)

    Creates a DOM text node with the given text as its content.

    :Parameters:
        - **text** --- the text for the node
    :Returns: the new text node

.. method:: addText(parent,text)

    Creates a DOM text node with the given text and appends it to the
    `parent` node.

    :Parameters:
        - **parent** --- the node where the text will be added
        - **text** --- the text for the new node
    :Returns: the new text node

.. describe:: Cookie.Set(name,data)

    Creates a MathJax cookie using the ``MathJax.HTML.Cookie.prefix``
    and the `name` as the cookie name, and the `key:value` pairs in
    the `data` object as the data for the cookie.  For example,

    .. code-block:: javascript

        MathJax.HTML.Cookie.Set("test",{x:42, y:"It Works!"});

    will create a cookie named "mjx:test" that stores the values of
    ``x`` and ``y`` provided in the `data` object.  This data can be
    retrieved using the :meth:`MathJax.HTML.Cookie.Get()` method
    discussed below.

    :Parameters:
        - **name** --- the name that identifies the coookie
        - **data** --- object containing the data to store in the cookie
    :Returns: ``null``

.. describe:: Cookie.Get(name[,obj])

    Looks up the data for the cookie named `name` and merges the data
    into the given `obj` object, or returns a new object containing
    the data.  For instance, given the cookie stored by the example
    above, 

    .. code-block:: javascript

        var data = MathJax.HTML.Cookie.Get("test");

    would set ``data`` to ``{x:42, y:"It Works!"}``, while

    .. code-block:: javascript

        var data = {x:10, z:"Safe"};
	MathJax.HTML.Cookie.Get("test",data);

    would leave ``data`` as ``{x:42, y:"It Works!", z:"Safe"}``.
