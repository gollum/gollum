/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/jax.js
 *
 *  Implements the HTML-CSS OutputJax that displays mathematics
 *  using HTML and CSS to position the characters from math fonts
 *  in their proper locations.
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

(function (MML,AJAX,HTMLCSS) {
   
  var FONTTEST = MathJax.Object.Subclass({
    FontInfo: {
      STIX: {family: "STIXSizeOneSym", testString: "() {} []"},
      TeX:  {family: "MathJax_Size1",  testString: "() {} []"}
    },
    comparisonFont: ["sans-serif","monospace","script","Times","Courier","Arial","Helvetica"],
    testSize: ["40px","50px","60px","30px","20px"],

    Init: function () {
      var div = this.div = document.body.appendChild(document.createElement("div"));
      div.style.position = "absolute"; div.style.visibility = "hidden";
      div.style.top = div.style.left = 0;
      div.style.fontWeight = "normal";
      div.style.fontStyle = "normal";
      div.style.fontSize = this.testSize[0];
      this.text = this.div.appendChild(document.createTextNode(""));
    },

    findFont: function (fonts,pref) {
      if (pref && this.testCollection(pref)) {return pref}
      for (var i = 0, m = fonts.length; i < m; i++) {
        if (fonts[i] === pref) continue;
        if (this.testCollection(fonts[i])) {return fonts[i]}
      }
      return null;
    },

    testCollection: function (name) {return this.testFont(this.FontInfo[name])},

    testFont: function (font) {
      if (font.isWebFont && HTMLCSS.FontFaceBug) {
        this.div.style.fontWeight = this.div.style.fontStyle = "normal";
      } else {
        this.div.style.fontWeight = (font.weight||"normal");
        this.div.style.fontStyle  = (font.style||"normal");
      }
      var W = this.getComparisonWidths(font.testString);
      if (W) {
        this.div.style.fontFamily = "'"+font.family+"',"+this.comparisonFont[0];
        if (this.div.offsetWidth == W[0]) {
          this.div.style.fontFamily = "'"+font.family+"',"+this.comparisonFont[W[2]];
          if (this.div.offsetWidth == W[1]) {return false}
        }
        if (this.div.offsetWidth != W[3]) {
          if (!HTMLCSS.FONTDATA || !HTMLCSS.FONTDATA.hasStyleChar) {return true}
          for (var i = 0, m = this.testSize.length; i < m; i++)
            {if (this.testStyleChar(font,this.testSize[i])) {return true}}
        }
      }
      return false;
    },

    styleChar:   String.fromCharCode(0xEFFD), // width encodes style
    versionChar: String.fromCharCode(0xEFFE), // width encodes version
    compChar:    String.fromCharCode(0xEFFF), // "standard" width to compare to

    testStyleChar: function (font,size) {
      var n = 3 + (font.weight ? 2 : 0) + (font.style ? 4 : 0);
      var extra = "", dw = 0;
      var SIZE = this.div.style.fontSize; this.div.style.fontSize = size;
      if (HTMLCSS.msieItalicWidthBug && font.style === "italic") {
        this.text.nodeValue = extra = this.compChar;
        dw = this.div.offsetWidth;
      }
      if (HTMLCSS.safariTextNodeBug) {this.div.innerHTML = this.compChar+extra}
        else {this.text.nodeValue = this.compChar+extra}
      var W = this.div.offsetWidth-dw;
      if (HTMLCSS.safariTextNodeBug) {this.div.innerHTML = this.styleChar+extra}
        else {this.text.nodeValue = this.styleChar+extra}
      var N = Math.floor((this.div.offsetWidth-dw)/W+.5);
      if (N === n) {
        if (HTMLCSS.safariTextNodeBug) {this.div.innerHTML = this.versionChar+extra}
          else {this.text.nodeValue = this.versionChar+extra}
        font.version = Math.floor((this.div.offsetWidth-dw)/W+1.5)/2;
      }
      this.div.style.fontSize = SIZE;
      return (N === n);
    },

    getComparisonWidths: function (string) {
      if (HTMLCSS.FONTDATA && HTMLCSS.FONTDATA.hasStyleChar)
        {string += this.styleChar + " " + this.compChar}
      if (HTMLCSS.safariTextNodeBug) {this.div.innerHTML = string}
        else {this.text.nodeValue = string}
      this.div.style.fontFamily = this.comparisonFont[0];
      var W = this.div.offsetWidth, sW = -1;
      if (HTMLCSS.safariWebFontSerif) {
        this.div.style.fontFamily = HTMLCSS.safariWebFontSerif[0];
        sW = this.div.offsetWidth;
      }
      for (var i = 1, m = this.comparisonFont.length; i < m; i++) {
        this.div.style.fontFamily = this.comparisonFont[i];
        if (this.div.offsetWidth != W) {return [W,this.div.offsetWidth,i,sW]}
      }
      return null;
    },

    loadWebFont: function (font) {
      var n = MathJax.Message.File("Web-Font "+HTMLCSS.fontInUse+"/"+font.directory);
      var callback = MathJax.CallBack(["loadComplete",this,font,n]);
      AJAX.timer.start(AJAX,[this.checkWebFont,font,callback],1);
      return callback;
    },
    loadComplete: function (font,n) {
      MathJax.Message.Clear(n);
    },

    checkWebFont: function (check,font,callback) {
      if (check.time(callback)) return;
      if (HTMLCSS.Font.testFont(font)) {callback(check.STATUS.OK)}
        else {setTimeout(check,check.delay)}
    },

    fontFace: function (name) {
      var type = HTMLCSS.allowWebFonts;
      var dir = AJAX.fileURL(HTMLCSS.webfontDir+"/"+type);
      var fullname = name.replace(/-b/,"-B").replace(/-i/,"-I").replace(/-Bold-/,"-Bold");
      if (!fullname.match(/-/)) {fullname += "-Regular"}
      if (type === "svg") {fullname += ".svg#"+fullname} else {fullname += "."+type}
      var def = {
        "font-family": HTMLCSS.FONTDATA.FONTS[name].family,
        src: "url('"+dir+"/"+fullname+"')"
      };
      if (type === "svg") def.src += " format('svg')";
      if (!(HTMLCSS.FontFaceBug && HTMLCSS.FONTDATA.FONTS[name].isWebFont)) {
        if (name.match(/-bold/)) {def["font-weight"] = "bold"}
        if (name.match(/-italic/)) {def["font-style"] = "italic"}
      }
      return def;
    }
  });

  HTMLCSS.Augment({

    config: {
      styles: {
        ".MathJax": {
          "font-family":    "serif",
          "font-style":     "normal",
          "font-weight":    "normal",
          "line-height":    "normal",
          "font-size":      "100%",
          "text-indent":    0,
          "text-align":     "left",
          "text-transform": "none",
          "letter-spacing": "normal",
          "word-spacing":   "normal",
          "word-wrap":      "none",
          "white-space":    "nowrap",
          border: 0, padding: 0, margin: 0,
          "float": "none"
        },

        ".MathJax_Display": {
          position:    "relative"
        },

        ".MathJax span, .MathJax img, .MathJax nobr, .MathJax a": {
          border:  0, padding: 0, margin:  0,
          "vertical-align": 0,
          "line-height": "normal",
          "text-decoration": "none"
        }
      }
    },

    Font: FONTTEST(),

    Config: function () {
      MathJax.OutputJax.prototype.Config.call(this);
      var font = this.Font.findFont(this.config.availableFonts,this.config.preferredFont);
      if (!font && this.allowWebFonts) {font = this.config.webFont}
      if (!font && this.config.imageFont) {font = this.config.imageFont; this.imgFonts = true}
      if (font) {
        this.fontInUse = font; this.fontDir += "/" + font; this.webfontDir += "/" + font;
        if (!this.require) {this.require = []}
        this.require.push(this.fontDir+"/fontdata.js");
        if (this.imgFonts) {this.require.push(this.directory+"/imageFonts.js")}
      } else {
        MathJax.Message.Set("Can't find a valid font using ["+this.config.availableFonts.join(", ")+"]",null,3000);
        this.FONTDATA = {
          TeX_factor: 1, baselineskip: 1.2, lineH: .8, lineD: .2, ffLineH: .8,
          FONTS: {}, VARIANT: {normal: {fonts:[]}}, RANGES: [],
          DEFAULTFAMILY: "serif", DEFAULTWEIGHT: "normal", DEFAULTSTYLE: "normal",
          DELIMITERS: {}, RULECHAR: 0x2D, REMAP: {}
        };
        MathJax.InputJax.TeX.Definitions.macros.overline[1]  = "002D";
        MathJax.InputJax.TeX.Definitions.macros.underline[1] = "002D";
      }
    },

    Startup: function () {
      //  Set up default fonts
      var MJ = this.config.styles[".MathJax"];
      var family = [], fonts = this.FONTDATA.VARIANT.normal.fonts;
      if (!(fonts instanceof Array)) {fonts = [fonts]}
      for (var i = 0, m = fonts.length; i < m; i++) {
        family[i] = this.FONTDATA.FONTS[fonts[i]].family;
        if (!family[i]) {family[i] = fonts[i]}
      }
      MJ["font-family"] = family.join(',');

      // Make hidden div for when math is in a display:none block
      this.hiddenDiv = this.Element("div",{
        style:{visibility:"hidden", overflow:"hidden", height:"1px",
               position:"absolute", top:0}
      });
      if (!document.body.firstChild) {document.body.appendChild(this.hiddenDiv)}
        else {document.body.insertBefore(this.hiddenDiv,document.body.firstChild)}
      this.hiddenDiv = this.addElement(this.hiddenDiv,"div",{id:"MathJax_Hidden"});

      // Determine pixels per inch
      var div = this.addElement(this.hiddenDiv,"div",{style:{width:"5in"}});
      this.pxPerInch = div.offsetWidth/5; this.hiddenDiv.removeChild(div);

      // Markers used by getW
      this.startMarker = HTMLCSS.createStrut(this.Element("span"),10,true);
      this.endMarker = this.addText(this.Element("span"),"x").parentNode;

      // Used in getHD
      this.HDspan = this.Element("span");
      if (this.operaHeightBug) {this.createStrut(this.HDspan,0)}
      if (this.msieInlineBlockAlignBug) {
        this.HDimg = this.addElement(this.HDspan,"img",{style:{height:"0px", width:"1px"}});
        try {this.HDimg.src = "about:blank"} catch(err) {}
      } else {
        this.HDimg = HTMLCSS.createStrut(this.HDspan,0);
      }

      // Used in getScales
      this.HDMspan = this.Element("span",{style: {position:"absolute"}});
      if (this.msieInlineBlockAlignBug) {
        this.HDMimg = this.addElement(this.HDMspan,"img",{style:{height:"0px",width:"1px"}});
        try {this.HDMimg.src = "about:blank"} catch(err) {}
      } else {
        this.HDMimg = HTMLCSS.createStrut(this.HDMspan,0); this.HDMimg.style.marginRight = "";
      }

      // Used for computing factor to fix margin width in MSIE
      this.marginCheck = HTMLCSS.Element("span");
      HTMLCSS.addElement(this.marginCheck,"span",{style: {display:"inline-block", width:"5em"}});
      this.marginMove = HTMLCSS.addElement(this.marginCheck,"span",
        {style: {display:"inline-block", width:"5em", marginLeft:"-5em"}});

      // Set up styles and preload web fonts
      return MathJax.Ajax.Styles(this.config.styles,["PreloadWebFonts",this]);
    },

    PreloadWebFonts: function () {
      if (!HTMLCSS.allowWebFonts || !HTMLCSS.config.preloadWebFonts) return;
      for (var i = 0, m = HTMLCSS.config.preloadWebFonts.length; i < m; i++) {
        var FONT = HTMLCSS.FONTDATA.FONTS[HTMLCSS.config.preloadWebFonts[i]];
        if (!FONT.available) {HTMLCSS.Font.testFont(FONT)}
      }
    },

    Translate: function (script) {
      var math = script.MathJax.elementJax.root;
      var span = this.Element("span",{className:"MathJax"}), div = span;
      if (math.Get("display") === "block") {
        div = this.Element("div",{className:"MathJax_Display", style:{width:"100%", position:"relative"}});
        div.appendChild(span);
      }
      // (screen readers don't know about role="math" yet, so use "textbox" instead)
      div.setAttribute("role","textbox"); div.setAttribute("aria-readonly","true");
      script.parentNode.insertBefore(div,script);
      this.getScales(div,span); var isHidden = (this.em === 0 || String(this.em) === "NaN");
      if (isHidden) {this.hiddenDiv.appendChild(div); this.getScales(div,span)}
      this.initImg(span);
      this.initHTML(math,span);
      math.setTeXclass();
      try {math.toHTML(span,div)} catch (err) {
        if (err.restart) {div.parentNode.removeChild(div)}
        throw err;
      }
      if (isHidden) {script.parentNode.insertBefore(div,script)}
    },

    initImg: function (span) {},
    initHTML: function (math,span) {},
    initFont: function (name) {
      var FONTS = HTMLCSS.FONTDATA.FONTS, AVAIL = HTMLCSS.config.availableFonts;
      if (AVAIL && AVAIL.length && HTMLCSS.Font.testFont(FONTS[name]))
        {FONTS[name].available = true; return null}
      if (!this.allowWebFonts) {return null}
      FONTS[name].isWebFont = true;
      if (HTMLCSS.FontFaceBug) {FONTS[name].family = name}
      return AJAX.Styles({"@font-face":this.Font.fontFace(name)});
    },

    Remove: function (jax) {
      var span = jax.SourceElement(); if (!span) return;
      span = span.previousSibling; if (!span) return;
      if (span.className.match(/^MathJax/)) {span.parentNode.removeChild(span)}
    },

    getScales: function (span,mj) {
      span.parentNode.insertBefore(this.HDMspan,span);
      this.HDMspan.className = "";
      this.HDMimg.style.height = "1px"; this.HDMimg.style.width = "60ex";
      var ex = this.HDMspan.offsetWidth/60;
      this.HDMspan.className = "MathJax"; this.HDMimg.style.width = "60em";
      var em = this.HDMspan.offsetWidth/60;
      var scale = Math.floor((ex/this.TeX.x_height) / em * this.config.scale);
      mj.style.fontSize = this.HDMspan.style.fontSize = scale+"%";
      this.em = MML.mbase.prototype.em = this.HDMspan.offsetWidth/60;
      span.parentNode.removeChild(this.HDMspan);
      this.msieMarginScale = this.getMarginScale(mj);
    },
    getMarginScale: function (span) {return 1},
    getMSIEmarginScale: function (span) {
      span.appendChild(this.marginCheck);
      var W = this.marginCheck.offsetWidth, w = this.marginMove.offsetWidth;
      var scale = w/(2*w - W);
      span.removeChild(this.marginCheck);
      return scale;
    },
    getHD: function (span) {
      var position = span.style.position;
      span.style.position = "absolute";
      this.HDimg.style.height = "0px";
      span.appendChild(this.HDspan);
      var HD = {h:span.offsetHeight};
      this.HDimg.style.height = HD.h+"px";
      HD.d = span.offsetHeight - HD.h; HD.h -= HD.d;
      HD.h /= this.em; HD.d /= this.em;
      span.removeChild(this.HDspan);
      span.style.position = position;
      return HD;
    },
    getW: function (span) {
      var W = span.offsetWidth, w = (span.bbox ? span.bbox.w: -1), start = span;
      if ((w < 0 || this.negativeSkipBug) && W >= 0) {
        // IE can't deal with a space at the beginning, so put something else first
        if (this.negativeSkipBug) {
          var position = span.style.position; span.style.position = "absolute";
          start = this.startMarker;
          if (span.firstChild) {span.insertBefore(start,span.firstChild)}
            else {span.appendChild(start)}
          start = this.startMarker;
        }
        span.appendChild(this.endMarker);
        W = this.endMarker.offsetLeft - start.offsetLeft;
        span.removeChild(this.endMarker);
        if (this.negativeSkipBug) {
          span.removeChild(start);
          span.style.position = position;
        }
      }
      return W/this.em;
    },
    Measured: function (span,parent) {
      if (span.bbox.width == null && span.bbox.w) {
        var w = this.getW(span);
        span.bbox.rw += w - span.bbox.w;
        span.bbox.w = w;
      }
      if (!parent) {parent = span.parentNode}
      if (!parent.bbox) {parent.bbox = span.bbox}
      return span;
    },
    Remeasured: function (span,parent) {
      parent.bbox = this.Measured(span,parent).bbox;
    },

    Em: function (m) {
      if (Math.abs(m) < .0006) {return "0em"}
      return (m < 0 ? "-" : "")+String(Math.abs(m)+.0005).replace(/(\.\d\d\d).+/,'$1') + "em";
    },
    Percent: function (m) {
      return String(m*100+.5).replace(/\..+/,'') + "%";
    },
    length2percent: function (length) {
      return this.Percent(this.length2em(length));
    },
    length2em: function (length,size) {
      if (typeof(length) !== "string") {length = length.toString()}
      if (length === "") {return ""}
      if (length === MML.SIZE.NORMAL) {return 1}
      if (length === MML.SIZE.BIG)    {return 2}
      if (length === MML.SIZE.SMALL)  {return .71}
      if (length === "infinity")      {return HTMLCSS.BIGDIMEN}
      var factor = this.FONTDATA.TeX_factor;
      if (length.match(/mathspace$/)) {return HTMLCSS.MATHSPACE[length]*factor}
      var match = length.match(/^\s*([-+]?(?:\.\d+|\d+(?:\.\d*)?))?(pt|em|ex|mu|px|in|mm|cm|%)?/);
      var m = parseFloat(match[1]||"1"), unit = match[2];
      if (size == null) {size = 1}
      if (unit === "em") {return m * factor}
      if (unit === "ex") {return m * HTMLCSS.TeX.x_height * factor}
      if (unit === "%")  {return m / 100 * size}
      if (unit === "px") {return m / HTMLCSS.em}
      if (unit === "pt") {return m / 10 * factor}                        // 10 pt to an em
      if (unit === "in") {return m * this.pxPerInch / HTMLCSS.em}
      if (unit === "cm") {return m * this.pxPerInch / HTMLCSS.em / 2.54} // 2.54 cm to an inch
      if (unit === "mm") {return m * this.pxPerInch / HTMLCSS.em / 25.4} // 10 mm to a cm
      if (unit === "pc") {return m * this.pxPerInch / HTMLCSS.em / 12}   // 12 pc to an inch
      if (unit === "mu") {return m / 18 * factor} // FIXME:  needs to include scale
      return m*factor*size;  // relative to given size (or 1em as default)
    },
    thickness2em: function (length) {
      var thick = HTMLCSS.TeX.rule_thickness;
      if (length === MML.LINETHICKNESS.MEDIUM) {return thick}
      if (length === MML.LINETHICKNESS.THIN) {return .67*thick}
      if (length === MML.LINETHICKNESS.THICK) {return 1.67*thick}
      return this.length2em(length,thick);
    },

    createStrut: function (span,h,before) {
      var strut = this.Element("span",{
        style:{display:"inline-block", overflow:"hidden", height:h+"px",
               width:"1px", marginRight:"-1px"}
      });
      if (before) {span.insertBefore(strut,span.firstChild)} else {span.appendChild(strut)}
      return strut;
    },
    createBlank: function (span,w,before) {
      var blank = this.Element("span",{
        style: {display:"inline-block", overflow:"hidden", height:"1px", width:this.Em(w)}
      });
      if (before) {span.insertBefore(blank,span.firstChild)} else {span.appendChild(blank)}
      return blank;
    },
    createShift: function (span,w,before) {
      var space = this.Element("span",{style:{marginLeft:this.Em(w)}});
      if (before) {span.insertBefore(space,span.firstChild)} else {span.appendChild(space)}
      return space;
    },
    createSpace: function (span,h,d,w,color) {
      var H = this.Em(Math.max(0,h+d)), D = this.Em(-d);
      if (this.msieInlineBlockAlignBug) {D = this.Em(HTMLCSS.getHD(span.parentNode).d-d)}
      if (span.isBox || span.className == "mspace") {
        span.bbox = {
          h: h*span.scale, d: d*span.scale,
          w: w*span.scale, rw: w*span.scale, lw: 0
        };
        span.style.height = H; span.style.verticalAlign = D;
      } else {
        span = this.addElement(span,"span",{style: {height:H, verticalAlign:D}});
      }
      if (w >= 0) {
        span.style.width = this.Em(w);
        span.style.display = "inline-block";
      } else {
        if (this.msieNegativeSpaceBug) {span.style.height = ""}
        span.style.marginLeft = this.Em(w);
        if (HTMLCSS.safariNegativeSpaceBug && span.parentNode.firstChild == span)
          {this.createBlank(span,0,true)}
      }
      if (color && color !== MML.COLOR.TRANSPARENT) {span.style.backgroundColor = color}
      return span;
    },
    createRule: function (span,h,d,w,color) {
      var min = HTMLCSS.TeX.min_rule_thickness;
      // If rule is very thin, make it at least min_rule_thickness so it doesn't disappear
      if (w > 0 && w*this.em < min) {w = min/this.em}
      if (h+d > 0 && (h+d)*this.em < min) {var f = 1/(h+d)*(min/this.em); h *= f; d *= f}
      if (!color) {color = "solid"} else {color = "solid "+color}
      color = this.Em(w)+" "+color;
      var H = this.Em(h+d), D = this.Em(-d);
      if (span.isBox || span.className == "mspace") {span.bbox = {h:h, d:d, w:w, rw:w, lw: 0}}
      span = this.addElement(span,"span",{
        style: {borderLeft: color, display: "inline-block", overflow:"hidden",
                width:0, height:H, verticalAlign:D}
      });
      if (w > 0 && span.offsetWidth == 0) {span.style.width = this.Em(w)}
      return span;
    },

    createStack: function (span,nobbox,w) {
      if (this.msiePaddingWidthBug) {this.createStrut(span,0)}
      span = this.addElement(span,"span",{
        style: {display:"inline-block", position:"relative",
                width:(w == null ? 0: "100%"), height:0}
      });
      if (!nobbox) {
        span.parentNode.bbox = span.bbox = {
          h: -this.BIGDIMEN, d: -this.BIGDIMEN,
          w:0, lw: this.BIGDIMEN, rw: -this.BIGDIMEN
        };
        if (w != null) {span.bbox.width = span.parentNode.bbox.width = w}
      }
      return span;
    },
    createBox: function (span,w) {
      var box = this.addElement(span,"span",{style:{position:"absolute"}, isBox: true});
      if (w != null) {box.style.width = w}
      return box;
    },
    addBox: function (span,box) {
      box.style.position = "absolute"; box.isBox = true;
      return span.appendChild(box);
    },
    placeBox: function (span,x,y,noclip) {
      var parent = span.parentNode, bbox = span.bbox, BBOX = parent.bbox;
      if (this.msiePlaceBoxBug) {this.addText(span,this.NBSP)}
      if (this.imgSpaceBug) {this.addText(span,this.imgSpace)}
      var HD = this.getHD(span), dx = 0;
      // Make sure vertical alignment of baseline is correct
      span.style.top = this.Em(-HD.h);
      if (-span.offsetTop !== Math.floor(HD.h*this.em+.5))
        {HD.h += .95*Math.floor(HD.h*this.em+span.offsetTop+.5)/this.em};
      // Clip so that bbox doesn't include extra height and depth
      if (bbox) {
        if (this.negativeSkipBug) {
          if (bbox.lw < 0) {dx = bbox.lw; HTMLCSS.createBlank(span,-dx,true); l = 0}
          if (bbox.rw > bbox.w) {HTMLCSS.createBlank(span,bbox.rw-bbox.w+.1)}
        }
        if (!this.msieClipRectBug && !bbox.noclip && !noclip) {
          var dd = 3/this.em;
          var H = (bbox.H == null ? bbox.h : bbox.H), D = (bbox.D == null ? bbox.d : bbox.D);
          var t = HD.h - H - dd, b = HD.h + D + dd, l = bbox.lw - 3*dd, r = 1000;
          span.style.clip = "rect("+this.Em(t)+" "+this.Em(r)+" "+this.Em(b)+" "+this.Em(l)+")";
        }
      }
      // Place the box
      span.style.left = this.Em(x+dx);
      span.style.top  = this.Em(-(y+HD.h));
      // Update the bounding box
      if (bbox && BBOX) {
        if (bbox.H != null && (BBOX.H == null || bbox.H + y > BBOX.H)) {BBOX.H = bbox.H + y}
        if (bbox.D != null && (BBOX.D == null || bbox.D - y > BBOX.D)) {BBOX.D = bbox.D - y}
        if (bbox.h + y > BBOX.h) {BBOX.h = bbox.h + y}
        if (bbox.d - y > BBOX.d) {BBOX.d = bbox.d - y}
        if (BBOX.H != null && BBOX.H <= BBOX.h) {delete BBOX.H}
        if (BBOX.D != null && BBOX.D <= BBOX.d) {delete BBOX.D}
        if (bbox.w + x > BBOX.w) {
          BBOX.w = bbox.w + x;
          if (BBOX.width == null) {parent.style.width = this.Em(BBOX.w)}
        }
        if (bbox.rw + x > BBOX.rw) {BBOX.rw = bbox.rw + x}
        if (bbox.lw + x < BBOX.lw) {BBOX.lw = bbox.lw + x}
        // FIXME:  deal with non-percent widths
        if (bbox.width != null) {
          if (BBOX.width == null) {parent.style.width = BBOX.width = "100%"}
          span.style.width = bbox.width;
        }
      }
    },
    alignBox: function (span,align,y) {
      this.placeBox(span,0,y); // set y position (and left aligned)
      var r = 0, c = -span.bbox.w/2;
      if (this.negativeSkipBug) {r = span.bbox.w-span.bbox.rw-.1; c += span.bbox.lw}
      // FIXME: handle width that is not a percent
      c = (span.bbox.width ? "-"+Math.floor(parseInt(span.bbox.width)/2)+"%" :
                             this.Em(c*this.msieMarginScale));
      MathJax.Hub.Insert(span.style,({
        right:  {left:"", right: this.Em(r)},
        center: {left:"50%", marginLeft: c}
      })[align]);
    },
    setStackWidth: function (span,w) {
      if (typeof(w) === "number") {
        span.style.width = this.Em(Math.max(0,w));
        if (span.bbox) {span.bbox.w = w};
        if (span.parentNode.bbox) {span.parentNode.bbox.w = w}
      } else {
        span.style.width = span.parentNode.style.width = "100%";
        if (span.bbox) {span.bbox.width = w}
        if (span.parentNode.bbox) {span.parentNode.bbox.width = w}
      }
    },

    createDelimiter: function (span,code,HW,scale,font) {
      if (!code) {
        span.bbox = {h:0, d:0, w:this.TeX.nulldelimiterspace, lw: 0};
        span.bbox.rw = span.bbox.w;
        this.createSpace(span,span.bbox.h,span.bbox.d,span.bbox.w);
        return;
      }
      if (!scale) {scale = 1};
      if (!(HW instanceof Array)) {HW = [HW,HW]}
      var hw = HW[1]; HW = HW[0];
      var delim = {alias: code};
      while (delim.alias) {
        code = delim.alias; delim = this.FONTDATA.DELIMITERS[code];
        if (!delim) {delim = {HW: [0,this.FONTDATA.VARIANT[MML.VARIANT.NORMAL]]}}
      }
      for (var i = 0, m = delim.HW.length; i < m; i++) {
        if (delim.HW[i][0]*scale >= HW-.01 || (i == m-1 && !delim.stretch)) {
          if (delim.HW[i][2]) {scale *= delim.HW[i][2]}
          if (delim.HW[i][3]) {code = delim.HW[i][3]}
          var chr = this.addElement(span,"span");
          this.createChar(chr,[code,delim.HW[i][1]],scale,font);
          span.bbox = chr.bbox;
          span.offset = .65 * span.bbox.w;
          span.scale = scale;
          return;
        }
      }
      if (delim.stretch) {this["extendDelimiter"+delim.dir](span,hw,delim.stretch,scale,font)}
    },
    extendDelimiterV: function (span,H,delim,scale,font) {
      var stack = this.createStack(span,true);
      var top = this.createBox(stack), bot = this.createBox(stack);
      this.createChar(top,(delim.top||delim.ext),scale,font);
      this.createChar(bot,(delim.bot||delim.ext),scale,font);
      var ext = {bbox:{w:0,lw:0,rw:0}}, mid = ext;
      var h = top.bbox.h + top.bbox.d + bot.bbox.h + bot.bbox.d;
      var y = -top.bbox.h; this.placeBox(top,0,y,true); y -= top.bbox.d;
      if (delim.mid) {
        mid = this.createBox(stack); this.createChar(mid,delim.mid,scale,font);
        h += mid.bbox.h + mid.bbox.d;
      }
      if (H > h) {
        ext = this.Element("span"); this.createChar(ext,delim.ext,scale,font);
        var eH = ext.bbox.h + ext.bbox.d, eh = eH - .05, n, N, k = (delim.mid ? 2 : 1);
        N = n = Math.ceil((H-h)/(k*eh));
        if (!delim.fullExtenders) {eh = (H-h)/(k*n)}
        var dy = (n/(n+1))*(eH - eh); eh = eH - dy; y += dy + eh - ext.bbox.h;
        while (k-- > 0) {
          while (n-- > 0) {y -= eh; this.placeBox(this.addBox(stack,ext.cloneNode(true)),0,y,true)}
          y += dy - ext.bbox.d;
          if (delim.mid && k) {
            this.placeBox(mid,0,y-mid.bbox.h,true); n = N;
            y += -(mid.bbox.h + mid.bbox.d) + dy + eh - ext.bbox.h;
          }
        }
      } else {
        y += (h - H)/2;
        if (delim.mid) {this.placeBox(mid,0,y-mid.bbox.h,true); y += -(mid.bbox.h + mid.bbox.d)}
        y += (h - H)/2;
      }
      this.placeBox(bot,0,y-bot.bbox.h,true); y -= bot.bbox.h + bot.bbox.d;
      span.bbox = {
        w:  Math.max(top.bbox.w,ext.bbox.w,bot.bbox.w,mid.bbox.w),
        lw: Math.min(top.bbox.lw,ext.bbox.lw,bot.bbox.lw,mid.bbox.lw),
        rw: Math.max(top.bbox.rw,ext.bbox.rw,bot.bbox.rw,mid.bbox.rw),
        h: 0, d: -y
      }
      span.scale = scale;
      span.offset = .55 * span.bbox.w;
      span.isMultiChar = true;
      this.setStackWidth(stack,span.bbox.w);
    },
    extendDelimiterH: function (span,W,delim,scale,font) {
      var stack = this.createStack(span,true);
      var left = this.createBox(stack), right = this.createBox(stack);
      this.createChar(left,(delim.left||delim.rep),scale,font);
      this.createChar(right,(delim.right||delim.rep),scale,font);
      var rep = this.Element("span"); this.createChar(rep,delim.rep,scale,font);
      var mid = {bbox: {h:-this.BIGDIMEN, d:-this.BIGDIMEN}};
      this.placeBox(left,-left.bbox.lw,0,true);
      var w = (left.bbox.rw - left.bbox.lw) + (right.bbox.rw - right.bbox.lw) - .05,
          x = left.bbox.rw - left.bbox.lw - .025;
      if (delim.mid) {
        mid = this.createBox(stack); this.createChar(mid,delim.mid,scale,font);
        w += mid.bbox.w;
      }
      if (W > w) {
        var rW = rep.bbox.rw-rep.bbox.lw, rw = rW - .05, n, N, k = (delim.mid ? 2 : 1);
        N = n = Math.ceil((W-w)/(k*rw)); rw = (W-w)/(k*n);
        var dx = (n/(n+1))*(rW - rw); rw = rW - dx; x -= rep.bbox.lw + dx;
        while (k-- > 0) {
          while (n-- > 0) {this.placeBox(this.addBox(stack,rep.cloneNode(true)),x,0,true); x += rw}
          if (delim.mid && k) {this.placeBox(mid,x,0,true); x += mid.bbox.w - dx; n = N}
        }
      } else {
        x -= (w - W)/2;
        if (delim.mid) {this.placeBox(mid,x,0,true); x += mid.bbox.w}
        x -= (w - W)/2;
      }
      this.placeBox(right,x,0,true);
      span.bbox = {
        w: x+right.bbox.rw, lw: 0, rw: x+right.bbox.rw,
        H: Math.max(left.bbox.h,rep.bbox.h,right.bbox.h,mid.bbox.h),
        D: Math.max(left.bbox.d,rep.bbox.d,right.bbox.d,mid.bbox.d),
        h: rep.bbox.h, d: rep.bbox.d
      }
      span.scale = scale;
      span.isMultiChar = true;
      this.setStackWidth(stack,span.bbox.w);
    },
    createChar: function (span,data,scale,font) {
      var SPAN = span, text = "", variant = {fonts: [data[1]], noRemap:true};
      if (font && font === MML.VARIANT.BOLD) {variant.fonts = [data[1]+"-bold",data[1]]}
      if (typeof(data[1]) !== "string") {variant = data[1]}
      if (data[0] instanceof Array) {
        for (var i = 0, m = data[0].length; i < m; i++) {text += String.fromCharCode(data[0][i])}
      } else {text = String.fromCharCode(data[0])}
      if (scale !== 1) {
        SPAN = this.addElement(span,"span",{style:{fontSize: this.Percent(scale)}, scale:scale});
        this.handleVariant(SPAN,variant,text);
        span.bbox = SPAN.bbox;
      } else {this.handleVariant(span,variant,text)}
      if (data[2]) {span.style.marginLeft = this.Em(data[2])}
      if (this.AccentBug && span.bbox.w === 0) {
        //  Handle combining characters by adding a non-breaking space and removing that width
        SPAN.firstChild.nodeValue += this.NBSP;
        HTMLCSS.createSpace(span,0,0,-span.offsetWidth/HTMLCSS.em);
      }
    },
    positionDelimiter: function (span,h) {
      h -= span.bbox.h; span.bbox.d -= h; span.bbox.h += h;
      if (h) {
        if (this.safariVerticalAlignBug || this.msieVerticalAlignBug || this.konquerorVerticalAlignBug ||
           (this.operaVerticalAlignBug && span.isMultiChar)) {
          if (span.firstChild.style.display === "" && span.style.top !== "")
            {span = span.firstChild; h -= parseFloat(span.style.top)}
          span.style.position = "relative";
          span.style.top = this.Em(-h);
        } else {
          span.style.verticalAlign = this.Em(h);
          if (HTMLCSS.ffVerticalAlignBug) {HTMLCSS.createRule(span.parentNode,span.bbox.h,0,0)}
        }
      }
    },

    handleVariant: function (span,variant,text) {
      var newtext = "", n, c, C, font, noVariant = 1, VARIANT;
      if (text.length === 0) return;
      if (!span.bbox) {
        span.bbox = {
          w: 0, h: -this.BIGDIMEN, d: -this.BIGDIMEN,
          rw: -this.BIGDIMEN, lw: this.BIGDIMEN
        };
      }
      if (!variant) {variant = this.FONTDATA.VARIANT[MML.VARIANT.NORMAL]}
      VARIANT = variant;
      for (var i = 0, m = text.length; i < m; i++) {
        variant = VARIANT;
        n = text.charCodeAt(i); c = text.charAt(i);
        if (c == this.PLANE1) {
          i++; n = text.charCodeAt(i) + 0x1D400 - 0xDC00;
        } else {
          var id, M, RANGES = this.FONTDATA.RANGES;
          for (id = 0, M = RANGES.length; id < M; id++) {
            if (RANGES[id].name === "alpha" && variant.noLowerCase) continue;
            var N = variant["offset"+RANGES[id].offset];
            if (N && n >= RANGES[id].low && n <= RANGES[id].high) {
              if (RANGES[id].remap && RANGES[id].remap[n]) {
                n = N + RANGES[id].remap[n];
              } else {
                n = n - RANGES[id].low + N;
                if (RANGES[id].add) {n += RANGES[id].add}
              }
              if (variant["variant"+RANGES[id].offset])
                {variant = this.FONTDATA.VARIANT[variant["variant"+RANGES[id].offset]]}
              break;
            }
          }
        }
        if (variant.remap && variant.remap[n]) {
          if (variant.remap[n] instanceof Array) {
            var remap = variant.remap[n];
            n = remap[0]; variant = this.FONTDATA.VARIANT[remap[1]];
          } else {
            n = variant.remap[n];
            if (variant.remap.variant) {variant = this.FONTDATA.VARIANT[variant.remap.variant]}
          }
        }
        if (this.FONTDATA.REMAP[n] && !variant.noRemap) {n = this.FONTDATA.REMAP[n]}
        font = this.lookupChar(variant,n); c = font[n];
        if (noVariant && !c[5].img) {this.handleFont(span,font); noVariant = 1}
        newtext = this.handleChar(span,font,c,n,newtext);
        if (c[0]/1000 > span.bbox.h) {span.bbox.h = c[0]/1000}
        if (c[1]/1000 > span.bbox.d) {span.bbox.d = c[1]/1000}
        if (span.bbox.w + c[3]/1000 < span.bbox.lw) {span.bbox.lw = span.bbox.w + c[3]/1000}
        if (span.bbox.w + c[4]/1000 > span.bbox.rw) {span.bbox.rw = span.bbox.w + c[4]/1000}
        span.bbox.w += c[2]/1000;
      }
      if (newtext.length) {this.addText(span,newtext)}
      if (span.scale && span.scale !== 1) {
        span.bbox.h *= span.scale; span.bbox.d *= span.scale;
        span.bbox.w *= span.scale; span.bbox.lw *= span.scale; span.bbox.rw *= span.scale;
      }
      if (text.length == 1 && font.skew && font.skew[n]) {span.bbox.skew = font.skew[n]}
    },

    handleFont: function (span,font) {
      span.style.fontFamily = font.family;
      if (!(HTMLCSS.FontFaceBug && font.isWebFont)) {
        var style  = font.style  || this.FONTDATA.DEFAULTSTYLE,
            weight = font.weight || this.FONTDATA.DEFAULTWEIGHT;
        if (style !== "normal")  {span.style.fontStyle  = style}
        if (weight !== "normal") {span.style.fontWeight = weight}
      }
    },

    handleChar: function (span,font,c,n,text) {
      var C = c[5];
      if (C.img) {return this.handleImg(span,font,c,n,text)}
      if (C.c == null) {
        if (n <= 0xFFFF) {C.c = String.fromCharCode(n)}
                    else {C.c = this.PLANE1 + String.fromCharCode(n-0x1D400+0xDC00)}
      }
      if (c[2] || !this.msieAccentBug || text.length) {return text + C.c}
      //  Handle IE accent clipping bug
      HTMLCSS.createShift(span,c[3]/1000);
      HTMLCSS.createShift(span,(c[4]-c[3])/1000);
      this.addText(span,C.c);
      HTMLCSS.createShift(span,-c[4]/1000);
      return "";
    },
    handleImg: function (span,font,c,n,text) {return text}, // replaced by imageFont extension

    lookupChar: function (variant,n) {
      var i, m;
      if (!variant.FONTS) {
        var FONTS = this.FONTDATA.FONTS;
        var fonts = (variant.fonts || this.FONTDATA.VARIANT.normal.fonts);
        if (!(fonts instanceof Array)) {fonts = [fonts]}
        if (variant.fonts != fonts) {variant.fonts = fonts}
        variant.FONTS = [];
        for (i = 0, m = fonts.length; i < m; i++) {
          if (FONTS[fonts[i]]) {
            variant.FONTS.push(FONTS[fonts[i]]);
            FONTS[fonts[i]].name = fonts[i]; // FIXME: should really be in the font files
          }
        }
      }
      for (i = 0, m = variant.FONTS.length; i < m; i++) {
        var font = variant.FONTS[i];
        if (typeof(font) === "string") {
          delete variant.FONTS; this.loadFont(font);
        }
        if (font[n]) {
          if (font[n].length === 5) {font[n][5] = {}}
          if (HTMLCSS.allowWebFonts && !font.available)
            {this.loadWebFont(font)} else {return font}
        } else {this.findBlock(font,n)}
      }
      var unknown = (variant.defaultFont || {family:HTMLCSS.FONTDATA.DEFAULTFAMILY+",serif"});
      unknown[n] = [800,200,500,0,500,{isUnknown:true}]; // [h,d,w,lw,rw,{data}]
      return unknown;
    },

    findBlock: function (font,c) {
      if (font.Ranges) {
        // FIXME:  do binary search?
        for (var i = 0, m = font.Ranges.length; i < m; i++) {
          if (c <  font.Ranges[i][0]) return;
          if (c <= font.Ranges[i][1]) {
            var file = font.Ranges[i][2];
            for (var j = font.Ranges.length-1; j >= 0; j--)
              {if (font.Ranges[j][2] == file) {font.Ranges.splice(j,1)}}
            this.loadFont(font.directory+"/"+file+".js");
          }
        }
      }
    },

    loadFont: function (file) {
      var queue = MathJax.CallBack.Queue();
      queue.Push(["Require",MathJax.Ajax,this.fontDir+"/"+file]);
      if (this.imgFonts) {queue.Push(["Require",MathJax.Ajax,this.webfontDir+"/png/"+file])}
      MathJax.Hub.RestartAfter(queue.Push({}));
    },

    loadWebFont: function (font) {
      font.available = font.isWebFont = true;
      if (HTMLCSS.FontFaceBug) {font.family = font.name}
      var callback = this.Font.loadWebFont(font);
      MathJax.Hub.RestartAfter(callback);
    },

    Element: function (type,def) {
      var obj = document.createElement(type);
      for (var i = 1, m = arguments.length; i < m; i++) {
        if (arguments[i]) {MathJax.Hub.Insert(obj,arguments[i]);}
      }
      return obj;
    },
    addElement: function (span,type,def) {return span.appendChild(this.Element(type,def))},
    TextNode: function (text) {return document.createTextNode(text)},
    addText: function (span,text) {return span.appendChild(this.TextNode(text))},

    BIGDIMEN: 10000000,
    ID: 0,
    GetID: function () {this.ID++; return this.ID},

    MATHSPACE: {
      veryverythinmathspace:  1/18,
      verythinmathspace:      2/18,
      thinmathspace:          3/18,
      mediummathspace:        4/18,
      thickmathspace:         5/18,
      verythickmathspace:     6/18,
      veryverythickmathspace: 7/18,
      negativeveryverythinmathspace:  -1/18,
      negativeverythinmathspace:      -2/18,
      negativethinmathspace:          -3/18,
      negativemediummathspace:        -4/18,
      negativethickmathspace:         -5/18,
      negativeverythickmathspace:     -6/18,
      negativeveryverythickmathspace: -7/18
    },

    TeX: {
      x_height:         .430554,
      quad:             1,
      num1:             .676508,
      num2:             .393732,
      num3:             .44373,
      denom1:           .685951,
      denom2:           .344841,
      sup1:             .412892,
      sup2:             .362892,
      sup3:             .288888,
      sub1:             .15,
      sub2:             .247217,
      sup_drop:         .386108,
      sub_drop:         .05,
      delim1:          2.39,
      delim2:          1.0,
      axis_height:      .25,
      rule_thickness:   .06,
      big_op_spacing1:  .111111,
      big_op_spacing2:  .166666,
      big_op_spacing3:  .2,
      big_op_spacing4:  .6,
      big_op_spacing5:  .1,

      scriptspace:         .1,
      nulldelimiterspace:  .12,
      delimiterfactor:     901,
      delimitershortfall:   .1,    // originally .3,

      min_rule_thickness:  1.25     // in pixels
    },

    PLANE1: String.fromCharCode(0xD835),
    NBSP: String.fromCharCode(0xA0),

    rfuzz: 0         // adjustment to rule placements in roots
  });

  MML.mbase.Augment({
    toHTML: function (span) {
      span = this.HTMLcreateSpan(span);
      for (var i = 0, m = this.data.length; i < m; i++)
        {if (this.data[i]) {this.data[i].toHTML(span)}}
      var stretchy = this.HTMLcomputeBBox(span);
      var h = span.bbox.h, d = span.bbox.d;
      for (i = 0, m = stretchy.length; i < m; i++) {stretchy[i].HTMLstretchV(span,h,d)}
      if (stretchy.length) {this.HTMLcomputeBBox(span,true)}
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLcomputeBBox: function (span,full) {
      var i, m, child, bbox, BBOX, hasDimens = 0, width, stretchy = [];
      BBOX = span.bbox = {};
      for (i = 0, m = this.data.length; i < m; i++) {
        var core = this.data[i]; if (!core) continue;
        if (!full && core.HTMLcanStretch("Vertical"))
          {stretchy.push(core); core = (core.CoreMO()||core)}
        this.HTMLcombineBBoxes(core,BBOX);
      }
      this.HTMLcleanBBox(BBOX);
      return stretchy;
    },
    HTMLcombineBBoxes: function (core,BBOX) {
      if (BBOX.w == null) {
        BBOX.h = BBOX.d = BBOX.H = BBOX.D = BBOX.rw = -HTMLCSS.BIGDIMEN;
        BBOX.w = 0; BBOX.lw = HTMLCSS.BIGDIMEN;
      }
      var child = core.HTMLspanElement(); if (!child || !child.bbox) return;
      var bbox = child.bbox;
      if (bbox.d > BBOX.d) {BBOX.d = bbox.d}
      if (bbox.h > BBOX.h) {BBOX.h = bbox.h}
      if (bbox.D != null && bbox.D > BBOX.D) {BBOX.D = bbox.D}
      if (bbox.H != null && bbox.H > BBOX.H) {BBOX.H = bbox.H}
      if (child.style.paddingLeft) {BBOX.w += parseFloat(child.style.paddingLeft)*(child.scale||1)}
      if (BBOX.w + bbox.lw < BBOX.lw) {BBOX.lw = BBOX.w + bbox.lw}
      if (BBOX.w + bbox.rw > BBOX.rw) {BBOX.rw = BBOX.w + bbox.rw}
      BBOX.w += bbox.w;
      if (child.style.paddingRight) {BBOX.w += parseFloat(child.style.paddingRight)*(child.scale||1)}
      if (bbox.width) {BBOX.width = bbox.width}
    },
    HTMLcleanBBox: function (BBOX) {
      if (BBOX.h === this.BIGDIMEN)
        {BBOX.h = BBOX.d = BBOX.H = BBOX.D = BBOX.w = BBOX.rw = BBOX.lw = 0}
      if (BBOX.D <= BBOX.d) {delete BBOX.D}; if (BBOX.H <= BBOX.h) {delete BBOX.H}
    },
    HTMLcanStretch: function (direction) {
      if (this.isEmbellished()) {return this.Core().HTMLcanStretch(direction)}
      return false;
    },
    HTMLstretchH: function (box,W) {return this.HTMLspanElement()},
    HTMLstretchV: function (box,h,d) {return this.HTMLspanElement()},

    HTMLcreateSpan: function (span) {
      if (this.spanID) {
        var SPAN = this.HTMLspanElement();
        if (SPAN) {
          while (SPAN.firstChild) {SPAN.removeChild(SPAN.firstChild)}
          SPAN.bbox = {w:0, h:0, d:0, lw:0, rw:0};
          SPAN.scale = 1; SPAN.isMultChar = null;
          SPAN.style.cssText = "";
          return SPAN;
        }
      }
      if (this.href) {span = HTMLCSS.addElement(span,"a",{href:this.href})}
      span = HTMLCSS.addElement(span,"span",{className: this.type});
      if (HTMLCSS.imgHeightBug) {span.style.display = "inline-block"}
      if (this["class"] != null) {span.className += " "+this["class"]}
      if (this.style) {span.style.cssText = this.style}
      this.spanID = HTMLCSS.GetID(); span.id = (this.id || "MathJax-Span-"+this.spanID);
      span.bbox = {w:0, h:0, d:0, lw:0, lr:0};
      if (this.href) {span.parentNode.bbox = span.bbox}
      return span;
    },
    HTMLspanElement: function () {
      if (!this.spanID) {return null}
      return document.getElementById(this.id || "MathJax-Span-"+this.spanID);
    },

    HTMLhandleVariant: function (span,variant,text) {HTMLCSS.handleVariant(span,variant,text)},

    HTMLhandleSize: function (span) {
      if (!span.scale) {
        span.scale = this.HTMLgetScale();
        if (span.scale !== 1) {span.style.fontSize = HTMLCSS.Percent(span.scale)}
      }
      return span;
    },

    HTMLhandleColor: function (span) {
      var values = this.getValues("mathcolor","color");
      if (this.mathbackground) {values.mathbackground = this.mathbackground}
      if (this.background) {values.background = this.background}
      if (this.style && span.style.backgroundColor) {values.mathbackground = span.style.backgroundColor}
      if (values.color && !this.mathcolor) {values.mathcolor = values.color}
      if (values.background && !this.mathbackground) {values.mathbackground = values.background}
      if (values.mathcolor) {span.style.color = values.mathcolor}
      if (values.mathbackground && values.mathbackground !== MML.COLOR.TRANSPARENT) {
        var dd = 1/HTMLCSS.em, lW = 0, rW = 0;
        if (this.isToken) {lW = span.bbox.lw; rW = span.bbox.rw - span.bbox.w}
        if (span.style.paddingLeft  !== "") {lW += parseFloat(span.style.paddingLeft)*(span.scale||1)}
        if (span.style.paddingRight !== "") {rW -= parseFloat(span.style.paddingRight)*(span.scale||1)}
        var W = Math.max(0,HTMLCSS.getW(span) + (HTMLCSS.PaddingWidthBug ? 0 : rW - lW));
        if (HTMLCSS.msieCharPaddingWidthBug && span.style.paddingLeft !== "")
          {W += parseFloat(span.style.paddingLeft)*(span.scale||1)}
        var H = span.bbox.h + span.bbox.d, D = -span.bbox.d;
        if (W > 0) {W += 2*dd; lW -= dd}; if (H > 0) {H += 2*dd; D -= dd}; rW = -W-lW;
        var frame = HTMLCSS.Element("span",{id:"MathJax-Color-"+this.spanID,
          style:{display:"inline-block", backgroundColor:values.mathbackground,
                 width: HTMLCSS.Em(W), height:HTMLCSS.Em(H), verticalAlign: HTMLCSS.Em(D),
                 marginLeft: HTMLCSS.Em(lW), marginRight: HTMLCSS.Em(rW)}
        });
        if (HTMLCSS.msieInlineBlockAlignBug) {
          frame.style.position = "relative"; frame.style.width = frame.style.height = 0;
          frame.style.verticalAlign = frame.style.marginLeft = frame.style.marginRight = "";
          HTMLCSS.placeBox(HTMLCSS.addElement(frame,"span",{
            style: {display:"inline-block", position:"absolute", overflow:"hidden",
                    width: HTMLCSS.Em(W), height: HTMLCSS.Em(H),
                    background: values.mathbackground}
          }),lW,span.bbox.h+dd);
        } else {
        }
        span.parentNode.insertBefore(frame,span);
      }
    },
    HTMLremoveColor: function () {
      var color = document.getElementById("MathJax-Color-"+this.spanID);
      if (color) {color.parentNode.removeChild(color)}
    },

    HTMLhandleSpace: function (span) {
      if (this.useMMLspacing) {
        if (this.type !== "mo") return;
        var values = this.getValues("scriptlevel","lspace","rspace");
        if (values.scriptlevel <= 0 || this.hasValue("lspace") || this.hasValue("rspace")) {
          values.lspace = Math.max(0,HTMLCSS.length2em(values.lspace));
          values.rspace = Math.max(0,HTMLCSS.length2em(values.rspace));
          var core = this, parent = this.Parent();
          while (parent && parent.isEmbellished() && parent.Core() === core)
            {core = parent; parent = parent.Parent(); span = core.HTMLspanElement()}
          if (values.lspace) {span.style.paddingLeft =  HTMLCSS.Em(values.lspace)}
          if (values.rspace) {span.style.paddingRight = HTMLCSS.Em(values.rspace)}
        }
      } else {
        var space = this.texSpacing();
        if (space !== "") {
          space = HTMLCSS.length2em(space)/(span.scale||1);
          if (span.style.paddingLeft) {space += parseFloat(span.style.paddingLeft)}
          span.style.paddingLeft = HTMLCSS.Em(space);
        }
      }
    },

    HTMLgetScale: function () {
      var scale = 1, values = this.getValues("mathsize","scriptlevel","fontsize","scriptminsize");
      if (this.style) {
        var span = this.HTMLspanElement();
        if (span.style.fontSize != "") {values.fontsize = span.style.fontSize}
      }
      if (values.fontsize && !this.mathsize) {values.mathsize = values.fontsize}
      if (values.scriptlevel !== 0) {
        if (values.scriptlevel > 2) {values.scriptlevel = 2}
        scale = Math.pow(this.Get("scriptsizemultiplier"),values.scriptlevel);
        values.scriptminsize = HTMLCSS.length2em(values.scriptminsize);
        if (scale < values.scriptminsize) {scale = values.scriptminsize}
      }
      scale *= HTMLCSS.length2em(values.mathsize);
      return scale;
    },

    HTMLgetVariant: function () {
      var values = this.getValues("mathvariant","fontfamily","fontweight","fontstyle");
      if (this.style) {
        var span = this.HTMLspanElement();
        if (span.style.fontFamily) {values.fontfamily = span.style.fontFamily}
        if (span.style.fontWeight) {values.fontweight = span.style.fontWeight}
        if (span.style.fontStyle)  {values.fontStyle  = span.style.fontStyle}
      }
      var variant = values.mathvariant; if (this.variantForm) {variant = "-"+HTMLCSS.fontInUse+"-variant"}
      if (values.fontfamily && !this.mathvariant) {
        if (!values.fontweight && values.mathvariant.match(/bold/)) {values.fontweight = "bold"}
        if (!values.fontstyle && values.mathvariant.match(/italic/)) {values.fontstyle = "italic"}
        return {FONTS:[], fonts:[], noRemap:true,
                defaultFont: {family:values.fontfamily, style:values.fontstyle, weight:values.fontweight}};
      }
      if (values.fontweight === "bold") {
        variant = {
          normal:MML.VARIANT.BOLD, italic:MML.VARIANT.BOLDITALIC,
          fraktur:MML.VARIANT.BOLDFRAKTUR, script:MML.VARIANT.BOLDSCRIPT,
          "sans-serif":MML.VARIANT.BOLDSANSSERIF,
          "sans-serif-italic":MML.VARIANT.SANSSERIFBOLDITALIC
        }[variant]||variant;
      } else if (values.fontweight === "normal") {
        variant = {
          bold:MML.VARIANT.normal, "bold-italic":MML.VARIANT.ITALIC,
          "bold-fraktur":MML.VARIANT.FRAKTUR, "bold-script":MML.VARIANT.SCRIPT,
          "bold-sans-serif":MML.VARIANT.SANSSERIF,
          "sans-serif-bold-italic":MML.VARIANT.SANSSERIFITALIC
        }[variant]||variant;
      }
      if (values.fontstyle === "italic") {
        variant = {
          normal:MML.VARIANT.ITALIC, bold:MML.VARIANT.BOLDITALIC,
          "sans-serif":MML.VARIANT.SANSSERIFITALIC,
          "bold-sans-serif":MML.VARIANT.SANSSERIFBOLDITALIC
        }[variant]||variant;
      } else if (values.fontstyle === "normal") {
        variant = {
          italic:MML.VARIANT.NORMAL, "bold-italic":MML.VARIANT.BOLD,
          "sans-serif-italic":MML.VARIANT.SANSSERIF,
          "sans-serif-bold-italic":MML.VARIANT.BOLDSANSSERIF
        }[variant]||variant;
      }
      return HTMLCSS.FONTDATA.VARIANT[variant];
    }
  },{
    HTMLautoload: function () {
      var file = HTMLCSS.autoloadDir+"/"+this.type+".js";
      MathJax.Hub.RestartAfter(AJAX.Require(file));
    },

    HTMLstretchH: function (box,w) {
      this.HTMLremoveColor();
      return this.toHTML(box,w);
    },

    HTMLstretchV: function (box,h,d) {
      this.HTMLremoveColor();
      return this.toHTML(box,h,d);
    }
  });

  MML.chars.Augment({
    toHTML: function (span,variant) {
      this.HTMLhandleVariant(span,variant,this.data.join("").replace(/[\u2061-\u2064]/g,"")); // remove invisibles
    }
  });
  MML.entity.Augment({
    toHTML: function (span,variant) {
      this.HTMLhandleVariant(span,variant,this.toString().replace(/[\u2061-\u2064]/g,"")); // remove invisibles
    }
  });

  MML.mi.Augment({
    toHTML: function (span) {
      span = this.HTMLhandleSize(this.HTMLcreateSpan(span)); span.bbox = null;
      var variant = this.HTMLgetVariant();
      for (var i = 0, m = this.data.length; i < m; i++)
        {if (this.data[i]) {this.data[i].toHTML(span,variant)}}
      if (!span.bbox) {span.bbox = {w:0, h:0, d:0, rw:0, lw:0}}
      if (this.data.join("").length !== 1) {delete span.bbox.skew}
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    }
  });

  MML.mn.Augment({
    toHTML: function (span) {
      span = this.HTMLhandleSize(this.HTMLcreateSpan(span)); span.bbox = null;
      var variant = this.HTMLgetVariant();
      for (var i = 0, m = this.data.length; i < m; i++)
        {if (this.data[i]) {this.data[i].toHTML(span,variant)}}
      if (!span.bbox) {span.bbox = {w:0, h:0, d:0, rw:0, lw:0}}
      if (this.data.join("").length !== 1) {delete span.bbox.skew}
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    }
  });

  MML.mo.Augment({
    toHTML: function (span) {
      span = this.HTMLhandleSize(this.HTMLcreateSpan(span));
      if (this.data.length == 0) {return span} else {span.bbox = null}
      var text = this.data.join("");
      var variant = this.HTMLgetVariant();
      var values = this.getValues("largeop","displaystyle");
      if (values.largeop)
        {variant = HTMLCSS.FONTDATA.VARIANT[values.displaystyle ? "-largeOp" : "-smallOp"]}
      for (var i = 0, m = this.data.length; i < m; i++)
        {if (this.data[i]) {this.data[i].toHTML(span,variant)}}
      if (!span.bbox) {span.bbox = {w:0, h:0, d:0, rw:0, lw:0}}
      if (text.length !== 1) {delete span.bbox.skew}
      if (HTMLCSS.AccentBug && span.bbox.w === 0 && text.length === 1 && span.firstChild) {
        //  Handle combining characters by adding a non-breaking space and removing that width
        span.firstChild.nodeValue += HTMLCSS.NBSP;
        HTMLCSS.createSpace(span,0,0,-span.offsetWidth/HTMLCSS.em);
      }
      if (values.largeop) {
        var p = (span.bbox.h - span.bbox.d)/2 - HTMLCSS.TeX.axis_height*span.scale;
        if (HTMLCSS.safariVerticalAlignBug && span.lastChild.nodeName === "IMG") {
          span.lastChild.style.verticalAlign =
            HTMLCSS.Em(parseFloat(span.lastChild.style.verticalAlign||0)/HTMLCSS.em-p/span.scale);
        } else if (HTMLCSS.konquerorVerticalAlignBug && span.lastChild.nodeName === "IMG") {
          span.style.position = "relative";
          span.lastChild.style.position="relative";
          span.lastChild.style.top = HTMLCSS.Em(p/span.scale);
        } else {
          span.style.verticalAlign = HTMLCSS.Em(-p/span.scale);
        }
        span.bbox.h -= p; span.bbox.d += p;
        if (span.bbox.rw > span.bbox.w) {
          span.bbox.ic = span.bbox.rw-span.bbox.w;
          HTMLCSS.createBlank(span,span.bbox.ic);
          span.bbox.w = span.bbox.rw;
        }
      }
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLcanStretch: function (direction) {
      if (!this.Get("stretchy")) {return false}
      var c = this.data.join("");
      if (c.length > 1) {return false}
      c = HTMLCSS.FONTDATA.DELIMITERS[c.charCodeAt(0)];
      return (c && c.dir == direction.substr(0,1));
    },
    HTMLstretchV: function (box,h,d) {
      this.HTMLremoveColor();
      var values = this.getValues("symmetric","maxsize","minsize");
      var span = this.HTMLspanElement(), H, W = span.bbox.w;
      var axis = HTMLCSS.TeX.axis_height, scale = span.scale;
      if (values.symmetric) {H = 2*Math.max(h-axis,d+axis)} else {H = h + d}
      values.maxsize = HTMLCSS.length2em(values.maxsize,span.bbox.h+span.bbox.d);
      values.minsize = HTMLCSS.length2em(values.minsize,span.bbox.h+span.bbox.d);
      H = Math.max(values.minsize,Math.min(values.maxsize,H));
      span = this.HTMLcreateSpan(box); // clear contents and attributes
      HTMLCSS.createDelimiter(span,this.data.join("").charCodeAt(0),H,scale);
      if (values.symmetric) {H = (span.bbox.h + span.bbox.d)/2 + axis}
        else {H = (span.bbox.h + span.bbox.d) * h/(h + d)}
      HTMLCSS.positionDelimiter(span,H);
      this.HTMLhandleSpace(span); // add in lspace/rspace, if any
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLstretchH: function (box,W) {
      this.HTMLremoveColor();
      var values = this.getValues("maxsize","minsize","mathvariant","fontweight");
      if (values.fontweight === "bold" && !this.mathvariant) {values.mathvariant = MML.VARIANT.BOLD}
      var span = this.HTMLspanElement(), scale = span.scale;
      values.maxsize = HTMLCSS.length2em(values.maxsize,span.bbox.w);
      values.minsize = HTMLCSS.length2em(values.minsize,span.bbox.w);
      W = Math.max(values.minsize,Math.min(values.maxsize,W));
      span = this.HTMLcreateSpan(box); // clear contents and attributes
      HTMLCSS.createDelimiter(span,this.data.join("").charCodeAt(0),W,scale,values.mathvariant);
      this.HTMLhandleSpace(span); // add in lspace/rspace, if any
      this.HTMLhandleColor(span);
      return span;
    }
  });

  MML.mtext.Augment({
    toHTML: function (span) {
      span = this.HTMLhandleSize(this.HTMLcreateSpan(span)); span.bbox = null;
      if (this.Parent().type === "merror") {
        //  Avoid setting the font style for error text
        HTMLCSS.addText(span,this.data.join(""));
        var HD = HTMLCSS.getHD(span), W = HTMLCSS.getW(span);
        span.bbox = {h: HD.h, d: HD.d, w: W, lw: 0, rw: W};
      } else {
        var variant = this.HTMLgetVariant();
        for (var i = 0, m = this.data.length; i < m; i++)
          {if (this.data[i]) {this.data[i].toHTML(span,variant)}}
        if (!span.bbox) {span.bbox = {w:0, h:0, d:0, rw:0, lw:0}}
        if (this.data.join("").length !== 1) {delete span.bbox.skew}
      }
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    }
  });

  MML.ms.Augment({toHTML: MML.mbase.HTMLautoload});

  MML.mglyph.Augment({toHTML: MML.mbase.HTMLautoload});

  MML.mspace.Augment({
    toHTML: function (span) {
      span = this.HTMLhandleSize(this.HTMLcreateSpan(span));
      var values = this.getValues("height","depth","width");
      values.mathbackground = this.mathbackground;
      if (this.background && !this.mathbackground) {values.mathbackground = this.background}
      var h = HTMLCSS.length2em(values.height), d = HTMLCSS.length2em(values.depth),
          w = HTMLCSS.length2em(values.width);
     HTMLCSS.createSpace(span,h,d,w,values.mathbackground);
     return span;
    }
  });

  MML.mphantom.Augment({
    toHTML: function (span,HW,D) {
      span = this.HTMLcreateSpan(span);
      var box = HTMLCSS.Measured(this.data[0].toHTML(span),span);
      if (D != null) {HTMLCSS.Remeasured(this.data[0].HTMLstretchV(span,HW,D),span)}
      else if (HW != null) {HTMLCSS.Remeasured(this.data[0].HTMLstretchH(span,HW),span)}
      span.bbox = {w: box.bbox.w, h: box.bbox.h, d: box.bbox.d, lw: 0, rw: 0};
      for (var i = 0, m = span.childNodes.length; i < m; i++)
        {span.childNodes[i].style.visibility = "hidden"}
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLstretchH: MML.mbase.HTMLstretchH,
    HTMLstretchV: MML.mbase.HTMLstretchV
  });

  MML.mpadded.Augment({
    toHTML: function (span,HW,D) {
      span = this.HTMLcreateSpan(span);
      var stack = HTMLCSS.createStack(span,true);
      var box = HTMLCSS.createBox(stack);
      HTMLCSS.Measured(this.data[0].toHTML(box),box);
      if (D != null) {HTMLCSS.Remeasured(this.data[0].HTMLstretchV(box,HW,D),box)}
      else if (HW != null) {HTMLCSS.Remeasured(this.data[0].HTMLstretchH(box,HW),box)}
      var values = this.getValues("height","depth","width","lspace","voffset"), x = 0, y = 0, v;
      if (values.lspace)  {x = this.HTMLlength2em(box,values.lspace)}
      if (values.voffset) {y = this.HTMLlength2em(box,values.voffset)}
      HTMLCSS.placeBox(box,x,y);
      span.bbox = {
        h: box.bbox.h, d: box.bbox.d, w: box.bbox.w,
        lw: Math.min(0,box.bbox.lw+x), rw: Math.max(box.bbox.w,box.bbox.rw+x),
        H: Math.max((box.bbox.H == null ? -HTMLCSS.BIGDIMEN : box.bbox.H),box.bbox.h+y),
        D: Math.max((box.bbox.D == null ? -HTMLCSS.BIGDIMEN : box.bbox.D),box.bbox.d-y)
      };
      if (values.height !== "") {span.bbox.h = this.HTMLlength2em(box,values.height,"h",0)}
      if (values.depth  !== "") {span.bbox.d = this.HTMLlength2em(box,values.depth,"d",0)}
      if (values.width  !== "") {span.bbox.w = this.HTMLlength2em(box,values.width,"w",0)}
      if (span.bbox.H <= span.bbox.h) {delete span.bbox.H}
      if (span.bbox.D <= span.bbox.d) {delete span.bbox.D}
      HTMLCSS.setStackWidth(stack,span.bbox.w);
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLlength2em: function (span,length,d,m) {
      if (m == null) {m = -HTMLCSS.BIGDIMEN}
      var match = String(length).match(/width|height|depth/);
      var size = (match ? span.bbox[match[0].charAt(0)] : (d ? span.bbox[d] : null));
      var v = HTMLCSS.length2em(length,size);
      if (d && String(length).match(/^\s*[-+]/))
        {return Math.max(m,span.bbox[d]+v)} else {return v}
    },
    HTMLstretchH: MML.mbase.HTMLstretchH,
    HTMLstretchV: MML.mbase.HTMLstretchV
  });

  MML.mrow.Augment({
    HTMLstretchH: function (box,w) {
      this.HTMLremoveColor();
      var span = this.HTMLspanElement();
      this.data[this.core].HTMLstretchH(span,w);
      this.HTMLcomputeBBox(span,true);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLstretchV: function (box,h,d) {
      this.HTMLremoveColor();
      var span = this.HTMLspanElement();
      this.data[this.core].HTMLstretchV(span,h,d);
      this.HTMLcomputeBBox(span,true);
      this.HTMLhandleColor(span);
      return span;
    }
  });

  MML.mstyle.Augment({
    toHTML: function (span) {
      if (this.data.length) {
        span = this.data[0].toHTML(span);
        this.spanID = this.data[0].spanID;
        this.HTMLhandleSpace(span);
        this.HTMLhandleColor(span);
      }
      return span;
    },
    HTMLspanElement: function () {
      return (this.data.length ? this.data[0].HTMLspanElement() : null);
    },
    HTMLstretchH: function (box,w) {
      return (this.data.length ? this.data[0].HTMLstretchH(box,w) : box);
    },
    HTMLstretchV: function (box,h,d) {
      return (this.data.length ? this.data[0].HTMLstretchV(box,h,d) : box);
    }
  });

  MML.mfrac.Augment({
    toHTML: function (span) {
      span = this.HTMLcreateSpan(span);
      var frac = HTMLCSS.createStack(span);
      var num = HTMLCSS.createBox(frac), den = HTMLCSS.createBox(frac);
      HTMLCSS.Measured(this.data[0].toHTML(num),num);
      HTMLCSS.Measured(this.data[1].toHTML(den),den);
      var values = this.getValues("displaystyle","linethickness","numalign","denomalign","bevelled");
      var scale = this.HTMLgetScale(), isDisplay = values.displaystyle;
      var a = HTMLCSS.TeX.axis_height * scale;
      if (values.bevelled) {
        var delta = (isDisplay ? .4 : .15);
        var H = Math.max(num.bbox.h+num.bbox.d,den.bbox.h+den.bbox.d)+2*delta;
        var bevel = HTMLCSS.createBox(frac);
        HTMLCSS.createDelimiter(bevel,0x2F,H);
        HTMLCSS.placeBox(num,0,(num.bbox.d-num.bbox.h)/2+a+delta);
        HTMLCSS.placeBox(bevel,num.bbox.w-delta/2,(bevel.bbox.d-bevel.bbox.h)/2+a);
        HTMLCSS.placeBox(den,num.bbox.w+bevel.bbox.w-delta,(den.bbox.d-den.bbox.h)/2+a-delta);
      } else {
        var W = Math.max(num.bbox.w,den.bbox.w);
        var t = HTMLCSS.thickness2em(values.linethickness), p,q, u,v;
        var mt = HTMLCSS.TeX.min_rule_thickness/this.em;
        if (isDisplay) {u = HTMLCSS.TeX.num1; v = HTMLCSS.TeX.denom1}
          else {u = (t === 0 ? HTMLCSS.TeX.num3 : HTMLCSS.TeX.num2); v = HTMLCSS.TeX.denom2}
        u *= scale; v *= scale;
        if (t === 0) {// \atop
          p = Math.max((isDisplay ? 7 : 3) * HTMLCSS.TeX.rule_thickness, 2*mt); // force to at least 2 px
          q = (u - num.bbox.d) - (den.bbox.h - v);
          if (q < p) {u += (p - q)/2; v += (p - q)/2}
        } else {// \over
          p = Math.max((isDisplay ? 2 : 0) * mt + t, t/2 + 1.5*mt);  // force to be at least 1.5px
          q = (u - num.bbox.d) - (a + t/2); if (q < p) {u += p - q}
          q = (a - t/2) - (den.bbox.h - v); if (q < p) {v += p - q}
          var rule = HTMLCSS.createBox(frac);
          HTMLCSS.createRule(rule,t,0,W+2*t);
          HTMLCSS.placeBox(rule,0,a-t/2);
        }
        HTMLCSS.alignBox(num,values.numalign,u);
        HTMLCSS.alignBox(den,values.denomalign,-v);
      }
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLcanStretch: function (direction) {return false},
    HTMLhandleSpace: function (span) {
      if (!this.texWithDelims) {
        var space = (this.useMMLspacing ? 0 : HTMLCSS.length2em(this.texSpacing()||0)) + .12;
        span.style.paddingLeft = HTMLCSS.Em(space);
        span.style.paddingRight = ".12em";
      }
    }
  });

  MML.msqrt.Augment({
    toHTML: function (span) {
      span = this.HTMLcreateSpan(span);
      var sqrt = HTMLCSS.createStack(span);
      var base = HTMLCSS.createBox(sqrt),
          rule = HTMLCSS.createBox(sqrt),
          surd = HTMLCSS.createBox(sqrt);
      HTMLCSS.Measured(this.data[0].toHTML(base),base);
      var scale = this.HTMLgetScale();
      var t = HTMLCSS.TeX.rule_thickness * scale, p,q, H, W;
      if (this.Get("displaystyle")) {p = HTMLCSS.TeX.x_height * scale} else {p = t}
      q = Math.max(t + p/4,2*HTMLCSS.TeX.min_rule_thickness/this.em); // force to be at least 2px
      H = base.bbox.h + base.bbox.d + q + t;
      W = base.bbox.w;
      HTMLCSS.createDelimiter(surd,0x221A,H,scale); HTMLCSS.Measured(surd);
      var x = 0;
      if (surd.isMultiChar || (HTMLCSS.AdjustSurd && HTMLCSS.imgFonts)) {surd.bbox.w *= .95}
      if (surd.bbox.h + surd.bbox.d > H) {q += ((surd.bbox.h+surd.bbox.d) - (H-t))/2}
      var ruleC = HTMLCSS.FONTDATA.DELIMITERS[HTMLCSS.FONTDATA.RULECHAR];
      if (!ruleC || W < ruleC.HW[0][0]*scale || scale < .75) {
        HTMLCSS.createRule(rule,t,0,W);
      } else {
        HTMLCSS.createDelimiter(rule,HTMLCSS.FONTDATA.RULECHAR,W,scale);
      }
      H = base.bbox.h + q + t;
      x = this.HTMLaddRoot(sqrt,surd,x,surd.bbox.h+surd.bbox.d-H,scale);
      HTMLCSS.placeBox(surd,x,H-surd.bbox.h);
      HTMLCSS.placeBox(rule,x+surd.bbox.w,H-rule.bbox.h+HTMLCSS.rfuzz);
      HTMLCSS.placeBox(base,x+surd.bbox.w,0);
      span.bbox.h += t;
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLaddRoot: function (sqrt,surd,x,d,scale) {return x}
  });

  MML.mroot.Augment({
    toHTML: MML.msqrt.prototype.toHTML,
    HTMLaddRoot: function (sqrt,surd,x,d,scale) {
      var box = HTMLCSS.createBox(sqrt);
      var root = this.data[1].toHTML(box);
      root.style.paddingRight = root.style.paddingLeft = ""; // remove extra padding, if any
      HTMLCSS.Measured(root,box);
      var h = this.HTMLrootHeight(surd.bbox.h+surd.bbox.d,scale,box)-d;
      var w = Math.min(box.bbox.w,box.bbox.rw); // remove extra right-hand padding, if any
      x = Math.max(w,surd.offset);
      HTMLCSS.placeBox(box,x-w,h);
      return x - surd.offset;
    },
    HTMLrootHeight: function (d,scale,root) {
      return .45*(d-.9*scale)+.6*scale + Math.max(0,root.bbox.d-.075);
    }
  });

  MML.mfenced.Augment({
    toHTML: function (span) {
      span = this.HTMLcreateSpan(span);
      if (this.data.open) {this.data.open.toHTML(span)}
      if (this.data[0]) {this.data[0].toHTML(span)}
      for (var i = 1, m = this.data.length; i < m; i++) {
        if (this.data[i]) {
          if (this.data["sep"+i]) {this.data["sep"+i].toHTML(span)}
          this.data[i].toHTML(span);
        }
      }
      if (this.data.close) {this.data.close.toHTML(span)}
      var stretchy = this.HTMLcomputeBBox(span);
      var h = span.bbox.h, d = span.bbox.d;
      for (i = 0, m = stretchy.length; i < m; i++) {stretchy[i].HTMLstretchV(span,h,d)}
      if (stretchy.length) {this.HTMLcomputeBBox(span,true)}
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLcomputeBBox: function (span,full) {
      var i, m, child, bbox, BBOX, hasDimens = 0, width, stretchy = [];
      BBOX = span.bbox = {};
      this.HTMLcheckStretchy(this.data.open,BBOX,stretchy,full);
      this.HTMLcheckStretchy(this.data[0],BBOX,stretchy,full);
      for (i = 1, m = this.data.length; i < m; i++) {
        if (this.data[i]) {
          this.HTMLcheckStretchy(this.data["sep"+i],BBOX,stretchy,full);
          this.HTMLcheckStretchy(this.data[i],BBOX,stretchy,full);
        }
      }
      this.HTMLcheckStretchy(this.data.close,BBOX,stretchy,full);
      this.HTMLcleanBBox(BBOX);
      return stretchy;
    },
    HTMLcheckStretchy: function (core,BBOX,stretchy,full) {
      if (core) {
        if (!full && core.HTMLcanStretch("Vertical"))
          {stretchy.push(core); core = (core.CoreMO()||core)}
        this.HTMLcombineBBoxes(core,BBOX);
      }
    }
  });

  MML.menclose.Augment({toHTML: MML.mbase.HTMLautoload});

  MML.semantics.Augment({
    toHTML: function (span) {
      if (this.data.length) {
        span = this.data[0].toHTML(span);
        this.spanID = this.data[0].spanID;
        this.HTMLhandleSpace(span);
      }
      return span;
    },
    HTMLspanElement: function () {
      return (this.data.length ? this.data[0].HTMLspanElement() : null);
    },
    HTMLstretchH: function (box,w) {
      return (this.data.length ? this.data[0].HTMLstretchH(box,w) : box);
    },
    HTMLstretchV: function (box,h,d) {
      return (this.data.length ? this.data[0].HTMLstretchV(box,h,d) : box);
    }
  });

  MML.munderover.Augment({
    toHTML: function (span,HW,D) {
      var values = this.getValues("displaystyle","accent","accentunder","align");
      if (!values.displaystyle && this.data[this.base].Get("movablelimits"))
        {return MML.msubsup.prototype.toHTML.call(this,span)}
      span = this.HTMLcreateSpan(span); var scale = this.HTMLgetScale();
      var stack = HTMLCSS.createStack(span);
      var boxes = [], stretch = [], box, i, m, W = -HTMLCSS.BIGDIMEN, WW = W;
      for (i = 0, m = this.data.length; i < m; i++) {
        if (this.data[i]) {
          box = boxes[i] = HTMLCSS.createBox(stack);
          HTMLCSS.Measured(this.data[i].toHTML(box),box);
          if (i == this.base) {
            if (D != null) {HTMLCSS.Remeasured(this.data[this.base].HTMLstretchV(box,HW,D),box)}
            else if (HW != null) {HTMLCSS.Remeasured(this.data[this.base].HTMLstretchH(box,HW),box)}
            stretch[i] = (D == null && HW != null ? false :
                         this.data[i].HTMLcanStretch("Horizontal"));
          } else {
            stretch[i] = this.data[i].HTMLcanStretch("Horizontal");
          }
          if (box.bbox.w > WW) {WW = box.bbox.w}
          if (!stretch[i] && WW > W) {W = WW}
        }
      }
      if (W == -HTMLCSS.BIGDIMEN) {W = WW}
      if (D == null && HW != null) {W = WW = HW}
      var t = HTMLCSS.TeX.rule_thickness, factor = HTMLCSS.FONTDATA.TeX_factor;
      var base = boxes[this.base], delta = (base.bbox.ic || 0);
      var x, y, z1, z2, z3, dw, k;
      for (i = 0, m = this.data.length; i < m; i++) {
        if (this.data[i]) {
          box = boxes[i];
          if (stretch[i]) {box.bbox = this.data[i].HTMLstretchH(box,W).bbox}
          z3 = HTMLCSS.TeX.big_op_spacing5 * scale;
          var accent = (i != this.base && values[this.ACCENTS[i]]);
          if (accent && box.bbox.w <= 1/HTMLCSS.em+.0001) { // images can get the width off by 1px
            box.bbox.w = box.bbox.rw - box.bbox.lw; box.bbox.noclip = true;
	    if (box.bbox.lw)
	      {box.insertBefore(HTMLCSS.createSpace(box.parentNode,0,0,-box.bbox.lw),box.firstChild)}
            HTMLCSS.createBlank(box,0,0,box.bbox.rw+.1);
          }
          dw = {left:0, center:(W-box.bbox.w)/2, right:W-box.bbox.w}[values.align];
          x = dw; y = 0;
          if (i == this.over) {
            if (accent) {
              k = Math.max(t * scale * factor,2.5/this.em); z3 = 0;
              if (base.bbox.skew) {x += base.bbox.skew}
            } else {
              z1 = HTMLCSS.TeX.big_op_spacing1 * scale * factor;
              z2 = HTMLCSS.TeX.big_op_spacing3 * scale * factor;
              k = Math.max(z1,z2-Math.max(0,box.bbox.d));
            }
            k = Math.max(k,1.5/this.em); // force to be at least 1.5px
            x += delta; y = base.bbox.h + box.bbox.d + k;
            box.bbox.h += z3;
          } else if (i == this.under) {
            if (accent) {
              k = 3*t * scale * factor; z3 = 0;
            } else {
              z1 = HTMLCSS.TeX.big_op_spacing2 * scale * factor;
              z2 = HTMLCSS.TeX.big_op_spacing4 * scale * factor;
              k = Math.max(z1,z2-box.bbox.h);
            }
            k = Math.max(k,1.5/this.em); // force to be at least 1.5px
            x -= delta; y = -(base.bbox.d + box.bbox.h + k);
            box.bbox.d += z3;
          }
          HTMLCSS.placeBox(box,x,y);
        }
      }
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLstretchH: MML.mbase.HTMLstretchH,
    HTMLstretchV: MML.mbase.HTMLstretchV
  });

  MML.msubsup.Augment({
    toHTML: function (span,HW,D) {
      span = this.HTMLcreateSpan(span); var scale = this.HTMLgetScale();
      var stack = HTMLCSS.createStack(span), script, box, values;
      var base = HTMLCSS.createBox(stack);
      HTMLCSS.Measured(this.data[this.base].toHTML(base),base);
      if (D != null) {HTMLCSS.Remeasured(this.data[this.base].HTMLstretchV(base,HW,D),base)}
      else if (HW != null) {HTMLCSS.Remeasured(this.data[this.base].HTMLstretchH(base,HW),base)}
      HTMLCSS.placeBox(base,0,0);
      var sscale = (this.data[this.sup] || this.data[this.sub]).HTMLgetScale();
      var x_height = HTMLCSS.TeX.x_height * scale,
          s = HTMLCSS.TeX.scriptspace * scale * .75;  // FIXME: .75 can be removed when IC is right?
      var sup, sub;
      if (this.data[this.sup]) {
        sup = HTMLCSS.createBox(stack);
        HTMLCSS.Measured(this.data[this.sup].toHTML(sup),sup);
        sup.bbox.w += s; sup.bbox.rw = Math.max(sup.bbox.w,sup.bbox.rw);
      }
      if (this.data[this.sub]) {
        sub = HTMLCSS.createBox(stack);
        HTMLCSS.Measured(this.data[this.sub].toHTML(sub),sub);
        sub.bbox.w += s; sub.bbox.rw = Math.max(sub.bbox.w,sub.bbox.rw);
      }
      var q = HTMLCSS.TeX.sup_drop * sscale, r = HTMLCSS.TeX.sub_drop * sscale;
      var u = base.bbox.h - q, v = base.bbox.d + r, delta = 0, p;
      if (base.bbox.ic) {delta = base.bbox.ic}
      if (this.data[this.base].type === "mi" || this.data[this.base].type === "mo") {
        if (this.data[this.base].data.join("").length === 1 && base.bbox.scale === 1 &&
            !this.data[this.base].Get("largeop")) {u = v = 0}
      }
      var min = this.getValues("subscriptshift","superscriptshift");
      min.subscriptshift   = (min.subscriptshift === ""   ? 0 : HTMLCSS.length2em(min.subscriptshift));
      min.superscriptshift = (min.superscriptshift === "" ? 0 : HTMLCSS.length2em(min.superscriptshift));
      if (!sup) {
        v = Math.max(v,HTMLCSS.TeX.sub1*scale,sub.bbox.h-(4/5)*x_height,min.subscriptshift);
        HTMLCSS.placeBox(sub,base.bbox.w+s-delta,-v,sub.bbox);
      } else {
        if (!sub) {
          var values = this.getValues("displaystyle","texprimestyle");
          p = HTMLCSS.TeX[(values.displaystyle ? "sup1" : (values.texprimestyle ? "sup3" : "sup2"))];
          u = Math.max(u,p*scale,sup.bbox.d+(1/4)*x_height,min.superscriptshift);
          HTMLCSS.placeBox(sup,base.bbox.w+s,u,sup.bbox);
        } else {
          v = Math.max(v,HTMLCSS.TeX.sub2*scale);
          var t = HTMLCSS.TeX.rule_thickness * scale;
          if ((u - sup.bbox.d) - (sub.bbox.h - v) < 3*t) {
            v = 3*t - u + sup.bbox.d + sub.bbox.h;
            q = (4/5)*x_height - (u - sup.bbox.d) + .05*scale*0;
            if (q > 0) {u += q; v -= q}
          }
          HTMLCSS.placeBox(sup,base.bbox.w+s,Math.max(u,min.superscriptshift));
          HTMLCSS.placeBox(sub,base.bbox.w+s-delta,-Math.max(v,min.subscriptshift));
        }
      }
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLstretchH: MML.mbase.HTMLstretchH,
    HTMLstretchV: MML.mbase.HTMLstretchV
  });

  MML.mtable.Augment({
    toHTML: function (span) {
      span = this.HTMLcreateSpan(span);
      if (this.data.length === 0) {return span}
      var values = this.getValues("columnalign","columnspacing","rowspacing",
                                  "align","useHeight","width","side","minlabelspacing");
      var WIDTH = (values.width === "auto" ? null : values.width);
      var COLWIDTH = (WIDTH ? "100%" : null);
      var stack = HTMLCSS.createStack(span,false,WIDTH);
      var scale = this.HTMLgetScale(); var LABEL = -1;
      //
      //  Create cells and measure columns and rows
      //
      var H = [], D = [], W = [], A = [], i, j, J = 0, m, M, s, row, C = [];
      var LHD = HTMLCSS.FONTDATA.baselineskip * scale * values.useHeight,
          LH = HTMLCSS.FONTDATA.lineH * scale, LD = HTMLCSS.FONTDATA.lineD * scale;
      for (i = 0, m = this.data.length; i < m; i++) {
        row = this.data[i]; s = (row.type === "mlabeledtr" ? LABEL : 0);
        A[i] = []; H[i] = 0; D[i] = 0;
        for (j = s, M = row.data.length + s; j < M; j++) {
          if (W[j] == null) {
            W[j] = -HTMLCSS.BIGDIMEN; if (j > J) {J =j}
            // FIXME:  these widths should come from columnwidths attribute
            C[j] = HTMLCSS.createStack(HTMLCSS.createBox(stack,COLWIDTH),false,COLWIDTH);
          }
          A[i][j] = HTMLCSS.createBox(C[j]);
          HTMLCSS.Measured(row.data[j-s].toHTML(A[i][j]),A[i][j]);
          if (A[i][j].bbox.h > H[i]) {H[i] = A[i][j].bbox.h}
          if (A[i][j].bbox.d > D[i]) {D[i] = A[i][j].bbox.d}
          if (A[i][j].bbox.w > W[j]) {W[j] = A[i][j].bbox.w}
        }
      }
      H[0] = Math.max(H[0],LH); D[A.length-1] = Math.max(D[A.length-1],LD);
      //
      //  Determine spacing and alignment
      //
      var CSPACE = values.columnspacing.split(/ /),
          RSPACE = values.rowspacing.split(/ /),
          CALIGN = values.columnalign.split(/ /);
      for (i = 0, m = CSPACE.length; i < m; i++) {CSPACE[i] = HTMLCSS.length2em(CSPACE[i])}
      for (i = 0, m = RSPACE.length; i < m; i++) {RSPACE[i] = HTMLCSS.length2em(RSPACE[i])}
      while (CSPACE.length <= J) {CSPACE.push(CSPACE[CSPACE.length-1])}
      while (CALIGN.length <= J) {CALIGN.push(CALIGN[CALIGN.length-1])}
      while (RSPACE.length <= A.length) {RSPACE.push(RSPACE[RSPACE.length-1])}
      if (C[LABEL]) {
        CALIGN[LABEL] = (values.side.substr(0,1) === "l" ? "left" : "right");
        CSPACE[LABEL] = -W[LABEL];
      }
      //
      //  Determine array total height
      //
      var HD = H[0] + D[A.length-1];
      for (i = 0, m = A.length-1; i < m; i++) {HD += Math.max(LHD,D[i]+H[i+1]+RSPACE[i])}
      //
      //  Compute alignment
      //
      var Y = HD/2 + HTMLCSS.TeX.axis_height*scale - H[0];
      //
      //  Lay out array by columns
      //
      var x = 0, y = Y; s = (C[LABEL] ? LABEL : 0);
      for (j = s; j <= J; j++) {
        for (i = 0, m = A.length; i < m; i++) {
          s = (this.data[i].type === "mlabeledtr" ? LABEL : 0);
          if (A[i][j])
            {HTMLCSS.alignBox(A[i][j],(this.data[i].data[j-s].columnalign||CALIGN[j]),y)}
          if (i < A.length-1) {y -= Math.max(LHD,D[i]+H[i+1]+ RSPACE[i])}
        }
        HTMLCSS.placeBox(C[j].parentNode,x,0);
        x += W[j] + CSPACE[j]; y = Y;
      }
      //
      //  Place the labels, if any
      //
      if (C[LABEL]) {
        var eqn = HTMLCSS.createStack(span,false,"100%");
        var align = HTMLCSS.config.styles[".MathJax_Display"]["text-align"];
        HTMLCSS.addBox(eqn,stack); HTMLCSS.alignBox(stack,align,0);
        HTMLCSS.addBox(eqn,C[LABEL]); HTMLCSS.alignBox(C[LABEL],CALIGN[LABEL],0);
        C[LABEL].style.marginRight = C[LABEL].style.marginLeft =
          HTMLCSS.Em(HTMLCSS.length2em(values.minlabelspacing));
      }
      //
      //  Finish the table
      //
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLhandleSpace: function (span) {
      span.style.paddingLeft = span.style.paddingRight = ".1667em";
    }
  });

  MML.math.Augment({
    toHTML: function (span,node) {
      var alttext = this.Get("alttext"); if (alttext) {node.setAttribute("aria-label",alttext)}
      var nobr = HTMLCSS.addElement(span,"nobr",{style:{visibility:"hidden"}});
      span = this.HTMLcreateSpan(nobr);
      var stack = HTMLCSS.createStack(span);
      var box = HTMLCSS.createBox(stack);
      if (HTMLCSS.msieColorBug) {
        this.data[0].background = this.background;
        this.data[0].mathbackground = this.mathbackground;
        delete this.background; delete this.mathbackground;
      }
      var math = HTMLCSS.Measured(this.data[0].toHTML(box),box);
      HTMLCSS.placeBox(box,0,0);
      if (math.bbox.width != null) {
        stack.style.width = math.bbox.width;
        box.style.width = "100%";
      }
      this.HTMLhandleColor(span);
      HTMLCSS.createRule(span,math.bbox.h,math.bbox.d,0);
      nobr.style.visibility = "";
      return span;
    }
  });

  MML.TeXAtom.Augment({
    toHTML: function (span) {
      span = this.HTMLcreateSpan(span);
      if (this.texClass === MML.TEXCLASS.VCENTER) {
        var stack = HTMLCSS.createStack(span);
        var box = HTMLCSS.createBox(stack);
        HTMLCSS.Measured(this.data[0].toHTML(box),box);
        // FIXME: should the axis height be scaled?
        HTMLCSS.placeBox(box,0,HTMLCSS.TeX.axis_height-(box.bbox.h+box.bbox.d)/2+box.bbox.d);
      } else {
        span.bbox = this.data[0].toHTML(span).bbox;
      }
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    }
  });

  //
  //  Handle browser-specific setup
  //
  MathJax.Hub.Browser.Select({
    MSIE: function (browser) {
      var isIE7 = browser.versionAtLeast("7.0");
      var isIE8 = browser.versionAtLeast("8.0") && document.documentMode > 7;
      var quirks = (document.compatMode === "BackCompat");
      // MSIE can't measure widths properly without this
      HTMLCSS.config.styles[".MathJax span"] = {position: "relative"};
      // FIXME:  work out tests for these?
      HTMLCSS.Augment({
        getMarginScale: HTMLCSS.getMSIEmarginScale,
        PaddingWidthBug: true,
        msieAccentBug: true,
        msieColorBug: true,
        msieMarginWidthBug: true,
        msiePaddingWidthBug: true,
        msieCharPaddingWidthBug: (isIE8 && !quirks),
        msieBorderWidthBug: quirks,
        msieInlineBlockAlignBug: (!isIE8 || quirks),
        msieVerticalAlignBug: (isIE8 && !quirks),
        msiePlaceBoxBug: (isIE8 && !quirks),
        msieClipRectBug: !isIE8,
        msieNegativeSpaceBug: quirks,
        negativeSkipBug: true,
        msieIE6: !isIE7,
        msieItalicWidthBug: true,
        FontFaceBug: true,
        allowWebFonts: "eot"
      });
    },

    Firefox: function (browser) {
      var webFonts = false;
      if (browser.versionAtLeast("3.5")) {
        var root = String(document.location).replace(/[^\/]*$/,"");
        if (document.location.protocol !== "file:" ||
            (MathJax.Hub.config.root+"/").substr(0,root.length) === root) {webFonts = "otf"}
      }
      HTMLCSS.Augment({
        ffVerticalAlignBug: true,
        AccentBug: true,
        allowWebFonts: webFonts
      });
    },

    Safari: function (browser) {
      var v3p0 = browser.versionAtLeast("3.0");
      var v3p1 = browser.versionAtLeast("3.1");
      browser.isMobile = (navigator.appVersion.match(/Mobile/i) != null);
      HTMLCSS.Augment({
        rfuzz: .05,
        AccentBug: true,
        AdjustSurd: true,
        safariNegativeSpaceBug: true,
        safariVerticalAlignBug: !v3p1,
        safariTextNodeBug: !v3p0,
        safariWebFontSerif: ["serif"],
        allowWebFonts: (v3p1 && !browser.isMobile ? (browser.isPC ? "svg" : "otf") : false)
      });
    },

    Chrome: function (browser) {
      HTMLCSS.Augment({
        rfuzz: .05,
        AccentBug: true,
        AdjustSurd: true,
        allowWebFonts: "svg",
        safariNegativeSpaceBug: true,
        safariWebFontSerif: [""]
      });
    },

    Opera: function (browser) {
      HTMLCSS.config.styles[".MathJax .merror"]["vertical-align"] = null;
      HTMLCSS.Augment({
        operaHeightBug: true,
        operaVerticalAlignBug: true,
        negativeSkipBug: true,
        FontFaceBug: true,
        PaddingWidthBug: true,
        allowWebFonts: (browser.versionAtLeast("10.0") ? "otf" : false)
      });
    },

    Konqueror: function (browser) {
      HTMLCSS.Augment({
        konquerorVerticalAlignBug: true
      });
    }
  });
  
  HTMLCSS.loadComplete("jax.js");

})(MathJax.ElementJax.mml, MathJax.Ajax, MathJax.OutputJax["HTML-CSS"]);
