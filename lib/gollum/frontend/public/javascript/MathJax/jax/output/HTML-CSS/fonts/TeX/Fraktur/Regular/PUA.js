/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/Fraktur/Regular/PUA.js
 *
 *  Copyright (c) 2009-2010 Design Science, Inc.
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
  MathJax.OutputJax['HTML-CSS'].FONTDATA.FONTS['MathJax_Fraktur'],
  {
    0xE300: [683,32,497,75,430],       // ??
    0xE301: [616,30,498,35,432],       // ??
    0xE302: [680,215,333,29,339],      // ??
    0xE303: [679,224,329,28,318],      // ??
    0xE304: [471,214,503,52,449],      // ??
    0xE305: [686,20,333,26,315],       // ??
    0xE306: [577,22,334,29,347],       // ??
    0xE307: [475,22,501,10,514]        // ??
  }
);

MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].fontDir + "/Fraktur/Regular/PUA.js");
