/*************************************************************
 *
 *  MathJax/extensions/jsMath2jax.js
 *  
 *  Implements a jsMath to Jax preprocessor that locates jsMath-style
 *  <SPAN CLASS="math">...</SPAN> and <DIV CLASS="math">...</DIV> tags
 *  and replaces them with SCRIPT tags for processing by MathJax.
 *  (Note: use the tex2jax preprocessor to convert TeX delimiters or 
 *  custom delimiters to MathJax SCRIPT tags.  This preprocessor is
 *  only for the SPAN and DIV form of jsMath delimiters).
 *  
 *  To use this preprocessor, include "jsMath2jax.js" in the extensions
 *  array in your config/MathJax.js file, or the MathJax.Hub.Config() call
 *  in your HTML document.
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

MathJax.Extension.jsMath2jax = {
  config: {
    previewTeX: true,   // Set to false to prevent preview strings from being inserted
  },
  
  PreProcess: function (element) {
    if (!this.configured) {
      MathJax.Hub.Insert(this.config,(MathJax.Hub.config.jsMath2jax||{}));
      this.previewClass = MathJax.Hub.config.preRemoveClass;
      this.configured = true;
    }
    if (typeof(element) === "string") {element = document.getElementById(element)}
    if (!element) {element = this.config.element || document.body}
    var span = element.getElementsByTagName("span"), i, m;
    for (i = 0, m = span.length; i < m; i++)
      {if (String(span[i].className).match(/\bmath\b/)) {this.ConvertMath(span[i],"")}}
    var div = element.getElementsByTagName("div");
    for (i = 0, m = div.length; i < m; i++)
      {if (String(div[i].className).match(/\bmath\b/)) {this.ConvertMath(div[i],"; mode=display")}}
  },
  
  ConvertMath: function (node,mode) {
    var parent = node.parentNode,
        script = this.CreateMathTag(mode,node.innerHTML);
    if (node.nextSibling) {parent.insertBefore(script,node.nextSibling)}
      else {parent.appendChild(script)}
    if (this.config.previewTeX) {
      node.className = String(node.className).replace(/\bmath\b/,this.previewClass);
    } else {
      parent.removeChild(node);
    }
  },
  
  CreateMathTag: function (mode,tex) {
    var script = document.createElement("script");
    script.type = "math/tex" + mode;
    if (MathJax.Hub.Browser.isMSIE) {script.text = tex}
      else {script.appendChild(document.createTextNode(tex))}
    return script;
  }
  
};

MathJax.Hub.Register.PreProcessor(["PreProcess",MathJax.Extension.jsMath2jax]);
MathJax.Ajax.loadComplete("[MathJax]/extensions/jsMath2jax.js");
