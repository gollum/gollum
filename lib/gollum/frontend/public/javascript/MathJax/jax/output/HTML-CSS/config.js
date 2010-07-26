/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/config.js
 *  
 *  Initializes the HTML-CCS OutputJax  (the main definition is in
 *  MathJax/jax/input/HTML-CSS/jax.js, which is loaded when needed).
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

MathJax.OutputJax["HTML-CSS"] = MathJax.OutputJax({
  name: "HTML-CSS",
  version: 1.0,
  directory: MathJax.OutputJax.directory + "/HTML-CSS",
  extensionDir: MathJax.OutputJax.extensionDir + "/HTML-CSS",
  autoloadDir: MathJax.OutputJax.directory + "/HTML-CSS/autoload",
  fontDir: MathJax.OutputJax.directory + "/HTML-CSS/fonts", // font name added later
  webfontDir: MathJax.OutputJax.fontDir + "/HTML-CSS",      // font name added later
  
  config: {
    scale: 100,
    availableFonts: ["STIX","TeX"],
    preferredFont: "TeX",
    webFont: "TeX",
    imageFont: "TeX",
    
    styles: {
      ".MathJax_Display": {
        "text-align": "center",
        margin:       "1em 0em"
      },
      
      ".MathJax .merror": {
        "background-color": "#FFFF88",
        color:   "#CC0000",
        border:  "1px solid #CC0000",
        padding: "1px 3px",
        "font-family": "serif",
        "font-style": "italic",
        "font-size":  "90%"
      },
      
      ".MathJax_Preview": {color: "#888888"}
    }
    
  }
});
MathJax.OutputJax["HTML-CSS"].Register("jax/mml");

(function (HUB,HTMLCSS) {
  var CONFIG;
  CONFIG = HUB.Insert({

    //
    //  The minimum versions that HTML-CSS supports
    //
    minBrowserVersion: {
      Firefox: 3.0,
      Opera: 9.52,
      MSIE: 6.0,
      Chrome: 0.3,
      Safari: 2.0,
      Konqueror: 4.0
    },
    
    //
    //  For unsupported browsers, put back these delimiters for the preview
    //
    inlineMathDelimiters:  ['$','$'],    // or ["",""] or ["\\(","\\)"]
    displayMathDelimiters: ['$$','$$'],  // or ["",""] or ["\\[","\\]"]
    //
    //  For displayed math, insert <BR> for \n?
    //
    multilineDisplay: true,

    //
    //  The function to call to display the math for unsupported browsers
    //
    minBrowserTranslate: function (script) {
      var MJ = HUB.getJaxFor(script), text = ["[Math]"];
      var span = document.createElement("span",{className: "MathJax_Preview"});
      var display = MJ.root.Get("displaystyle")
      if (MJ.inputJax.name === "TeX") {
        if (display) {
          var delim = CONFIG.displayMathDelimiters;
          text = [delim[0]+MJ.originalText+delim[1]];
          if (CONFIG.multilineDisplay) text = text[0].split(/\n/);
        } else {
          var delim = CONFIG.inlineMathDelimiters;
          text = [delim[0]+MJ.originalText.replace(/^\s+/,"").replace(/\s+$/,"")+delim[1]];
        }
      }
      for (var i = 0, m = text.length; i < m; i++) {
        span.appendChild(document.createTextNode(text[i]));
        if (i < m-1) {span.appendChild(document.createElement("br"))}
      }
      script.parentNode.insertBefore(span,script);
    }

  },(HUB.config["HTML-CSS"]||{}));

  if (HUB.Browser.version !== "0.0" &&
     !HUB.Browser.versionAtLeast(CONFIG.minBrowserVersion[HUB.Browser]||0.0)) {
       HTMLCSS.Translate = CONFIG.minBrowserTranslate;
       MathJax.Hub.Config({showProcessingMessages: false});
       MathJax.Message.Set("Your browser does not support MathJax",null,4000);
       HUB.Startup.signal.Post("MathJax not supported");
  }

})(MathJax.Hub,MathJax.OutputJax["HTML-CSS"]);


MathJax.OutputJax["HTML-CSS"].loadComplete("config.js");
