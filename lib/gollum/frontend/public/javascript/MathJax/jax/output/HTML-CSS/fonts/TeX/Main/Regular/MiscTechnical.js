/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/Main/Regular/MiscTechnical.js
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
    0x2308: [751,250,444,174,422],     // LEFT CEILING
    0x2309: [751,250,444,21,269],      // RIGHT CEILING
    0x230A: [750,251,444,174,422],     // LEFT FLOOR
    0x230B: [751,251,444,20,269],      // RIGHT FLOOR
    0x2322: [388,-122,1000,55,944],    // stix-small down curve
    0x2323: [378,-134,1000,55,944],    // stix-small up curve
    0x23B0: [743,241,512,56,456],      // UPPER LEFT OR LOWER RIGHT CURLY BRACKET SECTION
    0x23B1: [743,242,512,56,457]       // UPPER RIGHT OR LOWER LEFT CURLY BRACKET SECTION
  }
);

MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].fontDir + "/Main/Regular/MiscTechnical.js");
