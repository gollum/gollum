.. _glossary:

********
Glossary
********

.. if you add new entries, keep the alphabetical sorting!

.. glossary::

    Callback
        A JavaScript function that is used to perform actions that
        must wait for other actions to complete before they are
        performed.
    
    Callback Queue
        MathJax uses `Queues` to synchronize its activity so that
        actions that operate asynchronously (like loading files) will
        be performed in the right order.  :term:`Callback` functions
        are pushed onto the queue, and are performed in order, with
        MathJax handling the synchronization if operations need to
        wait for other actions to finish.
    
    Callback Signal
        A JavaScript object that acts as a mailbox for MathJax events.
        Like an event handler, but it also keeps a history of
        messages.  Your code can register an "interest" in a signal,
        or can register a :term:`callback` to be called when a
        particular message is sent along the signal channel.
    
    HTML-CSS
        MathJax output form that employs only on HTML and CSS 2.1,
        allowing MathJax to remain compatible across all browsers.
    
    jax
        MathJax's input and output processors are called "jax", as is
        its internal format manager.  The code for the jax are in the
        ``MathJax/jax`` directory.

    LaTeX
        LaTeX is a variant of :term:`TeX` that is now the dominant TeX style.
        
        .. seealso::
            
            `LaTeX Wikipedia entry <http://en.wikipedia.org/wiki/LaTeX>`_
    
    MathML
        An XML specification created to describe mathematical
        notations and capture both its structure and content. MathML
        is much more verbose than :term:`TeX`, but is much more
        machine-readable.
        
        .. seealso::
            
            `MathML Wikipedia entry <http://en.wikipedia.org/wiki/MathML>`_
    
    STIX
        The Scientific and Technical Information Exchange font
        package. A comprehensive set of scientific glyphs.
        
        .. seealso::
            
            `STIX project <http://stixfonts.org/>`_
    
    TeX
        A document markup language with robust math markup commands
        developed by Donald Knuth in the late 1970's, but still in
        extensive use today.  It became the industry standard for
        typesetting of mathematics, and is one of the most common
        formats for mathematical journals, articles, and books.
        
        .. seealso::
            
            `TeX Wikipedia entry <http://en.wikipedia.org/wiki/TeX>`_
    
