/*************************************************************
 *
 *  MathJax/jax/input/TeX/jax.js
 *  
 *  Implements the TeX InputJax that reads mathematics in
 *  TeX and LaTeX format and converts it to the MML ElementJax
 *  internal format.
 *
 *  ---------------------------------------------------------------------
 *  
 *  Copyright (c) 2009-2010 Design Science, Inc.
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

(function (TEX) {
  var TRUE = true, FALSE = false, MML; 
  
  TEX.Stack = MathJax.Object.Subclass({
    Init: function (env) {
      this.global = {};
      this.data = [STACKITEM.start().With({global: this.global})];
      if (env) {this.data[0].env = env}
      this.env = this.data[0].env;
    },
    Push: function () {
      var i, m, item, top;
      for (i = 0, m = arguments.length; i < m; i++) {
        item = arguments[i];
        if (item instanceof MML.mbase) {item = STACKITEM.mml(item)}
        item.global = this.global;
        top = (this.data.length ? this.Top().checkItem(item) : TRUE);
        if (top instanceof Array) {this.Pop(); this.Push.apply(this,top)}
        else if (top instanceof STACKITEM) {this.Pop(); this.Push(top)}
        else if (top) {
          this.data.push(item);
          if (item.env) {
            for (var id in this.env)
              {if (this.env.hasOwnProperty(id)) {item.env[id] = this.env[id]}}
            this.env = item.env;
          } else {item.env = this.env}
        }
      }
    },
    Pop: function () {
      var item = this.data.pop(); if (!item.isOpen) {delete item.env}
      this.env = (this.data.length ? this.Top().env : {});
      return item;
    },
    Top: function (n) {
      if (n == null) {n = 1}
      if (this.data.length < n) {return null}
      return this.data[this.data.length-n];
    },
    Prev: function (noPop) {
      var top = this.Top();
      if (noPop) {return top.data[top.data.length-1]}
            else {return top.Pop()}
    },
    toString: function () {return "stack[\n  "+this.data.join("\n  ")+"\n]"}
  });
  
  var STACKITEM = TEX.Stack.Item = MathJax.Object.Subclass({
    type: "base",
    closeError: "Extra close brace or missing open brace",
    rightError: "Missing \\left or extra \\right",
    Init: function () {
      if (this.isOpen) {this.env = {}}
      this.data = [];
      this.Push.apply(this,arguments);
    },
    Push: function () {this.data.push.apply(this.data,arguments)},
    Pop: function () {return this.data.pop()},
    mmlData: function (inferred,forceRow) {
      if (inferred == null) {inferred = TRUE}
      if (this.data.length === 1 && !forceRow) {return this.data[0]}
      return MML.mrow.apply(MML,this.data).With((inferred ? {inferred: TRUE}: {}));
    },
    checkItem: function (item) {
      if (item.type === "over" && this.isOpen) {item.num = this.mmlData(FALSE); this.data = []}
      if (item.type === "cell" && this.isOpen) {TEX.Error("Misplaced "+item.name)}
      if (item.isClose && this[item.type+"Error"]) {TEX.Error(this[item.type+"Error"])}
      if (!item.isNotStack) {return TRUE}
      this.Push(item.data[0]); return FALSE;
    },
    With: function (def) {
      for (var id in def) {if (def.hasOwnProperty(id)) {this[id] = def[id]}}
      return this;
    },
    toString: function () {return this.type+"["+this.data.join("; ")+"]"}
  });

  STACKITEM.start = STACKITEM.Subclass({
    type: "start", isOpen: TRUE,
    checkItem: function (item) {
      if (item.type === "stop") {return STACKITEM.mml(this.mmlData())}
      return this.SUPER(arguments).checkItem.call(this,item);
    }
  });

  STACKITEM.stop = STACKITEM.Subclass({
    type: "stop", isClose: TRUE
  });

  STACKITEM.open = STACKITEM.Subclass({
    type: "open", isOpen: TRUE,
    stopError: "Extra open brace or missing close brace",
    checkItem: function (item) {
      if (item.type === "close") {
        var mml = this.mmlData(); // this.mmlData(TRUE,TRUE); // force row
        return STACKITEM.mml(MML.TeXAtom(mml)); // TeXAtom make it an ORD to prevent spacing (FIXME: should be another way)
      }
      return this.SUPER(arguments).checkItem.call(this,item);
    }
  });

  STACKITEM.close = STACKITEM.Subclass({
    type: "close", isClose: TRUE
  });

  STACKITEM.subsup = STACKITEM.Subclass({
    type: "subsup",
    stopError: "Missing superscript or subscript argument",
    checkItem: function (item) {
      var script = ["","subscript","superscript"][this.position];
      if (item.type === "open" || item.type === "left") {return TRUE}
      if (item.type === "mml") {
        this.data[0].SetData(this.position,item.data[0]);
        return STACKITEM.mml(this.data[0]);
      }
      if (this.SUPER(arguments).checkItem.call(this,item))
        {TEX.Error("Missing open brace for "+script)}
    },
    Pop: function () {}
  });

  STACKITEM.over = STACKITEM.Subclass({
    type: "over", isClose: TRUE, name: "\\over",
    checkItem: function (item,stack) {
      if (item.type === "over") {TEX.Error("Ambiguous use of "+item.name)}
      if (item.isClose) {
        var mml = MML.mfrac(this.num,this.mmlData(FALSE));
        if (this.thickness != null) {mml.linethickness = this.thickness}
        if (this.open || this.close) {
          mml.texClass = MML.TEXCLASS.INNER;
          mml.texWithDelims = TRUE;
          mml = MML.mfenced(mml).With({open: this.open, close: this.close});
        }
        return [STACKITEM.mml(mml), item];
      }
      return this.SUPER(arguments).checkItem.call(this,item);
    },
    toString: function () {return "over["+this.num+" / "+this.data.join("; ")+"]"}
  });

  STACKITEM.left = STACKITEM.Subclass({
    type: "left", isOpen: TRUE, delim: '(',
    stopError: "Extra \\left or missing \\right",
    checkItem: function (item) {
      if (item.type === "right") {
        var mml = MML.mfenced(this.data.length === 1 ? this.data[0] : MML.mrow.apply(MML,this.data));
        return STACKITEM.mml(mml.With({open: this.delim, close: item.delim}));
      }
      return this.SUPER(arguments).checkItem.call(this,item);
    }
  });

  STACKITEM.right = STACKITEM.Subclass({
    type: "right", isClose: TRUE, delim: ')'
  });

  STACKITEM.begin = STACKITEM.Subclass({
    type: "begin", isOpen: TRUE,
    checkItem: function (item) {
      if (item.type === "end") {
        if (item.name !== this.name)
          {TEX.Error("\\begin{"+this.name+"} ended with \\end{"+item.name+"}")}
        if (!this.end) {return STACKITEM.mml(this.mmlData())}
        return this.parse[this.end].call(this.parse,this,this.data);
      }
      if (item.type === "stop") {TEX.Error("Missing \\end{"+this.name+"}")}
      return this.SUPER(arguments).checkItem.call(this,item);
    }
  });
  
  STACKITEM.end = STACKITEM.Subclass({
    type: "end", isClose: TRUE
  });

  STACKITEM.style = STACKITEM.Subclass({
    type: "style",
    checkItem: function (item) {
      if (!item.isClose) {return this.SUPER(arguments).checkItem.call(this,item)}
      var mml = MML.mstyle.apply(MML,this.data).With(this.styles);
      return [STACKITEM.mml(mml),item];
    }
  });
  
  STACKITEM.position = STACKITEM.Subclass({
    type: "position",
    checkItem: function (item) {
      if (item.isClose) {TEX.Error("Missing box for "+this.name)}
      if (item.isNotStack) {
        var mml = item.mmlData();
        switch (this.move) {
         case 'vertical':
          var mml = MML.mpadded(mml).With({height: this.dh, depth: this.dd, voffset: this.dh});
          return [STACKITEM.mml(mml)];
         case 'horizontal':
          return [STACKITEM.mml(this.left),item,STACKITEM.mml(this.right)];
        }
      }
      return this.SUPER(arguments).checkItem.call(this,item);
    }
  });
  
  STACKITEM.array = STACKITEM.Subclass({
    type: "array", isOpen: TRUE, arraydef: {},
    Init: function () {
      this.table = []; this.row = []; this.env = {};
      this.SUPER(arguments).Init.apply(this,arguments);
    },
    checkItem: function (item) {
      if (item.isClose) {
        if (item.isEntry) {this.EndEntry(); this.clearEnv(); return FALSE}
        if (item.isCR)    {this.EndEntry(); this.EndRow(); this.clearEnv(); return FALSE}
        this.EndTable(); this.clearEnv();
        var mml = MML.mtable.apply(MML,this.table).With(this.arraydef);
        if (this.open || this.close) {
          mml = MML.mfenced(mml).With({open: this.open, close: this.close});
        }
        mml = STACKITEM.mml(mml);
        if (this.requireClose) {
          if (item.type === 'close') {return mml}
          TEX.Error("Missing close brace");
        }
        return [mml,item];
      }
      return this.SUPER(arguments).checkItem.call(this,item);
    },
    EndEntry: function () {this.row.push(MML.mtd.apply(MML,this.data)); this.data = []},
    EndRow:   function () {this.table.push(MML.mtr.apply(MML,this.row)); this.row = []},
    EndTable: function () {
      if (this.data.length || this.row.length) {this.EndEntry(); this.EndRow()}
    },
    clearEnv: function () {
      for (var id in this.env) {if (this.env.hasOwnProperty(id)) {delete this.env[id]}}
    }
  });
  
  STACKITEM.cell = STACKITEM.Subclass({
    type: "cell", isClose: TRUE
  });

  STACKITEM.mml = STACKITEM.Subclass({
    type: "mml", isNotStack: TRUE,
    Push: function () {
      // embellished are type ORD in TeX (but not MML) so wrap them in TeXAtom
      for (var i = 0, m = arguments.length; i < m; i++) {
        if (arguments[i].type !== "mo" && arguments[i].isEmbellished())
          {arguments[i] = MML.TeXAtom(arguments[i]).With({isEmbellishedWrapper: TRUE})}
      }
      this.data.push.apply(this.data,arguments);
    },
    Add: function () {this.data.push.apply(this.data,arguments); return this}
  });
  

  var TEXDEF = TEX.Definitions = {};
  
  TEX.Startup = function () {
    MML = MathJax.ElementJax.mml;
    MathJax.Hub.Insert(TEXDEF,{
  
      // patterns for letters and numbers
      letter:  /[a-z]/i,
      digit:   /[0-9.]/,
      number:  /^(?:[0-9]+(?:\{,\}[0-9]{3})*(?:\.[0-9]*)*|\.[0-9]+)/,
    
      special: {
        '\\':  'ControlSequence',
        '{':   'Open',
        '}':   'Close',
        '~':   'Tilde',
        '^':   'Superscript',
        '_':   'Subscript',
        ' ':   'Space',
        "\t":  'Space',
        "\r":  'Space',
        "\n":  'Space',
        "'":   'Prime',
        '%':   'Comment',
        '&':   'Entry',
        '#':   'Hash',
        '\u2019': 'Prime'
      },
      
      remap: {
        '-':   '2212',
        '*':   '2217'
      },
    
      mathchar0mi: {
	// Lower-case greek
	alpha:        '03B1',
	beta:         '03B2',
	gamma:        '03B3',
	delta:        '03B4',
	epsilon:      '03F5',
	zeta:         '03B6',
	eta:          '03B7',
	theta:        '03B8',
	iota:         '03B9',
	kappa:        '03BA',
	lambda:       '03BB',
	mu:           '03BC',
	nu:           '03BD',
	xi:           '03BE',
	omicron:      '03BF', // added for completeness
	pi:           '03C0',
	rho:          '03C1',
	sigma:        '03C3',
	tau:          '03C4',
	upsilon:      '03C5',
	phi:          '03D5',
	chi:          '03C7',
	psi:          '03C8',
	omega:        '03C9',
	varepsilon:   '03B5',
	vartheta:     '03D1',
	varpi:        '03D6',
	varrho:       '03F1',
	varsigma:     '03C2',
	varphi:       '03C6',
        
        // Ord symbols
        S:            '00A7',
        aleph:        ['2135',{mathvariant: MML.VARIANT.NORMAL}],
        hbar:         '210F',
        imath:        '0131',
        jmath:        '0237',
        ell:          '2113',
        wp:           ['2118',{mathvariant: MML.VARIANT.NORMAL}],
        Re:           ['211C',{mathvariant: MML.VARIANT.NORMAL}],
        Im:           ['2111',{mathvariant: MML.VARIANT.NORMAL}],
        partial:      ['2202',{mathvariant: MML.VARIANT.NORMAL}],
        infty:        ['221E',{mathvariant: MML.VARIANT.NORMAL}],
        prime:        ['2032',{mathvariant: MML.VARIANT.NORMAL}],
        emptyset:     ['2205',{mathvariant: MML.VARIANT.NORMAL}],
        nabla:        ['2207',{mathvariant: MML.VARIANT.NORMAL}],
        top:          ['22A4',{mathvariant: MML.VARIANT.NORMAL}],
        bot:          ['22A5',{mathvariant: MML.VARIANT.NORMAL}],
        angle:        ['2220',{mathvariant: MML.VARIANT.NORMAL}],
        triangle:     ['25B3',{mathvariant: MML.VARIANT.NORMAL}],
        backslash:    ['2216',{mathvariant: MML.VARIANT.NORMAL}],
        forall:       ['2200',{mathvariant: MML.VARIANT.NORMAL}],
        exists:       ['2203',{mathvariant: MML.VARIANT.NORMAL}],
        neg:          ['00AC',{mathvariant: MML.VARIANT.NORMAL}],
        lnot:         ['00AC',{mathvariant: MML.VARIANT.NORMAL}],
        flat:         ['266D',{mathvariant: MML.VARIANT.NORMAL}],
        natural:      ['266E',{mathvariant: MML.VARIANT.NORMAL}],
        sharp:        ['266F',{mathvariant: MML.VARIANT.NORMAL}],
        clubsuit:     ['2663',{mathvariant: MML.VARIANT.NORMAL}],
        diamondsuit:  ['2662',{mathvariant: MML.VARIANT.NORMAL}],
        heartsuit:    ['2661',{mathvariant: MML.VARIANT.NORMAL}],
        spadesuit:    ['2660',{mathvariant: MML.VARIANT.NORMAL}]
      },
        
      mathchar0mo: {
        surd:         '221A',

        // big ops
        coprod:       ['2210',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        bigvee:       ['22C1',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        bigwedge:     ['22C0',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        biguplus:     ['2A04',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        bigcap:       ['22C2',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        bigcup:       ['22C3',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        'int':        ['222B',{texClass: MML.TEXCLASS.OP}],
        intop:        ['222B',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE, movablelimits:TRUE}],
        iint:         ['222C',{texClass: MML.TEXCLASS.OP}],
        iiint:        ['222D',{texClass: MML.TEXCLASS.OP}],
        prod:         ['220F',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        sum:          ['2211',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        bigotimes:    ['2A02',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        bigoplus:     ['2A01',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        bigodot:      ['2A00',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        oint:         ['222E',{texClass: MML.TEXCLASS.OP}],
        bigsqcup:     ['2A06',{texClass: MML.TEXCLASS.OP, movesupsub:TRUE}],
        smallint:     ['222B',{largeop:FALSE}],
        
        // binary operations
        triangleleft:      '25C3',
        triangleright:     '25B9',
        bigtriangleup:     '25B3',
        bigtriangledown:   '25BD',
        wedge:        '2227',
        land:         '2227',
        vee:          '2228',
        lor:          '2228',
        cap:          '2229',
        cup:          '222A',
        ddagger:      '2021',
        dagger:       '2020',
        sqcap:        '2293',
        sqcup:        '2294',
        uplus:        '228E',
        amalg:        '2A3F',
        diamond:      '22C4',
        bullet:       '2219',
        wr:           '2240',
        div:          '00F7',
        odot:         ['2299',{largeop: FALSE}],
        oslash:       ['2298',{largeop: FALSE}],
        otimes:       ['2297',{largeop: FALSE}],
        ominus:       ['2296',{largeop: FALSE}],
        oplus:        ['2295',{largeop: FALSE}],
        mp:           '2213',
        pm:           '00B1',
        circ:         '2218',
        bigcirc:      '25EF',
        setminus:     '2216',
        cdot:         '22C5',
        ast:          '2217',
        times:        '00D7',
        star:         '22C6',
        
        // Relations
        propto:       '221D',
        sqsubseteq:   '2291',
        sqsupseteq:   '2292',
        parallel:     '2225',
        mid:          '2223',
        dashv:        '22A3',
        vdash:        '22A2',
        leq:          '2264',
        le:           '2264',
        geq:          '2265',
        ge:           '2265',
        lt:           '003C',
        gt:           '003E',
        succ:         '227B',
        prec:         '227A',
        approx:       '2248',
        succeq:       '2AB0',  // or '227C',
        preceq:       '2AAF',  // or '227D',
        supset:       '2283',
        subset:       '2282',
        supseteq:     '2287',
        subseteq:     '2286',
        'in':         '2208',
        ni:           '220B',
        notin:        '2209',
        owns:         '220B',
        gg:           '226B',
        ll:           '226A',
        sim:          '223C',
        simeq:        '2243',
        perp:         '22A5',
        equiv:        '2261',
        asymp:        '224D',
        smile:        '2323',
        frown:        '2322',
        ne:           '2260',
        neq:          '2260',
        cong:         '2245',
        doteq:        '2250',
        bowtie:       '22C8',
        models:       '22A8',
        
        notChar:      '0338',
        
        
        // Arrows
        Leftrightarrow:     '21D4',
        Leftarrow:          '21D0',
        Rightarrow:         '21D2',
        leftrightarrow:     '2194',
        leftarrow:          '2190',
        gets:               '2190',
        rightarrow:         '2192',
        to:                 '2192',
        mapsto:             '21A6',
        leftharpoonup:      '21BC',
        leftharpoondown:    '21BD',
        rightharpoonup:     '21C0',
        rightharpoondown:   '21C1',
        nearrow:            '2197',
        searrow:            '2198',
        nwarrow:            '2196',
        swarrow:            '2199',
        rightleftharpoons:  '21CC',
        hookrightarrow:     '21AA',
        hookleftarrow:      '21A9',
        longleftarrow:      '27F5',
        Longleftarrow:      '27F8',
        longrightarrow:     '27F6',
        Longrightarrow:     '27F9',
        Longleftrightarrow: '27FA',
        longleftrightarrow: '27F7',
        longmapsto:         '27FC',
        
        
        // Misc.
        ldots:            '2026',
        cdots:            '22EF',
        vdots:            '22EE',
        ddots:            '22F1',
        dots:             '2026',  // should be more complex than this
        dotsc:            '2026',  // dots with commas
        dotsb:            '22EF',  // dots with binary ops and relations
        dotsm:            '22EF',  // dots with multiplication
        dotsi:            '22EF',  // dots with integrals
        dotso:            '2026',  // other dots
        
        ldotp:            ['002E', {texClass: MML.TEXCLASS.PUNCT}],
        cdotp:            ['22C5', {texClass: MML.TEXCLASS.PUNCT}],
        colon:            ['003A', {texClass: MML.TEXCLASS.PUNCT}]
      },
      
      mathchar7: {
        Gamma:        '0393',
        Delta:        '0394',
        Theta:        '0398',
        Lambda:       '039B',
        Xi:           '039E',
        Pi:           '03A0',
        Sigma:        '03A3',
        Upsilon:      '03A5',
        Phi:          '03A6',
        Psi:          '03A8',
        Omega:        '03A9',
        
        '_':          '005F',
        '#':          '0023',
        '$':          '0024',
        '%':          '0025',
        '&':          '0026',
        And:          '0026'
      },
      
      delimiter: {
        '(':                '(',
        ')':                ')',
        '[':                '[',
        ']':                ']',
        '<':                '27E8',
        '>':                '27E9',
        '\\lt':             '27E8',
        '\\gt':             '27E9',
        '/':                '/',
        '|':                ['|',{texClass:MML.TEXCLASS.ORD}],
        '.':                '',
        '\\\\':             '\\',
        '\\lmoustache':     '23B0',  // non-standard
        '\\rmoustache':     '23B1',  // non-standard
        '\\lgroup':         '27EE',  // non-standard
        '\\rgroup':         '27EF',  // non-standard
        '\\arrowvert':      '23D0',
        '\\Arrowvert':      '2016',
        '\\bracevert':      '23AA',  // non-standard
        '\\Vert':           ['2225',{texClass:MML.TEXCLASS.ORD}],
        '\\|':              ['2225',{texClass:MML.TEXCLASS.ORD}],
        '\\vert':           ['|',{texClass:MML.TEXCLASS.ORD}],
        '\\uparrow':        '2191',
        '\\downarrow':      '2193',
        '\\updownarrow':    '2195',
        '\\Uparrow':        '21D1',
        '\\Downarrow':      '21D3',
        '\\Updownarrow':    '21D5',
        '\\backslash':      '\\',
        '\\rangle':         '27E9',
        '\\langle':         '27E8',
        '\\rbrace':         '}',
        '\\lbrace':         '{',
        '\\}':              '}',
        '\\{':              '{',
        '\\rceil':          '2309',
        '\\lceil':          '2308',
        '\\rfloor':         '230B',
        '\\lfloor':         '230A',
        '\\lbrack':         '[',
        '\\rbrack':         ']'
      },
      
      macros: {
        displaystyle:      ['SetStyle','D',TRUE,0],
        textstyle:         ['SetStyle','T',FALSE,0],
        scriptstyle:       ['SetStyle','S',FALSE,1],
        scriptscriptstyle: ['SetStyle','SS',FALSE,2],
        
        rm:                ['SetFont',MML.VARIANT.NORMAL],
        mit:               ['SetFont',MML.VARIANT.ITALIC],
        oldstyle:          ['SetFont',MML.VARIANT.OLDSTYLE],
        cal:               ['SetFont',MML.VARIANT.CALIGRAPHIC],
        it:                ['SetFont',MML.VARIANT.ITALIC], // may need special handling
        bf:                ['SetFont',MML.VARIANT.BOLD],
        bbFont:            ['SetFont',MML.VARIANT.DOUBLESTRUCK],
        scr:               ['SetFont',MML.VARIANT.SCRIPT],
        frak:              ['SetFont',MML.VARIANT.FRAKTUR],
        sf:                ['SetFont',MML.VARIANT.SANSSERIF],
        tt:                ['SetFont',MML.VARIANT.MONOSPACE],

//      font:
        
        tiny:              ['SetSize',0.5],
        Tiny:              ['SetSize',0.6],  // non-standard
        scriptsize:        ['SetSize',0.7],
        small:             ['SetSize',0.85],
        normalsize:        ['SetSize',1.0],
        large:             ['SetSize',1.2],
        Large:             ['SetSize',1.44],
        LARGE:             ['SetSize',1.73],
        huge:              ['SetSize',2.07],
        Huge:              ['SetSize',2.49],
        
        arcsin:            ['NamedOp',0],
        arccos:            ['NamedOp',0],
        arctan:            ['NamedOp',0],
        arg:               ['NamedOp',0],
        cos:               ['NamedOp',0],
        cosh:              ['NamedOp',0],
        cot:               ['NamedOp',0],
        coth:              ['NamedOp',0],
        csc:               ['NamedOp',0],
        deg:               ['NamedOp',0],
        det:                'NamedOp',
        dim:               ['NamedOp',0],
        exp:               ['NamedOp',0],
        gcd:                'NamedOp',
        hom:               ['NamedOp',0],
        inf:                'NamedOp',
        ker:               ['NamedOp',0],
        lg:                ['NamedOp',0],
        lim:                'NamedOp',
        liminf:            ['NamedOp',null,'lim&thinsp;inf'],
        limsup:            ['NamedOp',null,'lim&thinsp;sup'],
        ln:                ['NamedOp',0],
        log:               ['NamedOp',0],
        max:                'NamedOp',
        min:                'NamedOp',
        Pr:                 'NamedOp',
        sec:               ['NamedOp',0],
        sin:               ['NamedOp',0],
        sinh:              ['NamedOp',0],
        sup:                'NamedOp',
        tan:               ['NamedOp',0],
        tanh:              ['NamedOp',0],
        
        limits:            ['Limits',1],
        nolimits:          ['Limits',0],

        overline:            ['UnderOver','203E'],
        underline:           ['UnderOver','005F'],
        overbrace:           ['UnderOver','23DE',1],
        underbrace:          ['UnderOver','23DF',1],
        overrightarrow:      ['UnderOver','2192'],
        underrightarrow:     ['UnderOver','2192'],
        overleftarrow:       ['UnderOver','2190'],
        underleftarrow:      ['UnderOver','2190'],
        overleftrightarrow:  ['UnderOver','2194'],
        underleftrightarrow: ['UnderOver','2194'],

        overset:            'Overset',
        underset:           'Underset',
        stackrel:           ['Macro','\\mathrel{\\mathop{#2}\\limits^{#1}}',2],
          
        over:               'Over',
        overwithdelims:     'Over',
        atop:               'Over',
        atopwithdelims:     'Over',
        above:              'Over',
        abovewithdelims:    'Over',
        brace:             ['Over','{','}'],
        brack:             ['Over','[',']'],
        choose:            ['Over','(',')'],
        
        frac:               'Frac',
        sqrt:               'Sqrt',
        root:               'Root',
        uproot:            ['MoveRoot','upRoot'],
        leftroot:          ['MoveRoot','leftRoot'],
        
        left:               'LeftRight',
        right:              'LeftRight',

        llap:               'Lap',
        rlap:               'Lap',
        raise:              'RaiseLower',
        lower:              'RaiseLower',
        moveleft:           'MoveLeftRight',
        moveright:          'MoveLeftRight',

        ',':               ['Spacer',MML.LENGTH.THINMATHSPACE],
        ':':               ['Spacer',MML.LENGTH.THINMATHSPACE],  // for LaTeX
        '>':               ['Spacer',MML.LENGTH.MEDIUMMATHSPACE],
        ';':               ['Spacer',MML.LENGTH.THICKMATHSPACE],
        '!':               ['Spacer',MML.LENGTH.NEGATIVETHINMATHSPACE],
        enspace:           ['Spacer',".5em"],
        quad:              ['Spacer',"1em"],
        qquad:             ['Spacer',"2em"],
        thinspace:         ['Spacer',MML.LENGTH.THINMATHSPACE],
        negthinspace:      ['Spacer',MML.LENGTH.NEGATIVETHINMATHSPACE],
    
        hskip:              'Hskip',
        hspace:             'Hskip',
        kern:               'Hskip',
        mskip:              'Hskip',
        mspace:             'Hskip',
        mkern:              'Hskip',
        Rule:              ['Rule'],
        Space:             ['Rule','blank'],
    
        big:               ['MakeBig',MML.TEXCLASS.ORD,0.85],
        Big:               ['MakeBig',MML.TEXCLASS.ORD,1.15],
        bigg:              ['MakeBig',MML.TEXCLASS.ORD,1.45],
        Bigg:              ['MakeBig',MML.TEXCLASS.ORD,1.75],
        bigl:              ['MakeBig',MML.TEXCLASS.OPEN,0.85],
        Bigl:              ['MakeBig',MML.TEXCLASS.OPEN,1.15],
        biggl:             ['MakeBig',MML.TEXCLASS.OPEN,1.45],
        Biggl:             ['MakeBig',MML.TEXCLASS.OPEN,1.75],
        bigr:              ['MakeBig',MML.TEXCLASS.CLOSE,0.85],
        Bigr:              ['MakeBig',MML.TEXCLASS.CLOSE,1.15],
        biggr:             ['MakeBig',MML.TEXCLASS.CLOSE,1.45],
        Biggr:             ['MakeBig',MML.TEXCLASS.CLOSE,1.75],
        bigm:              ['MakeBig',MML.TEXCLASS.REL,0.85],
        Bigm:              ['MakeBig',MML.TEXCLASS.REL,1.15],
        biggm:             ['MakeBig',MML.TEXCLASS.REL,1.45],
        Biggm:             ['MakeBig',MML.TEXCLASS.REL,1.75],

        mathord:           ['TeXAtom',MML.TEXCLASS.ORD],
        mathop:            ['TeXAtom',MML.TEXCLASS.OP],
        mathopen:          ['TeXAtom',MML.TEXCLASS.OPEN],
        mathclose:         ['TeXAtom',MML.TEXCLASS.CLOSE],
        mathbin:           ['TeXAtom',MML.TEXCLASS.BIN],
        mathrel:           ['TeXAtom',MML.TEXCLASS.REL],
        mathpunct:         ['TeXAtom',MML.TEXCLASS.PUNCT],
        mathinner:         ['TeXAtom',MML.TEXCLASS.INNER],

        vcenter:           ['TeXAtom',MML.TEXCLASS.VCENTER],

        mathchoice:        ['Extension','mathchoice'],
        buildrel:           'BuildRel',
    
        hbox:               ['HBox',0],
        text:               'HBox',
        mbox:               ['HBox',0],
        fbox:               'FBox',

        strut:              'Strut',
        mathstrut:         ['Macro','\\vphantom{(}'],
        phantom:            'Phantom',
        vphantom:          ['Phantom',1,0],
        hphantom:          ['Phantom',0,1],
        smash:              'Smash',
    
        acute:             ['Accent', "02CA"],  // or 0301
        grave:             ['Accent', "02CB"],  // or 0300
        ddot:              ['Accent', "00A8"],  // or 0308
        tilde:             ['Accent', "02DC"],  // or 0303
        bar:               ['Accent', "02C9"],  // or 0304
        breve:             ['Accent', "02D8"],  // or 0306
        check:             ['Accent', "02C7"],  // or 030C
        hat:               ['Accent', "02C6"],  // or 0302
        vec:               ['Accent', "20D7"],
        dot:               ['Accent', "02D9"],  // or 0307
        widetilde:         ['Accent', "02DC",1], // or 0303
        widehat:           ['Accent', "02C6",1], // or 0302

        matrix:             'Matrix',
        array:              'Matrix',
        pmatrix:           ['Matrix','(',')'],
        cases:             ['Matrix','{','',"left left",null,".1em"],
        eqalign:           ['Matrix',null,null,"right left",MML.LENGTH.THICKMATHSPACE,".5em",'D'],
        displaylines:      ['Matrix',null,null,"center",null,".5em",'D'],
        cr:                 'Cr',
        '\\':               'Cr',
        newline:            'Cr',
//      noalign:            'HandleNoAlign',
        eqalignno:         ['Matrix',null,null,"right left right",MML.LENGTH.THICKMATHSPACE+" 3em",".5em",'D'],
        leqalignno:        ['Matrix',null,null,"right left right",MML.LENGTH.THICKMATHSPACE+" 3em",".5em",'D'],

        //  TeX substitution macros
        bmod:              ['Macro','\\mathbin{\\rm mod}'],
        pmod:              ['Macro','\\pod{{\\rm mod}\\kern 6mu #1}',1],
        mod:               ['Macro','\\mathchoice{\\kern18mu}{\\kern12mu}{\\kern12mu}{\\kern12mu}{\\rm mod}\\,\\,#1',1],
        pod:               ['Macro','\\mathchoice{\\kern18mu}{\\kern8mu}{\\kern8mu}{\\kern8mu}(#1)',1],
        iff:               ['Macro','\\;\\Longleftrightarrow\\;'],
        skew:              ['Macro','{{#2{#3\\mkern#1mu}\\mkern-#1mu}{}}',3],
        mathcal:           ['Macro','{\\cal #1}',1],
        mathscr:           ['Macro','{\\scr #1}',1],
        mathrm:            ['Macro','{\\rm #1}',1],
        mathbf:            ['Macro','{\\bf #1}',1],
        mathbb:            ['Macro','{\\bbFont #1}',1],
        Bbb:               ['Macro','{\\bbFont #1}',1],
        mathit:            ['Macro','{\\it #1}',1],
        mathfrak:          ['Macro','{\\frak #1}',1],
        mathsf:            ['Macro','{\\sf #1}',1],
        mathtt:            ['Macro','{\\tt #1}',1],
        textrm:            ['Macro','\\mathord{\\rm\\text{#1}}',1],
        textit:            ['Macro','\\mathord{\\it{\\text{#1}}}',1],
        textbf:            ['Macro','\\mathord{\\bf{\\text{#1}}}',1],
        pmb:               ['Macro','\\rlap{#1}\\kern1px{#1}',1],
        TeX:               ['Macro','T\\kern-.14em\\lower.5ex{E}\\kern-.115em X'],
        LaTeX:             ['Macro','L\\kern-.325em\\raise.21em{\\scriptstyle{A}}\\kern-.17em\\TeX'],
        not:               ['Macro','\\mathrel{\\rlap{\\kern.5em\\notChar}}'],
        ' ':               ['Macro','\\text{ }'],
        space:              'Tilde',
        

        //  LaTeX
        begin:              'Begin',
        end:                'End',

        newcommand:        ['Extension','newcommand'],
        newenvironment:    ['Extension','newcommand'],
        def:               ['Extension','newcommand'],
        
        verb:              ['Extension','verb'],
        
        boldsymbol:        ['Extension','boldsymbol'],
        
        tag:               ['Extension','AMSmath'],
        notag:             ['Extension','AMSmath'],
        label:             ['Macro','',1],           // not implemented yet
        nonumber:          ['Macro',''],             // not implemented yet

        //  Extensions to TeX
        unicode:    ['Extension','unicode'],
        color:      'Color',
        
//      href:       ['Extension','HTML'],
//      'class':    ['Extension','HTML'],
//      style:      ['Extension','HTML'],
//      cssId:      ['Extension','HTML'],
//      bbox:       ['Extension','bbox'],
    
        require:            'Require'

      },
      
      environment: {
        array:        ['Array'],
        matrix:       ['Array',null,null,null,'c'],
        pmatrix:      ['Array',null,'(',')','c'],
        bmatrix:      ['Array',null,'[',']','c'],
        Bmatrix:      ['Array',null,'\\{','\\}','c'],
        vmatrix:      ['Array',null,'\\vert','\\vert','c'],
        Vmatrix:      ['Array',null,'\\Vert','\\Vert','c'],
        cases:        ['Array',null,'\\{','.','ll',null,".1em"],
        eqnarray:     ['Array',null,null,null,'rcl',MML.LENGTH.THICKMATHSPACE,".5em",'D'],
        'eqnarray*':  ['Array',null,null,null,'rcl',MML.LENGTH.THICKMATHSPACE,".5em",'D'],

        equation:     [null,'Equation'],
        'equation*':  [null,'Equation'],

        align:        ['ExtensionEnv',null,'AMSmath'],
        'align*':     ['ExtensionEnv',null,'AMSmath'],
        aligned:      ['ExtensionEnv',null,'AMSmath'],
        multline:     ['ExtensionEnv',null,'AMSmath'],
        'multline*':  ['ExtensionEnv',null,'AMSmath'],
        split:        ['ExtensionEnv',null,'AMSmath'],
        gather:       ['ExtensionEnv',null,'AMSmath'],
        'gather*':    ['ExtensionEnv',null,'AMSmath'],
        gathered:     ['ExtensionEnv',null,'AMSmath'],
        alignat:      ['ExtensionEnv',null,'AMSmath'],
        'alignat*':   ['ExtensionEnv',null,'AMSmath'],
        alignedat:    ['ExtensionEnv',null,'AMSmath']
      },
      
      p_height: 1.2 / .85   // cmex10 height plus depth over .85

    });
  };
  
  /************************************************************************/
  /*
   *   The TeX Parser
   */

  TEX.Parse = MathJax.Object.Subclass({
    Init: function (string,env) {
      this.string = string; this.i = 0;
      var ENV; if (env) {ENV = {}; for (var id in env) {if (env.hasOwnProperty(id)) {ENV[id] = env[id]}}}
      this.stack = TEX.Stack(ENV);
      this.Parse();
      this.Push(STACKITEM.stop());
    },
    Parse: function () {
      var c;
      while (this.i < this.string.length) {
        c = this.string.charAt(this.i++);
        if (TEXDEF.special[c]) {this[TEXDEF.special[c]](c)}
        else if (TEXDEF.letter.test(c)) {this.Variable(c)}
        else if (TEXDEF.digit.test(c)) {this.Number(c)}
        else {this.Other(c)}
      }
    },
    Push: function () {this.stack.Push.apply(this.stack,arguments)},
    mml: function () {
      if (this.stack.Top().type !== "mml") {return null}
      return this.stack.Top().data[0];
    },
    mmlToken: function (token) {return token}, // used by boldsymbol extension
    
    /************************************************************************/
    /*
     *   Handle various token classes
     */

    /*
     *  Lookup a control-sequence and process it
     */
    ControlSequence: function (c) {
      var name = this.GetCS();
      if (TEXDEF.macros[name]) {                                  // javascript macro
        var macro = TEXDEF.macros[name];
        if (!(macro instanceof Array)) {macro = [macro]}
        var fn = macro[0]; if (!(fn instanceof Function)) {fn = this[fn]}
        fn.apply(this,["\\"+name].concat(macro.slice(1)));
      } else if (TEXDEF.mathchar0mi[name]) {                      // normal mathchar (mi)
        var mchar = TEXDEF.mathchar0mi[name]; var def = {mathvariant: MML.VARIANT.ITALIC};
        if (mchar instanceof Array) {def = mchar[1]; mchar = mchar[0]}
        this.Push(this.mmlToken(MML.mi(MML.entity("#x"+mchar)).With(def)));
      } else if (TEXDEF.mathchar0mo[name]) {                      // normal mathchar (mo)
        var mchar = TEXDEF.mathchar0mo[name]; var def = {stretchy: FALSE};
        if (mchar instanceof Array) {def = mchar[1]; def.stretchy = FALSE; mchar = mchar[0]}
        this.Push(this.mmlToken(MML.mo(MML.entity("#x"+mchar)).With(def)));
      } else if (TEXDEF.mathchar7[name]) {                        // mathchar in current family
        var mchar = TEXDEF.mathchar7[name]; var def = {mathvariant: MML.VARIANT.NORMAL};
        if (mchar instanceof Array) {def = mchar[1]; mchar = mchar[0]}
        if (this.stack.env.font) {def.mathvariant = this.stack.env.font}
        this.Push(this.mmlToken(MML.mi(MML.entity("#x"+mchar)).With(def)));
      } else if (TEXDEF.delimiter["\\"+name] != null) {           // delimiter
        var delim = TEXDEF.delimiter["\\"+name], def = {};
        if (delim instanceof Array) {def = delim[1]; delim = delim[0]}
        if (delim.length === 4) {delim = MML.entity('#x'+delim)} else {delim = MML.chars(delim)}
        this.Push(this.mmlToken(MML.mo(delim).With({fence: FALSE, stretchy: FALSE}).With(def)));
      } else {                                                    // error
        TEX.Error("Undefined control sequence \\"+name);
      }
    },

    /*
     *  Handle a variable (a single letter)
     */
    Variable: function (c) {
      var def = {}; if (this.stack.env.font) {def.mathvariant = this.stack.env.font}
      this.Push(this.mmlToken(MML.mi(MML.chars(c)).With(def)));
    },

    /*
     *  Determine the extent of a number (pattern may need work)
     */
    Number: function (c) {
      var mml, n = this.string.slice(this.i-1).match(TEXDEF.number);
      if (n) {mml = MML.mn(n[0].replace(/[{}]/g,"")); this.i += n[0].length - 1}
        else {mml = MML.mo(MML.chars(c))}
      if (this.stack.env.font) {mml.mathvariant = this.stack.env.font}
      this.Push(this.mmlToken(mml));
    },
    
    /*
     *  Handle { and }
     */
    Open: function (c) {this.Push(STACKITEM.open())},
    Close: function (c) {this.Push(STACKITEM.close())},
    
    /*
     *  Handle tilde and spaces
     */
    Tilde: function (c) {this.Push(MML.mtext(MML.chars(" ")))},
    Space: function (c) {},
    
    /*
     *  Handle ^, _, and '
     */
    Superscript: function (c) {
      var position, base = this.stack.Prev(); if (!base) {base = MML.mi("")}
      if (base.isEmbellishedWrapper) {base = base.data[0].data[0]}
      if (base.type === "msubsup") {
        if (base.data[base.sup]) {
          if (!base.data[base.sup].isPrime) {TEX.Error("Double exponent: use braces to clarify")}
          base = MML.msubsup(base,null,null);
        }
        position = base.sup;
      } else if (base.movesupsub) {
        if (base.type !== "munderover" || base.data[base.over])
          {base = MML.munderover(base,null,null).With({movesupsub:TRUE})}
        position = base.over;
      } else {
        base = MML.msubsup(base,null,null);
        position = base.sup;
      }
      this.Push(STACKITEM.subsup(base).With({position: position}));
    },
    Subscript: function (c) {
      var position, base = this.stack.Prev(); if (!base) {base = MML.mi("")}
      if (base.isEmbellishedWrapper) {base = base.data[0].data[0]}
      if (base.type === "msubsup") {
        if (base.data[base.sub]) {TEX.Error("Double subscripts: use braces to clarify")}
        position = base.sub;
      } else if (base.movesupsub) {
        if (base.type !== "munderover" || base.data[base.under])
          {base = MML.munderover(base,null,null).With({movesupsub:TRUE})}
        position = base.under;
      } else {
        base = MML.msubsup(base,null,null);
        position = base.sub;
      }
      this.Push(STACKITEM.subsup(base).With({position: position}));
    },
    PRIME: String.fromCharCode(0x2032), SMARTQUOTE: String.fromCharCode(0x2019),
    Prime: function (c) {
      var base = this.stack.Prev(); if (!base) {base = MML.mi()}
      if (base.type === "msubsup" && base.data[base.sup])
        {TEX.Error("Prime causes double exponent: use braces to clarify")}
      var sup = ""; this.i--;
      do {sup += this.PRIME; this.i++, c = this.GetNext()}
        while (c === "'" || c === this.SMARTQUOTE);
      sup = this.mmlToken(MML.mo(MML.chars(sup)).With({isPrime: TRUE, variantForm: TEX.isSTIX}));
      this.Push(MML.msubsup(base,null,sup));
    },
    
    /*
     *  Handle comments
     */
    Comment: function (c) {
      while (this.i < this.string.length && this.string.charAt(this.i) != "\n") {this.i++}
    },
    
    /*
     *  Handle hash marks outside of definitions
     */
    Hash: function (c) {
      TEX.Error("You can't use 'macro parameter character #' in math mode");
    },
    
    /*
     *  Handle other characters (as <mo> elements)
     */
    Other: function (c) {
      var def = {stretchy: false}, mo;
      if (this.stack.env.font) {def.mathvariant = this.stack.env.font}
      if (TEXDEF.remap[c]) {
        c = TEXDEF.remap[c];
        if (c instanceof Array) {def = c[1]; c = c[0]}
        mo = MML.mo(MML.entity('#x'+c));
      } else {
        mo = MML.mo(c);
      }
      if (mo.autoDefault("texClass",true) == "") {mo = MML.TeXAtom(mo)}
      this.Push(this.mmlToken(mo.With(def)));
    },
    
    /************************************************************************/
    /*
     *   Macros
     */
    
    SetFont: function (name,font) {this.stack.env.font = font},
    SetStyle: function (name,texStyle,style,level) {
      this.stack.env.style = texStyle; this.stack.env.level = level;
      this.Push(STACKITEM.style().With({styles: {displaystyle: style, scriptlevel: level}}));
    },
    SetSize: function (name,size) {
      this.stack.env.size = size;
      this.Push(STACKITEM.style().With({styles: {mathsize: size+"em"}})); // convert to absolute?
    },

    Color: function (name) {
      var color = this.GetArgument(name);
      var old = this.stack.env.color; this.stack.env.color = color;
      var math = this.ParseArg(name);
      if (old) {this.stack.env.color} else {delete this.stack.env.color}
      this.Push(MML.mstyle(math).With({mathcolor: color}));
    },
    
    Spacer: function (name,space) {
      this.Push(MML.mspace().With({width: space, mathsize: MML.SIZE.NORMAL, scriptlevel:1}));
    },
    
    LeftRight: function (name) {
      this.Push(STACKITEM[name.substr(1)]().With({delim: this.GetDelimiter(name)}));
    },
    
    NamedOp: function (name,limits,id) {
      var underover = (limits != null && limits === 0 ? FALSE : TRUE);
      if (!id) {id = name.substr(1)}; limits = ((limits || limits == null) ? TRUE : FALSE);
      id = id.replace(/&thinsp;/,String.fromCharCode(0x2006));
      var mml = MML.mo(id).With({
        movablelimits: limits,
        movesupsub: underover,
        form: MML.FORM.PREFIX,
        texClass: MML.TEXCLASS.OP
      });
      mml.useMMLspacing &= ~mml.SPACE_ATTR.form;  // don't count this explicit form setting
      this.Push(this.mmlToken(mml));
    },
    Limits: function (name,limits) {
      var op = this.stack.Prev("nopop");
      if (op.texClass !== MML.TEXCLASS.OP) {TEX.Error(name+" is allowed only on operators")}
      op.movesupsub = (limits ? TRUE : FALSE);
      op.movablelimits = FALSE;
    },
    
    Over: function (name,open,close) {
      var mml = STACKITEM.over().With({name: name});
      if (open || close) {
        mml.open = open; mml.close = close;
      } else if (name.match(/withdelims$/)) {
        mml.open  = this.GetDelimiter(name);
        mml.close = this.GetDelimiter(name);
      }
      if (name.match(/^\\above/)) {mml.thickness = this.GetDimen(name)}
      else if (name.match(/^\\atop/) || open || close) {mml.thickness = 0}
      this.Push(mml);
    },

    Frac: function (name) {
      var num = this.ParseArg(name);
      var den = this.ParseArg(name);
      this.Push(MML.mfrac(num,den));
    },

    Sqrt: function (name) {
      var n = this.GetBrackets(name), mml = this.ParseArg(name);
      if (n == "") {mml = MML.msqrt.apply(MML,mml.array())}
              else {mml = MML.mroot(mml,this.parseRoot(n))}
      this.Push(mml);
    },
    Root: function (name) {
      var n = this.GetUpTo(name,"\\of");
      var arg = this.ParseArg(name);
      this.Push(MML.mroot(arg,this.parseRoot(n)));
    },
    parseRoot: function (n) {
      var env = this.stack.env, inRoot = env.inRoot; env.inRoot = true;
      var parser = TEX.Parse(n,env); n = parser.mml(); var global = parser.stack.global;
      if (global.leftRoot || global.upRoot) {
        n = MML.mpadded(n);
        if (global.leftRoot) {n.width = global.leftRoot}
        if (global.upRoot) {n.voffset = global.upRoot; n.height = global.upRoot}
      }
      env.inRoot = inRoot;
      return n;
    },
    MoveRoot: function (name,id) {
      if (!this.stack.env.inRoot) TEX.Error(name+" can appear only within a root");
      if (this.stack.global[id]) TEX.Error("Multiple use of "+name);
      var n = this.GetArgument(name);
      if (!n.match(/-?[0-9]+/)) TEX.Error("The argument to "+name+" must be an integer");
      n = (n/15)+"em";
      if (n.substr(0,1) !== "-") {n = "+"+n}
      this.stack.global[id] = n;
    },
    
    Accent: function (name,accent,stretchy) {
      var c = this.ParseArg(name);
      var mml = this.mmlToken(MML.mo(MML.entity("#x"+accent)).With({accent: TRUE}));
      mml.stretchy = (stretchy ? TRUE : FALSE);
      this.Push(MML.munderover(c,null,mml).With({accent: TRUE}));
    },
    
    UnderOver: function (name,c,stack) {
      var pos = {o: "over", u: "under"}[name.charAt(1)];
      var base = this.ParseArg(name);
      var mml = MML.munderover(base,null,null);
      if (stack) {mml.movesupsub = TRUE}
      mml.data[mml[pos]] = 
        this.mmlToken(MML.mo(MML.entity("#x"+c)).With({stretchy: TRUE, accent: (pos == "under")}));
      this.Push(mml);
    },
    
    Overset: function (name) {
      var top = this.ParseArg(name), base = this.ParseArg(name);
      this.Push(MML.munderover(base,null,top));
    },
    Underset: function (name) {
      var bot = this.ParseArg(name), base = this.ParseArg(name);
      this.Push(MML.munderover(base,bot,null));
    },
    
    TeXAtom: function (name,mclass) {
      var def = {texClass: mclass};
      if (mclass == MML.TEXCLASS.OP) {def.movesupsub = def.movablelimits = TRUE}
      this.Push(MML.TeXAtom(this.ParseArg(name)).With(def));
    },
    
    Strut: function (name) {
      this.Push(MML.mpadded().With({height: "8.6pt", depth: "3pt", width: 0}));
    },
    
    Phantom: function (name,v,h) {
      var box = MML.mphantom(this.ParseArg(name));
      if (v || h) {
        box = MML.mpadded(box);
        if (h) {box.height = box.depth = 0}
        if (v) {box.width = 0}
      }
      this.Push(box);
    },
    
    Smash: function (name) {
      var bt = this.trimSpaces(this.GetBrackets(name));
      var smash = MML.mpadded(this.ParseArg(name));
      switch (bt) {
        case "b": smash.depth = 0; break;
        case "t": smash.height = 0; break;
        default: smash.height = smash.depth = 0;
      }
      this.Push(smash);
    },
    
    Lap: function (name) {
      var mml = MML.mpadded(this.ParseArg(name)).With({width: 0});
      if (name === "\\llap") {mml.lspace = "-1 width"}
      this.Push(mml);
    },
    
    RaiseLower: function (name) {
      var h = this.GetDimen(name);
      var item = STACKITEM.position().With({name: name, move: 'vertical'});
      if (h.charAt(0) === '-') {h = h.slice(1); name = {raise: "\\lower", lower: "\\raise"}[name.substr(1)]}
      if (name === "\\lower") {item.dh = '-'+h; item.dd = h} else {item.dh = h; item.dd = '-'+h}
      this.Push(item);
    },
    
    MoveLeftRight: function (name) {
      var h = this.GetDimen(name);
      var nh = (h.charAt(0) === '-' ? h.slice(1) : '-'+h);
      if (name === "\\moveleft") {var tmp = h; h = nh; nh = tmp}
      this.Push(STACKITEM.position().With({
        name: name, move: 'horizontal',
        left:  MML.mspace().With({width: h, mathsize: MML.SIZE.NORMAL, scriptlevel:1}),
        right: MML.mspace().With({width: nh, mathsize: MML.SIZE.NORMAL, scriptlevel:1})
      }));
    },
    
    Hskip: function (name) {
      this.Push(MML.mspace().With({
        width: this.GetDimen(name), mathsize: MML.SIZE.NORMAL, scriptlevel:0
      }));
    },
    
    Rule: function (name,style) {
      var w = this.GetDimen(name),
          h = this.GetDimen(name),
          d = this.GetDimen(name);
      var mml, type = "mspace", def = {width:w, height:h, depth:d};
      if (style !== 'blank') {
        def.mathbackground = (this.stack.env.color || "black");
        type = "mpadded";
      }
      mml = (MML[type])().With(def);
      this.Push(mml);
    },
    
    MakeBig: function (name,mclass,size) {
      size *= TEXDEF.p_height;
      size = String(size).replace(/(\.\d\d\d).+/,'$1')+"em";
      var delim = this.GetDelimiter(name);
      this.Push(MML.TeXAtom(MML.mo(delim).With({
        minsize: size, maxsize: size, scriptlevel: 0,
        fence: TRUE, stretchy: TRUE, symmetric: TRUE
      })).With({texClass: mclass}));
    },
    
    BuildRel: function (name) {
      var top = this.ParseUpTo(name,"\\over");
      var bot = this.ParseArg(name);
      this.Push(MML.TeXAtom(MML.munderover(bot,null,top)).With({mclass: MML.TEXCLASS.REL}));
    },
    
    HBox: function (name,style) {
      this.Push.apply(this,this.InternalMath(this.GetArgument(name),style));
    },
    
    FBox: function (name) {
      this.Push(MML.menclose.apply(MML,this.InternalMath(this.GetArgument(name))));
    },
    
    Require: function (name) {
      var file = this.GetArgument(name); // @@@ FIXME: check for OK URL
      this.Extension(null,file);
    },
    
    Extension: function (name,file,array) {
      if (name && !typeof(name) === "string") {name = name.name}
      file = TEX.extensionDir+"/"+file;
      if (!file.match(/\.js$/)) {file += ".js"}
      if (!MathJax.Ajax.loaded[MathJax.Ajax.fileURL(file)]) {
        if (name != null) {delete TEXDEF[array || 'macros'][name.replace(/^\\/,"")]}
        MathJax.Hub.RestartAfter(MathJax.Ajax.Require(file));
      }
    },
    
    Macro: function (name,macro,argcount) {
      if (argcount) {
        var args = [];
        for (var i = 0; i < argcount; i++) {args.push(this.GetArgument(name))}
        macro = this.SubstituteArgs(args,macro);
      }
      this.string = this.AddArgs(macro,this.string.slice(this.i));
      this.i = 0;
    },
    
    Matrix: function (name,open,close,align,spacing,vspacing,style) {
      var c = this.GetNext(); if (c === "") {TEX.Error("Missing argument for "+name)}
      if (c === "{") {this.i++} else {this.string = c+"}"+this.string.slice(this.i+1); this.i = 0}
      var array = STACKITEM.array().With({
        requireClose: TRUE,
        arraydef: {
          rowspacing: (vspacing||"3pt"),
          columnspacing: (spacing||"1em")
        }
      });
      if (open || close)    {array.open = open; array.close = close}
      if (style === "D")    {array.arraydef.displaystyle = TRUE}
      if (align != null)    {array.arraydef.columnalign = align}
      this.Push(array);
    },
    
    Entry: function (name) {
      this.Push(STACKITEM.cell().With({isEntry: TRUE, name: name}));
    },
    
    Cr: function (name) {
      this.Push(STACKITEM.cell().With({isCR: TRUE, name: name}));
    },
    
   /************************************************************************/
   /*
    *   LaTeX environments
    */

    Begin: function (name) {
      var env = this.GetArgument(name);
      if (env.match(/[^a-z*]/i)) {TEX.Error('Invalid environment name "'+env+'"')}
      if (!TEXDEF.environment[env]) {TEX.Error('Unknown environment "'+env+'"')}
      var cmd = TEXDEF.environment[env]; if (!(cmd instanceof Array)) {cmd = [cmd]}
      var mml = STACKITEM.begin().With({name: env, end: cmd[1], parse:this});
      if (cmd[0] && this[cmd[0]]) {mml = this[cmd[0]].apply(this,[mml].concat(cmd.slice(2)))}
      this.Push(mml);
    },
    End: function (name) {
      this.Push(STACKITEM.end().With({name: this.GetArgument(name)}));
    },
    
    Equation: function (begin,row) {return row},
    
    ExtensionEnv: function (begin,file) {this.Extension(begin.name,file,"environment")},
    
    Array: function (begin,open,close,align,spacing,vspacing,style,raggedHeight) {
      if (!align) {align = this.GetArgument("\\begin{"+begin.name+"}")}
      var lines = align.replace(/[^clr|]/g,'').replace(/[^|]\|/g,'|').split('').join(' ');
      align = align.replace(/[^clr]/g,'').split('').join(' ');
      align = align.replace(/l/g,'left').replace(/r/g,'right').replace(/c/g,'center');
      var array = STACKITEM.array().With({
        arraydef: {
          columnalign: align,
          columnspacing: (spacing||"1em"),
          rowspacing: (vspacing||"3pt")
        }
      });
      // FIXME: do something about initial (and terminal?) vertical line
      if (lines.match(/\|/))
        {array.arraydef.columnlines = lines.replace(/[^| ]/g,'none').replace(/\|/g,'solid')}
      if (open)  {array.open  = this.convertDelimiter(open)}
      if (close) {array.close = this.convertDelimiter(close)}
      if (style === "D") {array.arraydef.displaystyle = TRUE}
      if (style === "S") {array.arraydef.scriptlevel = 1} // FIXME: should use mstyle?
      if (raggedHeight)  {array.arraydef.useHeight = FALSE}
      this.Push(begin);
      return array;
    },
    
    /************************************************************************/
    /*
     *   String handling routines
     */

    /*
     *  Convert delimiter to character
     */
    convertDelimiter: function (c) {
      if (c) {c = TEXDEF.delimiter[c]}
      if (c == null) {return null}
      if (c instanceof Array) {c = c[0]}
      if (c.length === 4) {c = String.fromCharCode(parseInt(c,16))}
      return c;
    },

    /*
     *  Trim spaces from a string
     */
    trimSpaces: function (text) {
      if (typeof(text) != 'string') {return text}
      return text.replace(/^\s+|\s+$/g,'');
    },

    /*
     *   Check if the next character is a space
     */
    nextIsSpace: function () {
      return this.string.charAt(this.i).match(/[ \n\r\t]/);
    },
    
    /*
     *  Get the next non-space character
     */
    GetNext: function () {
      while (this.nextIsSpace()) {this.i++}
      return this.string.charAt(this.i);
    },
  
    /*
     *  Get and return a control-sequence name
     */
    GetCS: function () {
      var CS = this.string.slice(this.i).match(/^([a-z]+|.) ?/i);
      if (CS) {this.i += CS[1].length; return CS[1]} else {this.i++; return " "}
    },

    /*
     *  Get and return a TeX argument (either a single character or control sequence,
     *  or the contents of the next set of braces).
     */
    GetArgument: function (name,noneOK) {
      switch (this.GetNext()) {
       case "":
        if (!noneOK) {TEX.Error("Missing argument for "+name)}
        return null;
       case '}':
        if (!noneOK) {TEX.Error("Extra close brace or missing open brace")}
        return null;
       case '\\':
        this.i++; return "\\"+this.GetCS();
       case '{':
        var j = ++this.i, parens = 1;
        while (this.i < this.string.length) {
          switch (this.string.charAt(this.i++)) {
           case '\\':  this.i++; break;
           case '{':   parens++; break;
           case '}':
            if (parens == 0) {TEX.Error("Extra close brace")}
            if (--parens == 0) {return this.string.slice(j,this.i-1)}
            break;
          }
        }
        TEX.Error("Missing close brace");
        break;
      }        
      return this.string.charAt(this.i++);
    },
    
    /*
     *  Get an optional LaTeX argument in brackets
     */
    GetBrackets: function (name) {
      if (this.GetNext() != '[') {return ''};
      var j = ++this.i, parens = 0;
      while (this.i < this.string.length) {
        switch (this.string.charAt(this.i++)) {
         case '{':   parens++; break;
         case '\\':  this.i++; break;
         case '}':
          if (parens-- <= 0) {TEX.Error("Extra close brace while looking for ']'")}
          break;   
         case ']':
          if (parens == 0) {return this.string.slice(j,this.i-1)}
          break;
        }
      }
      TEX.Error("Couldn't find closing ']' for argument to "+name);
    },
  
    /*
     *  Get the name of a delimiter (check it in the delimiter list).
     */
    GetDelimiter: function (name) {
      while (this.nextIsSpace()) {this.i++}
      var c = this.string.charAt(this.i);
      if (this.i < this.string.length) {
        this.i++; if (c == "\\") {c += this.GetCS(name)}
        if (TEXDEF.delimiter[c] != null) {return this.convertDelimiter(c)}
      }
      TEX.Error("Missing or unrecognized delimiter for "+name);
    },

    /*
     *  Get a dimension (including its units).
     */
    GetDimen: function (name) {
      if (this.nextIsSpace()) {this.i++}
      if (this.string.charAt(this.i) == '{') {
        var dimen = this.GetArgument(name);
        if (dimen.match(/^\s*([-+]?(\.\d+|\d+(\.\d*)?))\s*(pt|em|ex|mu|px|mm|cm|in|pc)\s*$/))
          {return dimen.replace(/ /g,"")}
      } else {
        var dimen = this.string.slice(this.i);
        var match = dimen.match(/^\s*(([-+]?(\.\d+|\d+(\.\d*)?))\s*(pt|em|ex|mu|px|mm|cm|in|pc)) ?/);
        if (match) {
          this.i += match[0].length;
          return match[1].replace(/ /g,"");
        }
      }
      TEX.Error("Missing dimension or its units for "+name);
    },
    
    /*
     *  Get everything up to the given control sequence (token)
     */
    GetUpTo: function (name,token) {
      while (this.nextIsSpace()) {this.i++}
      var j = this.i, k, c, parens = 0;
      while (this.i < this.string.length) {
        k = this.i; c = this.string.charAt(this.i++);
        switch (c) {
         case '\\':  c += this.GetCS(); break;
         case '{':   parens++; break;
         case '}':
          if (parens == 0) {TEX.Error("Extra close brace while looking for "+token)}
          parens--;
          break;
        }
        if (parens == 0 && c == token) {return this.string.slice(j,k)}
      }
      TEX.Error("Couldn't find "+token+" for "+name);
    },

    /*
     *  Parse various substrings
     */
    ParseArg: function (name) {return TEX.Parse(this.GetArgument(name),this.stack.env).mml()},
    ParseUpTo: function (name,token) {return TEX.Parse(this.GetUpTo(name,token),this.stack.env).mml()},
    
    /*
     *  Break up a string into text and math blocks
     *  @@@ FIXME:  skip over braced groups?  @@@
     *  @@@ FIXME:  pass environment to TEX.Parse? @@@
     */
    InternalMath: function (text,level) {
      var def = {displaystyle: FALSE}; if (level != null) {def.scriptlevel = level}
      if (this.stack.env.font) {def.mathvariant = this.stack.env.font}
      if (!text.match(/\$|\\\(/)) {return [MML.mtext(MML.chars(text)).With(def)]}
      var i = 0, k = 0, c, match = '';
      var mml = [];
      while (i < text.length) {
        c = text.charAt(i++);
        if (c === '$') {
          if (match === '$') {
            mml.push(MML.TeXAtom(TEX.Parse(text.slice(k,i-1)).mml().With(def)));
            match = ''; k = i;
          } else {
            if (k < i-1) {mml.push(MML.mtext(MML.chars(text.slice(k,i-1))).With(def))}
            match = '$'; k = i;
          }
        } else if (c === '\\') {
          c = text.charAt(i++);
          if (c === '(' && match == '') {
            if (k < i-2) {mml.push(MML.mtext(MML.chars(text.slice(k,i-2))).With(def))}
            match = ')'; k = i;
          } else if (c === ')' && match === ')') {
            mml.push(MML.TeXAtom(TEX.Parse(text.slice(k,i-2)).mml().With(def)));
            match = ''; k = i;
          }
        }
      }
      if (match !== '') {TEX.Error("Math not terminated in text box")}
      if (k < text.length) {mml.push(MML.mtext(MML.chars(text.slice(k))).With(def))}
      return mml;
    },

    /*
     *  Replace macro paramters with their values
     */
    SubstituteArgs: function (args,string) {
      var text = ''; var newstring = ''; var c; var i = 0;
      while (i < string.length) {
        c = string.charAt(i++);
        if (c === "\\") {text += c + string.charAt(i++)}
        else if (c === '#') {
          c = string.charAt(i++);
          if (c === '#') {text += c} else {
            if (!c.match(/[1-9]/) || c > args.length)
              {TEX.Error("Illegal macro parameter reference")}
            newstring = this.AddArgs(this.AddArgs(newstring,text),args[c-1]);
            text = '';
          }
        } else {text += c}
      }
      return this.AddArgs(newstring,text);
    },
    
    /*
     *  Make sure that macros are followed by a space if their names
     *  could accidentally be continued into the following text.
     */
    AddArgs: function (s1,s2) {
      if (s2.match(/^[a-z]/i) && s1.match(/(^|[^\\])(\\\\)*\\[a-z]+$/i)) {s1 += ' '}
      return s1+s2;
    }
    
  });
  
  /************************************************************************/

  TEX.Augment({
    Translate: function (script) {
      var mml, math = script.innerHTML.replace(/^\s+/,"").replace(/\s+$/,"");
      if (MathJax.Hub.Browser.isKonqueror)
        {math = math.replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&amp;/g,"&")}
      var displaystyle = 
        (script.type.replace(/\n/g," ").match(/(;|\s|\n)mode\s*=\s*display(;|\s|\n|$)/) != null);
      math = TEX.prefilterMath(math,displaystyle,script);
      try {
        mml = TEX.Parse(math).mml();
//        mml = MML.semantics(mml,MML.annotation(math).With({encoding:"application:x-tex"}));
      } catch(err) {
        if (!err.texError) {throw err}
        mml = this.formatError(err,math,displaystyle,script);
      }
      if (mml.inferred) {mml = MML.apply(MathJax.ElementJax,mml.data)} else {mml = MML(mml)}
      if (displaystyle) {mml.root.display = "block"}
      return mml;
    },
    prefilterMath: function (math,displaystyle,script) {return math},
    formatError: function (err,math,displaystyle,script) {
      return MML.merror(err.message.replace(/\n.*/,""));
    },
    Error: function (message) {
      throw MathJax.Hub.Insert(Error(message),{texError: TRUE});
    },
    Macro: function (name,def,argn) {
      TEXDEF.macros[name] = ['Macro'].concat([].slice.call(arguments,1));
    }
  });

  TEX.loadComplete("jax.js");
  
})(MathJax.InputJax.TeX);
