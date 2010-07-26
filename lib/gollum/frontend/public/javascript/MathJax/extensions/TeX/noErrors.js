/*************************************************************
 *
 *  MathJax/extensions/TeX/noErrors.js
 *  
 *  Prevents the TeX error messages from being displayed and shows the
 *  original TeX code instead.  You can configure whether the dollar signs
 *  are shown or not for in-line math, and whether to put all the TeX on
 *  one line or use multiple-lines.
 *  
 *  To configure this extension, use
 *  
 *      MathJax.Hub.Configure({
 *        TeX: {
 *          noErrors: {
 *            inlineDelimiters: ["",""],   // or ["$","$"] or ["\\(","\\)"]
 *            multiLine: true,             // false for TeX on all one line
 *            style: {
 *              "font-family": "serif",
 *              "font-size":   "80%",
 *              "color":       "black",
 *              "border":      "1px solid" 
 *                // add any additional CSS styles that you want
 *                //  (be sure there is no extra comma at the end of the last item)
 *            }
 *          }
 *        }
 *      });
 *  
 *  Display-style math is always shown in multi-line format, and without
 *  delimiters, as it will already be set off in its own centered
 *  paragraph, like standard display mathematics.
 *  
 *  The default settings place the invalid TeX in a multi-line box with a
 *  black border.  If you want it to look as though the TeX is just part of
 *  the paragraph, use
 *
 *      MathJax.Hub.Configure({
 *        TeX: {
 *          noErrors: {
 *            inlineDelimiters: ["$","$"],   // or ["",""] or ["\\(","\\)"]
 *            multiLine: false,
 *            style: {
 *              "font-size": "normal",
 *              "border": ""
 *            }
 *          }
 *        }
 *      });
 *  
 *  You may also wish to set the font family, as the default is "serif"
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

(function () {
  
  //
  //  The configuration defaults, augmented by the user settings
  //  
  MathJax.Extension["TeX/noErrors"] = {
    config: MathJax.Hub.Insert({
      multiLine: true,
      inlineDelimiters: ["",""],     // or use ["$","$"] or ["\\(","\\)"]
      style: {
        "font-family": "serif",
        "font-size":   "80%",
        "color":       "black",
        "border":      "1px solid"
      }
    },((MathJax.Hub.config.TeX||{}).noErrors||{}))
  };
  
  var CONFIG = MathJax.Extension["TeX/noErrors"].config;
  var NBSP = String.fromCharCode(0xA0);
  
  MathJax.Hub.Config({
    TeX: {
      Augment: {
        //
        //  Make error messages be the original TeX code
        //  Mark them as errors and multi-line or not, and for
        //  multi-line TeX, make spaces non-breakable (to get formatting right)
        //
        formatError: function (err,math,displaystyle,script) {
          var delim = CONFIG.inlineDelimiters;
          var multiLine = (displaystyle || CONFIG.multiLine);
          if (!displaystyle) {math = delim[0] + math + delim[1]}
          if (multiLine) {math = math.replace(/ /g,NBSP)} else {math = math.replace(/\n/g," ")}
          return MathJax.ElementJax.mml.merror(math).With({isError:true, multiLine: multiLine});
        }
      }
    },
    
    "HTML-CSS": {
      styles: {
        ".MathJax .merror": MathJax.Hub.Insert({
          "font-style":       null,
          "background-color": null,
          "vertical-align":   (MathJax.Hub.Browser.isMSIE && CONFIG.multiLine ? "-2px" : "")
        },CONFIG.style)
      }
    }
  });

})();
  
MathJax.Hub.Register.StartupHook("HTML-CSS Jax Ready",function () {
  var MML = MathJax.ElementJax.mml;
  var HTMLCSS = MathJax.OutputJax["HTML-CSS"];
  var CONFIG = MathJax.Extension["TeX/noErrors"].config;
  
  //
  // Override math toHTML routine so that error messages
  //   don't have the clipping and other unneeded overhead
  //
  var math_toHTML = MML.math.prototype.toHTML;
  MML.math.Augment({
    toHTML: function (span) {
      if (this.data[0] && this.data[0].data[0] && this.data[0].data[0].isError) {
        return this.data[0].data[0].toHTML(span);
      }
      return math_toHTML.call(this,span);
    }
  });
  
  //
  //  Override merror toHTML routine so that it puts out the
  //    TeX code in an inlin-block with line breaks as in the original
  //
  MML.merror.Augment({
    toHTML: function (span) {
      span = this.HTMLcreateSpan(span);
      if (this.multiLine) {span.style.display = "inline-block"}
      var text = this.data[0].data.join("").split(/\n/);
      for (var i = 0, m = text.length; i < m; i++) {
        HTMLCSS.addText(span,text[i]);
        if (i !== m-1) {HTMLCSS.addElement(span,"br")}
      }
      var HD = HTMLCSS.getHD(span.parentNode), W = HTMLCSS.getW(span.parentNode);
      if (m > 1) {
        var H = (HD.h + HD.d)/2, x = HTMLCSS.TeX.x_height/2;
        var scale = HTMLCSS.config.styles[".MathJax .merror"]["font-size"];
        if (scale && scale.match(/%/)) {x *= parseInt(scale)/100}
        span.parentNode.style.verticalAlign = HTMLCSS.Em(HD.d+(x-H));
        HD.h = x + H; HD.d = H - x;
      }
      span.bbox = {h: HD.h, d: HD.d, w: W, lw: 0, rw: W};
      return span;
    }
  });

  MathJax.Hub.Startup.signal.Post("TeX noErrors Ready");
});

MathJax.Ajax.loadComplete("[MathJax]/extensions/TeX/noErrors.js");
