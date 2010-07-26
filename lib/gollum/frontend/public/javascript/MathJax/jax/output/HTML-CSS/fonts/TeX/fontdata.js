/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/fontdata.js
 *  
 *  Initializes the HTML-CSS OutputJax to use the MathJax TeX fonts
 *  for displaying mathematics.
 *
 *  ---------------------------------------------------------------------
 *  
 *  Copyright (c) 2009 Design Science, Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

(function (HTMLCSS,MML,AJAX) {
  
  var MAIN   = "MathJax_Main",
      BOLD   = "MathJax_Main-bold",
      ITALIC = "MathJax_Math-italic",
      AMS    = "MathJax_AMS",
      SIZE1  = "MathJax_Size1",
      SIZE2  = "MathJax_Size2",
      SIZE3  = "MathJax_Size3",
      SIZE4  = "MathJax_Size4";
  var H = "H", V = "V";

  HTMLCSS.Augment({
    FONTDATA: {
      TeX_factor: 1,    // TeX em's to font em's
      baselineskip: 1.2,
      lineH: .8, lineD: .2,
      
      hasStyleChar: true,  // char 0xEFFD encodes font style
 
      FONTS: {
        "MathJax_Main":             "Main/Regular/Main.js",
        "MathJax_Main-bold":        "Main/Bold/Main.js",
        "MathJax_Main-italic":      "Main/Italic/Main.js",
        "MathJax_Math-italic":      "Math/Italic/Main.js",
        "MathJax_Math-bold-italic": "Math/BoldItalic/Main.js",
        "MathJax_Caligraphic":      "Caligraphic/Regular/Main.js",
        "MathJax_Size1":            "Size1/Regular/Main.js",
        "MathJax_Size2":            "Size2/Regular/Main.js",
        "MathJax_Size3":            "Size3/Regular/Main.js",
        "MathJax_Size4":            "Size4/Regular/Main.js",
        "MathJax_AMS":              "AMS/Regular/Main.js",
        "MathJax_Fraktur":          "Fraktur/Regular/Main.js",
        "MathJax_Fraktur-bold":     "Fraktur/Bold/Main.js",
        "MathJax_SansSerif":        "SansSerif/Regular/Main.js",
        "MathJax_SansSerif-bold":   "SansSerif/Bold/Main.js",
        "MathJax_SansSerif-italic": "SansSerif/Italic/Main.js",
        "MathJax_Script":           "Script/Regular/Main.js",
        "MathJax_Typewriter":       "Typewriter/Regular/Main.js"
      },
      
      DEFAULTFAMILY: MAIN,  DEFAULTWEIGHT: "normal", DEFAULTSTYLE: "normal",

      VARIANT: {
        "normal": {fonts:[MAIN,SIZE1,AMS]},
        "bold":   {fonts:[BOLD,SIZE1,AMS]},
        "italic": {fonts:[ITALIC,"MathJax_Main-italic",MAIN,SIZE1,AMS],
                   offsetN: 0x30, variantN: "normal"},
        "bold-italic": {fonts:["MathJax_Math-bold-italic",BOLD,SIZE1,AMS]},
        "double-struck": {fonts:[AMS, MAIN]},
        "fraktur": {fonts:["MathJax_Fraktur",MAIN,SIZE1,AMS]},
        "bold-fraktur": {fonts:["MathJax_Fraktur-bold",BOLD,SIZE1,AMS]},
        "script": {fonts:["MathJax_Script",MAIN,SIZE1,AMS]},
        "bold-script": {fonts:["MathJax_Script",BOLD,SIZE1,AMS]},
        "sans-serif": {fonts:["MathJax_SansSerif",MAIN,SIZE1,AMS]},
        "bold-sans-serif": {fonts:["MathJax_SansSerif-bold",BOLD,SIZE1,AMS]},
        "sans-serif-italic": {fonts:["MathJax_SansSerif-italic","MathJax_Main-italic",SIZE1,AMS]},
        "sans-serif-bold-italic": {fonts:["MathJax_SansSerif-italic","MathJax_Main-italic",SIZE1,AMS]},
        "monospace": {fonts:["MathJax_Typewriter",MAIN,SIZE1,AMS]},
        "-tex-caligraphic": {fonts:["MathJax_Caligraphic",MAIN], offsetA: 0x41, variantA: "italic"},
        "-tex-oldstyle": {fonts:["MathJax_Caligraphic",MAIN]},
        "-largeOp": {fonts:[SIZE2,SIZE1,MAIN]},
        "-smallOp": {fonts:[SIZE1,MAIN]}
      },
      
      RANGES: [
        {name: "alpha", low: 0x61, high: 0x7A, offset: "A", add: 32},
        {name: "number", low: 0x30, high: 0x39, offset: "N"}
      ],
      
      RULECHAR: 0x2212,
      
      REMAP: { 
        0x203E: 0x2C9,                  // overline
        0x20D0: 0x21BC, 0x20D1: 0x21C0, // combining left and right harpoons
        0x20D6: 0x2190, 0x20E1: 0x2194, // combining left arrow and lef-right arrow
        0x20EC: 0x21C1, 0x20ED: 0x21BD, // combining low right and left harpoons
        0x20EE: 0x2190, 0x20EF: 0x2192, // combining low left and right arrows
        0x20F0: 0x2A,                   // combining asterisk
        0xFE37: 0x23DE, 0xFE38: 0x23DF, // OverBrace, UnderBrace

        0xB7: 0x22C5,                   // center dot
        0x2B9: 0x2032,                  // prime,
        0x3D2: 0x3A5,                   // Upsilon
        0x2015: 0x2014, 0x2017: 0x5F,   // horizontal bars
        0x2022: 0x2219, 0x2044: 0x2F,   // bullet, fraction slash
        0x2305: 0x22BC, 0x2306: 0x2A5E, // barwedge, doublebarwedge
        0x25AA: 0x25A0, 0x25B4: 0x25B2, // blacksquare, blacktriangle
        0x25B5: 0x25B3, 0x25BE: 0x25BC, // triangle, blacktriangledown
        0x25BF: 0x25BD, 0x25C2: 0x25C0, // triangledown, blacktriangleleft
        0x2329: 0x27E8, 0x232A: 0x27E9, // langle, rangle
        0x3008: 0x27E8, 0x3009: 0x27E9, // langle, rangle
        0x2758: 0x2223,                 // VerticalSeparator
        0x2A2F: 0xD7                    // cross product
      },
      
      DELIMITERS: {
        0x0028: // (
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {top: [0x239B,SIZE4], ext: [0x239C,SIZE4], bot: [0x239D,SIZE4]}
        },
        0x0029: // )
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {top:[0x239E,SIZE4], ext:[0x239F,SIZE4], bot:[0x23A0,SIZE4]}
        },
        0x002F: // /
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]]
        },
        0x005B: // [
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {top:[0x23A1,SIZE4], ext:[0x23A2,SIZE4], bot:[0x23A3,SIZE4]}
        },
        0x005C: // \
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]]
        },
        0x005D: // ]
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {top:[0x23A4,SIZE4], ext:[0x23A5,SIZE4], bot:[0x23A6,SIZE4]}
        },
        0x007B: // {
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {top:[0x23A7,SIZE4], mid:[0x23A8,SIZE4], bot:[0x23A9,SIZE4], ext:[0x23AA,SIZE4]}
        },
        0x007C: // |
        {
          dir: V, HW: [[1,MAIN]], stretch: {ext:[0x2223,MAIN]}
        },
        0x007D: // }
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {top: [0x23AB,SIZE4], mid:[0x23AC,SIZE4], bot: [0x23AD,SIZE4], ext: [0x23AA,SIZE4]}
        },
        0x02C6: // wide hat
        {
          dir: H, HW: [[.267+.05,MAIN],[.567+.05,SIZE1],[1.005+.05,SIZE2],[1.447+.1,SIZE3],[1.909+.1,SIZE4]]
        },
        0x02DC: // wide tilde
        {
          dir: H, HW: [[.333,MAIN],[.555+.05,SIZE1],[1+.05,SIZE2],[1.443+.1,SIZE3],[1.887+.1,SIZE4]]
        },
        0x2016: // vertical arrow extension
        {
          dir: V, HW: [[.602,SIZE1],[1,MAIN,null,0x2225]], stretch: {ext:[0x2225,MAIN]}
        },
        0x2190: // left arrow
        {
          dir: H, HW: [[1,MAIN]], stretch: {left:[0x2190,MAIN],rep:[0x2212,MAIN]}
        },
        0x2191: // \uparrow
        {
          dir: V, HW: [[.888,MAIN]], stretch: {top:[0x2191,SIZE1], ext:[0x23D0,SIZE1]}
        },
        0x2192: // right arrow
        {
          dir: H, HW: [[1,MAIN]], stretch: {rep:[0x2212,MAIN], right:[0x2192,MAIN]}
        },
        0x2193: // \downarrow
        {
          dir: V, HW: [[.888,MAIN]], stretch: {ext:[0x23D0,SIZE1], bot:[0x2193,SIZE1]}
        },
        0x2194: // left-right arrow
        {
          dir: H, HW: [[1,MAIN]],
          stretch: {left:[0x2190,MAIN],rep:[0x2212,MAIN], right:[0x2192,MAIN]}
        },
        0x2195: // \updownarrow
        {
          dir: V, HW: [[1.044,MAIN]],
          stretch: {top:[0x2191,SIZE1], ext:[0x23D0,SIZE1], bot:[0x2193,SIZE1]}
        },
        0x21D1: // \Uparrow
        {
          dir: V, HW: [[.888,MAIN]], stretch: {top:[0x21D1,SIZE1], ext:[0x2016,SIZE1]}
        },
        0x21D3: // \Downarrow
        {
          dir: V, HW: [[.888,MAIN]], stretch: {ext:[0x2016,SIZE1], bot:[0x21D3,SIZE1]}
        },
        0x21D5: // \Updownarrow
        {
          dir: V, HW: [[1.044,MAIN]],
          stretch: {top:[0x21D1,SIZE1], ext:[0x2016,SIZE1], bot:[0x21D3,SIZE1]}
        },
        0x2212: // horizontal line
        {
          dir: H, HW: [[.611,MAIN]], stretch: {rep:[0x2212,MAIN]}
        },
        0x221A: // \surd
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3,SIZE4]],
          stretch: {top:[0xE001,SIZE4], ext:[0xE000,SIZE4], bot:[0x23B7,SIZE4], fullExtenders:true}
        },
        0x2223: // \vert
        {
          dir: V, HW: [[1,MAIN]], stretch: {ext:[0x2223,MAIN]}
        },
        0x2225: // \Vert
        {
          dir: V, HW: [[1,MAIN]], stretch: {ext:[0x2225,MAIN]}
        },
        0x2308: // \lceil
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {top:[0x23A1,SIZE4], ext:[0x23A2,SIZE4]}
        },
        0x2309: // \rceil
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {top:[0x23A4,SIZE4], ext:[0x23A5,SIZE4]}
        },
        0x230A: // \lfloor
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {ext:[0x23A2,SIZE4], bot:[0x23A3,SIZE4]}
        },
        0x230B: // \rfloor
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]],
          stretch: {ext:[0x23A5,SIZE4], bot:[0x23A6,SIZE4]}
        },
        0x23AA: // \bracevert
        {
          dir: V, HW: [[.32,SIZE4]],
          stretch: {top:[0x23AA,SIZE4], ext:[0x23AA,SIZE4], bot:[0x23AA,SIZE4]}
        },
        0x23B0: // \lmoustache
        {
          dir: V, HW: [[.989,MAIN]],
          stretch: {top:[0x23A7,SIZE4], ext:[0x23AA,SIZE4], bot:[0x23AD,SIZE4]}
        },
        0x23B1: // \rmoustache
        {
          dir: V, HW: [[.989,MAIN]],
          stretch: {top:[0x23AB,SIZE4], ext:[0x23AA,SIZE4], bot:[0x23A9,SIZE4]}
        },
        0x23D0: // vertical line extension
        {
          dir: V, HW: [[.602,SIZE1],[1,MAIN,null,0x2223]], stretch: {ext:[0x2223,MAIN]}
        },
        0x23DE: // horizontal brace down
        {
          dir: H, HW: [],
          stretch: {left:[0xE150,SIZE4], mid:[[0xE153,0xE152],SIZE4], right:[0xE151,SIZE4], rep:[0xE154,SIZE4]}
        },
        0x23DF: // horizontal brace up
        {
          dir: H, HW: [],
          stretch: {left:[0xE152,SIZE4], mid:[[0xE151,0xE150],SIZE4], right:[0xE153,SIZE4], rep:[0xE154,SIZE4]}
        },
        0x27E8: // \langle
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]]
        },
        0x27E9: // \rangle
        {
          dir: V, HW: [[1,MAIN],[1.2,SIZE1],[1.8,SIZE2],[2.4,SIZE3],[3.0,SIZE4]]
        },
        0x27EE: // \lgroup
        {
          dir: V, HW: [[.989,MAIN]],
          stretch: {top:[0x23A7,SIZE4], ext:[0x23AA,SIZE4], bot:[0x23A9,SIZE4]}
        },
        0x27EF: // \rgroup
        {
          dir: V, HW: [[.989,MAIN]],
          stretch: {top:[0x23AB,SIZE4], ext:[0x23AA,SIZE4], bot:[0x23AD,SIZE4]}
        },
        0x002D: {alias: 0x2212, dir:H}, // minus
        0x005E: {alias: 0x02C6, dir:H}, // wide hat
        0x005F: {alias: 0x2212, dir:H}, // low line
        0x007E: {alias: 0x02DC, dir:H}, // wide tilde
        0x00AF: {alias: 0x2212, dir:H}, // over line
        0x0332: {alias: 0x2212, dir:H}, // combining low line
        0x2015: {alias: 0x2212, dir:H}, // horizontal line
        0x2017: {alias: 0x2212, dir:H}, // horizontal line
        0x203E: {alias: 0x2212, dir:H}, // over line
        0x2329: {alias: 0x27E8, dir:V}, // langle
        0x232A: {alias: 0x27E9, dir:V}, // rangle
        0x23AF: {alias: 0x2212, dir:H}, // horizontal line extension
        0x2500: {alias: 0x2212, dir:H}, // horizontal line
        0x2758: {alias: 0x2223, dir:V}, // vertical separator
        0x3008: {alias: 0x27E8, dir:V}, // langle
        0x3009: {alias: 0x27E9, dir:V}, // rangle
        0xFE37: {alias: 0x23DE, dir:H}, // horizontal brace down
        0xFE38: {alias: 0x23DF, dir:H}  // horizontal brace up
      }
    }
  });

  //
  //  Handle error with reversed glyphs for \bigcap and \bigcup in version 1 of fonts
  //
  HTMLCSS.Font.oldLoadComplete = HTMLCSS.Font.loadComplete;
  HTMLCSS.Font.loadComplete = function (font,n) {
    if (n != null) {this.oldLoadComplete(font,n)}
    if (font.family === SIZE1 || font.family === SIZE2) {
      if (font.version === 1) {
        HTMLCSS.FONTDATA.VARIANT["-largeOp"].remap = {0x22C2: 0x22C3, 0x22C3: 0x22C2};
        HTMLCSS.FONTDATA.VARIANT["-smallOp"].remap = {0x22C2: 0x22C3, 0x22C3: 0x22C2};
      }
    }
  };
  
  MathJax.Hub.Register.StartupHook("TeX Jax Ready", function () {
    var TEX = MathJax.InputJax.TeX;
    TEX.Definitions.mathchar0mi.ell  = ['2113',{mathvariant: MML.VARIANT.NORMAL}];
    TEX.Definitions.mathchar0mi.hbar = ['210F',{mathvariant: MML.VARIANT.NORMAL}];
    TEX.Definitions.mathchar0mi.S    = ['00A7',{mathvariant: MML.VARIANT.SCRIPT}];
    if (MathJax.Hub.Browser.isOpera) {
      TEX.Definitions.macros.not = ['Macro','\\mathrel{\\rlap{\\hphantom{\\mathrel{\\subset}}\\notChar}}'];
    } else {
      TEX.Definitions.mathchar0mo.notChar = ['002F',{mathvariant: MML.VARIANT.ITALIC}];
      TEX.Definitions.macros.not = ['Macro','\\mathrel{\\rlap{\\notChar}}'];
    }
  });
  
  HTMLCSS.FONTDATA.FONTS['MathJax_Caligraphic'] = {
    directory: 'Caligraphic/Regular',
    family: 'MathJax_Caligraphic',
    testString: "MATHJAX CALIGRAPHIC",
    skew: {
      0x41: 0.194,
      0x42: 0.139,
      0x43: 0.139,
      0x44: 0.0833,
      0x45: 0.111,
      0x46: 0.111,
      0x47: 0.111,
      0x48: 0.111,
      0x49: 0.0278,
      0x4A: 0.167,
      0x4B: 0.0556,
      0x4C: 0.139,
      0x4D: 0.139,
      0x4E: 0.0833,
      0x4F: 0.111,
      0x50: 0.0833,
      0x51: 0.111,
      0x52: 0.0833,
      0x53: 0.139,
      0x54: 0.0278,
      0x55: 0.0833,
      0x56: 0.0278,
      0x57: 0.0833,
      0x58: 0.139,
      0x59: 0.0833,
      0x5A: 0.139
    },
    0x20: [0,0,250,0,0],               // SPACE
    0x30: [452,22,500,39,460],         // DIGIT ZERO
    0x31: [454,0,500,86,426],          // DIGIT ONE
    0x32: [453,0,500,44,449],          // DIGIT TWO
    0x33: [452,216,500,41,456],        // DIGIT THREE
    0x34: [464,194,500,27,471],        // DIGIT FOUR
    0x35: [453,217,500,50,448],        // DIGIT FIVE
    0x36: [666,22,500,42,456],         // DIGIT SIX
    0x37: [463,216,500,54,485],        // DIGIT SEVEN
    0x38: [666,21,500,43,457],         // DIGIT EIGHT
    0x39: [453,216,500,42,457],        // DIGIT NINE
    0x41: [728,50,798,30,819],         // LATIN CAPITAL LETTER A
    0x42: [705,22,657,31,664],         // LATIN CAPITAL LETTER B
    0x43: [705,25,527,12,533],         // LATIN CAPITAL LETTER C
    0x44: [684,1,771,19,767],          // LATIN CAPITAL LETTER D
    0x45: [706,22,528,30,565],         // LATIN CAPITAL LETTER E
    0x46: [683,32,719,18,829],         // LATIN CAPITAL LETTER F
    0x47: [704,119,595,43,599],        // LATIN CAPITAL LETTER G
    0x48: [683,48,845,18,803],         // LATIN CAPITAL LETTER H
    0x49: [683,1,545,-31,642],         // LATIN CAPITAL LETTER I
    0x4A: [683,119,678,47,839],        // LATIN CAPITAL LETTER J
    0x4B: [705,23,762,32,733],         // LATIN CAPITAL LETTER K
    0x4C: [706,22,690,32,656],         // LATIN CAPITAL LETTER L
    0x4D: [705,50,1201,28,1137],       // LATIN CAPITAL LETTER M
    0x4E: [790,50,820,-27,979],        // LATIN CAPITAL LETTER N
    0x4F: [705,22,796,58,777],         // LATIN CAPITAL LETTER O
    0x50: [684,57,696,19,733],         // LATIN CAPITAL LETTER P
    0x51: [706,131,817,114,787],       // LATIN CAPITAL LETTER Q
    0x52: [683,22,848,19,837],         // LATIN CAPITAL LETTER R
    0x53: [705,23,606,17,642],         // LATIN CAPITAL LETTER S
    0x54: [717,69,545,34,834],         // LATIN CAPITAL LETTER T
    0x55: [684,28,626,-17,687],        // LATIN CAPITAL LETTER U
    0x56: [683,52,613,25,658],         // LATIN CAPITAL LETTER V
    0x57: [683,53,988,25,1034],        // LATIN CAPITAL LETTER W
    0x58: [684,1,713,52,807],          // LATIN CAPITAL LETTER X
    0x59: [683,143,668,31,714],        // LATIN CAPITAL LETTER Y
    0x5A: [683,0,725,37,767],          // LATIN CAPITAL LETTER Z
    0xA0: [0,0,250,0,0]                // NO-BREAK SPACE
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Main-bold'] = {
    directory: 'Main/Bold',
    family: 'MathJax_Main',
    weight: 'bold',
    testString: "MathJax Main",
    skew: {
      0x131: 0.0319,
      0x237: 0.0958,
      0x210F: -0.0319,
      0x2113: 0.128,
      0x2202: 0.0958
    },
    Ranges: [
      [0xA0,0xFF,"Latin1Supplement"],
      [0x100,0x17F,"LatinExtendedA"],
      [0x180,0x24F,"LatinExtendedB"],
      [0x2B0,0x2FF,"SpacingModLetters"],
      [0x300,0x36F,"CombDiacritMarks"],
      [0x2000,0x206F,"GeneralPunctuation"],
      [0x20D0,0x20FF,"CombDiactForSymbols"],
      [0x2100,0x214F,"LetterlikeSymbols"],
      [0x2190,0x21FF,"Arrows"],
      [0x2200,0x22FF,"MathOperators"],
      [0x2300,0x23FF,"MiscTechnical"],
      [0x25A0,0x25FF,"GeometricShapes"],
      [0x2600,0x26FF,"MiscSymbols"],
      [0x27C0,0x27EF,"MiscMathSymbolsA"],
      [0x27F0,0x27FF,"SupplementalArrowsA"],
      [0x2A00,0x2AFF,"SuppMathOperators"]
    ],
    0x20: [0,0,250,0,0],               // SPACE
    0x21: [705,-1,350,89,260],         // EXCLAMATION MARK
    0x22: [694,-329,603,38,492],       // QUOTATION MARK
    0x23: [694,193,958,64,893],        // NUMBER SIGN
    0x24: [750,56,575,64,510],         // DOLLAR SIGN
    0x25: [750,56,958,65,893],         // PERCENT SIGN
    0x26: [705,11,894,48,836],         // AMPERSAND
    0x27: [694,-329,319,74,261],       // APOSTROPHE
    0x28: [751,250,447,103,382],       // LEFT PARENTHESIS
    0x29: [750,249,447,64,343],        // RIGHT PARENTHESIS
    0x2A: [750,-306,575,73,501],       // ASTERISK
    0x2B: [633,131,894,64,829],        // PLUS SIGN
    0x2C: [171,194,319,74,258],        // COMMA
    0x2D: [278,-166,383,13,318],       // HYPHEN-MINUS
    0x2E: [171,-1,319,74,245],         // FULL STOP
    0x2F: [750,250,575,63,511],        // SOLIDUS
    0x30: [655,10,575,45,529],         // DIGIT ZERO
    0x31: [655,0,575,80,494],          // DIGIT ONE
    0x32: [654,0,575,57,517],          // DIGIT TWO
    0x33: [655,12,575,47,526],         // DIGIT THREE
    0x34: [657,0,575,32,542],          // DIGIT FOUR
    0x35: [655,11,575,57,517],         // DIGIT FIVE
    0x36: [655,11,575,48,527],         // DIGIT SIX
    0x37: [676,11,575,64,559],         // DIGIT SEVEN
    0x38: [654,11,575,48,526],         // DIGIT EIGHT
    0x39: [654,11,575,48,526],         // DIGIT NINE
    0x3A: [444,-1,319,74,245],         // COLON
    0x3B: [444,194,319,74,248],        // SEMICOLON
    0x3C: [587,85,894,96,797],         // LESS-THAN SIGN
    0x3D: [393,-109,894,64,829],       // EQUALS SIGN
    0x3E: [587,85,894,95,797],         // GREATER-THAN SIGN
    0x3F: [700,-1,543,65,478],         // QUESTION MARK
    0x40: [700,6,894,64,829],          // COMMERCIAL AT
    0x41: [698,0,869,40,828],          // LATIN CAPITAL LETTER A
    0x42: [687,0,818,39,753],          // LATIN CAPITAL LETTER B
    0x43: [697,11,831,64,767],         // LATIN CAPITAL LETTER C
    0x44: [687,0,882,39,817],          // LATIN CAPITAL LETTER D
    0x45: [681,0,756,38,723],          // LATIN CAPITAL LETTER E
    0x46: [680,0,724,39,675],          // LATIN CAPITAL LETTER F
    0x47: [697,10,904,64,845],         // LATIN CAPITAL LETTER G
    0x48: [686,0,900,39,860],          // LATIN CAPITAL LETTER H
    0x49: [686,0,436,25,410],          // LATIN CAPITAL LETTER I
    0x4A: [686,11,594,8,527],          // LATIN CAPITAL LETTER J
    0x4B: [686,0,901,39,852],          // LATIN CAPITAL LETTER K
    0x4C: [686,0,692,39,643],          // LATIN CAPITAL LETTER L
    0x4D: [687,0,1092,39,1052],        // LATIN CAPITAL LETTER M
    0x4E: [687,1,900,39,861],          // LATIN CAPITAL LETTER N
    0x4F: [696,10,864,64,798],         // LATIN CAPITAL LETTER O
    0x50: [686,0,786,39,721],          // LATIN CAPITAL LETTER P
    0x51: [697,193,864,64,806],        // LATIN CAPITAL LETTER Q
    0x52: [687,11,862,39,858],         // LATIN CAPITAL LETTER R
    0x53: [697,11,639,63,575],         // LATIN CAPITAL LETTER S
    0x54: [675,0,800,41,758],          // LATIN CAPITAL LETTER T
    0x55: [686,12,885,39,845],         // LATIN CAPITAL LETTER U
    0x56: [686,7,869,25,843],          // LATIN CAPITAL LETTER V
    0x57: [686,8,1189,24,1164],        // LATIN CAPITAL LETTER W
    0x58: [686,0,869,33,835],          // LATIN CAPITAL LETTER X
    0x59: [686,0,869,19,849],          // LATIN CAPITAL LETTER Y
    0x5A: [687,0,703,64,645],          // LATIN CAPITAL LETTER Z
    0x5B: [750,250,319,128,293],       // LEFT SQUARE BRACKET
    0x5C: [750,250,575,63,511],        // REVERSE SOLIDUS
    0x5D: [750,250,319,25,190],        // RIGHT SQUARE BRACKET
    0x5E: [694,-520,575,126,448],      // CIRCUMFLEX ACCENT
    0x5F: [-10,61,575,0,574],          // LOW LINE
    0x60: [706,-503,575,114,338],      // GRAVE ACCENT
    0x61: [453,6,559,32,558],          // LATIN SMALL LETTER A
    0x62: [694,7,639,29,601],          // LATIN SMALL LETTER B
    0x63: [453,6,511,39,478],          // LATIN SMALL LETTER C
    0x64: [695,6,639,38,609],          // LATIN SMALL LETTER D
    0x65: [453,6,527,32,494],          // LATIN SMALL LETTER E
    0x66: [700,0,351,40,452],          // LATIN SMALL LETTER F
    0x67: [455,201,575,30,558],        // LATIN SMALL LETTER G
    0x68: [694,0,639,37,623],          // LATIN SMALL LETTER H
    0x69: [695,0,319,40,294],          // LATIN SMALL LETTER I
    0x6A: [695,200,351,-71,274],       // LATIN SMALL LETTER J
    0x6B: [694,0,607,29,587],          // LATIN SMALL LETTER K
    0x6C: [694,0,319,40,301],          // LATIN SMALL LETTER L
    0x6D: [451,0,958,37,942],          // LATIN SMALL LETTER M
    0x6E: [450,0,639,37,623],          // LATIN SMALL LETTER N
    0x6F: [452,5,575,32,542],          // LATIN SMALL LETTER O
    0x70: [450,194,639,28,600],        // LATIN SMALL LETTER P
    0x71: [450,194,607,38,609],        // LATIN SMALL LETTER Q
    0x72: [450,0,474,29,442],          // LATIN SMALL LETTER R
    0x73: [453,7,454,37,415],          // LATIN SMALL LETTER S
    0x74: [636,6,447,21,382],          // LATIN SMALL LETTER T
    0x75: [450,6,639,37,623],          // LATIN SMALL LETTER U
    0x76: [444,4,607,26,580],          // LATIN SMALL LETTER V
    0x77: [444,5,831,25,805],          // LATIN SMALL LETTER W
    0x78: [444,0,607,21,586],          // LATIN SMALL LETTER X
    0x79: [444,200,607,23,580],        // LATIN SMALL LETTER Y
    0x7A: [445,0,511,31,462],          // LATIN SMALL LETTER Z
    0x7B: [751,251,575,69,504],        // LEFT CURLY BRACKET
    0x7C: [750,249,319,129,190],       // VERTICAL LINE
    0x7D: [751,251,575,70,504],        // RIGHT CURLY BRACKET
    0x7E: [344,-201,575,96,478],       // TILDE
    0x393: [680,0,692,39,643],         // GREEK CAPITAL LETTER GAMMA
    0x394: [698,0,958,56,901],         // GREEK CAPITAL LETTER DELTA
    0x398: [696,10,894,64,829],        // GREEK CAPITAL LETTER THETA
    0x39B: [699,0,806,40,765],         // GREEK CAPITAL LETTER LAMDA
    0x39E: [675,0,767,48,718],         // GREEK CAPITAL LETTER XI
    0x3A0: [680,0,900,39,860],         // GREEK CAPITAL LETTER PI
    0x3A3: [686,0,831,63,766],         // GREEK CAPITAL LETTER SIGMA
    0x3A5: [697,0,894,64,829],         // GREEK CAPITAL LETTER UPSILON
    0x3A6: [686,0,831,64,766],         // GREEK CAPITAL LETTER PHI
    0x3A8: [686,0,894,64,829],         // GREEK CAPITAL LETTER PSI
    0x3A9: [696,1,831,51,780]          // GREEK CAPITAL LETTER OMEGA
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Main-italic'] = {
    directory: 'Main/Italic',
    family: 'MathJax_Main',
    style: 'italic',
    testString: "MathJax Main",
    Ranges: [
      [0xA0,0xFF,"Latin1Supplement"],
      [0x300,0x36F,"CombDiacritMarks"],
      [0x2000,0x206F,"GeneralPunctuation"],
      [0x2100,0x214F,"LetterlikeSymbols"]
    ],
    0x20: [0,0,250,0,0],               // SPACE
    0x21: [716,0,307,107,380],         // EXCLAMATION MARK
    0x22: [694,-379,514,176,538],      // QUOTATION MARK
    0x23: [694,194,818,115,828],       // NUMBER SIGN
    0x25: [751,56,818,144,848],        // PERCENT SIGN
    0x26: [716,22,767,127,802],        // AMPERSAND
    0x27: [694,-379,307,213,377],      // APOSTROPHE
    0x28: [750,250,409,144,517],       // LEFT PARENTHESIS
    0x29: [750,250,409,17,390],        // RIGHT PARENTHESIS
    0x2A: [751,-320,511,195,584],      // ASTERISK
    0x2B: [558,57,767,139,753],        // PLUS SIGN
    0x2C: [121,194,307,69,233],        // COMMA
    0x2D: [251,-179,358,84,341],       // HYPHEN-MINUS
    0x2E: [121,0,307,107,231],         // FULL STOP
    0x2F: [750,250,511,19,617],        // SOLIDUS
    0x30: [665,21,511,110,562],        // DIGIT ZERO
    0x31: [666,0,511,110,468],         // DIGIT ONE
    0x32: [666,22,511,76,551],         // DIGIT TWO
    0x33: [667,22,511,96,563],         // DIGIT THREE
    0x34: [666,194,511,46,479],        // DIGIT FOUR
    0x35: [666,22,511,106,567],        // DIGIT FIVE
    0x36: [665,22,511,120,566],        // DIGIT SIX
    0x37: [666,22,511,136,634],        // DIGIT SEVEN
    0x38: [666,21,511,99,553],         // DIGIT EIGHT
    0x39: [666,22,511,107,553],        // DIGIT NINE
    0x3A: [431,0,307,107,308],         // COLON
    0x3B: [431,194,307,70,308],        // SEMICOLON
    0x3D: [367,-133,767,116,776],      // EQUALS SIGN
    0x3F: [717,0,511,195,551],         // QUESTION MARK
    0x40: [705,11,767,152,789],        // COMMERCIAL AT
    0x41: [716,1,743,58,696],          // LATIN CAPITAL LETTER A
    0x42: [683,1,704,57,732],          // LATIN CAPITAL LETTER B
    0x43: [705,21,716,150,812],        // LATIN CAPITAL LETTER C
    0x44: [683,1,755,56,775],          // LATIN CAPITAL LETTER D
    0x45: [681,0,678,54,743],          // LATIN CAPITAL LETTER E
    0x46: [681,0,653,54,731],          // LATIN CAPITAL LETTER F
    0x47: [705,22,774,149,812],        // LATIN CAPITAL LETTER G
    0x48: [683,0,743,54,860],          // LATIN CAPITAL LETTER H
    0x49: [683,0,386,49,508],          // LATIN CAPITAL LETTER I
    0x4A: [683,21,525,78,622],         // LATIN CAPITAL LETTER J
    0x4B: [683,0,769,54,859],          // LATIN CAPITAL LETTER K
    0x4C: [683,0,627,54,628],          // LATIN CAPITAL LETTER L
    0x4D: [684,0,897,58,1010],         // LATIN CAPITAL LETTER M
    0x4E: [684,0,743,54,860],          // LATIN CAPITAL LETTER N
    0x4F: [704,22,767,149,788],        // LATIN CAPITAL LETTER O
    0x50: [684,0,678,55,729],          // LATIN CAPITAL LETTER P
    0x51: [704,194,767,149,788],       // LATIN CAPITAL LETTER Q
    0x52: [683,22,729,55,723],         // LATIN CAPITAL LETTER R
    0x53: [706,22,562,74,634],         // LATIN CAPITAL LETTER S
    0x54: [678,0,716,171,807],         // LATIN CAPITAL LETTER T
    0x55: [684,22,743,194,860],        // LATIN CAPITAL LETTER U
    0x56: [683,22,743,205,868],        // LATIN CAPITAL LETTER V
    0x57: [683,22,999,205,1124],       // LATIN CAPITAL LETTER W
    0x58: [684,0,743,50,826],          // LATIN CAPITAL LETTER X
    0x59: [684,0,743,198,875],         // LATIN CAPITAL LETTER Y
    0x5A: [683,1,613,80,705],          // LATIN CAPITAL LETTER Z
    0x5B: [751,251,307,73,446],        // LEFT SQUARE BRACKET
    0x5D: [751,251,307,-14,359],       // RIGHT SQUARE BRACKET
    0x5E: [694,-527,511,260,528],      // CIRCUMFLEX ACCENT
    0x5F: [-24,62,511,91,554],         // LOW LINE
    0x61: [442,11,511,101,543],        // LATIN SMALL LETTER A
    0x62: [694,11,460,108,467],        // LATIN SMALL LETTER B
    0x63: [441,10,460,103,470],        // LATIN SMALL LETTER C
    0x64: [694,11,511,100,567],        // LATIN SMALL LETTER D
    0x65: [442,10,460,107,470],        // LATIN SMALL LETTER E
    0x66: [705,204,307,-23,450],       // LATIN SMALL LETTER F
    0x67: [442,205,460,46,495],        // LATIN SMALL LETTER G
    0x68: [695,11,511,69,544],         // LATIN SMALL LETTER H
    0x69: [656,10,307,75,340],         // LATIN SMALL LETTER I
    0x6A: [656,204,307,-32,364],       // LATIN SMALL LETTER J
    0x6B: [694,11,460,69,499],         // LATIN SMALL LETTER K
    0x6C: [694,11,256,87,312],         // LATIN SMALL LETTER L
    0x6D: [443,11,818,75,851],         // LATIN SMALL LETTER M
    0x6E: [443,11,562,75,595],         // LATIN SMALL LETTER N
    0x6F: [442,11,511,103,517],        // LATIN SMALL LETTER O
    0x70: [442,194,511,5,518],         // LATIN SMALL LETTER P
    0x71: [442,195,460,100,504],       // LATIN SMALL LETTER Q
    0x72: [442,11,422,75,484],         // LATIN SMALL LETTER R
    0x73: [442,11,409,76,418],         // LATIN SMALL LETTER S
    0x74: [627,11,332,87,373],         // LATIN SMALL LETTER T
    0x75: [441,11,537,75,570],         // LATIN SMALL LETTER U
    0x76: [443,10,460,75,492],         // LATIN SMALL LETTER V
    0x77: [443,12,664,74,696],         // LATIN SMALL LETTER W
    0x78: [442,11,464,58,513],         // LATIN SMALL LETTER X
    0x79: [441,206,486,75,522],        // LATIN SMALL LETTER Y
    0x7A: [442,11,409,54,466],         // LATIN SMALL LETTER Z
    0x7E: [318,-208,511,246,571],      // TILDE
    0xA3: [714,11,769,87,699],         // POUND SIGN
    0x131: [441,10,307,75,340],        // LATIN SMALL LETTER DOTLESS I
    0x237: [442,205,332,-32,327],      // LATIN SMALL LETTER DOTLESS J
    0x393: [680,0,627,54,706],         // GREEK CAPITAL LETTER GAMMA
    0x394: [717,1,818,70,751],         // GREEK CAPITAL LETTER DELTA
    0x398: [704,22,767,149,788],       // GREEK CAPITAL LETTER THETA
    0x39B: [717,0,692,58,646],         // GREEK CAPITAL LETTER LAMDA
    0x39E: [678,1,664,74,754],         // GREEK CAPITAL LETTER XI
    0x3A0: [680,0,743,54,859],         // GREEK CAPITAL LETTER PI
    0x3A3: [683,1,716,80,782],         // GREEK CAPITAL LETTER SIGMA
    0x3A5: [706,0,767,213,833],        // GREEK CAPITAL LETTER UPSILON
    0x3A6: [683,1,716,158,728],        // GREEK CAPITAL LETTER PHI
    0x3A8: [683,0,767,207,824],        // GREEK CAPITAL LETTER PSI
    0x3A9: [705,0,716,100,759]         // GREEK CAPITAL LETTER OMEGA
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Main'] = {
    directory: 'Main/Regular',
    family: 'MathJax_Main',
    testString: "MathJax Main",
    skew: {
      0x131: 0.0278,
      0x237: 0.0833,
      0x2113: 0.111,
      0x2118: 0.111,
      0x2202: 0.0833
    },
    Ranges: [
      [0x2B0,0x2FF,"SpacingModLetters"],
      [0x300,0x36F,"CombDiacritMarks"],
      [0x25A0,0x25FF,"GeometricShapes"],
      [0x2600,0x26FF,"MiscSymbols"]
    ],
    0x20: [0,0,250,0,0],               // SPACE
    0x21: [716,-1,278,78,199],         // EXCLAMATION MARK
    0x22: [694,-379,500,34,372],       // QUOTATION MARK
    0x23: [694,194,833,55,778],        // NUMBER SIGN
    0x24: [750,56,500,54,444],         // DOLLAR SIGN
    0x25: [750,56,833,56,776],         // PERCENT SIGN
    0x26: [717,22,778,42,727],         // AMPERSAND
    0x27: [694,-379,278,78,212],       // APOSTROPHE
    0x28: [751,251,389,94,333],        // LEFT PARENTHESIS
    0x29: [750,250,389,55,294],        // RIGHT PARENTHESIS
    0x2A: [750,-319,500,64,435],       // ASTERISK
    0x2B: [583,83,778,55,722],         // PLUS SIGN
    0x2C: [121,194,278,78,210],        // COMMA
    0x2D: [252,-179,333,11,277],       // HYPHEN-MINUS
    0x2E: [120,0,278,78,199],          // FULL STOP
    0x2F: [751,250,500,56,445],        // SOLIDUS
    0x30: [666,22,500,39,460],         // DIGIT ZERO
    0x31: [666,0,500,83,427],          // DIGIT ONE
    0x32: [666,1,500,49,449],          // DIGIT TWO
    0x33: [665,23,500,41,457],         // DIGIT THREE
    0x34: [677,0,500,28,471],          // DIGIT FOUR
    0x35: [666,22,500,49,449],         // DIGIT FIVE
    0x36: [666,22,500,42,456],         // DIGIT SIX
    0x37: [676,22,500,55,485],         // DIGIT SEVEN
    0x38: [666,22,500,43,457],         // DIGIT EIGHT
    0x39: [666,22,500,41,456],         // DIGIT NINE
    0x3A: [430,0,278,78,199],          // COLON
    0x3B: [430,194,278,78,202],        // SEMICOLON
    0x3C: [540,40,778,83,694],         // LESS-THAN SIGN
    0x3D: [367,-133,778,55,722],       // EQUALS SIGN
    0x3E: [540,40,778,82,694],         // GREATER-THAN SIGN
    0x3F: [706,-1,472,55,416],         // QUESTION MARK
    0x40: [705,11,778,56,722],         // COMMERCIAL AT
    0x41: [717,0,750,32,717],          // LATIN CAPITAL LETTER A
    0x42: [684,0,708,28,651],          // LATIN CAPITAL LETTER B
    0x43: [706,21,722,56,666],         // LATIN CAPITAL LETTER C
    0x44: [683,0,764,27,708],          // LATIN CAPITAL LETTER D
    0x45: [680,0,681,24,652],          // LATIN CAPITAL LETTER E
    0x46: [680,0,653,25,611],          // LATIN CAPITAL LETTER F
    0x47: [706,22,785,56,735],         // LATIN CAPITAL LETTER G
    0x48: [683,0,750,25,724],          // LATIN CAPITAL LETTER H
    0x49: [683,0,361,21,339],          // LATIN CAPITAL LETTER I
    0x4A: [683,22,514,25,465],         // LATIN CAPITAL LETTER J
    0x4B: [683,0,778,24,736],          // LATIN CAPITAL LETTER K
    0x4C: [683,0,625,25,582],          // LATIN CAPITAL LETTER L
    0x4D: [683,0,917,29,887],          // LATIN CAPITAL LETTER M
    0x4E: [683,0,750,25,724],          // LATIN CAPITAL LETTER N
    0x4F: [705,22,778,56,722],         // LATIN CAPITAL LETTER O
    0x50: [684,0,681,27,624],          // LATIN CAPITAL LETTER P
    0x51: [705,193,778,56,728],        // LATIN CAPITAL LETTER Q
    0x52: [684,22,736,27,732],         // LATIN CAPITAL LETTER R
    0x53: [706,23,556,55,500],         // LATIN CAPITAL LETTER S
    0x54: [677,0,722,36,685],          // LATIN CAPITAL LETTER T
    0x55: [684,22,750,25,724],         // LATIN CAPITAL LETTER U
    0x56: [683,23,750,19,730],         // LATIN CAPITAL LETTER V
    0x57: [683,23,1028,18,1009],       // LATIN CAPITAL LETTER W
    0x58: [683,1,750,23,727],          // LATIN CAPITAL LETTER X
    0x59: [684,0,750,11,738],          // LATIN CAPITAL LETTER Y
    0x5A: [683,1,611,55,560],          // LATIN CAPITAL LETTER Z
    0x5B: [750,250,278,118,255],       // LEFT SQUARE BRACKET
    0x5C: [750,250,500,56,444],        // REVERSE SOLIDUS
    0x5D: [750,250,278,22,159],        // RIGHT SQUARE BRACKET
    0x5E: [694,-531,500,112,387],      // CIRCUMFLEX ACCENT
    0x5F: [-25,62,500,0,499],          // LOW LINE
    0x60: [699,-505,500,106,295],      // GRAVE ACCENT
    0x61: [448,11,500,34,493],         // LATIN SMALL LETTER A
    0x62: [694,11,556,20,522],         // LATIN SMALL LETTER B
    0x63: [448,11,444,34,415],         // LATIN SMALL LETTER C
    0x64: [694,11,556,34,535],         // LATIN SMALL LETTER D
    0x65: [448,11,444,28,415],         // LATIN SMALL LETTER E
    0x66: [705,0,306,25,372],          // LATIN SMALL LETTER F
    0x67: [453,206,500,29,485],        // LATIN SMALL LETTER G
    0x68: [695,0,556,25,543],          // LATIN SMALL LETTER H
    0x69: [669,0,278,26,255],          // LATIN SMALL LETTER I
    0x6A: [669,205,306,-55,218],       // LATIN SMALL LETTER J
    0x6B: [695,0,528,20,512],          // LATIN SMALL LETTER K
    0x6C: [694,0,278,26,263],          // LATIN SMALL LETTER L
    0x6D: [443,0,833,25,820],          // LATIN SMALL LETTER M
    0x6E: [443,0,556,25,543],          // LATIN SMALL LETTER N
    0x6F: [448,10,500,28,471],         // LATIN SMALL LETTER O
    0x70: [443,194,556,20,522],        // LATIN SMALL LETTER P
    0x71: [442,194,528,33,535],        // LATIN SMALL LETTER Q
    0x72: [442,0,392,20,364],          // LATIN SMALL LETTER R
    0x73: [449,12,394,32,359],         // LATIN SMALL LETTER S
    0x74: [615,10,389,18,334],         // LATIN SMALL LETTER T
    0x75: [442,11,556,25,542],         // LATIN SMALL LETTER U
    0x76: [431,11,528,19,508],         // LATIN SMALL LETTER V
    0x77: [432,12,722,18,704],         // LATIN SMALL LETTER W
    0x78: [431,0,528,10,516],          // LATIN SMALL LETTER X
    0x79: [431,204,528,19,508],        // LATIN SMALL LETTER Y
    0x7A: [431,0,444,28,401],          // LATIN SMALL LETTER Z
    0x7B: [750,250,500,64,434],        // LEFT CURLY BRACKET
    0x7C: [750,250,278,119,159],       // VERTICAL LINE
    0x7D: [750,250,500,64,435],        // RIGHT CURLY BRACKET
    0x7E: [318,-215,500,83,416],       // TILDE
    0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
    0xA8: [669,-554,500,95,404],       // DIAERESIS
    0xAC: [356,-89,667,55,611],        // NOT SIGN
    0xAF: [590,-544,500,69,430],       // MACRON
    0xB0: [715,-542,500,147,352],      // DEGREE SIGN
    0xB1: [666,0,778,55,722],          // PLUS-MINUS SIGN
    0xB4: [699,-505,500,203,393],      // ACUTE ACCENT
    0xD7: [491,-9,778,147,631],        // MULTIPLICATION SIGN
    0xF7: [537,36,778,55,721],         // DIVISION SIGN
    0x131: [442,0,278,26,255],         // LATIN SMALL LETTER DOTLESS I
    0x237: [442,205,306,-55,218],      // LATIN SMALL LETTER DOTLESS J
    0x2C6: [694,-531,500,112,387],     // MODIFIER LETTER CIRCUMFLEX ACCENT
    0x2C7: [644,-513,500,114,385],     // CARON
    0x2C9: [590,-544,500,69,430],      // MODIFIER LETTER MACRON
    0x2CA: [699,-505,500,203,393],     // MODIFIER LETTER ACUTE ACCENT
    0x2CB: [699,-505,500,106,295],     // MODIFIER LETTER GRAVE ACCENT
    0x2D8: [694,-515,500,92,407],      // BREVE
    0x2D9: [669,-549,500,190,309],     // DOT ABOVE
    0x2DC: [668,-565,500,83,416],      // SMALL TILDE
    0x393: [681,0,625,25,582],         // GREEK CAPITAL LETTER GAMMA
    0x394: [716,0,833,46,786],         // GREEK CAPITAL LETTER DELTA
    0x398: [705,22,778,56,722],        // GREEK CAPITAL LETTER THETA
    0x39B: [717,0,694,32,661],         // GREEK CAPITAL LETTER LAMDA
    0x39E: [677,0,667,42,624],         // GREEK CAPITAL LETTER XI
    0x3A0: [680,0,750,25,724],         // GREEK CAPITAL LETTER PI
    0x3A3: [683,1,722,55,666],         // GREEK CAPITAL LETTER SIGMA
    0x3A5: [705,0,778,55,722],         // GREEK CAPITAL LETTER UPSILON
    0x3A6: [683,0,722,56,665],         // GREEK CAPITAL LETTER PHI
    0x3A8: [683,0,778,54,722],         // GREEK CAPITAL LETTER PSI
    0x3A9: [704,1,722,44,677],         // GREEK CAPITAL LETTER OMEGA
    0x2002: [0,0,500,0,0],             // ??
    0x2003: [0,0,999,0,0],             // ??
    0x2004: [0,0,333,0,0],             // ??
    0x2005: [0,0,250,0,0],             // ??
    0x2006: [0,0,167,0,0],             // ??
    0x2009: [0,0,167,0,0],             // ??
    0x200A: [0,0,83,0,0],              // ??
    0x2013: [285,-248,500,0,499],      // EN DASH
    0x2014: [285,-248,1000,0,999],     // EM DASH
    0x2018: [694,-379,278,64,198],     // LEFT SINGLE QUOTATION MARK
    0x2019: [694,-379,278,78,212],     // RIGHT SINGLE QUOTATION MARK
    0x201C: [694,-379,500,128,466],    // LEFT DOUBLE QUOTATION MARK
    0x201D: [694,-379,500,34,372],     // RIGHT DOUBLE QUOTATION MARK
    0x2020: [705,217,444,55,390],      // DAGGER
    0x2021: [705,206,444,55,389],      // DOUBLE DAGGER
    0x2026: [120,0,1172,78,1093],      // HORIZONTAL ELLIPSIS
    0x2032: [560,-43,275,30,262],      // PRIME
    0x20D7: [714,-516,0,-471,-29],     // COMBINING RIGHT ARROW ABOVE
    0x210F: [695,13,540,42,562],       // stix-/hbar - Planck's over 2pi
    0x2111: [705,11,722,54,693],       // BLACK-LETTER CAPITAL I
    0x2113: [706,20,417,6,398],        // SCRIPT SMALL L
    0x2118: [453,216,636,67,625],      // SCRIPT CAPITAL P
    0x211C: [717,22,722,40,716],       // BLACK-LETTER CAPITAL R
    0x2135: [694,1,611,54,556],        // ALEF SYMBOL
    0x2190: [511,12,1000,54,944],      // LEFTWARDS ARROW
    0x2191: [694,194,500,17,483],      // UPWARDS ARROW
    0x2192: [512,11,1000,55,945],      // RIGHTWARDS ARROW
    0x2193: [694,194,500,17,483],      // DOWNWARDS ARROW
    0x2194: [511,11,1000,55,945],      // LEFT RIGHT ARROW
    0x2195: [772,272,500,17,483],      // UP DOWN ARROW
    0x2196: [720,196,1000,29,944],     // NORTH WEST ARROW
    0x2197: [720,195,1000,55,970],     // NORTH EAST ARROW
    0x2198: [695,220,1000,55,970],     // SOUTH EAST ARROW
    0x2199: [695,220,1000,29,944],     // SOUTH WEST ARROW
    0x21A6: [512,11,1000,54,945],      // RIGHTWARDS ARROW FROM BAR
    0x21A9: [511,12,1126,54,1070],     // LEFTWARDS ARROW WITH HOOK
    0x21AA: [512,11,1126,55,1071],     // RIGHTWARDS ARROW WITH HOOK
    0x21BC: [511,-230,1000,55,944],    // LEFTWARDS HARPOON WITH BARB UPWARDS
    0x21BD: [270,11,1000,55,944],      // LEFTWARDS HARPOON WITH BARB DOWNWARDS
    0x21C0: [511,-230,1000,55,944],    // RIGHTWARDS HARPOON WITH BARB UPWARDS
    0x21C1: [270,11,1000,55,945],      // RIGHTWARDS HARPOON WITH BARB DOWNWARDS
    0x21CC: [671,11,1000,55,944],      // RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON
    0x21D0: [525,24,1000,55,944],      // LEFTWARDS DOUBLE ARROW
    0x21D1: [694,194,611,31,579],      // UPWARDS DOUBLE ARROW
    0x21D2: [525,25,1000,55,944],      // RIGHTWARDS DOUBLE ARROW
    0x21D3: [694,194,611,31,579],      // DOWNWARDS DOUBLE ARROW
    0x21D4: [525,25,1000,34,966],      // LEFT RIGHT DOUBLE ARROW
    0x21D5: [772,272,611,31,580],      // UP DOWN DOUBLE ARROW
    0x2200: [694,22,556,0,556],        // FOR ALL
    0x2202: [715,22,531,41,566],       // PARTIAL DIFFERENTIAL
    0x2203: [694,0,556,55,500],        // THERE EXISTS
    0x2205: [772,78,500,39,460],       // EMPTY SET
    0x2207: [683,33,833,46,786],       // NABLA
    0x2208: [541,41,667,84,584],       // ELEMENT OF
    0x2209: [716,215,667,84,584],      // stix-negated (vert) set membership, variant
    0x220B: [541,40,667,83,582],       // CONTAINS AS MEMBER
    0x2212: [270,-230,778,83,694],     // MINUS SIGN
    0x2213: [500,167,778,55,722],      // MINUS-OR-PLUS SIGN
    0x2215: [751,250,500,56,445],      // DIVISION SLASH
    0x2216: [750,250,500,56,444],      // SET MINUS
    0x2217: [465,-34,500,64,435],      // ASTERISK OPERATOR
    0x2218: [444,-55,500,55,444],      // RING OPERATOR
    0x2219: [444,-55,500,55,444],      // BULLET OPERATOR
    0x221A: [800,200,833,72,853],      // SQUARE ROOT
    0x221D: [442,11,778,56,722],       // PROPORTIONAL TO
    0x221E: [442,11,1000,55,944],      // INFINITY
    0x2220: [694,0,722,55,666],        // ANGLE
    0x2223: [750,250,278,119,159],     // DIVIDES
    0x2225: [750,250,500,132,367],     // PARALLEL TO
    0x2227: [598,22,667,55,611],       // LOGICAL AND
    0x2228: [598,22,667,55,611],       // LOGICAL OR
    0x2229: [598,22,667,55,611],       // stix-intersection, serifs
    0x222A: [599,22,667,55,611],       // stix-union, serifs
    0x222B: [716,216,417,55,472],      // INTEGRAL
    0x223C: [367,-133,778,55,722],     // TILDE OPERATOR
    0x2240: [583,83,278,55,222],       // WREATH PRODUCT
    0x2243: [464,-36,778,55,722],      // ASYMPTOTICALLY EQUAL TO
    0x2245: [589,-22,1000,55,722],     // APPROXIMATELY EQUAL TO
    0x2248: [483,-55,778,55,722],      // ALMOST EQUAL TO
    0x224D: [484,-16,778,55,722],      // EQUIVALENT TO
    0x2250: [670,-133,778,55,722],     // APPROACHES THE LIMIT
    0x2260: [716,215,778,55,722],      // stix-not (vert) equals
    0x2261: [464,-36,778,55,722],      // IDENTICAL TO
    0x2264: [636,138,778,83,694],      // LESS-THAN OR EQUAL TO
    0x2265: [636,138,778,82,694],      // GREATER-THAN OR EQUAL TO
    0x226A: [568,68,1000,56,944],      // MUCH LESS-THAN
    0x226B: [567,67,1000,55,945],      // MUCH GREATER-THAN
    0x227A: [539,41,778,84,695],       // PRECEDES
    0x227B: [539,41,778,83,694],       // SUCCEEDS
    0x2282: [540,41,778,84,695],       // SUBSET OF
    0x2283: [541,40,778,82,693],       // SUPERSET OF
    0x2286: [636,139,778,84,695],      // SUBSET OF OR EQUAL TO
    0x2287: [637,138,778,83,693],      // SUPERSET OF OR EQUAL TO
    0x228E: [599,22,667,55,611],       // MULTISET UNION
    0x2291: [636,138,778,83,714],      // SQUARE IMAGE OF OR EQUAL TO
    0x2292: [636,138,778,63,694],      // SQUARE ORIGINAL OF OR EQUAL TO
    0x2293: [598,0,667,61,605],        // stix-square intersection, serifs
    0x2294: [598,0,667,61,605],        // stix-square union, serifs
    0x2295: [583,83,778,56,722],       // stix-circled plus (with rim)
    0x2296: [583,83,778,56,722],       // CIRCLED MINUS
    0x2297: [583,83,778,56,722],       // stix-circled times (with rim)
    0x2298: [583,83,778,56,722],       // CIRCLED DIVISION SLASH
    0x2299: [583,83,778,56,722],       // CIRCLED DOT OPERATOR
    0x22A2: [694,0,611,55,555],        // RIGHT TACK
    0x22A3: [694,0,611,55,555],        // LEFT TACK
    0x22A4: [668,0,778,55,723],        // DOWN TACK
    0x22A5: [668,0,778,55,723],        // UP TACK
    0x22A8: [750,250,867,119,811],     // TRUE
    0x22C4: [488,-12,500,12,488],      // DIAMOND OPERATOR
    0x22C5: [310,-190,278,78,199],     // DOT OPERATOR
    0x22C6: [486,-16,500,3,497],       // STAR OPERATOR
    0x22C8: [505,6,900,25,873],        // BOWTIE
    0x22EE: [900,30,278,78,199],       // VERTICAL ELLIPSIS
    0x22EF: [310,-190,1172,78,1093],   // MIDLINE HORIZONTAL ELLIPSIS
    0x22F1: [820,-100,1282,133,1148],  // DOWN RIGHT DIAGONAL ELLIPSIS
    0x2308: [751,250,444,174,422],     // LEFT CEILING
    0x2309: [751,250,444,21,269],      // RIGHT CEILING
    0x230A: [750,251,444,174,422],     // LEFT FLOOR
    0x230B: [751,251,444,20,269],      // RIGHT FLOOR
    0x2322: [388,-122,1000,55,944],    // stix-small down curve
    0x2323: [378,-134,1000,55,944],    // stix-small up curve
    0x23B0: [744,245,412,55,357],      // UPPER LEFT OR LOWER RIGHT CURLY BRACKET SECTION
    0x23B1: [745,244,412,55,357],      // UPPER RIGHT OR LOWER LEFT CURLY BRACKET SECTION
    0x27E8: [750,250,389,110,333],     // MATHEMATICAL LEFT ANGLE BRACKET
    0x27E9: [750,250,389,55,278],      // MATHEMATICAL RIGHT ANGLE BRACKET
    0x27EE: [744,245,412,173,357],     // MATHEMATICAL LEFT FLATTENED PARENTHESIS
    0x27EF: [744,245,412,55,240],      // MATHEMATICAL RIGHT FLATTENED PARENTHESIS
    0x27F5: [511,12,1609,54,1525],     // LONG LEFTWARDS ARROW
    0x27F6: [512,11,1638,83,1554],     // LONG RIGHTWARDS ARROW
    0x27F7: [512,12,1859,54,1804],     // LONG LEFT RIGHT ARROW
    0x27F8: [525,24,1609,55,1553],     // LONG LEFTWARDS DOUBLE ARROW
    0x27F9: [525,25,1638,55,1582],     // LONG RIGHTWARDS DOUBLE ARROW
    0x27FA: [525,24,1858,55,1802],     // LONG LEFT RIGHT DOUBLE ARROW
    0x27FC: [512,11,1638,54,1554],     // LONG RIGHTWARDS ARROW FROM BAR
    0x2A3F: [684,0,750,28,721],        // AMALGAMATION OR COPRODUCT
    0x2AAF: [636,138,778,83,695],      // PRECEDES ABOVE SINGLE-LINE EQUALS SIGN
    0x2AB0: [636,138,778,83,694]       // SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Math-italic'] = {
    directory: 'Math/Italic',
    family: 'MathJax_Math',
    style: 'italic',
    testString: "MathJax Math",
    skew: {
      0x41: 0.139,
      0x42: 0.0833,
      0x43: 0.0833,
      0x44: 0.0556,
      0x45: 0.0833,
      0x46: 0.0833,
      0x47: 0.0833,
      0x48: 0.0556,
      0x49: 0.111,
      0x4A: 0.167,
      0x4B: 0.0556,
      0x4C: 0.0278,
      0x4D: 0.0833,
      0x4E: 0.0833,
      0x4F: 0.0833,
      0x50: 0.0833,
      0x51: 0.0833,
      0x52: 0.0833,
      0x53: 0.0833,
      0x54: 0.0833,
      0x55: 0.0278,
      0x58: 0.0833,
      0x5A: 0.0833,
      0x63: 0.0556,
      0x64: 0.167,
      0x65: 0.0556,
      0x66: 0.167,
      0x67: 0.0278,
      0x68: -0.0278,
      0x6C: 0.0833,
      0x6F: 0.0556,
      0x70: 0.0833,
      0x71: 0.0833,
      0x72: 0.0556,
      0x73: 0.0556,
      0x74: 0.0833,
      0x75: 0.0278,
      0x76: 0.0278,
      0x77: 0.0833,
      0x78: 0.0278,
      0x79: 0.0556,
      0x7A: 0.0556,
      0x393: 0.0833,
      0x394: 0.167,
      0x398: 0.0833,
      0x39B: 0.167,
      0x39E: 0.0833,
      0x3A0: 0.0556,
      0x3A3: 0.0833,
      0x3A5: 0.0556,
      0x3A6: 0.0833,
      0x3A8: 0.0556,
      0x3A9: 0.0833,
      0x3B1: 0.0278,
      0x3B2: 0.0833,
      0x3B4: 0.0556,
      0x3B5: 0.0833,
      0x3B6: 0.0833,
      0x3B7: 0.0556,
      0x3B8: 0.0833,
      0x3B9: 0.0556,
      0x3BC: 0.0278,
      0x3BD: 0.0278,
      0x3BE: 0.111,
      0x3BF: 0.0556,
      0x3C1: 0.0833,
      0x3C2: 0.0833,
      0x3C4: 0.0278,
      0x3C5: 0.0278,
      0x3C6: 0.0833,
      0x3C7: 0.0556,
      0x3C8: 0.111,
      0x3D1: 0.0833,
      0x3D5: 0.0833,
      0x3F1: 0.0833,
      0x3F5: 0.0556
    },
    0x20: [0,0,250,0,0],               // SPACE
    0x2F: [716,215,778,139,638],       // SOLIDUS
    0x41: [717,0,750,35,727],          // LATIN CAPITAL LETTER A
    0x42: [683,0,759,35,756],          // LATIN CAPITAL LETTER B
    0x43: [705,22,715,50,760],         // LATIN CAPITAL LETTER C
    0x44: [683,1,828,32,804],          // LATIN CAPITAL LETTER D
    0x45: [680,1,738,30,764],          // LATIN CAPITAL LETTER E
    0x46: [681,0,643,30,749],          // LATIN CAPITAL LETTER F
    0x47: [705,22,786,50,760],         // LATIN CAPITAL LETTER G
    0x48: [683,0,831,31,889],          // LATIN CAPITAL LETTER H
    0x49: [684,0,440,26,504],          // LATIN CAPITAL LETTER I
    0x4A: [683,22,555,57,633],         // LATIN CAPITAL LETTER J
    0x4B: [684,0,849,31,889],          // LATIN CAPITAL LETTER K
    0x4C: [684,1,681,32,647],          // LATIN CAPITAL LETTER L
    0x4D: [684,0,970,35,1051],         // LATIN CAPITAL LETTER M
    0x4E: [684,0,803,31,888],          // LATIN CAPITAL LETTER N
    0x4F: [704,22,763,50,740],         // LATIN CAPITAL LETTER O
    0x50: [683,0,642,33,751],          // LATIN CAPITAL LETTER P
    0x51: [704,195,791,50,740],        // LATIN CAPITAL LETTER Q
    0x52: [683,22,759,33,755],         // LATIN CAPITAL LETTER R
    0x53: [705,22,613,52,645],         // LATIN CAPITAL LETTER S
    0x54: [678,0,584,21,705],          // LATIN CAPITAL LETTER T
    0x55: [684,22,683,59,767],         // LATIN CAPITAL LETTER U
    0x56: [683,23,583,52,769],         // LATIN CAPITAL LETTER V
    0x57: [684,22,944,51,1048],        // LATIN CAPITAL LETTER W
    0x58: [684,1,828,25,852],          // LATIN CAPITAL LETTER X
    0x59: [683,-1,581,29,763],         // LATIN CAPITAL LETTER Y
    0x5A: [684,1,683,58,724],          // LATIN CAPITAL LETTER Z
    0x61: [441,10,529,33,506],         // LATIN SMALL LETTER A
    0x62: [694,11,429,39,422],         // LATIN SMALL LETTER B
    0x63: [442,11,433,34,429],         // LATIN SMALL LETTER C
    0x64: [694,10,520,33,524],         // LATIN SMALL LETTER D
    0x65: [442,11,466,39,429],         // LATIN SMALL LETTER E
    0x66: [705,205,490,55,550],        // LATIN SMALL LETTER F
    0x67: [443,205,477,10,480],        // LATIN SMALL LETTER G
    0x68: [694,11,576,48,555],         // LATIN SMALL LETTER H
    0x69: [661,11,345,21,303],         // LATIN SMALL LETTER I
    0x6A: [661,204,412,-12,403],       // LATIN SMALL LETTER J
    0x6B: [694,11,521,48,503],         // LATIN SMALL LETTER K
    0x6C: [694,11,298,38,267],         // LATIN SMALL LETTER L
    0x6D: [442,11,878,21,857],         // LATIN SMALL LETTER M
    0x6E: [442,11,600,21,580],         // LATIN SMALL LETTER N
    0x6F: [441,11,485,34,476],         // LATIN SMALL LETTER O
    0x70: [442,194,503,-39,497],       // LATIN SMALL LETTER P
    0x71: [442,194,446,33,460],        // LATIN SMALL LETTER Q
    0x72: [442,11,451,21,430],         // LATIN SMALL LETTER R
    0x73: [442,10,469,53,419],         // LATIN SMALL LETTER S
    0x74: [626,11,361,19,330],         // LATIN SMALL LETTER T
    0x75: [442,11,572,21,551],         // LATIN SMALL LETTER U
    0x76: [443,11,485,21,467],         // LATIN SMALL LETTER V
    0x77: [444,11,716,20,690],         // LATIN SMALL LETTER W
    0x78: [443,11,572,35,523],         // LATIN SMALL LETTER X
    0x79: [442,205,490,21,496],        // LATIN SMALL LETTER Y
    0x7A: [442,12,465,35,468],         // LATIN SMALL LETTER Z
    0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
    0x393: [680,-1,615,31,721],        // GREEK CAPITAL LETTER GAMMA
    0x394: [716,1,833,48,788],         // GREEK CAPITAL LETTER DELTA
    0x398: [704,22,763,50,740],        // GREEK CAPITAL LETTER THETA
    0x39B: [717,0,694,35,671],         // GREEK CAPITAL LETTER LAMDA
    0x39E: [678,1,742,53,777],         // GREEK CAPITAL LETTER XI
    0x3A0: [681,0,831,31,888],         // GREEK CAPITAL LETTER PI
    0x3A3: [683,0,780,58,806],         // GREEK CAPITAL LETTER SIGMA
    0x3A5: [706,0,583,28,701],         // GREEK CAPITAL LETTER UPSILON
    0x3A6: [683,0,667,24,643],         // GREEK CAPITAL LETTER PHI
    0x3A8: [684,0,612,21,693],         // GREEK CAPITAL LETTER PSI
    0x3A9: [704,0,772,80,786],         // GREEK CAPITAL LETTER OMEGA
    0x3B1: [442,11,640,34,603],        // GREEK SMALL LETTER ALPHA
    0x3B2: [706,194,566,23,573],       // GREEK SMALL LETTER BETA
    0x3B3: [441,216,518,11,543],       // GREEK SMALL LETTER GAMMA
    0x3B4: [717,10,444,36,451],        // GREEK SMALL LETTER DELTA
    0x3B5: [453,22,466,27,428],        // GREEK SMALL LETTER EPSILON
    0x3B6: [704,204,438,44,472],       // GREEK SMALL LETTER ZETA
    0x3B7: [442,216,497,21,504],       // GREEK SMALL LETTER ETA
    0x3B8: [705,10,469,35,462],        // GREEK SMALL LETTER THETA
    0x3B9: [442,10,354,48,332],        // GREEK SMALL LETTER IOTA
    0x3BA: [442,11,576,49,554],        // GREEK SMALL LETTER KAPPA
    0x3BB: [694,12,583,46,556],        // GREEK SMALL LETTER LAMDA
    0x3BC: [443,216,603,22,580],       // GREEK SMALL LETTER MU
    0x3BD: [442,2,494,45,530],         // GREEK SMALL LETTER NU
    0x3BE: [704,205,438,21,443],       // GREEK SMALL LETTER XI
    0x3BF: [441,11,485,34,476],        // GREEK SMALL LETTER OMICRON
    0x3C0: [431,11,570,19,573],        // GREEK SMALL LETTER PI
    0x3C1: [442,216,517,22,510],       // GREEK SMALL LETTER RHO
    0x3C2: [442,108,363,31,405],       // GREEK SMALL LETTER FINAL SIGMA
    0x3C3: [431,11,571,31,572],        // GREEK SMALL LETTER SIGMA
    0x3C4: [431,13,437,17,517],        // GREEK SMALL LETTER TAU
    0x3C5: [443,10,540,21,523],        // GREEK SMALL LETTER UPSILON
    0x3C6: [442,219,654,50,618],       // GREEK SMALL LETTER PHI
    0x3C7: [442,204,626,24,601],       // GREEK SMALL LETTER CHI
    0x3C8: [694,205,651,21,634],       // GREEK SMALL LETTER PSI
    0x3C9: [444,11,622,15,604],        // GREEK SMALL LETTER OMEGA
    0x3D1: [705,11,591,21,563],        // GREEK THETA SYMBOL
    0x3D5: [695,206,596,43,579],       // GREEK PHI SYMBOL
    0x3D6: [431,10,828,19,823],        // GREEK PI SYMBOL
    0x3F1: [442,194,517,67,510],       // GREEK RHO SYMBOL
    0x3F5: [432,11,406,39,383]         // GREEK LUNATE EPSILON SYMBOL
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Size1'] = {
    directory: 'Size1/Regular',
    family: 'MathJax_Size1',
    testString: "() [] {}",
    0x20: [0,0,250,0,0],               // SPACE
    0x28: [850,349,458,152,422],       // LEFT PARENTHESIS
    0x29: [851,349,458,35,305],        // RIGHT PARENTHESIS
    0x2F: [850,349,578,55,522],        // SOLIDUS
    0x5B: [850,349,417,202,394],       // LEFT SQUARE BRACKET
    0x5C: [850,349,578,54,522],        // REVERSE SOLIDUS
    0x5D: [850,349,417,22,214],        // RIGHT SQUARE BRACKET
    0x7B: [850,349,583,104,477],       // LEFT CURLY BRACKET
    0x7D: [851,349,583,104,477],       // RIGHT CURLY BRACKET
    0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
    0x2C6: [744,-551,556,-8,564],      // MODIFIER LETTER CIRCUMFLEX ACCENT
    0x2DC: [722,-597,556,1,554],       // SMALL TILDE
    0x302: [744,-551,0,-564,8],        // COMBINING CIRCUMFLEX ACCENT
    0x303: [722,-597,0,-555,-2],       // COMBINING TILDE
    0x2016: [602,0,778,257,521],       // DOUBLE VERTICAL LINE
    0x2191: [600,0,667,112,555],       // UPWARDS ARROW
    0x2193: [600,0,667,112,555],       // DOWNWARDS ARROW
    0x21D1: [599,0,778,57,721],        // UPWARDS DOUBLE ARROW
    0x21D3: [600,-1,778,57,721],       // DOWNWARDS DOUBLE ARROW
    0x220F: [750,250,944,55,888],      // N-ARY PRODUCT
    0x2210: [750,250,944,55,888],      // N-ARY COPRODUCT
    0x2211: [751,250,1056,56,999],     // N-ARY SUMMATION
    0x221A: [850,350,1000,111,1020],   // SQUARE ROOT
    0x2223: [627,15,333,145,188],      // DIVIDES
    0x2225: [627,15,556,145,410],      // PARALLEL TO
    0x222B: [805,306,472,55,610],      // INTEGRAL
    0x222C: [805,306,819,55,957],      // DOUBLE INTEGRAL
    0x222D: [805,306,1166,55,1304],    // TRIPLE INTEGRAL
    0x222E: [805,306,472,55,610],      // CONTOUR INTEGRAL
    0x22C0: [750,249,833,55,777],      // N-ARY LOGICAL AND
    0x22C1: [750,249,833,55,777],      // N-ARY LOGICAL OR
    0x22C2: [750,249,833,54,777],      // N-ARY INTERSECTION
    0x22C3: [750,250,833,55,777],      // N-ARY UNION
    0x2308: [850,349,472,202,449],     // LEFT CEILING
    0x2309: [850,349,472,22,269],      // RIGHT CEILING
    0x230A: [850,349,472,202,449],     // LEFT FLOOR
    0x230B: [850,349,472,22,269],      // RIGHT FLOOR
    0x23D0: [602,0,667,312,355],       // VERTICAL LINE EXTENSION (used to extend arrows)
    0x27E8: [850,350,472,97,394],      // MATHEMATICAL LEFT ANGLE BRACKET
    0x27E9: [850,350,472,77,374],      // MATHEMATICAL RIGHT ANGLE BRACKET
    0x2A00: [750,250,1111,56,1054],    // N-ARY CIRCLED DOT OPERATOR
    0x2A01: [750,250,1111,56,1054],    // N-ARY CIRCLED PLUS OPERATOR
    0x2A02: [750,250,1111,56,1054],    // N-ARY CIRCLED TIMES OPERATOR
    0x2A04: [750,250,833,55,777],      // N-ARY UNION OPERATOR WITH PLUS
    0x2A06: [750,249,833,55,777]       // N-ARY SQUARE UNION OPERATOR
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Size2'] = {
    directory: 'Size2/Regular',
    family: 'MathJax_Size2',
    testString: "() [] {}",
    0x20: [0,0,250,0,0],               // SPACE
    0x28: [1150,649,597,180,561],      // LEFT PARENTHESIS
    0x29: [1151,649,597,35,416],       // RIGHT PARENTHESIS
    0x2F: [1150,649,811,55,755],       // SOLIDUS
    0x5B: [1150,649,472,224,455],      // LEFT SQUARE BRACKET
    0x5C: [1150,649,811,54,754],       // REVERSE SOLIDUS
    0x5D: [1150,649,472,16,247],       // RIGHT SQUARE BRACKET
    0x7B: [1150,649,667,119,547],      // LEFT CURLY BRACKET
    0x7D: [1151,649,667,119,547],      // RIGHT CURLY BRACKET
    0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
    0x2C6: [772,-565,1000,-5,1004],    // MODIFIER LETTER CIRCUMFLEX ACCENT
    0x2DC: [750,-611,1000,0,999],      // SMALL TILDE
    0x302: [772,-565,0,-1005,4],       // COMBINING CIRCUMFLEX ACCENT
    0x303: [750,-611,0,-1000,-1],      // COMBINING TILDE
    0x220F: [950,450,1278,56,1221],    // N-ARY PRODUCT
    0x2210: [950,450,1278,56,1221],    // N-ARY COPRODUCT
    0x2211: [950,450,1444,55,1388],    // N-ARY SUMMATION
    0x221A: [1150,650,1000,111,1020],  // SQUARE ROOT
    0x222B: [1360,862,556,55,944],     // INTEGRAL
    0x222C: [1361,862,1084,55,1473],   // DOUBLE INTEGRAL
    0x222D: [1361,862,1592,55,1981],   // TRIPLE INTEGRAL
    0x222E: [1360,862,556,55,944],     // CONTOUR INTEGRAL
    0x22C0: [950,450,1111,55,1055],    // N-ARY LOGICAL AND
    0x22C1: [950,450,1111,55,1055],    // N-ARY LOGICAL OR
    0x22C2: [949,450,1111,55,1055],    // N-ARY INTERSECTION
    0x22C3: [950,449,1111,55,1055],    // N-ARY UNION
    0x2308: [1150,649,528,224,511],    // LEFT CEILING
    0x2309: [1150,649,528,16,303],     // RIGHT CEILING
    0x230A: [1150,649,528,224,511],    // LEFT FLOOR
    0x230B: [1150,649,528,16,303],     // RIGHT FLOOR
    0x27E8: [1150,649,611,112,524],    // MATHEMATICAL LEFT ANGLE BRACKET
    0x27E9: [1150,649,611,85,498],     // MATHEMATICAL RIGHT ANGLE BRACKET
    0x2A00: [949,449,1511,56,1454],    // N-ARY CIRCLED DOT OPERATOR
    0x2A01: [949,449,1511,56,1454],    // N-ARY CIRCLED PLUS OPERATOR
    0x2A02: [949,449,1511,56,1454],    // N-ARY CIRCLED TIMES OPERATOR
    0x2A04: [950,449,1111,55,1055],    // N-ARY UNION OPERATOR WITH PLUS
    0x2A06: [950,450,1111,55,1055]     // N-ARY SQUARE UNION OPERATOR
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Size3'] = {
    directory: 'Size3/Regular',
    family: 'MathJax_Size3',
    testString: "() [] {}",
    0x20: [0,0,250,0,0],               // SPACE
    0x28: [1450,949,736,209,701],      // LEFT PARENTHESIS
    0x29: [1451,949,736,34,526],       // RIGHT PARENTHESIS
    0x2F: [1450,949,1044,55,989],      // SOLIDUS
    0x5B: [1450,949,528,247,516],      // LEFT SQUARE BRACKET
    0x5C: [1450,949,1044,56,988],      // REVERSE SOLIDUS
    0x5D: [1450,949,528,11,280],       // RIGHT SQUARE BRACKET
    0x7B: [1450,949,750,130,618],      // LEFT CURLY BRACKET
    0x7D: [1451,949,750,131,618],      // RIGHT CURLY BRACKET
    0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
    0x2C6: [772,-564,1444,-4,1447],    // MODIFIER LETTER CIRCUMFLEX ACCENT
    0x2DC: [749,-610,1444,1,1442],     // SMALL TILDE
    0x302: [772,-564,0,-1448,3],       // COMBINING CIRCUMFLEX ACCENT
    0x303: [749,-610,0,-1443,-2],      // COMBINING TILDE
    0x221A: [1450,951,1000,111,1020],  // SQUARE ROOT
    0x2308: [1450,949,583,246,571],    // LEFT CEILING
    0x2309: [1450,949,583,11,336],     // RIGHT CEILING
    0x230A: [1450,949,583,246,571],    // LEFT FLOOR
    0x230B: [1450,949,583,11,336],     // RIGHT FLOOR
    0x27E8: [1450,950,750,126,654],    // MATHEMATICAL LEFT ANGLE BRACKET
    0x27E9: [1450,950,750,94,623]      // MATHEMATICAL RIGHT ANGLE BRACKET
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Size4'] = {
    directory: 'Size4/Regular',
    family: 'MathJax_Size4',
    testString: "() [] {}",
    0x20: [0,0,250,0,0],               // SPACE
    0x28: [1750,1249,792,237,758],     // LEFT PARENTHESIS
    0x29: [1751,1250,792,33,554],      // RIGHT PARENTHESIS
    0x2F: [1750,1249,1278,56,1221],    // SOLIDUS
    0x5B: [1750,1249,583,269,577],     // LEFT SQUARE BRACKET
    0x5C: [1750,1249,1278,56,1221],    // REVERSE SOLIDUS
    0x5D: [1750,1249,583,5,313],       // RIGHT SQUARE BRACKET
    0x7B: [1750,1249,806,144,662],     // LEFT CURLY BRACKET
    0x7D: [1751,1249,806,144,662],     // RIGHT CURLY BRACKET
    0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
    0x2C6: [845,-561,1889,-14,1902],   // MODIFIER LETTER CIRCUMFLEX ACCENT
    0x2DC: [823,-583,1889,1,1885],     // SMALL TILDE
    0x302: [845,-561,0,-1903,13],      // COMBINING CIRCUMFLEX ACCENT
    0x303: [823,-583,0,-1888,-4],      // COMBINING TILDE
    0x221A: [1750,1251,1000,111,1020], // SQUARE ROOT
    0x2308: [1750,1249,639,269,633],   // LEFT CEILING
    0x2309: [1750,1249,639,5,369],     // RIGHT CEILING
    0x230A: [1750,1249,639,269,633],   // LEFT FLOOR
    0x230B: [1750,1249,639,5,369],     // RIGHT FLOOR
    0x239B: [1155,655,875,290,843],    // LEFT PARENTHESIS UPPER HOOK
    0x239C: [610,10,875,291,417],      // LEFT PARENTHESIS EXTENSION
    0x239D: [1165,644,875,291,843],    // LEFT PARENTHESIS LOWER HOOK
    0x239E: [1155,655,875,31,583],     // RIGHT PARENTHESIS UPPER HOOK
    0x239F: [610,10,875,457,583],      // RIGHT PARENTHESIS EXTENSION
    0x23A0: [1165,645,875,31,583],     // RIGHT PARENTHESIS LOWER HOOK
    0x23A1: [1154,645,667,319,666],    // LEFT SQUARE BRACKET UPPER CORNER
    0x23A2: [602,0,667,319,403],       // LEFT SQUARE BRACKET EXTENSION
    0x23A3: [1155,644,667,319,666],    // LEFT SQUARE BRACKET LOWER CORNER
    0x23A4: [1154,645,667,0,347],      // RIGHT SQUARE BRACKET UPPER CORNER
    0x23A5: [602,0,667,263,347],       // RIGHT SQUARE BRACKET EXTENSION
    0x23A6: [1155,644,667,0,347],      // RIGHT SQUARE BRACKET LOWER CORNER
    0x23A7: [899,10,889,383,719],      // LEFT CURLY BRACKET UPPER HOOK
    0x23A8: [1160,660,889,170,505],    // LEFT CURLY BRACKET MIDDLE PIECE
    0x23A9: [10,899,889,384,718],      // LEFT CURLY BRACKET LOWER HOOK
    0x23AA: [310,10,889,383,504],      // CURLY BRACKET EXTENSION
    0x23AB: [900,11,889,170,504],      // RIGHT CURLY BRACKET UPPER HOOK
    0x23AC: [1160,660,889,384,718],    // RIGHT CURLY BRACKET MIDDLE PIECE
    0x23AD: [10,899,889,170,505],      // RIGHT CURLY BRACKET LOWER HOOK
    0x23B7: [935,885,1056,111,742],    // RADICAL SYMBOL BOTTOM
    0x27E8: [1750,1249,806,140,703],   // MATHEMATICAL LEFT ANGLE BRACKET
    0x27E9: [1751,1249,806,103,665],   // MATHEMATICAL RIGHT ANGLE BRACKET
    0xE000: [625,15,1056,702,742],     // MJ-TeX: radical symbol vertical extender
    0xE001: [605,15,1056,702,1076],    // MJ-TeX: radical symbol top corner piece
    0xE150: [120,213,450,-24,461],     // MJ-TeX: horizontal brace, down left piece
    0xE151: [120,214,450,-11,475],     // MJ-TeX: horizontal brace, down right piece
    0xE152: [333,0,450,-24,461],       // MJ-TeX: horizontal brace, upper left piece
    0xE153: [333,0,450,-11,475],       // MJ-TeX: horizontal brace, upper right piece
    0xE154: [120,0,400,-10,410]        // MJ-TeX: horizontal brace, extender
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_WinChrome'] = {
    directory: 'WinChrome/Regular',
    family: 'MathJax_WinChrome',
    testString: "> T d "+String.fromCharCode(0x23A6)+" "+String.fromCharCode(0x2A00),
    skew: {
      0x54: 0.0278,
      0xE2F0: 0.0319
    },
    0x20: [0,0,250,0,0],               // SPACE
    0x3E: [540,40,778,82,694],         // GREATER-THAN SIGN
    0x54: [717,69,545,34,834],         // LATIN CAPITAL LETTER T
    0x64: [694,11,511,100,567],        // LATIN SMALL LETTER D
    0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
    0x22C3: [750,250,833,55,777],      // N-ARY UNION
    0x23A6: [1155,644,667,0,347],      // RIGHT SQUARE BRACKET LOWER CORNER
    0x2A00: [949,449,1511,56,1454],    // N-ARY CIRCLED DOT OPERATOR
    0xE2F0: [720,69,644,38,947],       // ??
    0xE2F1: [587,85,894,95,797]        // ??
  };

  HTMLCSS.FONTDATA.FONTS['MathJax_Main'][0x22EE][0] += 400;  // adjust height for \vdots
  HTMLCSS.FONTDATA.FONTS['MathJax_Main'][0x22F1][0] += 700;  // adjust height for \ddots
  HTMLCSS.FONTDATA.FONTS['MathJax_Size4'][0xE154][0] += 200;  // adjust height for brace extender
  HTMLCSS.FONTDATA.FONTS['MathJax_Size4'][0xE154][1] += 200;  // adjust depth for brace extender

  if (!HTMLCSS.imgFonts) {
    MathJax.Hub.Browser.Select({
      MSIE: function (browser) {
        
        if (!HTMLCSS.imgFonts && HTMLCSS.config.availableFonts && HTMLCSS.config.availableFonts.length) {
          
          HTMLCSS.FONTDATA.REMAP[0x2C9] = 0xAF; // macron
          HTMLCSS.FONTDATA.REMAP[0x2CA] = 0xB4; // acute
          HTMLCSS.FONTDATA.REMAP[0x2CB] = 0x60; // grave
          HTMLCSS.FONTDATA.REMAP[0x2DA] = 0xB0; // ring above
          
          var testString = HTMLCSS.msieCheckGreek =
            String.fromCharCode(0x393)+" "+String.fromCharCode(0x3A5)+" "+String.fromCharCode(0x39B);

          HTMLCSS.FONTDATA.RANGES.push({name: "greek", low: 0x03B1, high: 0x03C9, offset: "G", add: 32});
          HTMLCSS.FONTDATA.RANGES.push({name: "Greek", low: 0x0391, high: 0x03F6, offset: "G"});
          
          if (HTMLCSS.Font.testFont({family:"MathJax_Greek", testString: testString})) {
            HTMLCSS.Augment({
              FONTDATA: {
                VARIANT: {
                  normal:             {offsetG: 0x391, variantG: "-Greek"},
                  "fraktur":          {offsetG: 0x391, variantG: "-Greek"},
                  "script":           {offsetG: 0x391, variantG: "-Greek"},
                  "-tex-caligraphic": {offsetG: 0x391, variantG: "-Greek"},
                  "-tex-oldstyle":    {offsetG: 0x391, variantG: "-Greek"},
                  "-Greek":           {fonts:["MathJax_Greek"]}
                }
              }
            });

            HTMLCSS.FONTDATA.FONTS['MathJax_Greek'] = {
              directory: 'Greek/Regular',
              family: 'MathJax_Greek',
              testString: String.fromCharCode(0x393)+" "+String.fromCharCode(0x3A5)+" "+String.fromCharCode(0x39B),
              0x20: [0,0,250,0,0],               // SPACE
              0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
              0x393: [680,0,625,25,582],         // GREEK CAPITAL LETTER GAMMA
              0x394: [716,0,833,46,786],         // GREEK CAPITAL LETTER DELTA
              0x398: [705,22,778,56,722],        // GREEK CAPITAL LETTER THETA
              0x39B: [716,0,694,32,661],         // GREEK CAPITAL LETTER LAMDA
              0x39E: [677,0,667,42,624],         // GREEK CAPITAL LETTER XI
              0x3A0: [680,0,750,25,724],         // GREEK CAPITAL LETTER PI
              0x3A3: [683,0,722,55,666],         // GREEK CAPITAL LETTER SIGMA
              0x3A5: [705,0,778,55,722],         // GREEK CAPITAL LETTER UPSILON
              0x3A6: [683,0,722,56,665],         // GREEK CAPITAL LETTER PHI
              0x3A8: [683,0,778,55,722],         // GREEK CAPITAL LETTER PSI
              0x3A9: [704,0,722,44,677]          // GREEK CAPITAL LETTER OMEGA
            };
            
          }
          
          if (HTMLCSS.Font.testFont({family:"MathJax_Greek", weight:"bold", testString: testString})) {
            HTMLCSS.Augment({
              FONTDATA: {
                VARIANT: {
                  bold:               {offsetG: 0x391, variantG: "-Greek-Bold"},
                  "bold-fraktur":     {offsetG: 0x391, variantG: "-Greek-Bold"},
                  "bold-script":      {offsetG: 0x391, variantG: "-Greek-Bold"},
                  "-Greek-Bold":      {fonts:["MathJax_Greek-bold"]}
                }
              }
            });

            HTMLCSS.FONTDATA.FONTS['MathJax_Greek-bold'] = {
              directory: 'Greek/Bold',
              family: 'MathJax_Greek',
              weight: 'bold',
              testString: String.fromCharCode(0x393)+" "+String.fromCharCode(0x3A5)+" "+String.fromCharCode(0x39B),
              0x20: [0,0,250,0,0],               // SPACE
              0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
              0x393: [680,0,692,39,643],         // GREEK CAPITAL LETTER GAMMA
              0x394: [698,0,958,56,901],         // GREEK CAPITAL LETTER DELTA
              0x398: [696,10,894,64,829],        // GREEK CAPITAL LETTER THETA
              0x39B: [698,0,806,40,765],         // GREEK CAPITAL LETTER LAMDA
              0x39E: [675,0,767,48,718],         // GREEK CAPITAL LETTER XI
              0x3A0: [680,0,900,39,860],         // GREEK CAPITAL LETTER PI
              0x3A3: [686,0,831,64,766],         // GREEK CAPITAL LETTER SIGMA
              0x3A5: [697,0,894,64,829],         // GREEK CAPITAL LETTER UPSILON
              0x3A6: [686,0,831,64,766],         // GREEK CAPITAL LETTER PHI
              0x3A8: [686,0,894,64,829],         // GREEK CAPITAL LETTER PSI
              0x3A9: [696,1,831,51,779]          // GREEK CAPITAL LETTER OMEGA
            };
            
          }
          
          if (HTMLCSS.Font.testFont({family:"MathJax_Greek", style:"italic", testString: testString})) {
            HTMLCSS.Augment({
              FONTDATA: {
                VARIANT: {
                  italic:  {offsetG: 0x391, variantG: "-Greek-Italic"},
                  "-Greek-Italic": {fonts:["MathJax_Greek-italic"]}
                }
              }
            });

            HTMLCSS.FONTDATA.FONTS['MathJax_Greek-italic'] = {
              directory: 'Greek/Italic',
              family: 'MathJax_Greek',
              style: 'italic',
              testString: String.fromCharCode(0x393)+" "+String.fromCharCode(0x3A5)+" "+String.fromCharCode(0x39B),
              skew: {
                0x393: 0.0833,
                0x394: 0.167,
                0x398: 0.0833,
                0x39B: 0.167,
                0x39E: 0.0833,
                0x3A0: 0.0556,
                0x3A3: 0.0833,
                0x3A5: 0.0556,
                0x3A6: 0.0833,
                0x3A8: 0.0556,
                0x3A9: 0.0833,
                0x3B1: 0.0278,
                0x3B2: 0.0833,
                0x3B4: 0.0556,
                0x3B5: 0.0833,
                0x3B6: 0.0833,
                0x3B7: 0.0556,
                0x3B8: 0.0833,
                0x3B9: 0.0556,
                0x3BC: 0.0278,
                0x3BD: 0.0278,
                0x3BE: 0.111,
                0x3BF: 0.0556,
                0x3C1: 0.0833,
                0x3C2: 0.0833,
                0x3C4: 0.0278,
                0x3C5: 0.0278,
                0x3C6: 0.0833,
                0x3C7: 0.0556,
                0x3C8: 0.111,
                0x3D1: 0.0833,
                0x3D5: 0.0833,
                0x3F1: 0.0833,
                0x3F5: 0.0556
              },
              0x20: [0,0,250,0,0],               // SPACE
              0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
              0x393: [680,-1,615,31,721],        // GREEK CAPITAL LETTER GAMMA
              0x394: [716,0,833,48,788],         // GREEK CAPITAL LETTER DELTA
              0x398: [704,22,763,50,740],        // GREEK CAPITAL LETTER THETA
              0x39B: [716,0,694,35,670],         // GREEK CAPITAL LETTER LAMDA
              0x39E: [678,0,742,53,777],         // GREEK CAPITAL LETTER XI
              0x3A0: [681,0,831,31,887],         // GREEK CAPITAL LETTER PI
              0x3A3: [683,0,780,58,806],         // GREEK CAPITAL LETTER SIGMA
              0x3A5: [705,0,583,28,700],         // GREEK CAPITAL LETTER UPSILON
              0x3A6: [683,0,667,24,642],         // GREEK CAPITAL LETTER PHI
              0x3A8: [683,0,612,21,692],         // GREEK CAPITAL LETTER PSI
              0x3A9: [704,0,772,80,786],         // GREEK CAPITAL LETTER OMEGA
              0x3B1: [442,11,640,34,603],        // GREEK SMALL LETTER ALPHA
              0x3B2: [705,194,566,23,573],       // GREEK SMALL LETTER BETA
              0x3B3: [441,216,518,11,543],       // GREEK SMALL LETTER GAMMA
              0x3B4: [717,10,444,36,451],        // GREEK SMALL LETTER DELTA
              0x3B5: [452,22,466,27,428],        // GREEK SMALL LETTER EPSILON
              0x3B6: [704,204,438,44,471],       // GREEK SMALL LETTER ZETA
              0x3B7: [442,216,497,21,503],       // GREEK SMALL LETTER ETA
              0x3B8: [705,10,469,35,462],        // GREEK SMALL LETTER THETA
              0x3B9: [442,10,354,48,332],        // GREEK SMALL LETTER IOTA
              0x3BA: [442,11,576,49,554],        // GREEK SMALL LETTER KAPPA
              0x3BB: [694,12,583,47,556],        // GREEK SMALL LETTER LAMDA
              0x3BC: [442,216,603,23,580],       // GREEK SMALL LETTER MU
              0x3BD: [442,2,494,45,530],         // GREEK SMALL LETTER NU
              0x3BE: [704,205,438,21,443],       // GREEK SMALL LETTER XI
              0x3BF: [441,11,485,34,476],        // GREEK SMALL LETTER OMICRON
              0x3C0: [431,11,570,19,573],        // GREEK SMALL LETTER PI
              0x3C1: [442,216,517,23,510],       // GREEK SMALL LETTER RHO
              0x3C2: [442,107,363,31,405],       // GREEK SMALL LETTER FINAL SIGMA
              0x3C3: [431,11,571,31,572],        // GREEK SMALL LETTER SIGMA
              0x3C4: [431,13,437,18,517],        // GREEK SMALL LETTER TAU
              0x3C5: [443,10,540,21,523],        // GREEK SMALL LETTER UPSILON
              0x3C6: [442,218,654,50,618],       // GREEK SMALL LETTER PHI
              0x3C7: [442,204,626,25,600],       // GREEK SMALL LETTER CHI
              0x3C8: [694,205,651,21,634],       // GREEK SMALL LETTER PSI
              0x3C9: [443,11,622,15,604],        // GREEK SMALL LETTER OMEGA
              0x3D1: [705,11,591,21,563],        // GREEK THETA SYMBOL
              0x3D5: [694,205,596,43,579],       // GREEK PHI SYMBOL
              0x3D6: [431,10,828,19,823],        // GREEK PI SYMBOL
              0x3F1: [442,194,517,67,510],       // GREEK RHO SYMBOL
              0x3F5: [431,11,406,40,382]         // GREEK LUNATE EPSILON SYMBOL
            };
            
          }
        }
          
        if (HTMLCSS.msieIE6) {
          
          var WinIE6 = "MathJax_WinIE6";
          HTMLCSS.FONTDATA.FONTS[WinIE6] = "WinIE6/Regular/Main.js";
          HTMLCSS.FONTDATA.RANGES.push({name: "arrows", low: 0x2190, high: 0x2199, offset: "AR"});

          var REMAP = {variant:"-WinIE6",
            0x21D2:0xE20A, 0x21D4:0xE20B,                               // \Rightarrow, \Leftrightarrow
            0x2200:0xE20C, 0x2202:0xE20D, 0x2203:0xE20E, 0x2207:0xE20F, // \forall, \partial, \exists, \nabla
            0x2208:0xE210, 0x220B:0xE211, 0x2215:0xE212, 0x221A:0xE213, // \in, \ni, /, \surd
            0x221D:0xE214, 0x221E:0xE215, 0x2220:0xE216, 0x2223:0xE217, // \propto, \infty, \angle, \vert
            0x2225:0xE218, 0x2227:0xE219, 0x2228:0xE21A, 0x2229:0xE21B, // \Vert, \wedge, \vee, \cap
            0x222A:0xE21C, 0x222B:0xE21D, 0x223C:0xE21E, 0x2248:0xE21F, // \cup, \int, \sim, \approx
            0x2260:0xE220, 0x2261:0xE221, 0x2264:0xE222, 0x2265:0xE223, // \ne, \equiv, \le, \ge
            0x226A:0xE224, 0x226B:0xE225, 0x2282:0xE226, 0x2283:0xE227, // \ll, \gg, \subset, \supset
            0x2286:0xE228, 0x2287:0xE229, 0x2295:0xE22A, 0x2299:0xE22B, // \subseteq, \supseteq, \oplus, \odot
            0x22A5:0xE22C, 0x25B3:0xE22D, 0x25BD:0xE22E, 0x25EF:0xE22F, // \bot, \bigtriangleup, \bigtriangledown, \bigcirc
            0x2660:0xE230, 0x2661:0xE231, 0x2662:0xE232, 0x2663:0xE233, // \spadesuit, \heartsuit, \diamondsuit, \clubsuit
            0x266D:0xE234, 0x266E:0xE235, 0x266F:0xE236,                // \flat, \naturl, \sharp
            0x2266:0xE2C5, 0x2267:0xE2C6, 0x226E:0xE2C7, 0x226F:0xE2C8, // \leqq, \geqq, \nless, \ngtr
            0x250C:0xE2CA, 0x2510:0xE2CB, 0x2514:0xE2CC, 0x2518:0xE2CD, // corners
            0x2571:0xE2CE, 0x2572:0xE2CF, 0x25A0:0xE2D0, 0x25A1:0xE2D1, // \diagup, \diagdown, \blacksquare, \square
            0x25B2:0xE2D2, 0x25B6:0xE2D4, 0x25BC:0xE2D5,                // \blacktriangle, \blacktriangleright, \blacktriangledown
            0x25BD:0xE2D6, 0x25C0:0xE2D7, 0x25CA:0xE2D8,                // \vartriangledown, \blacktriangleleft, \lozenge
            0x2234:0xE2D9, 0x2235:0xE2DA, 0x2252:0xE2DB, 0x2605:0xE2DC, // \therefor, \because, \fallingdotseq, \bigstar
            0x223D:0xE2DD                                               // \backsim
          };
          var REMAPBOLD = {variant:"-WinIE6",
            0x21D2:0xE24A, 0x21D4:0xE24B,                               // \Rightarrow, \Leftrightarrow
            0x2200:0xE24C, 0x2202:0xE24D, 0x2203:0xE24E, 0x2207:0xE24F, // \forall, \partial, \exists, \nabla
            0x2208:0xE250, 0x220B:0xE251, 0x2215:0xE252, 0x221A:0xE253, // \in, \ni, /, \surd
            0x221D:0xE254, 0x221E:0xE255, 0x2220:0xE256, 0x2223:0xE257, // \propto, \infty, \angle, \vert
            0x2225:0xE258, 0x2227:0xE259, 0x2228:0xE25A, 0x2229:0xE25B, // \Vert, \wedge, \vee, \cap
            0x222A:0xE25C, 0x222B:0xE25D, 0x223C:0xE25E, 0x2248:0xE25F, // \cup, \int, \sim, \approx
            0x2260:0xE260, 0x2261:0xE261, 0x2264:0xE262, 0x2265:0xE263, // \ne, \equiv, \le, \ge
            0x226A:0xE264, 0x226B:0xE265, 0x2282:0xE266, 0x2283:0xE267, // \ll, \gg, \subset, \supset
            0x2286:0xE268, 0x2287:0xE269, 0x2295:0xE26A, 0x2299:0xE26B, // \subseteq, \supseteq, \oplus, \odot
            0x22A5:0xE26C, 0x25B3:0xE26D, 0x25BD:0xE26E, 0x25EF:0xE26F, // \bot, \bigtriangleup, \bigtriangledown, \bigcirc
            0x2660:0xE270, 0x2661:0xE271, 0x2662:0xE272, 0x2663:0xE273, // \spadesuit, \heartsuit, \diamondsuit, \clubsuit
            0x266D:0xE274, 0x266E:0xE275, 0x266F:0xE276,                // \flat, \naturl, \sharp
            0x2266:0xE2C5, 0x2267:0xE2C6, 0x226E:0xE2C7, 0x226F:0xE2C8, // \leqq, \geqq, \nless, \ngtr
            0x250C:0xE2CA, 0x2510:0xE2CB, 0x2514:0xE2CC, 0x2518:0xE2CD, // corners
            0x2571:0xE2CE, 0x2572:0xE2CF, 0x25A0:0xE2D0, 0x25A1:0xE2D1, // \diagup, \diagdown, \blacksquare, \square
            0x25B2:0xE2D2, 0x25B6:0xE2D4, 0x25BC:0xE2D5,                // \blacktriangle, \blacktriangleright, \blacktriangledown
            0x25BD:0xE2D6, 0x25C0:0xE2D7, 0x25CA:0xE2D8,                // \vartriangledown, \blacktriangleleft, \lozenge
            0x2234:0xE2D9, 0x2235:0xE2DA, 0x2252:0xE2DB, 0x2605:0xE2DC, // \therefor, \because, \fallingdotseq, \bigstar
            0x223D:0xE2DD                                               // \backsim
          };
          var VARNORMAL = {offsetAR:0xE200, variantAR:"-WinIE6", remap: REMAP};
          var VARBOLD   = {offsetAR:0xE240, variantAR:"-WinIE6", remap: REMAPBOLD};

          HTMLCSS.Augment({
            FONTDATA: {
              VARIANT: {
                "normal": VARNORMAL,
                "bold":   VARBOLD,
                "italic": VARNORMAL,
                "bold-italic": VARBOLD,
                "-largeOp": {fonts:[WinIE6,SIZE2,SIZE1,MAIN],
                             remap: {0x220F:0xE290, 0x2211:0xE291, 0x222B:0xE295, 0x222E:0xE296}},
                "-smallOp": {fonts:[WinIE6,SIZE1,MAIN],
                             remap: {0x220F:0xE280, 0x2211:0xE281, 0x222B:0xE285, 0x222E:0xE286}},
                "-WinIE6":  {fonts:[WinIE6]}
	      },
	      DELIMITERS: {
	        0x221A: {
	          HW:{
                    0:[1,WinIE6,null,0xE213], 1:[1.2,WinIE6,null,0xE282], 2:[1.8,WinIE6,null,0xE292],
                    3:[2.4,WinIE6,null,0xE2A2], 4:[3,WinIE6,null,0xE2B2]
                  }
	        },
                0x007C: {stretch:{ext:[0xE217,WinIE6]}},
                0x2223: {HW:{0:[1,WinIE6,null,0xE217]}, stretch:{ext:[0xE217,WinIE6]}},
                0x23D0: {HW:{1:[1,WinIE6,null,0xE217]}, stretch:{ext:[0xE217,WinIE6]}},
                0x2225: {HW:{0:[1,WinIE6,null,0xE218]}, stretch:{ext:[0xE218,WinIE6]}},
                0x2190: {HW:{0:[.889,WinIE6,null,0xE200]}, stretch:{left:[0xE200,WinIE6]}},
                0x2191: {HW:{0:[.888,WinIE6,null,0xE201]}, stretch:{top:[0xE287,WinIE6],ext:[0xE289,WinIE6]}},
                0x2192: {HW:{0:[.889,WinIE6,null,0xE202]}, stretch:{right:[0xE202,WinIE6]}},
                0x2193: {HW:{0:[.888,WinIE6,null,0xE203]}, stretch:{bot:[0xE288,WinIE6],ext:[0xE289,WinIE6]}},
                0x2194: {HW:{0:[1,WinIE6,null,0xE204]}, stretch:{left:[0xE200,WinIE6],right:[0xE202,WinIE6]}},
                0x2195: {HW:{0:[1.044,WinIE6,null,0xE203]}, stretch:{top:[0xE287,WinIE6],bot:[0xE288,WinIE6], ext:[0xE289,WinIE6]}}
              }
            }
          });
          
        }
        
      },
      
      Chrome: function (browser) {
        if (browser.isPC && !MathJax.Hub.Browser.versionAtLeast("5.0")) {
          // FIXME:  patch caligraphic bold, too
          var WinChrome = "-WinChrome";
          HTMLCSS.Augment({
            FONTDATA: {
              VARIANT: {
                normal: {remap: {0x3E:   [0x3E,WinChrome]}},
                bold:   {remap: {0xE2F1: [0x3E,WinChrome]}},
                italic: {remap: {0x64:   [0x64,WinChrome]}},
                "-tex-caligraphic": {remap: {0x54: [0x54,WinChrome]}},
                "-largeOp": {remap: {0x2A00: [0x2A00,WinChrome]}},
                "-smallOp": {remap: {0x22C3: [0x22C3,WinChrome]}},
                "-WinChrome": {fonts:["MathJax_WinChrome"]}
              },
              DELIMITERS: {
                0x005D: {stretch:{bot:[0x23A6,"MathJax_WinChrome"]}},
                0x230B: {stretch:{bot:[0x23A6,"MathJax_WinChrome"]}}
              }
            }
          });
        
          HTMLCSS.FONTDATA.FONTS['MathJax_WinChrome'] = {
            directory: 'WinChrome/Regular',
            family: 'MathJax_WinChrome',
            testString: "> T d "+String.fromCharCode(0x23A6)+" "+String.fromCharCode(0x2A00),
            skew: {
              0x54: 0.0278,
              0xE2F0: 0.0319
            },
            0x20: [0,0,250,0,0],               // SPACE
            0x3E: [540,40,778,82,694],         // GREATER-THAN SIGN
            0x54: [717,69,545,34,834],         // LATIN CAPITAL LETTER T
            0x64: [694,11,511,100,567],        // LATIN SMALL LETTER D
            0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
            0x22C3: [750,250,833,55,777],      // N-ARY UNION
            0x23A6: [1155,644,667,0,347],      // RIGHT SQUARE BRACKET LOWER CORNER
            0x2A00: [949,449,1511,56,1454],    // N-ARY CIRCLED DOT OPERATOR
            0xE2F0: [720,69,644,38,947],       // ??
            0xE2F1: [587,85,894,95,797]        // ??
          };
          
        }
      }

    });
  }
      
  //
  //  Create @font-face stylesheet for the declared fonts
  //
  (function () {
    var FONTS = HTMLCSS.FONTDATA.FONTS, AVAIL = HTMLCSS.config.availableFonts;
    var name, faces = [];
    if (HTMLCSS.allowWebFonts) {
      for (name in FONTS) {
        if (FONTS[name].family) {
          if (AVAIL && AVAIL.length && HTMLCSS.Font.testFont(FONTS[name])) {
            FONTS[name].available = true;
            HTMLCSS.Font.loadComplete(FONTS[name]);
          } else {
            FONTS[name].isWebFont = true;
            if (HTMLCSS.FontFaceBug) {FONTS[name].family = name}
            faces.push(HTMLCSS.Font.fontFace(name));
          }
        }
      }
      if (!HTMLCSS.config.preloadWebFonts) {HTMLCSS.config.preloadWebFonts = []}
      HTMLCSS.config.preloadWebFonts.push(MAIN,ITALIC,SIZE1);
      if (faces.length) {HTMLCSS.config.styles["@font-face"] = faces}
    } else if (AVAIL && AVAIL.length) {
      for (name in FONTS) {
        if (FONTS[name].family && HTMLCSS.Font.testFont(FONTS[name])) {
          FONTS[name].available = true;
          HTMLCSS.Font.loadComplete(FONTS[name]);
        }
      }
    }
  })();

  AJAX.loadComplete(HTMLCSS.fontDir + "/fontdata.js");
  
})(MathJax.OutputJax["HTML-CSS"],MathJax.ElementJax.mml,MathJax.Ajax);

