/*************************************************************
 *
 *  MathJax/extensions/TeX/AMSmath.js
 *
 *  Implements AMS math environments and macros.
 *  
 *  ---------------------------------------------------------------------
 *  
 *  Copyright (c) 2009 Design Science, Inc.
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

MathJax.Hub.Register.StartupHook("TeX Jax Ready",function () {
  var MML = MathJax.ElementJax.mml;
  var TEX = MathJax.InputJax.TeX;
  var TEXDEF = TEX.Definitions;
  var STACKITEM = TEX.Stack.Item;
  
  var COLS = function (W) {return W.join("em ") + "em"};
  
  MathJax.Hub.Insert(TEXDEF,{
    macros: {
      mathring:   ['Accent','2DA'],  // or 0x30A
      
      nobreakspace: 'Tilde',
      negmedspace:    ['Spacer',MML.LENGTH.NEGATIVEMEDIUMMATHSPACE],
      negthickspace:  ['Spacer',MML.LENGTH.NEGATIVETHICKMATHSPACE],
      
      intI:       ['Macro','\\mathchoice{\\!}{}{}{}\\!\\!\\int'],
//    iint:       ['MultiIntegral','\\int\\intI'],          // now in core TeX input jax
//    iiint:      ['MultiIntegral','\\int\\intI\\intI'],    // now in core TeX input jax
      iiiint:     ['MultiIntegral','\\int\\intI\\intI\\intI'],
      idotsint:   ['MultiIntegral','\\int\\cdots\\int'],
      
      dddot:      ['Macro','\\mathop{#1}\\limits^{\\textstyle \\mathord{.}\\mathord{.}\\mathord{.}}',1],
      ddddot:     ['Macro','\\mathop{#1}\\limits^{\\textstyle \\mathord{.}\\mathord{.}\\mathord{.}\\mathord{.}}',1],
      
      sideset:    ['Macro','\\mathop{\\mathop{\\rlap{\\phantom{#3}}}\\nolimits#1\\!\\mathop{#3}\\nolimits#2}',3],
      
      boxed:      ['Macro','\\fbox{$\\displaystyle{#1}$}',1],
      
      tag:         'HandleTag',
      notag:       'HandleNoTag',
      
      substack:   ['Macro','\\begin{subarray}{c}#1\\end{subarray}',1],
      
      injlim:     ['Macro','\\mathop{\\rm inj\\,lim}'],
      projlim:    ['Macro','\\mathop{\\rm proj\\,lim}'],
      varliminf:  ['Macro','\\mathop{\\underline{\\rm lim}}'],
      varlimsup:  ['Macro','\\mathop{\\overline{\\rm lim}}'],
      varinjlim:  ['Macro','\\mathop{\\underrightarrow{\\rm lim\\Rule{-1pt}{0pt}{1pt}}\\Rule{0pt}{0pt}{.45em}}'],
      varprojlim: ['Macro','\\mathop{\\underleftarrow{\\rm lim\\Rule{-1pt}{0pt}{1pt}}\\Rule{0pt}{0pt}{.45em}}'],
      
      DeclareMathOperator: 'HandleDeclareOp',
      operatorname:        'HandleOperatorName',
      
      genfrac:     'Genfrac',
      frac:       ['Genfrac',"","","",""],
      tfrac:      ['Genfrac',"","","",1],
      dfrac:      ['Genfrac',"","","",0],
      binom:      ['Genfrac',"(",")","0em",""],
      tbinom:     ['Genfrac',"(",")","0em",1],
      dbinom:     ['Genfrac',"(",")","0em",0],
      
      cfrac:       'CFrac',
      
      shoveleft:  ['HandleShove',MML.ALIGN.LEFT],
      shoveright: ['HandleShove',MML.ALIGN.RIGHT],
      
      xrightarrow: ['xArrow',0x2192,5,6],
      xleftarrow:  ['xArrow',0x2190,7,3]
    },
    
    environment: {
      align:         ['AMSarray',null,true,true,  'rlrlrlrlrlrl',COLS([5/18,2,5/18,2,5/18,2,5/18,2,5/18,2,5/18])],
      'align*':      ['AMSarray',null,false,true, 'rlrlrlrlrlrl',COLS([5/18,2,5/18,2,5/18,2,5/18,2,5/18,2,5/18])],
      multline:      ['Multline',null,true],
      'multline*':   ['Multline',null,false],
      split:         ['AMSarray',null,false,false,'rl',COLS([5/18])],
      gather:        ['AMSarray',null,true,true,  'c'],
      'gather*':     ['AMSarray',null,false,true, 'c'],
      
      alignat:       ['AlignAt',null,true,true],
      'alignat*':    ['AlignAt',null,false,true],
      alignedat:     ['AlignAt',null,false,false],

      aligned:       ['Array',null,null,null,'rlrlrlrlrlrl',COLS([5/18,2,5/18,2,5/18,2,5/18,2,5/18,2,5/18]),".5em",'D'],
      gathered:      ['Array',null,null,null,'c',null,".5em",'D'],

      subarray:      ['Array',null,null,null,null,COLS([0,0,0,0]),"0.1em",'S',1],
      smallmatrix:   ['Array',null,null,null,'c',COLS([1/3]),".2em",'S',1]
    },
    
    delimiter: {
      '\\lvert':     ['2223',{texClass:MML.TEXCLASS.OPEN}],
      '\\rvert':     ['2223',{texClass:MML.TEXCLASS.CLOSE}],
      '\\lVert':     ['2225',{texClass:MML.TEXCLASS.OPEN}],
      '\\rVert':     ['2225',{texClass:MML.TEXCLASS.CLOSE}]
    }
  });
    

  TEX.Parse.Augment({

    /*
     *  Add the tag to the environment to be added to the table row later
     */
    HandleTag: function (name) {
      var arg = this.trimSpaces(this.GetArgument(name));
      if (arg === "*") {arg = this.GetArgument(name)} else {arg = "("+arg+")"}
      if (this.stack.global.notag)
        {TEX.Error(name+" not allowed in "+this.stack.global.notag+" environment")}
      if (this.stack.global.tag) {TEX.Error("Multiple "+name)}
      this.stack.global.tag = MML.mtd.apply(MML,this.InternalMath(arg));
    },
    HandleNoTag: function (name) {
      if (this.stack.global.tag) {delete this.stack.global.tag}
    },
    
    /*
     *  Handle \DeclareMathOperator
     */
    HandleDeclareOp: function (name) {
      var limits = "";
      var cs = this.trimSpaces(this.GetArgument(name));
      if (cs == "*") {
        limits = "\\limits";
        cs = this.trimSpaces(this.GetArgument(name));
      }
      if (cs.charAt(0) == "\\") {cs = cs.substr(1)}
      var op = this.GetArgument(name);
      op = op.replace(/\*/g,'\\text{*}').replace(/-/g,'\\text{-}');
      TEX.Definitions.macros[cs] = ['Macro','\\mathop{\\rm '+op+'}'+limits];
    },
    
    HandleOperatorName: function (name) {
      var limits = "\\nolimits";
      var op = this.trimSpaces(this.GetArgument(name));
      if (op == "*") {
        limits = "\\limits";
        op = this.trimSpaces(this.GetArgument(name));
      }
      op = op.replace(/\*/g,'\\text{*}').replace(/-/g,'\\text{-}');
      this.string = '\\mathop{\\rm '+op+'}'+limits+" "+this.string.slice(this.i);
      this.i = 0;
    },
    
    /*
     *  Record presence of \shoveleft and \shoveright
     */
    HandleShove: function (name,shove) {
      var top = this.stack.Top();
      if (top.type !== "multline" || top.data.length) {TEX.Error(name+" must come at the beginning of the line")}
      top.data.shove = shove;
    },
    
    /*
     *  Handle \cfrac
     */
    CFrac: function (name) {
      var lr  = this.trimSpaces(this.GetBrackets(name)),
          num = this.GetArgument(name),
          den = this.GetArgument(name);
      var frac = MML.mfrac(TEX.Parse('\\strut\\textstyle{'+num+'}',this.stack.env).mml(),
                           TEX.Parse('\\strut\\textstyle{'+den+'}',this.stack.env).mml());
      lr = ({l:MML.ALIGN.LEFT, r:MML.ALIGN.RIGHT,"":""})[lr];
      if (lr == null) {TEX.Error("Illegal alignment specified in "+name)}
      if (lr) {frac.numalign = frac.denomalign = lr}
      this.Push(frac);
    },
    
    /*
     *  Implement AMS generalized fraction
     */
    Genfrac: function (name,left,right,thick,style) {
      if (left  == null) {left  = this.GetDelimiterArg(name)} else {left  = this.convertDelimiter(left)}
      if (right == null) {right = this.GetDelimiterArg(name)} else {right = this.convertDelimiter(right)}
      if (thick == null) {thick = this.GetArgument(name)}
      if (style == null) {style = this.trimSpaces(this.GetArgument(name))}
      var num = this.ParseArg(name);
      var den = this.ParseArg(name);
      var frac = MML.mfrac(num,den);
      if (thick !== "") {frac.linethickness = thick}
      if (left || right) {frac = MML.mfenced(frac).With({open: left, close: right})}
      if (style !== "") {
        var STYLE = (["D","T","S","SS"])[style];
        if (STYLE == null) {TEX.Error("Bad math style for "+name)}
        frac = MML.mstyle(frac);
        if (STYLE === "D") {frac.displaystyle = true; frac.scriptlevel = 0}
          else {frac.displaystyle = false; frac.scriptlevel = style - 1}
      }

      this.Push(frac);
    },

    /*
     *  Implements multline environment (mostly handled through STACKITEM below)
     */
    Multline: function (begin,numbered) {
      this.Push(begin);
      return STACKITEM.multline().With({
        arraydef: {
          displaystyle: true,
          rowspacing: ".5em",
          width: TEX.config.MultLineWidth, columnwidth:"100%",
          side: TEX.config.TagSide,
          minlabelspacing: TEX.config.TagIndent
        }
      });
    },

    /*
     *  Handle AMS aligned environments
     */
    AMSarray: function (begin,numbered,taggable,align,spacing) {
      this.Push(begin);
      align = align.replace(/[^clr]/g,'').split('').join(' ');
      align = align.replace(/l/g,'left').replace(/r/g,'right').replace(/c/g,'center');
      return STACKITEM.AMSarray(begin.name,numbered,taggable,this.stack).With({
        arraydef: {
          displaystyle: true,
          rowspacing: ".5em",
          columnalign: align,
          columnspacing: (spacing||"1em"),
          rowspacing: "3pt",
          side: TEX.config.TagSide,
          minlabelspacing: TEX.config.TagIndent
        }
      });
    },
    
    AlignAt: function (begin,numbered,taggable) {
      var n = this.GetArgument("\\begin{"+begin.name+"}");
      if (n.match(/[^0-9]/)) {TEX.Error("Argument to \\begin{"+begin.name+"} must me a positive integer")}
      align = ""; spacing = [];
      while (n > 0) {align += "rl"; spacing.push("0em 0em"); n--}
      spacing = spacing.join(" ");
      if (taggable) {return this.AMSarray(begin,numbered,taggable,align,spacing)}
      return this.Array(begin,null,null,align,spacing,".5em",'D');
    },
    
    /*
     *  Handle multiple integrals (make a mathop if followed by limits)
     */
    MultiIntegral: function (name,integral) {
      var next = this.GetNext();
      if (next === "\\") {
        var i = this.i; next = this.GetArgument(name); this.i = i;
        if (next === "\\limits") {
          if (name === "\\idotsint") {integral = "\\!\\!\\mathop{\\,\\,"+integral+"}"}
                           else {integral = "\\!\\!\\!\\mathop{\\,\\,\\,"+integral+"}"}
        }
      }
      this.string = integral + " " + this.string.slice(this.i);
      this.i = 0;
    },
    
    xArrow: function (name,chr,l,r) {
      var def = {width: "+"+(l+r)+"mu", lspace: l+"mu"};
      var bot = this.GetBrackets(name),
          top = this.ParseArg(name);
      var arrow = MML.mo(MML.chars(String.fromCharCode(chr))).With({
        stretchy: true, texClass: MML.TEXCLASS.REL
      });
      var mml = MML.munderover(arrow);
      mml.SetData(mml.over,MML.mpadded(top).With(def).With({voffset:".15em"}));
      if (bot) {
        bot = TEX.Parse(bot,this.stack.env).mml()
        mml.SetData(mml.under,MML.mpadded(bot).With(def).With({voffset:"-.24em"}));
      }
      this.Push(mml);
    },
    
    /*
     *  Get a delimiter or empty argument
     */
    GetDelimiterArg: function (name) {
      var c = this.trimSpaces(this.GetArgument(name));
      if (c == "") {return null}
      if (!TEXDEF.delimiter[c]) {TEX.Error("Missing or unrecognized delimiter for "+name)}
      return this.convertDelimiter(c);
    }
  });
  
  /*
   *  Implement multline environment via a STACKITEM
   */
  STACKITEM.multline = STACKITEM.array.Subclass({
    type: "multline",
    EndEntry: function () {
      var mtd = MML.mtd.apply(MML,this.data);
      if (this.data.shove) {mtd.columnalign = this.data.shove}
      this.row.push(mtd);
      this.data = [];
    },
    EndRow: function () {
      if (this.row.length != 1) {TEX.Error("multline rows must have exactly one column")}
      this.table.push(this.row); this.row = [];
    },
    EndTable: function () {
      this.SUPER(arguments).EndTable.call(this);
      if (this.table.length) {
        var m = this.table.length-1, i;
        if (!this.table[0][0].columnalign) {this.table[0][0].columnalign = MML.ALIGN.LEFT}
        if (!this.table[m][0].columnalign) {this.table[m][0].columnalign = MML.ALIGN.RIGHT}
        var mtr = MML.mtr;
        if (this.global.tag) {
          this.table[0] = [this.global.tag].concat(this.table[0]);
          delete this.global.tag; mtr = MML.mlabeledtr;
        }
        this.table[0] = mtr.apply(MML,this.table[0]);
        for (i = 1, m = this.table.length; i < m; i++)
          {this.table[i] = MML.mtr.apply(MML,this.table[i])}
      }
    }
  });
  
  STACKITEM.AMSarray = STACKITEM.array.Subclass({
    type: "AMSarray",
    Init: function (name,numbered,taggable,stack) {
      this.SUPER(arguments).Init.apply(this);
      this.numbered = numbered;
      this.save_notag = stack.global.notag;
      stack.global.notag = (taggable ? null : name);
    },
    EndRow: function () {
      var mtr = MML.mtr;
      if (this.global.tag) {
        this.row = [this.global.tag].concat(this.row);
        mtr = MML.mlabeledtr;
        delete this.global.tag;
      }
      this.table.push(mtr.apply(MML,this.row)); this.row = [];
    },
    EndTable: function () {
      this.SUPER(arguments).EndTable.call(this);
      this.global.notag = this.save_notag;
    }
  });
  
  //
  //  Look for \tag on a formula and make an mtable to include it
  //
  STACKITEM.start.Augment({
    oldCheckItem: STACKITEM.start.prototype.checkItem,
    checkItem: function (item) {
      if (item.type === "stop") {
        var mml = this.mmlData();
        if (this.global.tag) {
          mml = MML.mtable(MML.mlabeledtr(this.global.tag,MML.mtd(mml)));
          mml.side = TEX.config.TagSide;
          mml.minlabelspacing = TEX.config.TagIndent;
          delete this.global.tag;
        }
        return STACKITEM.mml(mml);
      }
      return this.SUPER(arguments).checkItem.call(this,item);
    }
  });
  
  MathJax.Hub.Startup.signal.Post("TeX AMSmath Ready");
  
});

MathJax.Ajax.loadComplete("[MathJax]/extensions/TeX/AMSmath.js");
