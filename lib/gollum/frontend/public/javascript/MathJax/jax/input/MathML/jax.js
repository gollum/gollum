/*************************************************************
 *
 *  MathJax/jax/input/MathML/jax.js
 *  
 *  Implements the MathML InputJax that reads mathematics in
 *  MathML format and converts it to the MML ElementJax
 *  internal format.
 *
 *  ---------------------------------------------------------------------
 *  
 *  Copyright (c) 2010 Design Science, Inc.
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

 */

(function (MATHML,BROWSER) {
  var MML;
  
  MATHML.Parse = MathJax.Object.Subclass({

    Init: function (string) {this.Parse(string)},
    
    //
    //  Parse the MathML and check for errors
    //
    Parse: function (math) {
      var doc;
      if (typeof math !== "string") {doc = math.parentNode} else {
        if (math.match(/^<[a-z]+:/i) && !math.match(/^<[^<>]* xmlns:/))
          {math = math.replace(/^<([a-z]+):math/i,'<$1:math xmlns:$1="http://www.w3.org/1998/Math/MathML"')}
        math = math.replace(/&([a-z]+);/ig,this.replaceEntity);
        doc = MATHML.ParseXML(math); if (doc == null) {MATHML.Error("Error parsing MathML")}
      }
      var err = doc.getElementsByTagName("parsererror")[0];
      if (err) MATHML.Error("Error parsing MathML: "+err.textContent.replace(/This page.*?errors:|XML Parsing Error: |Below is a rendering of the page.*/g,""));
      if (doc.childNodes.length !== 1) MATHML.Error("MathML must be formed by a single element");
      if (doc.firstChild.nodeName.toLowerCase() === "html") {
        var h1 = doc.getElementsByTagName("h1")[0];
        if (h1 && h1.textContent === "XML parsing error" && h1.nextSibling)
          MATHML.Error("Error parsing MathML: "+String(h1.nextSibling.nodeValue).replace(/fatal parsing error: /,""));
      }
      if (doc.firstChild.nodeName.toLowerCase().replace(/^[a-z]+:/,"") !== "math")
        MATHML.Error("MathML must be formed by a <math> element, not <"+doc.firstChild.nodeName+">");
      this.mml = this.MakeMML(doc.firstChild);
    },
    
    //
    //  Convert the MathML structure to the MathJax Element jax structure
    //
    MakeMML: function (node) {
      var type = node.nodeName.toLowerCase().replace(/^[a-z]+:/,"");
      if (!(MML[type] && MML[type].isa && MML[type].isa(MML.mbase)))
        {return MML.merror("Unknown node type: "+type)}
      var mml = MML[type](), i, m, value;
      for (i = 0, m = node.attributes.length; i < m; i++) {
        value = node.attributes[i].value;
        if (value.toLowerCase() === "true") {value = true}
          else if (value.toLowerCase() === "false") {value = false}
        mml[node.attributes[i].name] = value;
      }
      for (i = 0, m = node.childNodes.length; i < m; i++) {
        var child = node.childNodes[i];
        if (child.nodeName === "#comment") continue;
        if (child.nodeName === "#text") {
          if (mml.isToken) {
            var text = this.trimSpace(child.nodeValue);
            if (mml.isa(MML.mo) && text.length === 1 && this.Remap[text.charAt(0)])
              {text = this.Remap[text.charAt(0)]}
            text = text.replace(/&([a-z]+);/ig,this.replaceEntity);
            mml.Append(MML.chars(text));
          } else if (child.nodeValue.match(/\S/)) {
            MATHML.Error("Unexpected text node: '"+child.nodeValue+"'");
          }
        } else {mml.Append(this.MakeMML(child))}
      }
      if (MATHML.config.useMathMLspacing) {mml.useMMLspacing = 0x08}
      return mml;
    },
    
    trimSpace: function (string) {
      return string.replace(/^[ \t\n\r]+/,"")              // initial whitespace
                   .replace(/[ \t\n\r]+$/,"")              // trailing whitespace
                   .replace(/[ \t\n\r][ \t\n\r]+/g," ");   // internal multiple whitespace
    },
    
    replaceEntity: function (match,entity) {
      if (MATHML.Parse.Entity[entity]) {return MATHML.Parse.Entity[entity]}
      var file = entity.charAt(0).toLowerCase();
      var font = entity.match(/^[a-zA-Z](fr|scr|opf)$/);
      if (font) {file = font[1]}
      if (!MATHML.Parse.loaded[file]) {
        MATHML.Parse.loaded[file] = true;
        MathJax.Hub.RestartAfter(MathJax.Ajax.Require(MATHML.entityDir+"/"+file+".js"));
      }
      return match;
    },
    
    Remap: {
      '\u0027': '\u2032', // '
      '\u002A': '\u2217', // *
      '\u002D': '\u2212'  // -
    }
  }, {
    loaded: []
  });
  
  /************************************************************************/

  MATHML.Augment({
    Translate: function (script) {
      var mml, math;
      if (script.firstChild &&
          script.firstChild.nodeName.toLowerCase().replace(/^[a-z]+:/,"") === "math") {
        math = this.prefilterMathML(script.firstChild);
      } else {
        math = script.innerHTML.replace(/^\s+/,"").replace(/\s+$/,"");
        if (BROWSER.isMSIE) 
          {math = math.replace(/(&nbsp;)+$/,"").replace(/&amp;/g,"&").replace(/&lt;/g,"&amp;lt;")}
        else if (BROWSER.isKonqueror)
          {math = math.replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&amp;/g,"&")}
        math = this.prefilterMath(math,script);
      }
      try {
        mml = MATHML.Parse(math).mml;
      } catch(err) {
        if (!err.mathmlError) {throw err}
        mml = this.formatError(err,math,script);
      }
      return MML(mml);
    },
    prefilterMath: function (math,script) {return math},
    prefilterMathML: function (math) {return math},
    formatError: function (err,math,script) {
      return MML.merror(err.message.replace(/\n.*/,""));
    },
    Error: function (message) {
      throw MathJax.Hub.Insert(Error(message),{mathmlError: true});
    },
    //
    //  Parsers for various forms (DOMParser, Windows ActiveX object, other)
    //
    parseDOM: function (string) {return this.parser.parseFromString(string,"text/xml")},
    parseMS: function (string) {return (this.parser.loadXML(string) ? this.parser : null)},
    parseDIV: function (string) {
      this.div.innerHTML = string.replace(/<([a-z]+)([^>]*)\/>/g,"<$1$2></$1>");
      return this.div;
    },
    //
    //  Initialize the parser object (whichever type is used)
    //
    Startup: function () {
      MML = MathJax.ElementJax.mml;
      if (window.DOMParser) {
        this.parser = new DOMParser();
        this.ParseXML = this.parseDOM;
      } else if (window.ActiveXObject) {
        var xml = ["MSXML2.DOMDocument.6.0","MSXML2.DOMDocument.5.0","MSXML2.DOMDocument.4.0",
                   "MSXML2.DOMDocument.3.0","MSXML2.DOMDocument.2.0","Microsoft.XMLDOM"];
        for (var i = 0, m = xml.length; i < m && !this.parser; i++)
          {try {this.parser = new ActiveXObject(xml[i])} catch (err) {}}
        if (!this.parser) MATHML.Error("Can't create XML parser for MathML");
        this.parser.async = false;
        this.ParseXML = this.parseMS;
      } else {
        this.div = MathJax.Hub.Insert(document.createElement("div"),{
             style:{visibility:"hidden", overflow:"hidden", height:"1px",
                    position:"absolute", top:0}
        });
        if (!document.body.firstChild) {document.body.appendChild(this.div)}
          else {document.body.insertBefore(this.div,document.body.firstChild)}
        this.ParseXML = this.parseDIV;
      }
    }
  });
  
  MATHML.Parse.Entity = {
    ApplyFunction: '\u2061',
    Backslash: '\u2216',
    Because: '\u2235',
    Breve: '\u02D8',
    Cap: '\u22D2',
    CenterDot: '\u00B7',
    CircleDot: '\u2299',
    CircleMinus: '\u2296',
    CirclePlus: '\u2295',
    CircleTimes: '\u2297',
    Congruent: '\u2261',
    ContourIntegral: '\u222E',
    Coproduct: '\u2210',
    Cross: '\u2A2F',
    Cup: '\u22D3',
    CupCap: '\u224D',
    Dagger: '\u2021',
    Del: '\u2207',
    Delta: '\u0394',
    Diamond: '\u22C4',
    DifferentialD: '\u2146',
    DotEqual: '\u2250',
    DoubleDot: '\u00A8',
    DoubleRightTee: '\u22A8',
    DoubleVerticalBar: '\u2225',
    DownArrow: '\u2193',
    DownLeftVector: '\u21BD',
    DownRightVector: '\u21C1',
    DownTee: '\u22A4',
    Downarrow: '\u21D3',
    Element: '\u2208',
    EqualTilde: '\u2242',
    Equilibrium: '\u21CC',
    Exists: '\u2203',
    ExponentialE: '\u2147',
    FilledVerySmallSquare: '\u25AA',
    ForAll: '\u2200',
    Gamma: '\u0393',
    Gg: '\u22D9',
    GreaterEqual: '\u2265',
    GreaterEqualLess: '\u22DB',
    GreaterFullEqual: '\u2267',
    GreaterLess: '\u2277',
    GreaterSlantEqual: '\u2A7E',
    GreaterTilde: '\u2273',
    Hacek: '\u02C7',
    Hat: '\u005E',
    HumpDownHump: '\u224E',
    HumpEqual: '\u224F',
    Im: '\u2111',
    ImaginaryI: '\u2148',
    Integral: '\u222B',
    Intersection: '\u22C2',
    InvisibleComma: '\u2063',
    InvisibleTimes: '\u2062',
    Lambda: '\u039B',
    Larr: '\u219E',
    LeftAngleBracket: '\u2329',
    LeftArrow: '\u2190',
    LeftArrowRightArrow: '\u21C6',
    LeftCeiling: '\u2308',
    LeftDownVector: '\u21C3',
    LeftFloor: '\u230A',
    LeftRightArrow: '\u2194',
    LeftTee: '\u22A3',
    LeftTriangle: '\u22B2',
    LeftTriangleEqual: '\u22B4',
    LeftUpVector: '\u21BF',
    LeftVector: '\u21BC',
    Leftarrow: '\u21D0',
    Leftrightarrow: '\u21D4',
    LessEqualGreater: '\u22DA',
    LessFullEqual: '\u2266',
    LessGreater: '\u2276',
    LessSlantEqual: '\u2A7D',
    LessTilde: '\u2272',
    Ll: '\u22D8',
    Lleftarrow: '\u21DA',
    LongLeftArrow: '\u27F5',
    LongLeftRightArrow: '\u27F7',
    LongRightArrow: '\u27F6',
    Longleftarrow: '\u27F8',
    Longleftrightarrow: '\u27FA',
    Longrightarrow: '\u27F9',
    Lsh: '\u21B0',
    MinusPlus: '\u2213',
    NestedGreaterGreater: '\u226B',
    NestedLessLess: '\u226A',
    NotDoubleVerticalBar: '\u2226',
    NotElement: '\u2209',
    NotEqual: '\u2260',
    NotExists: '\u2204',
    NotGreater: '\u226F',
    NotGreaterEqual: '\u2271',
    NotLeftTriangle: '\u22EA',
    NotLeftTriangleEqual: '\u22EC',
    NotLess: '\u226E',
    NotLessEqual: '\u2270',
    NotPrecedes: '\u2280',
    NotPrecedesSlantEqual: '\u22E0',
    NotRightTriangle: '\u22EB',
    NotRightTriangleEqual: '\u22ED',
    NotSubsetEqual: '\u2288',
    NotSucceeds: '\u2281',
    NotSucceedsSlantEqual: '\u22E1',
    NotSupersetEqual: '\u2289',
    NotTilde: '\u2241',
    NotVerticalBar: '\u2224',
    Omega: '\u03A9',
    OverBar: '\u00AF',
    OverBrace: '\uFE37',
    PartialD: '\u2202',
    Phi: '\u03A6',
    Pi: '\u03A0',
    PlusMinus: '\u00B1',
    Precedes: '\u227A',
    PrecedesEqual: '\u2AAF',
    PrecedesSlantEqual: '\u227C',
    PrecedesTilde: '\u227E',
    Product: '\u220F',
    Proportional: '\u221D',
    Psi: '\u03A8',
    Rarr: '\u21A0',
    Re: '\u211C',
    ReverseEquilibrium: '\u21CB',
    RightAngleBracket: '\u232A',
    RightArrow: '\u2192',
    RightArrowLeftArrow: '\u21C4',
    RightCeiling: '\u2309',
    RightDownVector: '\u21C2',
    RightFloor: '\u230B',
    RightTee: '\u22A2',
    RightTeeArrow: '\u21A6',
    RightTriangle: '\u22B3',
    RightTriangleEqual: '\u22B5',
    RightUpVector: '\u21BE',
    RightVector: '\u21C0',
    Rightarrow: '\u21D2',
    Rrightarrow: '\u21DB',
    Rsh: '\u21B1',
    Sigma: '\u03A3',
    SmallCircle: '\u2218',
    Sqrt: '\u221A',
    Square: '\u25A1',
    SquareIntersection: '\u2293',
    SquareSubset: '\u228F',
    SquareSubsetEqual: '\u2291',
    SquareSuperset: '\u2290',
    SquareSupersetEqual: '\u2292',
    SquareUnion: '\u2294',
    Star: '\u22C6',
    Subset: '\u22D0',
    SubsetEqual: '\u2286',
    Succeeds: '\u227B',
    SucceedsEqual: '\u2AB0',
    SucceedsSlantEqual: '\u227D',
    SucceedsTilde: '\u227F',
    SuchThat: '\u220B',
    Sum: '\u2211',
    Superset: '\u2283',
    SupersetEqual: '\u2287',
    Supset: '\u22D1',
    Therefore: '\u2234',
    Theta: '\u0398',
    Tilde: '\u223C',
    TildeEqual: '\u2243',
    TildeFullEqual: '\u2245',
    TildeTilde: '\u2248',
    UnderBar: '\u0332',
    UnderBrace: '\uFE38',
    Union: '\u22C3',
    UnionPlus: '\u228E',
    UpArrow: '\u2191',
    UpDownArrow: '\u2195',
    UpTee: '\u22A5',
    Uparrow: '\u21D1',
    Updownarrow: '\u21D5',
    Upsilon: '\u03A5',
    Vdash: '\u22A9',
    Vee: '\u22C1',
    VerticalBar: '\u2223',
    VerticalTilde: '\u2240',
    Vvdash: '\u22AA',
    Wedge: '\u22C0',
    Xi: '\u039E',
    acute: '\u00B4',
    aleph: '\u2135',
    alpha: '\u03B1',
    amalg: '\u2A3F',
    and: '\u2227',
    ang: '\u2220',
    angmsd: '\u2221',
    angsph: '\u2222',
    ape: '\u224A',
    backprime: '\u2035',
    backsim: '\u223D',
    backsimeq: '\u22CD',
    beta: '\u03B2',
    beth: '\u2136',
    between: '\u226C',
    bigcirc: '\u25EF',
    bigodot: '\u2A00',
    bigoplus: '\u2A01',
    bigotimes: '\u2A02',
    bigsqcup: '\u2A06',
    bigstar: '\u2605',
    bigtriangledown: '\u25BD',
    bigtriangleup: '\u25B3',
    biguplus: '\u2A04',
    blacklozenge: '\u29EB',
    blacktriangle: '\u25B4',
    blacktriangledown: '\u25BE',
    blacktriangleleft: '\u25C2',
    bowtie: '\u22C8',
    boxdl: '\u2510',
    boxdr: '\u250C',
    boxminus: '\u229F',
    boxplus: '\u229E',
    boxtimes: '\u22A0',
    boxul: '\u2518',
    boxur: '\u2514',
    bsol: '\u005C',
    bull: '\u2022',
    cap: '\u2229',
    check: '\u2713',
    chi: '\u03C7',
    circ: '\u02C6',
    circeq: '\u2257',
    circlearrowleft: '\u21BA',
    circlearrowright: '\u21BB',
    circledR: '\u00AE',
    circledS: '\u24C8',
    circledast: '\u229B',
    circledcirc: '\u229A',
    circleddash: '\u229D',
    clubs: '\u2663',
    colon: '\u003A',
    comp: '\u2201',
    ctdot: '\u22EF',
    cuepr: '\u22DE',
    cuesc: '\u22DF',
    cularr: '\u21B6',
    cup: '\u222A',
    curarr: '\u21B7',
    curlyvee: '\u22CE',
    curlywedge: '\u22CF',
    dagger: '\u2020',
    daleth: '\u2138',
    ddarr: '\u21CA',
    deg: '\u00B0',
    delta: '\u03B4',
    digamma: '\u03DD',
    div: '\u00F7',
    divideontimes: '\u22C7',
    dot: '\u02D9',
    doteqdot: '\u2251',
    dotplus: '\u2214',
    dotsquare: '\u22A1',
    dtdot: '\u22F1',
    ecir: '\u2256',
    efDot: '\u2252',
    egs: '\u2A96',
    ell: '\u2113',
    els: '\u2A95',
    empty: '\u2205',
    epsi: '\u03F5',
    epsiv: '\u03B5',
    erDot: '\u2253',
    eta: '\u03B7',
    eth: '\u00F0',
    flat: '\u266D',
    fork: '\u22D4',
    frown: '\u2322',
    gEl: '\u2A8C',
    gamma: '\u03B3',
    gap: '\u2A86',
    gimel: '\u2137',
    gnE: '\u2269',
    gnap: '\u2A8A',
    gne: '\u2A88',
    gnsim: '\u22E7',
    gt: '\u003E',
    gtdot: '\u22D7',
    harrw: '\u21AD',
    hbar: '\u210F',
    hellip: '\u2026',
    hookleftarrow: '\u21A9',
    hookrightarrow: '\u21AA',
    imath: '\u0131',
    infin: '\u221E',
    intcal: '\u22BA',
    iota: '\u03B9',
    kappa: '\u03BA',
    kappav: '\u03F0',
    lEg: '\u2A8B',
    lambda: '\u03BB',
    lap: '\u2A85',
    larrlp: '\u21AB',
    larrtl: '\u21A2',
    lbrace: '\u007B',
    lbrack: '\u005B',
    le: '\u2264',
    leftleftarrows: '\u21C7',
    leftthreetimes: '\u22CB',
    lessdot: '\u22D6',
    lmoust: '\u23B0',
    lnE: '\u2268',
    lnap: '\u2A89',
    lne: '\u2A87',
    lnsim: '\u22E6',
    longmapsto: '\u27FC',
    looparrowright: '\u21AC',
    lowast: '\u2217',
    lowbar: '\u005F',
    loz: '\u25CA',
    lt: '\u003C',
    ltimes: '\u22C9',
    ltri: '\u25C3',
    malt: '\u2720',
    mho: '\u2127',
    mu: '\u03BC',
    multimap: '\u22B8',
    nVDash: '\u22AF',
    nVdash: '\u22AE',
    natur: '\u266E',
    nearr: '\u2197',
    nhArr: '\u21CE',
    nharr: '\u21AE',
    nlArr: '\u21CD',
    nlarr: '\u219A',
    not: '\u00AC',
    nrArr: '\u21CF',
    nrarr: '\u219B',
    nu: '\u03BD',
    nvDash: '\u22AD',
    nvdash: '\u22AC',
    nwarr: '\u2196',
    omega: '\u03C9',
    or: '\u2228',
    osol: '\u2298',
    period: '\u002E',
    phi: '\u03D5',
    phiv: '\u03C6',
    pi: '\u03C0',
    piv: '\u03D6',
    prap: '\u2AB7',
    precnapprox: '\u2AB9',
    precneqq: '\u2AB5',
    precnsim: '\u22E8',
    prime: '\u2032',
    psi: '\u03C8',
    rarrtl: '\u21A3',
    rbrace: '\u007D',
    rbrack: '\u005D',
    rho: '\u03C1',
    rhov: '\u03F1',
    rightrightarrows: '\u21C9',
    rightthreetimes: '\u22CC',
    ring: '\u02DA',
    rmoust: '\u23B1',
    rtimes: '\u22CA',
    rtri: '\u25B9',
    scap: '\u2AB8',
    scnE: '\u2AB6',
    scnap: '\u2ABA',
    scnsim: '\u22E9',
    sdot: '\u22C5',
    searr: '\u2198',
    sect: '\u00A7',
    sharp: '\u266F',
    sigma: '\u03C3',
    sigmav: '\u03C2',
    simne: '\u2246',
    smile: '\u2323',
    spades: '\u2660',
    sub: '\u2282',
    subE: '\u2AC5',
    subnE: '\u2ACB',
    subne: '\u228A',
    supE: '\u2AC6',
    supnE: '\u2ACC',
    supne: '\u228B',
    swarr: '\u2199',
    tau: '\u03C4',
    theta: '\u03B8',
    thetav: '\u03D1',
    tilde: '\u02DC',
    times: '\u00D7',
    triangle: '\u25B5',
    triangleq: '\u225C',
    upsi: '\u03C5',
    upuparrows: '\u21C8',
    veebar: '\u22BB',
    vellip: '\u22EE',
    weierp: '\u2118',
    xi: '\u03BE',
    yen: '\u00A5',
    zeta: '\u03B6',
    zigrarr: '\u21DD'
  };
  
  MATHML.loadComplete("jax.js");
  
})(MathJax.InputJax.MathML,MathJax.Hub.Browser);
