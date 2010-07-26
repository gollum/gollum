/*************************************************************
 *
 *  MathJax/extensions/TeX/autobold.js
 *  
 *  Adds \boldsymbol around mathematics that appears in a section
 *  of an HTML page that is in bold.
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
  var TEX = MathJax.InputJax.TeX;
  var oldPrefilter = TEX.prefilterMath;
  
  TEX.prefilterMath = function (math,displaystyle,script) {
    var span = script.parentNode.insertBefore(document.createElement("span"),script);
    span.visibility = "hidden";
    span.style.fontFamily = "Times, serif";
    span.appendChild(document.createTextNode("ABCXYZabcxyz"));
    var W = span.offsetWidth;
    span.style.fontWeight = "bold";
    if (span.offsetWidth == W) {math = "\\bf {"+math+"}"}
    span.parentNode.removeChild(span);
    return oldPrefilter.call(TEX,math,displaystyle,script);
  };
  
  MathJax.Hub.Startup.signal.Post("TeX autobold Ready");

});

MathJax.Ajax.loadComplete("[MathJax]/extensions/TeX/autobold.js");
