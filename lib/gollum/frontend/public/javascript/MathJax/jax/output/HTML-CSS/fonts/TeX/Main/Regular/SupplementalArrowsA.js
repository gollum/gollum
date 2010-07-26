/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/Main/Regular/SupplementalArrowsA.js
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
    0x27F5: [511,12,1609,54,1525],     // LONG LEFTWARDS ARROW
    0x27F6: [512,11,1638,83,1554],     // LONG RIGHTWARDS ARROW
    0x27F7: [512,12,1859,54,1804],     // LONG LEFT RIGHT ARROW
    0x27F8: [525,24,1609,55,1553],     // LONG LEFTWARDS DOUBLE ARROW
    0x27F9: [525,25,1638,55,1582],     // LONG RIGHTWARDS DOUBLE ARROW
    0x27FA: [525,24,1858,55,1802],     // LONG LEFT RIGHT DOUBLE ARROW
    0x27FC: [512,11,1638,54,1554]      // LONG RIGHTWARDS ARROW FROM BAR
  }
);

MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].fontDir + "/Main/Regular/SupplementalArrowsA.js");
