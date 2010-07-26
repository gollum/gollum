/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/Main/Regular/MiscMathSymbolsA.js
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
 *
 */

MathJax.Hub.Insert(
  MathJax.OutputJax['HTML-CSS'].FONTDATA.FONTS['MathJax_Main'],
  {
    0x27E8: [750,250,389,110,333],     // MATHEMATICAL LEFT ANGLE BRACKET
    0x27E9: [750,250,389,55,278],      // MATHEMATICAL RIGHT ANGLE BRACKET
    0x27EE: [743,242,400,100,344],     // MATHEMATICAL LEFT FLATTENED PARENTHESIS
    0x27EF: [743,241,400,56,301]       // MATHEMATICAL RIGHT FLATTENED PARENTHESIS
  }
);

MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].fontDir + "/Main/Regular/MiscMathSymbolsA.js");
