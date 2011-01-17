.. _TeX-support:

*****************************
MathJax TeX and LaTeX Support
*****************************

The support for TeX and LaTeX in MathJax consists of two parts:  the
`tex2jax` preprocessor, and the TeX input processor.  The first of
these looks for mathematics within your web page (indicated by math
delimiters like ``$$...$$``) and marks the mathematics for later
processing by MathJax.  The TeX input processor is what converts the
TeX notation into MathJax's internal format, where on of MathJax's
output processors then displays is in the web page.

The `tex2jax` preprocessor can be configured to look for whatever
markers you want to use for your math delimiters.  See the
:ref:`tex2jax configuration options <configure-tex2jax>` section for
details on how to customize the action of `tex2jax`.

The TeX input processor handles conversion of your mathematical
notation into MathJax's internal format (which is essentially MathML),
and so acts as a TeX to MathML converter.  The TeX input processor has
few configuration options (see the :ref:`TeX options
<configure-TeX>` section for details), but it can also be customized
through the use of extensions that define additional functionality
(see the :ref:`TeX and LaTeX extensions <tex-extensions>` below).

Note that the TeX input processor implements **only** the math-mode
macros of TeX and LaTeX, not the text-mode macros.  MathJax expects
that you will use standard HTML tags to handle formatting the text of
your page; it only handles the mathematics.  So, for example, MathJax
does not implement ``\emph`` or
``\begin{enumerate}...\end{enumerate}`` or other text-mode macros or
environments.  You must use HTML to handle such formatting tasks.  If
you need a LaTeX-to-HTML converter, you should consider `other options
<http://www.google.com/search?q=latex+to+html+converter>`_.


TeX and LaTeX in HTML documents
===============================

Keep in mind that your mathematics is part of an HTML document, so you
need to be aware of the special characters used by HTML as part of its
markup.  There can not be HTML tags within the math delimiters (other
than ``<BR>``) as TeX-formatted math does not include HTML tags.
Also, since the mathematics is initially given as text on the page,
you need to be careful that your mathematics doesn't look like HTML
tags to the browser (which parses the page before MathJax gets to see
it).  In particular, that means that you have to be careful about
things like less-than and greater-than signs (``<``and ``>``), and
ampersands (``&``), which have special meaning to the browsers.  For
example,

.. code-block:: latex

	... when $x<y$ we have ...

will cause a problem, because the brower will think ``<y`` is the
beginning of a tag named ``y`` (even though there is no such tag in
HTML).  When this happens, the browser will think the tag continues up
to the next ``>`` in the document (typically the end of the next
actual tag in the HTML file), and you may notice that you are missing
part of the text of the document.  In the example above, the `` we
have ...`` will not be displayed because the browsers thinks it is
part of the tag starting at ``<y``.  This is one indication you can
use to spot this prooblem; it is a common error and should be avoided.

Usually, it is sufficient to simply put spaces around these symbols to
cause the browser to avoid them, so

.. code-block:: latex

	... when $x < y$ we have ...

should work.  Alternatively, you can use the HTML entities ``&lt;``,
``&gt;`` and ``&amp;`` to encode these characters so that the browser
will not interpret them, but MathJax will.  E.g.,

.. code-block:: latex

	  ... when $x &lt; y$ we have ...

Finally, there are ``\lt`` and ``\gt`` macros defined to make it
easier to enter ``<`` and ``>`` using TeX-like syntax:

.. code-block:: latex

        ... when $x \lt y$ we have ...

Keep in mind that the browser interprets your text before MathJax
does.


.. _tex-extensions:

TeX and LaTeX extensions
========================

While MathJax includes nearly all of the Plain TeX math macros, and
many of the LaTeX macros and environments, note everything is
implemented in the core TeX input processor.  Some less-used commands
are defined in extensions to the TeX processor.  MathJax will load
some extensions automatically when you first use the commands they
implement (for example, the ``\def`` and ``\newcommand`` macros are
implemented in the ``TeX/newcommand.js`` extension, but MathJax loads
this extension itself when you use those macros).  Not all extensions
are set up to load automatically, however, so you may need to request
some extensions explicitly yourself.

To enable any of the TeX extensions, simply add the appropriate string
(e.g., `"TeX/AMSmath.js"`) to your config's `extensions` array.  The
main extensions are described below.


AMSmath and AMSsymbol
---------------------

The `AMSmath` extension implements AMS math environments and macros,
and the `AMSsymbol` extension implements macros for accessing the AMS
symbol fonts.  To use these extensions, add them to your `extensions` array.

.. code-block:: javascript

    extensions: ["TeX/AMSmath.js", "TeX/AMSsymbol.js", ...]

See the list of commands at the end of this document for details about
what commands are implemented in these extensions.

The `AMSmath` extension will be loaded automatically when you first
use one of the math environments it defines, but you will have to load
it explicitly if you want to use the other macros that it defines.
The `AMSsymbols` extension is not loaded automatically, so you must
include it explicitly if you want to use the macros it defines.


Autobold
--------

The `autobold` extension adds ``\boldsymbol{...}`` around mathematics that
appears in a section of an HTML page that is in bold.

.. code-block:: javascript

    extensions: ["TeX/autobold.js"]


noErrors
--------

The `noErrors` extension prevents TeX error messages from being
displayed and shows the original TeX code instead.  You can configure
whether the dollar signs are shown or not for in-line math, and
whether to put all the TeX on one line or use multiple lines (if the
original text contained line breaks).

To enable the `noErrors` extension and configure it, use

.. code-block:: javascript
 
    extensions: ["TeX/noErrors.js", ...],
    TeX: {
        noErrors: {
            inlineDelimiters: ["",""],   // or ["$","$"] or ["\\(","\\)"]
            multiLine: true,             // false for TeX on all one line
            style: {
                "font-family": "serif",
                "font-size":   "80%",
                "color":       "black",
                "border":      "1px solid" 
                // add any additional CSS styles that you want
                //  (be sure there is no extra comma at the end of the last item)
            }
        }
    }
 
Display-style math is always shown in multi-line format, and without
delimiters, as it will already be set off in its own centered
paragraph, like standard display mathematics.

The default settings place the invalid TeX in a multi-line box with a
black border. If you want it to look as though the TeX is just part of
the paragraph, use

.. code-block:: javascript

    TeX: {
        noErrors: {
            inlineDelimiters: ["$","$"],   // or ["",""] or ["\\(","\\)"]
            multiLine: false,
            style: {
                "font-size": "normal",
                "border": ""
            }
        }
    }
  
You may also wish to set the font family, as the default is "serif"


noUndefined
-----------

The `noUndefined` extension causes undefined control sequences to be
shown as their macro names rather than produce an error message. So
$X_{\xxx}$ would display as an "X" with a subscript consiting of the
text ``\xxx`` in red.

To enable and configure this extension, use for example

.. code-block:: javascript

    extensions: ["TeX/noUndefined.js", ...],
    TeX: {
        noUndefined: {
            attributes: {
                mathcolor: "red",
                mathbackground: "#FFEEEE",
                mathsize: "90%"
            }
        }
     }

The ``attributes`` setting specifies attributes to apply to the
``mtext`` element that encodes the name of the undefined macro.  The
default settings set ``mathcolor`` to ``"red"``, but do not set any
other attributes.  This example sets the background to a light pink,
and reduces the font size slightly.


Unicode support
---------------

The `unicode` extension implements a ``\unicode{}`` extension to TeX
that allows arbitrary unicode code points to be entered in your
mathematics.  You can specify the height and depth of the character
(the width is determined by the browser), and the default font from
which to take the character.
  
Examples:

.. code-block:: latex 

    \unicode{65}                        % the character 'A'
    \unicode{x41}                       % the character 'A'
    \unicode[.55,0.05]{x22D6}           % less-than with dot, with height .55em and depth 0.05em
    \unicode[.55,0.05][Geramond]{x22D6} % same taken from Geramond font
    \unicode[Garamond]{x22D6}           % same, but with default height, depth of .8em,.2em
    
Once a size and font are provided for a given unicode point, they need
not be specified again in subsequent ``\unicode{}`` calls for that
character.

The result of ``\unicode{...}`` will have TeX class `ORD` (i.e., it
will act like a variable).  Use ``\mathbin{...}``, ``\mathrel{...}``,
etc., to specify a different class.

Note that a font list can be given in the ``\unicode{}`` macro, but
Internet Explorer has a buggy implementation of the ``font-family``
CSS attribute where it only looks in the first font in the list that
is actually installed on the system, and if the required glyph is not
in that font, it does not look at later fonts, but goes directly to
the default font as set in the `Internet-Options/Font` panel.  For
this reason, the default font list for the ``\unicode{}`` macro is
``STIXGeneral, 'Arial Unicode MS'``, so if the user has :term:`STIX`
fonts, the symbol will be taken from that (almost all the symbols are
in `STIXGeneral`), otherwise MathJax tries `Arial Unicode MS`.

The `unicode` extension is loaded automatically when you first use the
``\unicode{}`` macro, so you do not need to add it to the `extensions`
array.  You can configure the extension as follows:

.. code-block:: javascript

    TeX: {
        unicode: {
            fonts: "STIXGeneral, 'Arial Unicode MS'"
        }
    }


.. _tex-commands:

Supported LaTeX commands
========================

This is a long list of the TeX macros supported by MathJax.  If the
macro is defined in an extension, the name of the extension follows
the macro name.

.. code-block:: latex
    
    #
    ( )
    .
    /
    [ ]
    \!
    \#
    \$
    \%
    \&    
    \:
    \;
    \\
    \_
    \{ \}
    \|
    
    A
    \above
    \abovewithdelims
    \acute
    \aleph
    \alpha
    \amalg
    \And
    \angle
    \approx
    \approxeq AMSsymbols
    \arccos
    \arcsin
    \arctan
    \arg
    \array
    \Arrowvert
    \arrowvert
    \ast
    \asymp
    \atop
    \atopwithdelims

    B
    \backepsilon AMSsymbols
    \backprime AMSsymbols
    \backsim AMSsymbols
    \backsimeq AMSsymbols
    \backslash
    \backslash
    \bar
    \barwedge AMSsymbols
    \Bbb
    \Bbbk AMSsymbols
    \bbFont
    \because AMSsymbols
    \begin ... \end
    \begin{align*} ... \end{align*}
    \begin{alignat*} ... \end{alignat*}
    \begin{alignat} ... \end{alignat}
    \begin{alignedat} ... \end{alignedat}
    \begin{aligned} ... \end{aligned}
    \begin{align} ... \end{align}
    \begin{array} ... \end{array}
    \begin{Bmatrix} ... \end{Bmatrix}
    \begin{bmatrix} ... \end{bmatrix}
    \begin{cases} ... \end{cases}
    \begin{eqnarray*} ... \end{eqnarray*}
    \begin{eqnarray} ... \end{eqnarray}
    \begin{equation*} ... \end{equation*}
    \begin{equation} ... \end{equation}
    \begin{gather*} ... \end{gather*}
    \begin{gathered} ... \end{gathered}
    \begin{gather} ... \end{gather}
    \begin{matrix} ... \end{matrix}
    \begin{multline*} ... \end{multline*}
    \begin{multline} ... \end{multline}
    \begin{pmatrix} ... \end{pmatrix}
    \begin{smallmatrix} ... \end{smallmatrix} AMSmath
    \begin{split} ... \end{split}
    \begin{subarray} ... \end{subarray} AMSmath
    \begin{Vmatrix} ... \end{Vmatrix}
    \begin{vmatrix} ... \end{vmatrix}
    \beta
    \beth AMSsymbols
    \between AMSsymbols
    \bf
    \Big
    \big
    \bigcap
    \bigcirc
    \bigcup
    \Bigg
    \bigg
    \Biggl
    \biggl
    \Biggm
    \biggm
    \Biggr
    \biggr
    \Bigl
    \bigl
    \Bigm
    \bigm
    \bigodot
    \bigoplus
    \bigotimes
    \Bigr
    \bigr
    \bigsqcup
    \bigstar AMSsymbols
    \bigtriangledown
    \bigtriangleup
    \biguplus
    \bigvee
    \bigwedge
    \binom AMSmath
    \blacklozenge AMSsymbols
    \blacksquare AMSsymbols
    \blacktriangle AMSsymbols
    \blacktriangledown AMSsymbols
    \blacktriangleleft AMSsymbols
    \blacktriangleright AMSsymbols
    \bmod
    \boldsymbol
    \bot
    \bowtie
    \Box AMSsymbols
    \boxdot AMSsymbols
    \boxed AMSmath
    \boxminus AMSsymbols
    \boxplus AMSsymbols
    \boxtimes AMSsymbols
    \brace
    \bracevert
    \brack
    \breve
    \buildrel
    \bullet
    \Bumpeq AMSsymbols
    \bumpeq AMSsymbols
    
    C
    \cal
    \Cap AMSsymbols
    \cap
    \cases
    \cdot
    \cdotp
    \cdots
    \centerdot AMSsymbols
    \cfrac AMSmath
    \check
    \checkmark AMSsymbols
    \chi
    \choose
    \circ
    \circeq AMSsymbols
    \circlearrowleft AMSsymbols
    \circlearrowright AMSsymbols
    \circledast AMSsymbols
    \circledcirc AMSsymbols
    \circleddash AMSsymbols
    \circledR AMSsymbols
    \circledS AMSsymbols
    \clubsuit
    \colon
    \color
    \complement AMSsymbols
    \cong
    \coprod
    \cos
    \cosh
    \cot
    \coth
    \cr
    \csc
    \Cup AMSsymbols
    \cup	
    \curlyeqprec AMSsymbols
    \curlyeqsucc AMSsymbols
    \curlyvee AMSsymbols
    \curlywedge AMSsymbols
    \curvearrowleft	AMSsymbols
    \curvearrowright AMSsymbols
    
    D
    \dagger
    \daleth AMSsymbols
    \dashleftarrow AMSsymbols
    \dashrightarrow AMSsymbols
    \dashv
    \dbinom AMSmath
    \ddagger
    \ddddot AMSmath
    \dddot AMSmath
    \ddot
    \ddots
    \DeclareMathOperator AMSmath
    \def
    \deg
    \Delta
    \delta
    \det
    \dfrac AMSmath
    \diagdown AMSsymbols
    \diagup AMSsymbols
    \Diamond AMSsymbols
    \diamond
    \diamondsuit
    \digamma AMSsymbols
    \dim
    \displaylines
    \displaystyle
    \div
    \divideontimes AMSsymbols
    \dot
    \Doteq AMSsymbols
    \doteq
    \doteqdot AMSsymbols
    \dotplus AMSsymbols
    \dots
    \dotsb
    \dotsc
    \dotsi
    \dotsm
    \dotso
    \doublebarwedge AMSsymbols
    \doublecap AMSsymbols
    \doublecup AMSsymbols
    \Downarrow
    \downarrow
    \downdownarrows AMSsymbols
    \downharpoonleft AMSsymbols
    \downharpoonright AMSsymbols
    
    E
    \ell
    \emptyset
    \enspace
    \epsilon
    \eqalign
    \eqalignno
    \eqcirc AMSsymbols
    \eqsim AMSsymbols
    \eqslantgtr AMSsymbols
    \eqslantless AMSsymbols
    \equiv
    \eta
    \eth AMSsymbols
    \exists
    \exp
    
    F
    \fallingdotseq AMSsymbols
    \fbox
    \Finv AMSsymbols
    \flat
    \forall
    \frac
    \frac AMSmath
    \frak
    \frown
    
    G
    \Game AMSsymbols
    \Gamma
    \gamma
    \gcd
    \ge
    \genfrac AMSmath
    \geq
    \geqq AMSsymbols
    \geqslant AMSsymbols
    \gets
    \gg
    \ggg AMSsymbols
    \gggtr AMSsymbols
    \gimel AMSsymbols
    \gnapprox AMSsymbols
    \gneq AMSsymbols
    \gneqq AMSsymbols
    \gnsim AMSsymbols
    \grave
    \gt
    \gt
    \gtrapprox AMSsymbols
    \gtrdot AMSsymbols
    \gtreqless AMSsymbols
    \gtreqqless AMSsymbols
    \gtrless AMSsymbols
    \gtrsim AMSsymbols
    \gvertneqq AMSsymbols
    
    H
    \hat
    \hbar
    \hbox
    \heartsuit
    \hom
    \hookleftarrow
    \hookrightarrow
    \hphantom
    \hskip
    \hslash AMSsymbols
    \hspace
    \Huge
    \huge
    
    I
    \idotsint AMSmath
    \iff
    \iiiint AMSmath
    \iiint
    \iint
    \Im
    \imath
    \impliedby AMSsymbols
    \implies AMSsymbols
    \in
    \inf
    \infty
    \injlim AMSmath
    \int
    \intercal AMSsymbols
    \intop
    \iota
    \it
    
    J    
    \jmath
    \Join AMSsymbols
    
    K
    \kappa
    \ker
    \kern
    
    L
    \label
    \Lambda
    \lambda
    \land
    \langle
    \LARGE
    \Large
    \large
    \LaTeX
    \lbrace
    \lbrack
    \lceil
    \ldotp
    \ldots
    \le
    \leadsto AMSsymbols
    \left
    \Leftarrow
    \leftarrow
    \leftarrowtail AMSsymbols
    \leftharpoondown
    \leftharpoonup
    \leftleftarrows AMSsymbols
    \Leftrightarrow
    \leftrightarrow
    \leftrightarrows AMSsymbols
    \leftrightharpoons AMSsymbols
    \leftrightsquigarrow AMSsymbols
    \leftroot
    \leftthreetimes AMSsymbols
    \leq
    \leqalignno
    \leqq AMSsymbols
    \leqslant AMSsymbols
    \lessapprox AMSsymbols
    \lessdot AMSsymbols
    \lesseqgtr AMSsymbols
    \lesseqqgtr AMSsymbols
    \lessgtr AMSsymbols
    \lesssim AMSsymbols
    \lfloor
    \lg
    \lgroup
    \lhd AMSsymbols
    \lim
    \liminf
    \limits
    \limsup
    \ll
    \llap
    \llcorner AMSsymbols
    \Lleftarrow AMSsymbols
    \lll AMSsymbols
    \llless AMSsymbols
    \lmoustache
    \ln
    \lnapprox AMSsymbols
    \lneq AMSsymbols
    \lneqq AMSsymbols
    \lnot
    \lnsim AMSsymbols
    \log
    \Longleftarrow
    \longleftarrow
    \Longleftrightarrow
    \longleftrightarrow
    \longmapsto
    \Longrightarrow
    \longrightarrow
    \looparrowleft AMSsymbols
    \looparrowright AMSsymbols
    \lor
    \lower
    \lozenge AMSsymbols
    \lrcorner AMSsymbols
    \Lsh AMSsymbols
    \lt
    \ltimes AMSsymbols
    \lVert AMSmath
    \lvert AMSmath
    \lvertneqq AMSsymbols
    
    M
    \maltese AMSsymbols
    \mapsto
    \mathbb
    \mathbf
    \mathbin
    \mathcal
    \mathchoice
    \mathclose
    \mathfrak
    \mathinner
    \mathit
    \mathop
    \mathopen
    \mathord
    \mathpunct
    \mathrel
    \mathring AMSmath
    \mathrm
    \mathscr
    \mathsf
    \mathstrut
    \mathtt
    \matrix
    \max
    \mbox
    \measuredangle AMSsymbols
    \mho AMSsymbols
    \mid
    \min
    \mit
    \mkern
    \mod
    \models
    \moveleft
    \moveright
    \mp
    \mskip
    \mspace
    \mu
    \multimap AMSsymbols 
    
    N
    \nabla
    \natural
    \ncong AMSsymbols
    \ne
    \nearrow
    \neg
    \negmedspace AMSmath
    \negthickspace AMSmath
    \negthinspace
    \neq
    \newcommand
    \newenvironment
    \newline
    \nexists AMSsymbols
    \ngeq AMSsymbols
    \ngeqq AMSsymbols
    \ngeqslant AMSsymbols
    \ngtr AMSsymbols
    \ni
    \nLeftarrow AMSsymbols
    \nleftarrow AMSsymbols
    \nLeftrightarrow AMSsymbols
    \nleftrightarrow AMSsymbols
    \nleq AMSsymbols
    \nleqq AMSsymbols
    \nleqslant AMSsymbols
    \nless AMSsymbols
    \nmid AMSsymbols
    \nobreakspace AMSmath
    \nolimits
    \nonumber
    \normalsize
    \not
    \notag
    \notin
    \nparallel AMSsymbols
    \nprec AMSsymbols
    \npreceq AMSsymbols
    \nRightarrow AMSsymbols
    \nrightarrow AMSsymbols
    \nshortmid AMSsymbols
    \nshortparallel AMSsymbols
    \nsim AMSsymbols
    \nsucc AMSsymbols
    \nsucceq AMSsymbols
    \ntriangleleft AMSsymbols
    \ntrianglelefteq AMSsymbols
    \ntriangleright AMSsymbols
    \ntrianglerighteq AMSsymbols
    \nu
    \nVDash AMSsymbols
    \nVdash AMSsymbols
    \nvDash AMSsymbols
    \nvdash AMSsymbols
    \nwarrow
    
    O
    \odot
    \oint
    \oldstyle
    \Omega
    \omega
    \omicron
    \ominus
    \operatorname AMSmath
    \oplus
    \oslash
    \otimes
    \over
    \overbrace
    \overleftarrow
    \overleftrightarrow
    \overline
    \overrightarrow
    \overset
    \overwithdelims
    \owns
    
    P
    \parallel
    \partial
    \perp
    \phantom
    \Phi
    \phi
    \Pi
    \pi
    \pitchfork AMSsymbols
    \pm
    \pmatrix
    \pmb
    \pmod
    \pod
    \Pr
    \prec
    \precapprox AMSsymbols
    \preccurlyeq AMSsymbols
    \preceq
    \precnapprox AMSsymbols
    \precneqq AMSsymbols
    \precnsim AMSsymbols
    \precsim AMSsymbols
    \prime
    \prod
    \projlim AMSmath
    \propto
    \Psi
    \psi
    
    Q
    \qquad
    \quad
    
    R
    \raise
    \rangle
    \rbrace
    \rbrack
    \rceil
    \Re
    \require
    \restriction AMSsymbols
    \rfloor
    \rgroup
    \rhd AMSsymbols
    \rho
    \right
    \Rightarrow
    \rightarrow
    \rightarrowtail AMSsymbols
    \rightharpoondown
    \rightharpoonup
    \rightleftarrows AMSsymbols
    \rightleftharpoons
    \rightleftharpoons AMSsymbols
    \rightrightarrows AMSsymbols
    \rightsquigarrow AMSsymbols
    \rightthreetimes AMSsymbols
    \risingdotseq AMSsymbols
    \rlap
    \rm
    \rmoustache
    \root
    \Rrightarrow AMSsymbols
    \Rsh AMSsymbols
    \rtimes AMSsymbols
    \Rule
    \rVert AMSmath
    \rvert AMSmath
        
    S
    \S
    \scr
    \scriptscriptstyle
    \scriptsize
    \scriptstyle
    \searrow
    \sec
    \setminus
    \sf
    \sharp
    \shortmid AMSsymbols
    \shortparallel AMSsymbols
    \shoveleft AMSmath
    \shoveright AMSmath
    \sideset AMSmath
    \Sigma
    \sigma
    \sim
    \simeq
    \sin
    \sinh
    \skew
    \small
    \smallfrown AMSsymbols
    \smallint
    \smallsetminus AMSsymbols
    \smallsmile AMSsymbols
    \smash
    \smile
    \Space
    \space
    \spadesuit
    \sphericalangle AMSsymbols
    \sqcap
    \sqcup
    \sqrt
    \sqsubset AMSsymbols
    \sqsubseteq
    \sqsupset AMSsymbols
    \sqsupseteq
    \square AMSsymbols
    \stackrel
    \star
    \strut
    \Subset AMSsymbols
    \subset
    \subseteq
    \subseteqq AMSsymbols
    \substack AMSmath
    \succ
    \succapprox AMSsymbols
    \succcurlyeq AMSsymbols
    \succeq
    \succnapprox AMSsymbols
    \succneqq AMSsymbols
    \succnsim AMSsymbols
    \succsim AMSsymbols
    \sum
    \sup
    \Supset AMSsymbols
    \supset
    \supseteq
    \supseteqq AMSsymbols
    \surd
    \swarrow
    
    T
    \tag
    \tan
    \tanh
    \tau
    \tbinom AMSmath
    \TeX
    \text
    \textbf
    \textit
    \textrm
    \textstyle
    \tfrac AMSmath
    \therefore AMSsymbols
    \Theta
    \theta
    \thickapprox AMSsymbols
    \thicksim AMSsymbols
    \thinspace
    \tilde
    \times
    \Tiny
    \tiny
    \to
    \top
    \triangle
    \triangledown AMSsymbols
    \triangleleft
    \trianglelefteq AMSsymbols
    \triangleq AMSsymbols
    \triangleright
    \trianglerighteq AMSsymbols
    \tt
    \twoheadleftarrow AMSsymbols
    \twoheadrightarrow AMSsymbols
        
    U
    \ulcorner AMSsymbols
    \underbrace
    \underleftarrow
    \underleftrightarrow
    \underline
    \underrightarrow
    \underset
    \unicode
    \unlhd AMSsymbols
    \unrhd AMSsymbols
    \Uparrow
    \uparrow
    \Updownarrow
    \updownarrow
    \upharpoonleft AMSsymbols
    \upharpoonright AMSsymbols
    \uplus
    \uproot
    \Upsilon
    \upsilon
    \upuparrows AMSsymbols
    \urcorner AMSsymbols
    
    V
    \varDelta AMSsymbols
    \varepsilon
    \varGamma AMSsymbols
    \varinjlim AMSmath
    \varkappa AMSsymbols
    \varLambda AMSsymbols
    \varliminf AMSmath
    \varlimsup AMSmath
    \varnothing AMSsymbols
    \varOmega AMSsymbols
    \varPhi AMSsymbols
    \varphi
    \varPi AMSsymbols
    \varpi
    \varprojlim AMSmath
    \varpropto AMSsymbols
    \varPsi AMSsymbols
    \varrho
    \varSigma AMSsymbols
    \varsigma
    \varTheta AMSsymbols
    \vartheta
    \vartriangle AMSsymbols
    \vartriangleleft AMSsymbols
    \vartriangleright AMSsymbols
    \varUpsilon AMSsymbols
    \varXi AMSsymbols
    \vcenter
    \Vdash AMSsymbols
    \vDash AMSsymbols
    \vdash
    \vdots
    \vec
    \vee
    \veebar AMSsymbols
    \verb
    \Vert
    \vert
    \vphantom
    \Vvdash AMSsymbols
    
    W
    \wedge
    \widehat
    \widetilde
    \wp
    \wr
    
    X
    \Xi
    \xi
    \xleftarrow AMSmath
    \xrightarrow AMSmath
    
    Y
    \yen AMSsymbols
    
    Z
    \zeta

