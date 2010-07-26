/*************************************************************
 *
 *  MathJax/extensions/mml2jax.js
 *  
 *  Implements the MathML to Jax preprocessor that locates <math> nodes
 *  within the text of a document and replaces them with SCRIPT tags
 *  for processing by MathJax.
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
 *  limitations under the License.
 */

MathJax.Extension.mml2jax = {
  config: {
    element: null           // The ID of the element to be processed
                            //   (defaults to full document)
  },
  MMLnamespace: "http://www.w3.org/1998/Math/MathML",
  
  PreProcess: function (element) {
    if (!this.configured) {
      MathJax.Hub.Insert(this.config,(MathJax.Hub.config.mml2jax||{}));
      this.configured = true;
    }
    if (typeof(element) === "string") {element = document.getElementById(element)}
    if (!element) {element = this.config.element || document.body}
    var math = element.getElementsByTagName("math");
    if (math.length === 0 && element.getElementsByTagNameNS)
      {math = element.getElementsByTagNameNS(this.MMLnamespace,"math")}
    if (this.msieMathTagBug) {
      for (var i = math.length-1; i >= 0; i--) {
        if (math[i].nodeName === "MATH") {this.msieProcessMath(math[i])}
                                    else {this.ProcessMath(math[i])}
      }
    } else {
      for (var i = math.length-1; i >= 0; i--) {this.ProcessMath(math[i])}
    }
  },
  
  ProcessMath: function (math) {
    var parent = math.parentNode;
    var script = document.createElement("script");
    script.type = "math/mml";
    parent.insertBefore(script,math);
    if (this.msieScriptBug) {
      var html = math.outerHTML; var prefix;
      html = html.replace(/<\?import .*?>/,"").replace(/<(\/?)m:/g,"<$1").replace(/&nbsp;/g,"&#xA0;");
      script.text = html;
      parent.removeChild(math);
    } else {
      script.appendChild(math);
    }
  },
  
  msieProcessMath: function (math) {
    var parent = math.parentNode;
    var script = document.createElement("script");
    script.type = "math/mml";
    parent.insertBefore(script,math);
    var mml = "";
    while (math && math.nodeName !== "/MATH") {
      if (math.nodeName === "#text" || math.nodeName === "#comment")
        {mml += math.nodeValue} else {mml += this.toLowerCase(math.outerHTML)}
      var node = math;
      math = math.nextSibling;
      node.parentNode.removeChild(node);
    }
    script.text = mml + "</math>";
  },
  toLowerCase: function (string) {
    var parts = string.split(/"/);
    for (var i = 0, m = parts.length; i < m; i += 2) {parts[i] = parts[i].toLowerCase()}
    return parts.join('"');
  }
  
};

MathJax.Hub.Browser.Select({
  MSIE: function (browser) {
    MathJax.Hub.Insert(MathJax.Extension.mml2jax,{
      msieScriptBug: true,
      msieMathTagBug: true
    })
  }
});
  
MathJax.Hub.Register.PreProcessor(["PreProcess",MathJax.Extension.mml2jax]);
MathJax.Ajax.loadComplete("[MathJax]/extensions/mml2jax.js");
