/*************************************************************
 *
 *  MathJax/jax/output/NativeMML/config.js
 *  
 *  Initializes the NativeMML OutputJax (the main definition is in
 *  MathJax/jax/input/NativeMML/jax.js, which is loaded when needed).
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

MathJax.OutputJax.NativeMML = MathJax.OutputJax({
  name: "NativeMML",
  version: 1.0,
  directory: MathJax.OutputJax.directory + "/NativeMML",
  extensionDir: MathJax.OutputJax.extensionDir + "/NativeMML",
  
  config: {
    styles: {
      "DIV.MathJax_MathML": {
        "text-align": "center",
        margin: ".75em 0px"
      }
    }
  }
});
MathJax.OutputJax.NativeMML.Register("jax/mml");

if (MathJax.Hub.Browser.isMSIE) {
  //
  //  Insert code needed to use MathPlayer for MathML output
  //
  document.write('<?xml:namespace prefix="mjx" ns="http://www.w3.org/1998/Math/MathML"?>');
  document.write('<object id="mathplayer" classid="clsid:32F66A20-7614-11D4-BD11-00104BD3F987"></object>');
  document.write('<?import namespace="mjx" implementation="#mathplayer"?>');
}

MathJax.OutputJax.NativeMML.loadComplete("config.js");
