.. _configure-hub:

******************************
The Core Configuration Options
******************************

The options below control the MathJax Hub, and so determine the code
behavior of MathJax.  They are given with their default values.  

.. describe:: jax: ["input/TeX","output/HTML-CSS"]

    A comma-separated list of input and output jax to initialize at
    startup.  Their main code is loaded only when they are actually
    used, so it is not inefficient to include jax that may not
    actually be used on the page. These are found in the ``MathJax/jax``
    directory.

.. describe:: extensions: []

    A comma-separated list of extensions to load at startup. The
    default directory is ``MathJax/extensions``.  The ``tex2jax`` and
    ``mml2jax`` preprocessors can be listed here, as well as a number
    of TeX-specific extensions (see the :ref:`TeX and LaTeX input
    <tex-and-latex-input>` section of the :ref:`Getting Started
    <getting-started>` document for more details).  There is also a
    ``FontWarnings`` extension that you can use to inform your user
    that mathematics fonts are available that they can download to
    improve their experience of your site.

.. describe:: config: []

    A comma-separated list of configuration files to load when MathJax
    starts up, e.g., to define local macros, etc., and there is a
    sample config file named ``config/local/local.js``.  The default
    directory is the `MathJax/config` directory.  The ``MMLorHTML.js``
    configuration is the only other predefined configuration file.

.. describe:: styleSheets: []

    A comma-separated list of CSS stylesheet files to be loaded when
    MathJax starts up.  The default directory is the `MathJax/config`
    directory.

.. describe:: styles: {}

    CSS `selector: rules;` styles to be defined dynamically at startup
    time.

.. describe:: preJax: null and postJax: null

    Patterns to remove from before and after math script tags. If you
    are not using one of the preprocessors, you need to insert
    something extra into your HTML file in order to avoid a bug in
    Internet Explorer.  IE removes spaces from the DOM that it thinks
    are redundent, and since a ``<script>`` tag usually doesn't add
    content to the page, if there is a space before and after a
    MathJax ``<script>`` tag, IE will remove the first space.  When
    MathJax inserts the typeset mathematics, this means there will be
    no space before it and the preceeding text.  In order to avoid
    this, you should include some "guard characters" before or after
    the math SCRIPT tag; define the patterns you want to use below.
    Note that these are used as regular expressions, so you will need
    to quote special characters.  Furthermore, since they are
    javascript strings, you must quote javascript special characters
    as well.  So to obtain a backslash, you must use ``\\`` (doubled
    for javascript).  For example, ``"\\["`` represents the pattern
    ``\[`` in the regular expression.  That means that if you want an
    actual backslash in your guard characters, you need to use
    ``"\\\\"`` in order to get ``\\`` in the regular expression, and
    ``\`` in the actual text.  If both preJax and postJax are defined,
    both must be present in order to be removed.

    See also the ``preRemoveClass`` comments below.

    Examples:

        ``preJax: "\\\\\\\\\"`` makes a double backslash the preJax text

	``preJax: "\\[\\[", postJax: "\\]\\]"`` makes it so jax
	scripts must be enclosed in double brackets.

.. describe:: preRemoveClass: "MathJax_Preview"

    The CSS class for a math preview to be removed preceeding a
    MathJax SCRIPT tag.  If the tag just before the MathJax
    ``<script>`` tag is of this class, its contents are removed when
    MathJax processes the ``<script>`` tag.  This allows you to
    include a math preview in a form that will be displayed prior to
    MathJax performing its typesetting.  It also avoids the Internet
    Explorer space-removal bug, and can be used in place of ``preJax``
    and ``postJax`` if that is more convenient.

    For example

    .. code-block:: html
    
        <span class="MathJax_Preview">[math]</span><script  type="math/tex">...</script>
  
    would display "[math]" in place of the math until MathJax is able
    to typeset it.

    See also the ``preJax`` and ``postJax`` comments above.

.. describe:: showProcessingMessages: true

    This value controls whether the `Processing Math: nn%` message are
    displayed in the lower left-hand corner. Set to ``false`` to
    prevent those messages (though file loading and other messages
    will still be shown).

.. describe:: messageStyle: "normal"

    This value controls the verbosity of the messages in the lower
    left-hand corner.  Set it to ``"none"`` to eliminate all messages,
    or set it to ``"simple"`` to show "Loading..." and "Processing..."
    rather than showing the full file name or the percentage of the
    mathematics processed.

.. describe:: displayAlign: "center" and displayIndent: "0em"

    These two parameters control the alignment and shifting of
    displayed equations.  The first can be ``"left"``, ``"center"``,
    or ``"right"``, and determines the alignment of displayed
    equations.  When the alignment is not ``"center"``, the second
    determines an indentation from the left or right side for the
    displayed equations.


.. describe:: delayStartupUntil: "none"

    Normally MathJax will perform its starup commands (loading of
    configuration, styles, jax, and so on) as soon as it can.  If you
    expect to be doing additional configuration on the page, however,
    you may want to have it wait until the page's onload hander is
    called.  If so, set this to ``"onload"``.

.. describe:: skipStartupTypeset: false

    Normally MathJax will typeset the mathematics on the page as soon
    as the page is loaded.  If you want to delay that process, in
    which case you will need to call :meth:`MathJax.Hub.Typeset()`
    yourself by hand, set this value to ``true``.

.. describe:: menuSettings: { ... }

    This block contains settings for the mathematics contextual menu
    that act as the defaults for the user's settings in that menu.
    The possible values are:

    .. describe:: zoom: "none"

        This indicates when typeset mathematics should be zoomed.  It
        can be set to ``"None"``, ``"Hover"``, ``"Click"``, or
        ``"Double-Click"`` to set the zoom trigger.

    .. describe:: CTRL: false, ALT: false, CMD: false, Shift: false

        These values indicate which keys must be pressed in order for
        math zoom to be triggered.  For example, if ``CTRL`` is set to
        ``true`` and ``zoom`` is ``"Click"``, then math will be zoomed
        only when the user control-clicks on mathematics (i.e., clicks
        while holding down the `CTRL` key).  If more than one is
        ``true``, then all the indicated keys must be pressed for the
        zoom to occur.

    .. describe:: zscale: "200%"

        This is the zoom scaling factor, and it can be set to any of
	the values available in the `Zoom Factor` menu of the
	`Settings` submenu of the contextual menu.

    .. describe:: context: "MathJax"

        This controls what contextual menu will be presented when a
        right click (on a PC) or CTRL-click (on the Mac) occurs over a
        typeset equation.  When set to ``"MathJax"``, the MathJax
        contextual menu will appear; when set to ``"Browser"``, the
        browser's contextual menu will be used.  For example, in
        Internet Explorer with the MathPlayer plugin, if this is set
        to ``"Browser"``, you will get the MathPlayer contextual menu
        rather than the MathJax menu.

    There are also settings for ``format``, ``renderer``, and ``font``,
    but these are maintained by MathJax and should not be set by the
    page author.

.. describe:: errorSettings: { ... }

    This block contains settings that control how MathJax responds to
    unexpected errors while processing mathematical equations.  Rather
    than simply crash, MathJax can report an error and go on.  The
    options you can set include:

    .. describe:: message: ["[Math Processing Error"]]

        This is an HTML snippet that will be inserted at the location
        of the mathematics for any formula that causes MathJax to
        produce an internal error (i.e., an error in the MathJax code
        itself).  See the :ref:`description of HTML snippets
        <html-snippets>` for details on how to represent HTML code in
        this way.

    .. describe:: style: {color:"#CC0000", "font-style":"italic"}

        This is the CSS style description to use for the error
        messages produced by internal MathJax errors.  See the section
        on :ref:`CSS style objects <css-style-objects>` for details on
        how these are specified in JavaScript.

